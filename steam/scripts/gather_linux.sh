#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="src-tauri/target/release/bundle"
DST_DIR="release/linux/Sixarata"

rm -rf "$DST_DIR"
mkdir -p "$DST_DIR"

# Prefer AppImage
appimage="$(find "$SRC_DIR/appimage" -maxdepth 1 -type f -name '*.AppImage' -print -quit 2>/dev/null || true)"
if [ -n "${appimage:-}" ]; then
  echo "Using AppImage: $appimage"
  cp "$appimage" "$DST_DIR/Sixarata.AppImage"
  chmod +x "$DST_DIR/Sixarata.AppImage"
  ls -la "$DST_DIR"
  exit 0
fi

# Optionally, you could add .deb/.rpm extraction here; for now, fail fast & loud
echo "::group::Linux bundle tree"
find "$SRC_DIR" -maxdepth 3 -print || true
echo "::endgroup::"
echo "::error::No AppImage found. Enable the AppImage target or add a .deb/.rpm extraction path."
exit 1