#Oefening 1: Systeem-info rapporter
# Opdracht:
#   - Toon helptekst bij --help of geen argumenten.
#   - Valideer een optioneel directory-pad.
#   - Controleer of script als root draait, anders foutmelding naar stderr en exit 1.
#   - Verzamel in een functie: OS-versie, beschikbare schijfruimte, actief processenaantal.
#   - Sla output op in een array en formatteer naar een logbestand in de opgegeven directory.
#   - Redirect foutmeldingen naar sys_report.err en stdout naar sys_report.log.
#   - Check beschikbaarheid van externe commando’s.

#!/bin/bash

#Functie: systeminfo tonen
#Author: younes
#versie: 0.1

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
if [ "$1" = "--help" ] || [ "$#" -eq 0 ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Maakt berekeningen met de file."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#directory-pad validaten 
log_dir="$1"
if [ ! -d "$log_dir" ]; then
    log_error "De dir $log_dir bestaat NIET!"
    exit 1
fi

#controle of runt als root
if [ "$(id -u)" != "0" ]; then
    log_error "Je moet dit script als ROOT uitvoeren!"
    exit 1
fi

#check aanwezigheid van externe commando’s
vereist=("uname" "df" "ps" "awk" "wc")
for cmd in "${vereist[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Vereist commando '$cmd' ontbreekt!"
        exit 1
    fi
done

command -v ab >/dev/null || (echo "Het programma ab is niet geïnstalleerd" >&2 && exit 1)

#redirect output
exec 1> "$log_dir/sys_report.log"
exec 2> "$log_dir/sys_report.err"

#tonen voor testing
exec > >(tee "$log_file")
exec 2> >(tee "$err_file" >&2)

#functie om systeeminfo te verzamelen
verzamel_info() {
    local os=$(uname -sr)
    local disk=$(df -h / | awk 'NR==2 {print $4}')
    local procs=$(ps -e --no-headers | wc -l)
    local tijd=$(date +"%Y-%m-%d %H:%M:%S")

    info=(
        "=== SYSTEEM INFO RAPPORT ==="
        "Tijdstip         : $tijd"
        "OS-versie        : $os"
        "Vrije ruimte (/) : $disk"
        "Aantal processen : $procs"
    )
}

#verzamel systeeminfo
verzamel_info

#output array naar log
for lijn in "${info[@]}"; do
    echo "$lijn"
done

#exit met code 0 = OK
exit 0