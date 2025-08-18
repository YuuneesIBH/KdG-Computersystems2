#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configuratie
readonly LOGO_URL="https://www.kdg.be/doc/huisstijl/Logo_V.png"
readonly LOGO_ORIG="Logo_V.png"
readonly LOGO_MOD="Logo_V_mod.png"

# Functie: download het origineel (max. 1×) via wget
download_logo() {
    if [[ -f "$LOGO_ORIG" ]]; then
        return 0
    fi
    echo "Download watermark-logo…" >&1
    if wget -q "$LOGO_URL" -O "$LOGO_ORIG"; then
        echo "Logo binnen, sla op als $LOGO_ORIG" >&1
    else
        echo "Fout: kon logo niet downloaden van $LOGO_URL" >&2
        exit 1
    fi
}

# Functie: maak een aangepaste versie (resize + zachter contrast)
adjust_logo() {
    # Maak enkel opnieuw aan als LOGO_ORIG nieuwer is dan LOGO_MOD
    if [[ -f "$LOGO_MOD" && "$LOGO_MOD" -nt "$LOGO_ORIG" ]]; then
        return 0
    fi
    echo "Aanpassen logo: resize → 92x20, contrast verlaagt…" >&1
    # -resize: nieuwe afmetingen, -brightness-contrast: minder dominant
    if convert "$LOGO_ORIG" -resize 92x20\! -brightness-contrast -20x0 "$LOGO_MOD"; then
        echo "Aangepaste logo klaar als $LOGO_MOD" >&1
    else
        echo "Fout: kon logo niet aanpassen" >&2
        exit 1
    fi
}

# Functie: voeg watermark toe aan $1 (input), schrijf naar $2 (PNG)
maak_watermerk() {
    local src="$1" dst="$2"
    # compositen met gravity: rechtsonder
    if composite -gravity southeast "$LOGO_MOD" "$src" "$dst"; then
        echo "Bestand '$(basename "$src")' → '$(basename "$dst")'" >&1
    else
        echo "Fout bij watermarken van '$(basename "$src")'" >&2
    fi
}

# Controleren op --help
if [[ "${1:-}" == "--help" ]]; then
    cat <<-EOF
Usage: $(basename "$0") [directory]

Dit script doorzoekt (niet-recusief) de opgegeven directory (standaard .)
naar .jpg/.jpeg-bestanden en maakt voor elk een PNG-versie met watermark.
EOF
    exit 0
fi

dir=${1:-.}
if [[ ! -d "$dir" ]]; then
    echo "Fout: '$dir' is geen directory." >&2
    exit 1
fi

# 1) Zorg dat we logo hebben en aangepast logo
download_logo
adjust_logo

# 2) Loop over alle JPEG's (case-insensitive, spatie-veilig)
find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0 |
while IFS= read -r -d '' file; do
    base="$(basename "$file")"
    naam="${base%.*}"
    dst="$dir/${naam}.png"
    maak_watermerk "$file" "$dst"
done

exit 0