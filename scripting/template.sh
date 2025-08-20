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

#script mag NIET als root uitgevoerd worden
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag het script NIET als root uitvoeren!"
    exit 1
fi

#help tonen if needed OR als er geen arguments worden gegeven!
if [ "$1" = "--help" ] || [ "$#" -ne 1 ]; then
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

bestand="gosrex.txt"
[[ -r $bestand ]] || { log_error "Bestand: $bestand is onleesbaar!" >&2; exit 1; }

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

# ==============================
# Voorbeeld: parameters controleren
# ==============================
# "$#" = aantal parameters waarmee script gestart wordt
# "-ne 3" = not equal to 3
#
# Voorbeeld van parametergebruik:
# bestand=$1   # eerste argument
# user=$2      # tweede argument
# groep=$3     # derde argument
#
# echo "Bestand=$bestand, User=$user, Groep=$groep"

# ==============================
# IFS (Internal Field Separator)
# ==============================
# Default = spatie, tab, newline
# Bash gebruikt IFS bij woord-splitsing en bij read/for loops
#
# Veelgebruikte instellingen:
#
# IFS=";"       # splitst op puntkomma → typisch CSV uit Excel
# IFS=","       # splitst op komma → CSV-bestanden
# IFS=":"       # splitst op dubbele punt → bv. /etc/passwd velden
# IFS=$'\n'     # splitst enkel op newline → handig bij bestandslezen
# IFS=" "       # splitst op spatie (zelden nodig, want standaard al zo)
# IFS=$'\t'     # splitst op tabs → bv. tab-gescheiden bestanden
# IFS=",:;"     # meerdere tegelijk: splitst op komma, dubbele punt en puntkomma
#
# Tip: na gebruik terugzetten naar default met:
#   unset IFS
# ==============================

# ==============================
# Command substitution (commando in variabele steken)
# ==============================
# Beste manier: gebruik $(commando)
# (backticks `commando` bestaan ook maar zijn verouderd)
#
# Voorbeelden:
#
# 1) Volledige output in variabele
# root_procs=$(ps -ef | grep root)
# echo "$root_procs"
#
# 2) Enkel specifieke kolom eruit halen (met awk)
# root_pids=$(ps -ef | awk '$1 == "root" {print $2}')
# echo "Alle PID's van root:"
# echo "$root_pids"
#
# 3) Foutmeldingen ook mee in variabele stoppen
# output=$(ls /nietbestaandepad 2>&1)
# echo "$output"
#
# Tip: gebruik altijd $() i.p.v. backticks voor leesbaarheid
# ==============================