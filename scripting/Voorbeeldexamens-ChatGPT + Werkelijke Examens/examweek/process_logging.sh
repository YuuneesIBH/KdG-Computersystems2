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
    echo "Usage: $(basename $0)"
    echo "Processen analyseren en logging maken."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

# check multiple commands installation
for cmd in ps awk sort; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Vereist commando '$cmd' ontbreekt!"
        exit 1
    fi
done

logfile="processlog_$(date +%Y%m%d_%H%M%S).log"

echo "PID    RSS    COMMAND" | tee "$logfile"
ps -eo pid,rss,comm --no-headers | \
    awk '{printf "%-6s %-8s %-30s\n", $1, $2, substr($3,1,30)}' | \
    sort -k2 -nr | head -n 5 | tee -a "$logfile"

kleur_output "1;32" "Resultaat ook opgeslagen in $logfile"

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