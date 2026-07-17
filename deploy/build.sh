#!/bin/bash
# Build: fetch the previous production deployment (HTML + image assets),
# patch the Jul 18 card server-side, emit everything into public/.
set -euo pipefail
BASE="https://japan-trip-planner-810skyo52-marqs-projects-1c6519ec.vercel.app"
SHARE="_vercel_share=XokSa3gTz7v3QxPlwp84YDDNScNG6Pj6"
JAR="$(mktemp)"
fetch() { # fetch <path> <outfile>
  curl -sSfL --retry 3 --retry-delay 2 -c "$JAR" -b "$JAR" "$BASE/$1?$SHARE" -o "$2"
}
mkdir -p public/img public/tickets

fetch "" orig.html
grep -q "Japan → Hawaii" orig.html || { echo "FATAL: fetched page is not the app (auth wall?)"; exit 1; }

python3 patch.py orig.html public/index.html

while IFS= read -r p; do
  fetch "$p" "public/$p"
done < assets.txt

# validate: no auth/HTML pages masquerading as images
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
