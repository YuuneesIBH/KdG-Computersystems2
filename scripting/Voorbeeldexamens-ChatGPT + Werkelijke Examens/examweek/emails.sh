#!/bin/bash

#Functie: Email parser
#Auteur: Younes El Azzouzi
#versie: 1.2

starttijd=$(date +%s)
version="1.2"

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

#script mag NIET als root uitgevoerd worden
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag het script NIET als root uitvoeren!"
    exit 1
fi

#help tonen if needed
if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Leest emails.txt en haalt naam, achternaam en domein uit."
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

bestand="emails.txt"
newfile="checkedreg.txt"

while IFS= read -r lijn; do
    regex='^([^;]+);([^;]+);([^@]+@[^.]+\.[a-zA-Z]{2,})$'
    if [[ "$lijn" =~ $regex ]]; then
        naam="${BASH_REMATCH[1]}"
        achternaam="${BASH_REMATCH[2]}"
        email="${BASH_REMATCH[3]}"
        extensie="${email##*@}"
        echo "$naam;$achternaam;$extensie" >> "$newfile"
    else
        log_error "Lijn matcht regex niet: $lijn"
    fi
done < "$bestand"

eindtijd=$(date +%s)
duur=$((eindtijd - starttijd))
kleur_output "1;33" "Het script duurde $duur seconden."

#OPTIONEEL --> toon errors indien van toepassing
if [ "${#errors[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${errors[@]}"; do
        echo "$fout"
    done
    exit 2
fi

exit 0