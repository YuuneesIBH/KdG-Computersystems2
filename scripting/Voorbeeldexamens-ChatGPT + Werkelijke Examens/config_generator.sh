# Oefening 4: Config-generator met parameter substitution
# Opdracht:
#   - Lees een .tmpl-template met placeholders ${HOST}, ${PORT}, ${USER}.
#   - Vraag interactief waarden via read met defaults.
#   - Vervang placeholders en valideer dat er geen overblijven.

#!/bin/bash
# Functie: Genereert configuratiebestand op basis van template
# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 1.0

version="1.0"

if [[ "$1" == "--help" ]]; then
    echo "Gebruik: $(basename "$0")"
    echo "Leest een .tmpl bestand met variabelen en genereert config"
    exit 0
fi

if [[ "$1" == "--version" ]]; then
    echo "$(basename "$0") versie: $version"
    exit 0
fi

#inputfile checken
template_file="config.tmpl"

if [[ ! -f "$template_file" ]]; then
    echo "FOUT: Bestand $template_file niet gevonden." >&2
    exit 1
fi

#vragen naar waarden anders default pakken 
read -p "Geef hostnaam [localhost]: " HOST
HOST=${HOST:-localhost}

read -p "Geef poort [8080]: " PORT
PORT=${PORT:-8080}

read -p "Geef gebruikersnaam [admin]: " USER
USER=${USER:-admin}

#file lezen en vervangen
output_file="config.conf"
content=$(<"$template_file")

content=${content//\$\{HOST\}/$HOST}
content=${content//\$\{PORT\}/$PORT}
content=${content//\$\{USER\}/$USER}

if echo "$content" | grep -q '\${'; then
    echo "FOUT: Niet alle placeholders zijn vervangen!" >&2
    exit 1
fi

#result wegschrijven naar een file
echo "Configuratiebestand gegenereerd: $output_file"

exit 0