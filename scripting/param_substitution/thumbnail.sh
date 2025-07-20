#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Functie: maak een 50×50 thumbnail van $1 (input) naar $2 (output)
maak_thumbnail() {
    local src="$1" dst="$2"
    # convert geeft exit code 0 bij succes
    if convert -thumbnail 50x50 -extent 50x50 -gravity center "$src" "$dst"; then
        # Succesbericht naar STDOUT (1)
        echo "Bestand '$(basename "$src")' omgezet naar '$(basename "$dst")'"
    else
        # Foutmelding naar STDERR (2)
        echo "Fout bij omzetten van '$(basename "$src")'" >&2
    fi
}

# Zoek in de huidige directory (niet recursief) naar .jpg/.jpeg, case-insensitive, veilig voor spaties
find . -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 |
while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    # Strip extensie (laatste punt + alles daarna weg)
    naamzonderext="${base%.*}"
    dst="thumbnail_${naamzonderext}.png"
    maak_thumbnail "$file" "$dst"
done

exit 0