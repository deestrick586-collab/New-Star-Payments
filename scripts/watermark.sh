#!/usr/bin/env bash
set -euo pipefail

IN_DIR="assets/input"
OUT_DIR="assets/output"
WM="watermark.svg"

mkdir -p "$OUT_DIR"

# Requires ImageMagick with rsvg support or inkscape fallback to rasterize SVG
# We'll rasterize the SVG to PNG once and reuse it for all overlays
TMP_WM="watermark_raster.png"
# 1600px wide translucent watermark; adjust as needed
if command -v magick >/dev/null 2>&1; then
  magick -background none -density 300 "$WM" -resize 1600x "$TMP_WM"
else
  # inkscape fallback
  inkscape "$WM" --export-type=png --export-filename="$TMP_WM" --export-width=1600
fi

for f in "$IN_DIR"/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  # Composite centered, 30% opacity
  magick "$f" "$TMP_WM" -gravity center -compose dissolve -define compose:args=30,100 -composite "$OUT_DIR/$base"
done

# Zip the outputs for easy download
zip -r "watermarked_assets.zip" "$OUT_DIR"
