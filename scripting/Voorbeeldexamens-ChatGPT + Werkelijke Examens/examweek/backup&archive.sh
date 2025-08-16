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
if [ "$1" = "--help" ] || [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) [--help | --version | {directory}]"
    echo "Maakt een backup van een meegegeven directory."
    echo "Voorbeeld: $(basename $0) directory"
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

passed_dir="$1"
if [ ! -d "$passed_dir"  ]; then
    log_error "Het meegegeven argument is geen directory!"
    exit 1
fi

# check tar installatie
error_geen_ab="Het programma 'tar' is niet geïnstalleerd."
if ! command -v tar >/dev/null 2>&1; then
    echo "$error_geen_ab"
    read -rp "Wil je 'tar' installeren? (y/n): " keuze
    if [[ "$keuze" =~ ^[Yy]$ ]]; then
        apt-get update && apt-get install -y tar || log_error "Er is iets onverwachts misgegaan!"
    else
        log_error "Script afgesloten omdat 'tar' ontbreekt."
        exit 1
    fi
fi

#STDERR meldingen wegschrijven 
errorlog="/var/log/error_$(basename $0).log"

#alle meldingen van STDOUT voor geen errormeldingen
backuplog="/var/log/backup_$(basename $0).log"

timestamp=$(date +%Y_%m_%d_%H_%M_%S)
backupfile="Backup_${timestamp}.tar.gz"

tar -czvf "$backupfile" "$passed_dir" 1>>"$backuplog" 2>>"$errorlog"

#check van de backup
if [ $? -eq 0 ]; then
    kleur_output "1;32" "Backup succesvol: $backupfile"
else
    log_error "Fout bij het maken van de backup."
    exit 1
fi

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