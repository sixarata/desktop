#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="src-tauri/target/release/bundle/macos"
DST_DIR="release/macos/Sixarata"

rm -rf "$DST_DIR"
mkdir -p "$DST_DIR"

# 1) Prefer a real .app bundle (from the macOS build artifact)
app_path="$(find "$SRC_DIR" -maxdepth 2 -type d -name '*.app' -print -quit || true)"
if [ -n "${app_path:-}" ]; then
  echo "Using app bundle: $app_path"
  cp -R "$app_path" "$DST_DIR/"
  ls -la "$DST_DIR"
  exit 0
fi

# 2) Fallback: extract the .app out of a .dmg with 7z (we're on Ubuntu)
dmg_path="$(find "$SRC_DIR" -maxdepth 2 -type f -name '*.dmg' -print -quit || true)"
if [ -n "${dmg_path:-}" ]; then
  echo "Found DMG: $dmg_path — extracting .app with 7z"
  tmpdir="$(mktemp -d)"
  7z x -o"$tmpdir" "$dmg_path" >/dev/null
  inner_app="$(find "$tmpdir" -type d -name '*.app' -print -quit || true)"
  if [ -n "${inner_app:-}" ]; then
    cp -R "$inner_app" "$DST_DIR/"
    rm -rf "$tmpdir"
    ls -la "$DST_DIR"
    exit 0
  fi
  echo "::group::DMG extraction contents"
  find "$tmpdir" -maxdepth 3 -print
  echo "::endgroup::"
  rm -rf "$tmpdir"
  echo "::error::No .app found inside DMG after extraction."
  exit 1
fi

echo "::group::macOS bundle tree"; find "$SRC_DIR" -maxdepth 3 -print || true; echo "::endgroup::"
echo "::error::No .app or .dmg found under $SRC_DIR"
exit 1