#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 -b BASE_URL [-o OUTPUT_DIR]"
  exit 1
}

BASE=""
OUT="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--base)
      BASE="$2"
      shift 2
      ;;
    -o|--out)
      OUT="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

[[ -z "$BASE" ]] && usage

mkdir -p "$OUT"

echo "Downloading file list from:"
echo "  $BASE/index.html"
echo

wget -qO- "$BASE/index.html" \
| grep -o "href='[^']*'" \
| cut -d"'" -f2 \
| grep -v '^index.html$' \
| sed "s|^|$BASE/|" \
| wget -i - -P "$OUT"

echo
echo "Done. Files saved to: $OUT"
