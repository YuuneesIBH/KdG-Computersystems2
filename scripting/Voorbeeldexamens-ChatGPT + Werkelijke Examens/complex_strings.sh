# Oefening 10: Complexe string-operaties en trimming
# Opdracht:
#   - Neem een URL als argument.
#   - Trim protocol en query-string.
#   - Haal domein, pad en extensie op met parameter substitution.

#!/bin/bash

#Functie: 
#Arguments: 
#Author: 
#Versie: 0.1

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "DOET DIT [TEMPLATE]"
    echo "Voorbeeld: $(basename $0) <args> "
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

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

#controle of er 1 argument is meegegeven
if [ "$#" -ne 1 ]; then
    log_error "Je hebt minder of meer dan één argument(en) meegegeven!"
    exit 1
fi

url="$1"

#trim protocol: verwijderen van http(s)://
zonder_protocol="${url#*://}"

zonder_query="${zonder_protocol%%\?*}"

#domein extractie
domein="${zonder_query%%/*}"

#pad 
pad="${zonder_query#*/}"

#extensie: alles na laatste .
extensie="${pad##*.}"

kleur_output "1;34" "Volledige URL: $url"
kleur_output "1;32" "Domein:        $domein"
kleur_output "1;36" "Pad:           /$pad"
kleur_output "1;35" "Extensie:      $extensie"

exit 0