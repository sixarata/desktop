#!/usr/bin/env bash
set -euo pipefail

dst="steam/../release/osx/Sixarata"
rm -rf "$dst" && mkdir -p "$dst"

app_src="src-tauri/target/release/bundle/macos"
app_bundle=$(ls "$app_src"/*.app 2>/dev/null | head -n1 || true)

if [[ -z "${app_bundle}" ]]; then
  echo "No .app found in $app_src" >&2
  exit 1
fi

cp -R "$app_bundle" "$dst/"
echo "macOS gathered into $dst/"