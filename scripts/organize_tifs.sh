#!/bin/bash
set -euo pipefail

# === Configuration — edit these for your setup ===
SRC_DIR="/path/to/your/tif/files"      # where the unsorted files currently live
DEST_DIR="/path/to/organized"          # where the per-code subfolders will be created
MODE="move"                            # "move", "copy", or "link"
DRY_RUN=true                           # leave true until you've checked the output looks right

mkdir -p "$DEST_DIR"

for filepath in "$SRC_DIR"/*.tif; do
    filename=$(basename "$filepath")

    # Field 3 (underscore-delimited) holds the long number, e.g. 4507458
    field3=$(cut -d'_' -f3 <<< "$filename")

    # First 5 digits of that field are the group code, e.g. 45074
    code="${field3:0:5}"

    target_dir="$DEST_DIR/$code"

    if [ "$DRY_RUN" = true ]; then
        echo "Would place $filename -> $target_dir/"
        continue
    fi

    mkdir -p "$target_dir"

    case "$MODE" in
        move) mv "$filepath" "$target_dir/" ;;
        copy) cp "$filepath" "$target_dir/" ;;
        link) ln -s "$filepath" "$target_dir/" ;;
        *) echo "Unknown MODE: $MODE" >&2; exit 1 ;;
    esac
done

echo "Done."
