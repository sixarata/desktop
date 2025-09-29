#!/usr/bin/env bash
set -euo pipefail

SRC_BASE="src-tauri/target/release/bundle"
NSIS_DIR="$SRC_BASE/nsis"
MSI_DIR="$SRC_BASE/msi"
DST_DIR="release/win64/Sixarata"

rm -rf "$DST_DIR"
mkdir -p "$DST_DIR"

rename_main_exe() {
  # Find the largest EXE and rename it to Sixarata.exe
  main_exe="$(find "$DST_DIR" -type f -name '*.exe' -printf '%s %p\n' \
    | sort -nr | head -n1 | awk '{print $2}')"
  if [ -n "${main_exe:-}" ]; then
    mv "$main_exe" "$DST_DIR/Sixarata.exe"
    echo "Renamed main exe to Sixarata.exe"
  else
    echo "::warning::No .exe found to rename."
  fi
}

# 1) Prefer MSI (msiextract)
msi="$(find "$MSI_DIR" -maxdepth 1 -type f -name '*.msi' -print -quit 2>/dev/null || true)"
if [ -n "${msi:-}" ]; then
  echo "Extracting MSI: $msi"
  tmp="$(mktemp -d)"
  msiextract -C "$tmp" "$msi"
  echo "MSI extracted to: $tmp"
  # Copy everything — usually includes app root + resources
  cp -R "$tmp"/* "$DST_DIR"/
  rm -rf "$tmp"
  rename_main_exe
  ls -la "$DST_DIR"
  exit 0
fi

# 2) Fallback: NSIS .exe (extract with 7z)
nsis="$(find "$NSIS_DIR" -maxdepth 1 -type f -name '*.exe' -print -quit 2>/dev/null || true)"
if [ -n "${nsis:-}" ]; then
  echo "Extracting NSIS: $nsis"
  tmp="$(mktemp -d)"
  7z x -o"$tmp" "$nsis" >/dev/null
  cp -R "$tmp"/* "$DST_DIR"/
  rm -rf "$tmp"
  rename_main_exe
  ls -la "$DST_DIR"
  exit 0
fi

echo "::group::Windows bundle tree"
find "$SRC_BASE" -maxdepth 4 -print || true
echo "::endgroup::"
echo "::error::No Windows bundles (.msi/.exe) found to gather."
exit 1