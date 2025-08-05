#!/bin/bash

#Functie: HTTP 404 Analyse Script via Bash Regex
#Author: Younes El Azzouzi - younes.elazzouzi@student.kdg.be
#Versie: 0.1

starttijd=$(date +%s)
version="0.1"
file="access.log"
tmpfile="$0.tmp"

#kleur tonen in terminal
kleur_output() {
    local kleurcode=$1
    local tekst=$2
    echo -e "\033[${kleurcode}m${tekst}\033[0m"
}

declare -a errors
declare -A foutpaden
totaal=0

#functie om errors te adden aan array
log_error() {
    local fout="$1"
    errors+=("$fout")
    kleur_output "1;31" "$fout" >&2
}

#toon helptekst als er argumenten zijn of als --help gevraagd wordt
if [[ "$1" == "--help" || "$#" -ne 0 ]]; then
    echo "Usage: $(basename $0)"
    echo "Analyseert access.log en toont de top 5 foutpagina's (404)."
    exit 0
fi

#toon versie als gevraagd
if [[ "$1" == "--version" ]]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#controleer of access.log bestaat én niet leeg is
if [ ! -s "$file" ]; then
    log_error "FOUT: Bestand '$file' bestaat niet of is leeg."
    exit 1
fi

#verwijder tijdelijk bestand als het al bestaat
[ -f "$tmpfile" ] && rm "$tmpfile"

#regex om pad + statuscode te extraheren uit Apache logregels
regex='"[A-Z]+ ([^ ]+) HTTP/[0-9.]+" ([0-9]{3})'

#lees bestand lijn per lijn in
while IFS= read -r lijn; do
    if [[ $lijn =~ $regex ]]; then
        pad="${BASH_REMATCH[1]}"
        status="${BASH_REMATCH[2]}"
        if [[ "$status" == "404" ]]; then
            ((foutpaden["$pad"]++))
            ((totaal++))
        fi
    fi
done < "$file"

#schrijf resultaat naar tmp bestand
for pad in "${!foutpaden[@]}"; do
    printf "%s\t%d\n" "$pad" "${foutpaden[$pad]}"
done | sort -k2 -nr > "$tmpfile"

#toon resultaat
echo "Dit is het script van Younes El Azzouzi."
echo -e "PAD\tAANTAL"
head -n 5 "$tmpfile"

echo ""
echo -e "TOTAAL AANTAL 404-REQUESTS: $totaal"

#tijdelijk bestand verwijderen
rm "$tmpfile"

#optioneel: toon duur van het script
eindtijd=$(date +%s)
duur=$((eindtijd - starttijd))
kleur_output "1;33" "Het script duurde $duur seconden."

#toon errors indien van toepassing
if [ "${#errors[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${errors[@]}"; do
        echo "$fout"
    done
    exit 2
fi

exit 0