#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# Usage: ./cutspace.sh [directory]
dir=${1:-.}

if [[ ! -d $dir ]]; then
  echo "Fout: '$dir' is geen directory of bestaat niet." >&2
  exit 1
fi

# Loop alleen over namen die minstens één spatie bevatten
for src in "$dir"/*\ *; do
  dst=${src// /_}
  if mv -- "$src" "$dst"; then
    echo "Hernoemd: '$(basename "$src")' → '$(basename "$dst")'"
  else
    echo "Fout bij hernoemen van '$(basename "$src")'" >&2
  fi
done