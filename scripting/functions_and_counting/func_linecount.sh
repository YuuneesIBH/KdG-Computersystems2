#!/usr/bin/env bash
#
# linecount.sh – telt het aantal lijnen in een bestand (zonder wc)
#
# Usage:
#   linecount.sh [-h|--help] <bestand>
#
# Exit codes:
#   0 Succes
#   1 Onjuist gebruik of bestand niet leesbaar

set -euo pipefail

print_help() {
  cat <<EOF
Usage: $(basename "$0") [-h|--help] <bestand>

Telt het aantal regels in <bestand> zonder gebruik van 'wc'.

Options:
  -h, --help    Toon deze helptekst en sluit af.
EOF
}

# — Argumenten parsen —
if [[ $# -eq 0 ]]; then
  echo "Fout: ontbrekend bestand." >&2
  print_help >&2
  exit 1
fi

case "$1" in
  -h|--help)
    print_help
    exit 0
    ;;
  *)
    file="$1"
    ;;
esac

# — Bestaan en leesbaarheid controleren —
if [[ ! -e "$file" ]]; then
  echo "Fout: bestand '$file' bestaat niet." >&2
  exit 1
elif [[ ! -r "$file" ]]; then
  echo "Fout: bestand '$file' is niet leesbaar." >&2
  exit 1
fi

# — Functie die regeltelt —
count_lines() {
  local filename="$1"
  local cnt=0
  # IFS staat hier lokaal op alleen newline...
  local IFS=$'\n'
  # ...en met read -r behoud je backslashes etc.
  while IFS= read -r _; do
    cnt=$((cnt + 1))
  done < "$filename"
  echo "$cnt"
}

# — Main —
line_count=$(count_lines "$file")
echo "$line_count $file"
