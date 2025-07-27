#Oefening 2: Gebruikersanalyse en archiveren
# Opdracht:
#   - Toon helptekst bij --help of foutief aantal argumenten (>1).
#   - Gebruik /etc/passwd als inputbestand.
#   - Lees het bestand regel per regel en haal met IFS of awk volgende velden op:
#       loginnaam, UID, shell.
#   - Toon elk resultaat in kleur per kolom: login = blauw, UID = geel, shell = groen.
#   - Sla de platte (niet-gekleurde) output op in een bestand genaamd:
#       passwd_analyse_YYYYMMDD_HHMMSS.log
#   - Maak een gzip-tar-archief van het logbestand: passwd_analyse_YYYYMMDD_HHMMSS.tar.gz
#   - Toon achteraf de namen van beide aangemaakte bestanden.
#   - Voorzie --version met versienummer.
#   - Voorzie best practices (shebang, foutcodes, commentaar, exit 0).

#!/bin/bash

#Functie: awk leren en dingen tonen
#Author: younes
#versie: 0.1

IFS=$'\n'

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

version="0.1"

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

inputfile="/etc/passwd"
if [ ! -s "$inputfile" ] || [ ! -r "$inputfile" ]; then
    log_error "FOUT: Bestand $inputfile bestaat niet, is leeg of is niet leesbaar."
    exit 1
fi

#waarden waarmee ik later ga werken
timestamp=$(date +"%Y%m%d_%H%M%S")
logbestand="passwd_analyse_${timestamp}.log"
archiefbestand="passwd_analyse_${timestamp}.tar.gz"

#logbestand aanmaken en errors loggen
touch "$logbestand" || {
    log_error "FOUT: Kan logbestand niet aanmaken."
    exit 1
}

awk -F: -v logfile="$logbestand" '
{
    login = $1
    uid = $3
    shell = $7

    # Toon gekleurde output
    printf "\033[1;34m%s\033[0m ", login    # blauw
    printf "\033[1;33m%s\033[0m ", uid      # geel
    printf "\033[1;32m%s\033[0m\n", shell   # groen

    # Schrijf platte output naar logbestand
    printf "%s %s %s\n", login, uid, shell >> logfile
}' "$inputfile"

#zippen van output
tar -czf "$archiefbestand" "$logbestand" || {
    log_error "FOUT: Archiveren van $logbestand mislukt."
    exit 1
}

echo "Logbestand: $logbestand"
echo "Archiefbestand: $archiefbestand"

unset IFS
exit 0