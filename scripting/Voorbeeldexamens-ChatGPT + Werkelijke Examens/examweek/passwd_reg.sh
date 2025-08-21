#!/bin/bash

#Functie:
#Auteur:
#versie: 1.1

starttijd=$(date +%s)
version="1.1"

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

#root check
if [ "$(id -u)" != "0" ]; then
    log_error "FOUT: je moet dit script als ROOT uitvoeren!"
    exit 1
fi

#help tonen if needed OR als er geen arguments worden gegeven!
if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Analyseert /etc/passwd en toont login, UID en shell."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

bestand="/etc/passwd"
[[ -s $bestand ]] || { log_error "Bestand: $bestand is onleesbaar!" >&2; exit 1; }

output="passwd_info.txt"
echo "Voor eerste : | Padextensie" > "$output"

while IFS=":" read -r lijn || [[ -n $lijn ]]; do
    regex='^([^:]+):.*:([^:]+)$'
    lijn=${lijn%$'\r'}
    if [[ $lijn =~ $regex ]]; then
        gebruiker="${BASH_REMATCH[1]}"
        shell="${BASH_REMATCH[2]}"
        printf "%s | %s\n" "$gebruiker" "$shell" >> "$output"
    else
        log_error "Geen match: $lijn"
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