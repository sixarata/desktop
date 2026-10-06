#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ASSETS="$ROOT/steam/assets"
SOURCE="$ASSETS/source"
OUTPUT="$ASSETS/generated"
KEY_ART="$SOURCE/key-art.png"
LOGO="$SOURCE/logo.svg"
APP_ICON="$ROOT/src-tauri/icons/app-512.png"

command -v magick >/dev/null 2>&1 || {
	echo "ImageMagick is required to build Steam artwork." >&2
	exit 1
}

test -f "$KEY_ART"
test -f "$LOGO"
test -f "$APP_ICON"

rm -rf "$OUTPUT"
mkdir -p "$OUTPUT/store" "$OUTPUT/library" "$OUTPUT/community"

logo_for() {
	local width="$1"
	local output="$2"
	magick -background none "$LOGO" -resize "${width}x" "$output"
}

art_for() {
	local width="$1"
	local height="$2"
	local output="$3"
	magick "$KEY_ART" \
		-filter point \
		-resize "${width}x${height}^" \
		-gravity center \
		-extent "${width}x${height}" \
		"$output"
}

capsule_for() {
	local width="$1"
	local height="$2"
	local logo_width="$3"
	local output="$4"
	local background logo
	background="$(mktemp -t sixarata-background).png"
	logo="$(mktemp -t sixarata-logo).png"
	art_for "$width" "$height" "$background"
	logo_for "$logo_width" "$logo"
	magick "$background" \
		"$logo" \
		-gravity north \
		-geometry "+0+$(( height / 10 ))" \
		-composite \
		-quality 92 \
		"$output"
	rm -f "$background" "$logo"
}

capsule_for 920 430 680 "$OUTPUT/store/header.jpg"
capsule_for 462 174 350 "$OUTPUT/store/small.jpg"
capsule_for 1232 706 900 "$OUTPUT/store/main.jpg"
capsule_for 748 896 620 "$OUTPUT/store/vertical.jpg"
capsule_for 600 900 510 "$OUTPUT/library/capsule.jpg"
capsule_for 920 430 680 "$OUTPUT/library/header.jpg"

art_for 3840 1240 "$OUTPUT/library/hero.png"
logo_for 1280 "$OUTPUT/library/logo.png"

magick "$APP_ICON" -strip -colorspace sRGB -resize 184x184 -background black -alpha remove -quality 92 "$OUTPUT/community/app-icon.jpg"
magick "$APP_ICON" -strip -colorspace sRGB -resize 256x256 "$OUTPUT/community/shortcut-icon.png"

while read -r path width height; do
	actual="$(magick identify -format '%wx%h' "$path")"
	expected="${width}x${height}"
	if [ "$actual" != "$expected" ]; then
		echo "Expected $path to be $expected, got $actual" >&2
		exit 1
	fi
done <<EOF
$OUTPUT/store/header.jpg 920 430
$OUTPUT/store/small.jpg 462 174
$OUTPUT/store/main.jpg 1232 706
$OUTPUT/store/vertical.jpg 748 896
$OUTPUT/library/capsule.jpg 600 900
$OUTPUT/library/hero.png 3840 1240
$OUTPUT/library/header.jpg 920 430
$OUTPUT/community/app-icon.jpg 184 184
$OUTPUT/community/shortcut-icon.png 256 256
EOF

echo "Steam artwork generated in $OUTPUT"
