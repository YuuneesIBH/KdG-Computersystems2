#!/bin/bash

#Functie: terminal tank spel
#Author: Younes El Azzouzi - younes.elazzouzi@student.kdg.be
#versie: 0.1

starttijd=$(date +%s)
version="0.1"
input="$1"
tmpfile="$0.tmp"

#functie om in kleur te tonen
kleur_output() {
    local kleurcode=$1
    local tekst=$2
    echo -e "\033[${kleurcode}m${tekst}\033[0m"
}

declare -a errors

#functie om errors te adden aan array
log_error() {
    local fout="$1"
    errors+=("$fout")
    kleur_output "1;31" "$fout" >&2
}

#help tonen if needed OR als er geen arguments worden gegeven!
if [ "$input" = "--help" ] || [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Voert per lijn een bc-berekening uit op een aparte CPU met taskset."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$input" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

if [ -f "$tmpfile" ]; then
    rm "$tmpfile"
fi

#genereren van de proceslijst
ps -vax > /tmp/ps_output.txt 2>/dev/null || {
    log_error "FOUT: ps commando is mislukt!"
    exit 1
}

#regex opmaken
regex='^[[:space:]]*[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+([0-9]+)[[:space:]]+[0-9]+[[:space:]]+(.+)$'

#we steken de RSS en COMMAND waarden in een array
declare -a regels

while IFS= read -r lijn; do
    if [[ $lijn =~ $regex ]]; then
            rss="${BASH_REMATCH[1]}"
            cmd="${BASH_REMATCH[2]}"
            cmd50="${cmd:0:50}"  # Max 50 karakters
            if [ "$rss" -ne 0 ]; then
                regels+=("${rss}"$'\t'"${cmd50}")
            fi
    fi
done < /tmp/ps_output.txt

#wegschrijven van de regels naar een bestand.
printf "%s\n" "${regels[@]}" | sort -nr > "$tmpfile"

#top 7 lijnen tonen van de bestand
kleur_output "1;32" $'RSS\tCOMMAND'
head -n 7 "$tmpfile"

#totale geheugengebruikt RRS Sum
totaal=$(awk '{sum+=$1} END{print sum}' "$tmpfile")
echo -e "\nTOTAAL GEBRUIKT GEHEUGEN (RSS): $totaal KiB"

endtijd=$(date +%s)
duur=$(( (endtijd - starttijd) / 60 ))
kleur_output "1;33" "Het script heeft $duur minuten geduurd."

duur=$((endtijd - starttijd))
kleur_output "1;33" "Het script heeft $duur seconden geduurd."

#(dit hier is optioneel gedaan --> voor gebruik van arrays te tonen)
if [ "${#errors[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${errors[@]}"; do
        echo "$fout"
    done
    exit 2
fi

rm "$tmpfile"

exit 0