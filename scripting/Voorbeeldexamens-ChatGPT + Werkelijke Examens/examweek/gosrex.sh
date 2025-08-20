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

bestand="gosrex.txt"
[[ -r $bestand ]] || { echo "Bestand '$bestand' onleesbaar" >&2; exit 1; }

output="output.txt"
echo "Wat gevonden? | Gevonden Item" > "$output"

while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='^[^@[:space:]]+@([[:alnum:]-]+\.[[:alpha:]]+)$'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn" 
        printf 'Captured:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#jane.doe+it extracten
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='([a-z]+\.[a-z]+\+[a-z]+)@'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='([a-z]+\-[a-z]+\.[a-z]{3})'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#tijd extracten
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='([01][0-9]|2[0-3]):([0-5][0-9])'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured uur:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
        printf 'Captured minuut:   %s\n' "${BASH_REMATCH[2]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#IP extracten
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='([0-9]{3}\.[0-9]{3}\.[0-1]\.[0-9]{2})'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured IP:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='([0-9]{3}\.[0-9]{3}\.[0-1]\.[0-9]{2})'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured IP:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#sessionID extracten
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='SessionID=([[:alnum:]]+)'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Captured session ID:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#file extraction
while IFS= read -r lijn || [[ -n $lijn ]]; do
    regex='file=([[:alnum:]_]+\.[[:alnum:]]{3,4})'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'file:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#Product extraction
while IFS=";" read -r lijn || [[ -n $lijn ]]; do
    regex='Product=([[:alnum:]_]+\.[[:alnum:]]{3,4})'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'Productpicture:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#CustomerID extraction
while IFS=";" read -r lijn || [[ -n $lijn ]]; do
    regex='CustomerID=([[:digit:]]+)'
    lijn=${lijn%$'\r'}
    [[ -z $lijn ]] && continue #sla lege lijnen over
    if [[ $lijn =~ $regex ]]; then
        printf 'Full match: %s\n' "$lijn"
        printf 'CustomerID extracted:   %s\n' "${BASH_REMATCH[1]}" >> "$output"
    else
        log_error "Geen match!"
    fi
done < "$bestand"

#eindtijd=$(date +%s)
#duur=$((eindtijd - starttijd))
#kleur_output "1;33" "Het script duurde $duur seconden."
exit 0