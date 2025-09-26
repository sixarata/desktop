#!/usr/bin/env bash
set -euo pipefail

dst="steam/../release/linux/Sixarata"
rm -rf "$dst" && mkdir -p "$dst"

# Prefer AppImage (simple for Steam)
appimage_dir="src-tauri/target/release/bundle/appimage"
appimage=$(ls "$appimage_dir"/*.AppImage 2>/dev/null | head -n1 || true)

if [[ -n "${appimage}" ]]; then
  cp "$appimage" "$dst/Sixarata.AppImage"
else
  # Fallback: raw folder from deb/rpm payloads if available
  echo "No AppImage found; consider enabling AppImage target or copy raw ELF folder."
  exit 1
fi

echo "Linux gathered into $dst/"