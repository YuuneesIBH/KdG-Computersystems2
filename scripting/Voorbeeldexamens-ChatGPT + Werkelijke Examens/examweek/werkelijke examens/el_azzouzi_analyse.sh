#!/bin/bash

#Functie: Analyse van directory en bestanden
#Auteur: Younes El Azzouzi
#Versie: 1.0

starttijd=$(date +%s)
version="1.0"

#functie om in kleur te tonen
kleur_output() {
    local kleurcode=$1
    local tekst=$2
    echo -e "\033[${kleurcode}m${tekst}\033[0m"
}

#array voor fouten
declare -a errors

#functie om errors te loggen
log_error() {
    local fout="$1"
    errors+=("$fout")
    kleur_output "1;31" "$fout" >&2
}

#functie om gemiddelde te berekenen
average() {
    local totaal=$1
    local aantal=$2
    if [ "$aantal" -eq 0 ]; then
        echo "0.00"
    else
        printf "%.2f\n" "$(echo "$totaal / $aantal" | bc -l)"
    fi
}

#argumenten check
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    log_error "Gebruik: $(basename "$0") <directory> [extensie]"
    exit 1
fi

directory=$1
file_extension=$2

#check of directory bestaat
if [ ! -d "$directory" ]; then
    log_error "FOUT: '$directory' bestaat niet of is geen directory!"
    exit 1
fi

#bestanden zoeken (met of zonder extensie, lege files negeren)
if [ -n "$file_extension" ]; then
    bestanden=$(find "$directory" -type f -name "*.$file_extension" ! -empty 2>/dev/null)
else
    bestanden=$(find "$directory" -type f ! -empty 2>/dev/null)
fi

#geen bestanden gevonden
if [ -z "$bestanden" ]; then
    log_error "Geen relevante bestanden gevonden in '$directory'."
    exit 1
fi

#analyse uitvoeren
count_extension=0
sum=0
while IFS= read -r bestand; do
    size=$(stat -c %s "$bestand" 2>/dev/null)
    if [ -n "$size" ]; then
        sum=$((sum + size))
        ((count_extension++))
    fi
done <<< "$bestanden"

#rapport tonen
kleur_output "1;36" "--- Bestandsanalyse Rapport ---"
echo "Directory: $directory"
echo "Bestandsextensie: ${file_extension:-Alle}"
echo "Totaal aantal relevante bestanden: $count_extension"
echo "Totale grootte van de relevante bestanden: $sum bytes"
echo "Gemiddelde bestandsgrootte: $(average "$sum" "$count_extension") bytes"

#eindtijd
eindtijd=$(date +%s)
echo "Uitvoeringstijd: $((eindtijd - starttijd)) seconden"