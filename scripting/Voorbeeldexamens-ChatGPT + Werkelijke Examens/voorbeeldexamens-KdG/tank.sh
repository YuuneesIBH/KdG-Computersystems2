#!/bin/bash

#Functie: terminal tank spel
#Author: Younes El Azzouzi - younes.elazzouzi@student.kdg.be
#versie: 0.1

starttijd=$(date +%s)
version="0.1"
input="$1"
afstand=0

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

#help tonen if needed OR als er geen arguments worden gegeven!
if [ "$input" = "--help" ] || [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Voert per lijn een bc-berekening uit op een aparte CPU met taskset."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$input" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#script mag NIET als root uitgevoerd worden
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag het script NIET als root uitvoeren!"
    exit 1
fi

#er wordt gevraagd naar exact één parameter
if [ "$#" -ne 1 ]; then 
    log_error "Er is GEEN of teveel parameters meegegeven!"
    exit 1
fi

if [ "$input" != "kort" ] && [ "$input" != "lang" ]; then
    log_error "Je moet het keyword 'kort' of 'lang' gebruiken!"
    exit 1
fi

if [ "$input" = "lang" ]; then
    afstand=200
else 
    afstand=100
fi

#scherm leegmaken voor een nette start
clear

echo "Dit is het script van Younes El Azzouzi"
echo "De ingestelde afstand is: $afstand."

#controle of bc beschikbaar is
if ! command -v bc >/dev/null; then
    log_error "Het programma 'bc' is niet geïnstalleerd."
    echo -n "Wil je 'bc' installeren? (j/n): "
    read antwoord
    if [[ "$antwoord" = "j" || "$antwoord" = "J" ]]; then
        if [ "$(id -u)" -ne 0 ]; then
            kleur_output "1;33" "Je bent geen root, 'sudo' zal worden gebruikt..."
        fi
        sudo apt-get update && sudo apt-get install -y bc
        if [ $? -ne 0 ]; then
            log_error "Installatie van 'bc' is mislukt!"
            exit 1
        else
            kleur_output "0;32" "'bc' is succesvol geïnstalleerd."
        fi
    else
        log_error "Het script vereist 'bc' om te werken. Afsluiten..."
        exit 1
    fi
fi

#input functie vragen naar vals en regex voor pattern recognition
input() {
    while true; do
        echo -n "Geef de hoek van de tankloop (in graden): "
        read hoek
        if [[ "$hoek" =~ ^[0-9]+$ ]]; then
            break
        else
            log_error "Ongeldige invoer voor hoek! Geef een positief geheel getal."
        fi
    done

    while true; do
        echo -n "Geef de kracht waarmee geschoten wordt: "
        read kracht
        if [[ "$kracht" =~ ^[0-9]+$ ]]; then
            break
        else
            log_error "Ongeldige invoer voor kracht! Geef een positief geheel getal."
        fi
    done
}

#berekening voor de afstand van de kogel
raak() {
    #afstand berekenen
    afstandkogel=$(echo "scale=0; $kracht * $kracht * s(2 * $hoek * 3.14 / 180) / 10" | bc -l)
    
    #verschil berekenen
    verschil=$(echo "$afstandkogel - $afstand" | bc)
    verschil=${verschil#-}  # absolute waarde (verwijder minteken)

    if [ "$verschil" -le 10 ]; then
        kleur_output "1;32" "RAAK op ${afstandkogel} meter!"
        echo "Gewonnen!"
        exit 0
    else
        kleur_output "1;31" "MIS! De kogel kwam op ${afstandkogel} meter."
    fi
}

gokcount=0

while [ $gokcount -ne 3 ]; do
    echo ""
    echo "Afstand is ${afstand} meter"
    input
    raak
    gokcount=$((gokcount + 1))
done

kleur_output "1;31" "Verloren"

endtijd=$(date +%s)
totaal=$((endtijd - starttijd))
kleur_output "1;33" "Het script heeft $totaal minuten geduurd."

#(dit hier is optioneel gedaan --> voor gebruik van arrays te tonen)
if [ "${#errors[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${errors[@]}"; do
        echo "$fout"
    done
    exit 2
fi