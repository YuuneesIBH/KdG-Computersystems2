#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# --- Helpfunctie ---
show_help() {
  cat <<-EOF
Usage: $(basename "$0") [OPTIONS] <directory>

Maakt een tar.gz-backup van <directory> met timestamp in de bestandsnaam.

OPTIONS:
  -h, --help    Toon dit helpbericht en stop.

Voorbeeld:
  $(basename "$0") /etc            # backup_etc_20250720_154512.tar.gz
EOF
}

# --- Detecteer help-flag anywhere in $@ met regex ---
# (^|[[:space:]]) zorgt dat -h niet in een ander woord zit
if [[ " $* " =~ (^|[[:space:]])(-h|--help)($|[[:space:]]) ]]; then
  show_help
  exit 0
fi

# --- Argumentcontrole ---
if [[ $# -ne 1 ]]; then
  echo "Fout: geef precies één directory op." >&2
  show_help
  exit 1
fi

src="$1"
if [[ ! -d "$src" ]]; then
  echo "Fout: '$src' is geen directory of bestaat niet." >&2
  exit 1
fi

# --- Backup-logica (simpel voorbeeld) ---
timestamp=$(date +%Y%m%d_%H%M%S)
dirname=$(basename "$src")
archive="backup_${dirname}_${timestamp}.tar.gz"

# Tar compress en rapporteer
if tar -czf "$archive" -C "$(dirname "$src")" "$dirname"; then
  echo "Backup gemaakt: $archive"
  exit 0
else
  echo "Fout bij het aanmaken van de backup." >&2
  exit 1
fi