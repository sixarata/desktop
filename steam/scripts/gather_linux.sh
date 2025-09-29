#!/usr/bin/env bash
set -euo pipefail

SRC_BASE="src-tauri/target/release/bundle"
DST_DIR="release/linux/Sixarata"

rm -rf "$DST_DIR"
mkdir -p "$DST_DIR"

# 1) Prefer AppImage anywhere under bundle/
appimage="$(find "$SRC_BASE" -type f -name '*.AppImage' -print -quit 2>/dev/null || true)"
if [ -n "${appimage:-}" ]; then
  echo "Using AppImage: $appimage"
  cp "$appimage" "$DST_DIR/Sixarata.AppImage"
  chmod +x "$DST_DIR/Sixarata.AppImage"
  ls -la "$DST_DIR"
  exit 0
fi

# 2) Fallback: .deb → extract and create a launcher
deb="$(find "$SRC_BASE" -type f -name '*.deb' -print -quit 2>/dev/null || true)"
if [ -n "${deb:-}" ]; then
  echo "Extracting DEB: $deb"
  tmp="$(mktemp -d)"
  dpkg-deb -x "$deb" "$tmp"

  # Heuristics: prefer usr/bin/*; else largest ELF under extracted tree
  candidate="$(find "$tmp/usr/bin" -maxdepth 1 -type f -executable -print -quit 2>/dev/null || true)"
  if [ -z "${candidate:-}" ]; then
    candidate="$(find "$tmp" -type f -executable -print0 2>/dev/null \
      | xargs -0 file --mime-type 2>/dev/null \
      | awk -F: '$2 ~ /application\/x-executable/ {print $1}' \
      | while read -r f; do printf "%s %s\n" "$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")" "$f"; done \
      | sort -nr | head -n1 | awk '{print $2}')"
  fi

  if [ -z "${candidate:-}" ]; then
    echo "::group::DEB extraction tree"; find "$tmp" -maxdepth 4 -print; echo "::endgroup::"
    echo "::error::No runnable binary found in DEB payload."
    exit 1
  fi

  echo "Selected binary: $candidate"
  # Copy full extracted payload and add a launcher script
  cp -R "$tmp"/* "$DST_DIR"/
  cat > "$DST_DIR/Sixarata.sh" <<'EOS'
#!/usr/bin/env bash
HERE="$(cd "$(dirname "$0")" && pwd)"
# Try usr/bin first, else search for the largest ELF and exec it
if [ -x "$HERE/usr/bin/Sixarata" ]; then
  exec "$HERE/usr/bin/Sixarata" "$@"
else
  target="$(find "$HERE" -type f -executable -print0 | xargs -0 file --mime-type \
    | awk -F: '$2 ~ /application\/x-executable/ {print $1}' \
    | while read -r f; do printf "%s %s\n" "$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")" "$f"; done \
    | sort -nr | head -n1 | awk '{print $2}')"
  exec "$target" "$@"
fi
EOS
  chmod +x "$DST_DIR/Sixarata.sh"
  ls -la "$DST_DIR"
  echo "::warning::No AppImage found; using DEB contents. Set Steam Linux launch to: Sixarata/Sixarata.sh"
  exit 0
fi

# 3) Fallback: .rpm → extract and create a launcher
rpm="$(find "$SRC_BASE" -type f -name '*.rpm' -print -quit 2>/dev/null || true)"
if [ -n "${rpm:-}" ]; then
  echo "Extracting RPM: $rpm"
  tmp="$(mktemp -d)"
  (cd "$tmp" && rpm2cpio "$rpm" | cpio -idmv >/dev/null 2>&1 || true)

  candidate="$(find "$tmp/usr/bin" -maxdepth 1 -type f -executable -print -quit 2>/dev/null || true)"
  if [ -z "${candidate:-}" ]; then
    candidate="$(find "$tmp" -type f -executable -print0 2>/dev/null \
      | xargs -0 file --mime-type 2>/dev/null \
      | awk -F: '$2 ~ /application\/x-executable/ {print $1}' \
      | while read -r f; do printf "%s %s\n" "$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")" "$f"; done \
      | sort -nr | head -n1 | awk '{print $2}')"
  fi

  if [ -z "${candidate:-}" ]; then
    echo "::group::RPM extraction tree"; find "$tmp" -maxdepth 4 -print; echo "::endgroup::"
    echo "::error::No runnable binary found in RPM payload."
    exit 1
  fi

  echo "Selected binary: $candidate"
  cp -R "$tmp"/* "$DST_DIR"/
  cat > "$DST_DIR/Sixarata.sh" <<'EOS'
#!/usr/bin/env bash
HERE="$(cd "$(dirname "$0")" && pwd)"
if [ -x "$HERE/usr/bin/Sixarata" ]; then
  exec "$HERE/usr/bin/Sixarata" "$@"
else
  target="$(find "$HERE" -type f -executable -print0 | xargs -0 file --mime-type \
    | awk -F: '$2 ~ /application\/x-executable/ {print $1}' \
    | while read -r f; do printf "%s %s\n" "$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f")" "$f"; done \
    | sort -nr | head -n1 | awk '{print $2}')"
  exec "$target" "$@"
fi
EOS
  chmod +x "$DST_DIR/Sixarata.sh"
  ls -la "$DST_DIR"
  echo "::warning::No AppImage found; using RPM contents. Set Steam Linux launch to: Sixarata/Sixarata.sh"
  exit 0
fi

echo "::group::Linux bundle tree"; find "$SRC_BASE" -maxdepth 3 -print || true; echo "::endgroup::"
echo "::error::No AppImage/DEB/RPM found to gather."
exit 1