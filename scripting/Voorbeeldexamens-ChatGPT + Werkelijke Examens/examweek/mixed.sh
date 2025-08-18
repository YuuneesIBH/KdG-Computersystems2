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

#script mag NIET als root uitgevoerd worden
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag het script NIET als root uitvoeren!"
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

# check ab installatie
error_geen_ab="Het programma 'ab' is niet geïnstalleerd."
if ! command -v ab >/dev/null 2>&1; then
    echo "$error_geen_ab"
    read -rp "Wil je 'ab' installeren? (y/n): " keuze
    if [[ "$keuze" =~ ^[Yy]$ ]]; then
        apt-get update && apt-get install -y apache2-utils || log_error "Installatie mislukt."
    else
        log_error "Script afgesloten omdat 'ab' ontbreekt."
        exit 1
    fi
fi

#maildomains extracten
bestand="mixed.txt"
newfile="domainsERE.txt"
while IFS= read -r lijn; do
    regex='^[^@]+@([[:alnum:].-]+\.[[:alpha:]]{2,})$'
    if [[ "$lijn" =~ $regex ]]; then
        emailextensie="${BASH_REMATCH[1]}"
        echo "$emailextensie" >> "$newfile"
    else
        log_error "Lijn matcht regex niet: $lijn"
    fi
done < "$bestand"

newfile="IPsERE.txt"
while IFS= read -r lijn; do
    regex='^([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+)'
    if [[ "$lijn" =~ $regex ]]; then
        emailextensie="${BASH_REMATCH[1]}"
        echo "$emailextensie" >> "$newfile"
    else
        log_error "Lijn matcht regex niet: $lijn"
    fi
done < "$bestand"

newfile="dates.txt"
while IFS= read -r lijn; do
    regex='^([0-9]{2}[/-][0-9]{2}[/-][0-9]{4}|[0-9]{4}[/-][0-9]{2}[/-][0-9]{2}|[0-9]{2}\.[0-9]{2}\.[0-9]{4})$'
    if [[ "$lijn" =~ $regex ]]; then
        emailextensie="${BASH_REMATCH[1]}"
        echo "$emailextensie" >> "$newfile"
    else
        log_error "Lijn matcht regex niet: $lijn"
    fi
done < "$bestand"

newfile="urls.txt" : > "$newfile"   # bestand leegmaken voor nieuwe run
while IFS= read -r lijn; do
    regex='^(https?://)([[:alnum:].-]+)\.([[:alpha:]]{2,4})'
    if [[ "$lijn" =~ $regex ]]; then
        protocol="${BASH_REMATCH[1]}"
        domain="${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
        echo "$protocol $domain" >> "$newfile"
    else
        log_error "Lijn matcht regex niet: $lijn"
    fi
done < "$bestand"

newfile="phones.txt"
: > "$newfile"
while IFS= read -r lijn; do
    regex='^(\+32[[:space:]][0-9]{3}[[:space:]][0-9]{2}[[:space:]][0-9]{2}[[:space:]][0-9]{2}|0032-[0-9]-[0-9]{7}|\+[0-9]{1,3}-[0-9]{1,3}-[0-9]{3}-[0-9]{4})$'
    if [[ "$lijn" =~ $regex ]]; then
        echo "$lijn" >> "$newfile"
    else
        log_error "Geen geldig telefoonnummer: $lijn"
    fi
done < "$bestand"

newfile="names.txt"
: > "$newfile"
while IFS= read -r lijn; do
    regex="^([A-Z][a-z]+([-'][A-Z][a-z]+)?),?[[:space:]]+[A-Z][a-z]+$"
    if [[ "$lijn" =~ $regex ]]; then
        echo "$lijn" >> "$newfile"
    else
        log_error "Geen geldige naamstructuur: $lijn"
    fi
done < "$bestand"

newfile="random.txt"
: > "$newfile"
while IFS= read -r lijn; do
    # Match ERROR-code of UserID
    regex='(ERROR\[[0-9]{3,}\]|UserID: [A-Za-z0-9_-]+)'
    if [[ "$lijn" =~ $regex ]]; then
        echo "${BASH_REMATCH[1]}" >> "$newfile"
    else
        log_error "Geen match in random tekst: $lijn"
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