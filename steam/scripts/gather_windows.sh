#!/usr/bin/env bash
set -euo pipefail

SRC_BASE="src-tauri/target/release/bundle"
DST_DIR="release/win64/Sixarata"

rm -rf "$DST_DIR"
mkdir -p "$DST_DIR"

log_tree() {
  echo "::group::Windows bundle tree"
  find "$SRC_BASE" -maxdepth 4 -print || true
  echo "::endgroup::"
}

rename_main_exe() {
  # pick the largest .exe as the entrypoint
  local main_exe
  main_exe="$(find "$DST_DIR" -type f -name '*.exe' -printf '%s %p\n' 2>/dev/null | sort -nr | head -n1 | awk '{print $2}')"
  if [ -n "${main_exe:-}" ]; then
    mv "$main_exe" "$DST_DIR/Sixarata.exe"
    echo "Renamed entrypoint to: $DST_DIR/Sixarata.exe"
  else
    echo "::warning::No .exe found to rename in $DST_DIR"
  fi
}

# 1) Prefer MSI anywhere under bundle/
msi="$(find "$SRC_BASE" -type f -name '*.msi' -print -quit 2>/dev/null || true)"
if [ -n "${msi:-}" ]; then
  echo "Extracting MSI: $msi"
  tmp="$(mktemp -d)"
  msiextract -C "$tmp" "$msi" >/dev/null 2>&1 || true
  if [ -z "$(ls -A "$tmp" 2>/dev/null)" ]; then
    log_tree
    echo "::error::msiextract produced no files."
    exit 1
  fi
  cp -R "$tmp"/* "$DST_DIR"/
  rm -rf "$tmp"
  rename_main_exe
  ls -la "$DST_DIR"
  exit 0
fi

# 2) Next, NSIS installer EXE (commonly contains 'setup' in name)
nsis="$(find "$SRC_BASE" -type f -iname '*setup*.exe' -print -quit 2>/dev/null || true)"
if [ -z "${nsis:-}" ]; then
  # fallback to any .exe (we'll try to extract; if it's portable, extraction yields little)
  nsis="$(find "$SRC_BASE" -type f -name '*.exe' \
           ! -name 'build_script_build-*.exe' ! -name 'build-script-build.exe' \
           -print -quit 2>/dev/null || true)"
fi

if [ -n "${nsis:-}" ]; then
  echo "Processing EXE: $nsis"
  tmp="$(mktemp -d)"
  # Try extracting as NSIS installer first
  if 7z x -o"$tmp" "$nsis" >/dev/null 2>&1; then
    if [ -n "$(ls -A "$tmp" 2>/dev/null)" ]; then
      echo "7z extracted NSIS payload; copying to depot."
      cp -R "$tmp"/* "$DST_DIR"/
      rm -rf "$tmp"
      rename_main_exe
      ls -la "$DST_DIR"
      exit 0
    fi
  fi
  rm -rf "$tmp"

  # If extraction produced nothing, treat as a **portable** EXE: copy its folder
  exe_dir="$(dirname "$nsis")"
  echo "Treating as portable EXE; copying its folder: $exe_dir"
  cp -R "$exe_dir"/* "$DST_DIR"/
  rename_main_exe
  ls -la "$DST_DIR"
  exit 0
fi

# 3) Nothing usable found — print tree and fail
log_tree
echo "::error::No Windows bundles (.msi/.exe) found to gather."
exit 1