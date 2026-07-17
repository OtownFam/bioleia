#!/bin/bash
# Fetch the final index.html from the pinned GitHub commit, and the image
# assets from the previous Vercel deployment (share-token auth). Emit public/.
set -euo pipefail
RAW="https://raw.githubusercontent.com/OtownFam/bioleia/b307c9cab15836147a006f656a9fcf4f265795a9"
BASE="https://japan-trip-planner-810skyo52-marqs-projects-1c6519ec.vercel.app"
SHARE="_vercel_share=XokSa3gTz7v3QxPlwp84YDDNScNG6Pj6"
JAR="$(mktemp)"
mkdir -p public/img public/tickets

curl -sSfL --retry 3 --retry-delay 2 "$RAW/index.html" -o public/index.html
grep -q "Crowd tactic" public/index.html || { echo "FATAL: index.html is not the patched version"; exit 1; }

while IFS= read -r p; do
  curl -sSfL --retry 3 --retry-delay 2 -c "$JAR" -b "$JAR" "$BASE/$p?$SHARE" -o "public/$p"
done < assets.txt

fail=0
while IFS= read -r p; do
  f="public/$p"
  sig=$(head -c 4 "$f" | od -An -tx1 | tr -d ' \n')
  case "$p" in
    *.jpg)  [ "${sig:0:4}" = "ffd8" ] || { echo "BAD JPG: $p ($sig)"; fail=1; } ;;
    *.png)  [ "$sig" = "89504e47" ]   || { echo "BAD PNG: $p ($sig)"; fail=1; } ;;
    *.svg)  grep -q "<svg" "$f"       || { echo "BAD SVG: $p"; fail=1; } ;;
  esac
done < assets.txt
[ "$fail" = 0 ] || exit 1
echo "BUILD OK: $(find public -type f | wc -l) files"
