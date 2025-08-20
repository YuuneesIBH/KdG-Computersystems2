#!/bin/bash
# Functie: Regex oefening - parsing van naam;achternaam;email
# Auteur: Younes El Azzouzi
# Versie: 1.0

starttijd=$(date +%s)
version="1.0"

# Functie om output in kleur te tonen
kleur_output() {
    local kleurcode=$1
    local tekst=$2
    echo -e "\033[${kleurcode}m${tekst}\033[0m"
}

# Array om fouten bij te houden
declare -a errors

# Functie om errors te loggen (naar STDERR en array)
log_error() {
    local fout="$1"
    errors+=("$fout")
    kleur_output "1;31" "FOUT: $fout" >&2
}

# Root-check (script mag NIET als root draaien)
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag dit script NIET als root uitvoeren!"
    exit 1
fi

# Bestand dat ingelezen moet worden
bestand="gosrex.txt"

# Controle of bestand bestaat en niet leeg is
if [[ ! -s "$bestand" ]]; then
    log_error "Inputbestand '$bestand' bestaat niet of is leeg!"
    exit 1
fi

# Regex: voornaam;achternaam;email
# - ^...$   = begin en einde lijn
# - ([^;]+) = alles behalve ; (1e groep voornaam, 2e groep achternaam)
# - ([^@]+@[^.]+\.[a-zA-Z]{2,}) = simpele email regex
regex='^([^;]+);([^;]+);([^@]+@[^.]+\.[a-zA-Z]{2,})$'

# Bestand lijn per lijn verwerken
while IFS= read -r lijn || [[ -n $lijn ]]; do
    # Lege lijnen overslaan
    [[ -z $lijn ]] && continue

    # Regex match controleren
    if [[ "$lijn" =~ $regex ]]; then
        voornaam="${BASH_REMATCH[1]}"
        achternaam="${BASH_REMATCH[2]}"
        email="${BASH_REMATCH[3]}"

        echo "Voornaam:   $voornaam"
        echo "Achternaam: $achternaam"
        echo "Email:      $email"
        echo "-----------------------------"
    else
        log_error "Regex match mislukt voor lijn: $lijn"
    fi
done < "$bestand"

# Eindtijd tonen
eindtijd=$(date +%s)
duur=$((eindtijd - starttijd))
echo "Script voltooid in $duur seconden (versie $version)"