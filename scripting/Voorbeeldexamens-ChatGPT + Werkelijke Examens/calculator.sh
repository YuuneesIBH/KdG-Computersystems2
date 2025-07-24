# Oefening 9: Data-transformatie met pipes en bc
# Opdracht:
#   - Lees een bestand met getallen (1 kolom).
#   - Bereken count, sum, gemiddelde en met wc, awk, bc.
#   - Redirect berekeningen netjes met pipes.

#!/bin/bash

#Functie: statistieken berekenen uit getallen.txt
#Author: younes
#versie: 0.1

file="getallen.txt"
version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Maakt berekeningen met de file."
    echo "Voorbeeld: $(basename $0)  "
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#controle op vereiste commando's 
for cmd in bc awk wc; do
    command -v $cmd >/dev/null || {
        echo "FOUT: vereist commando '$cmd' ontbreekt!" >&2
        exit 1
    }
done

#controle of het bestand bestaat en niet leeg is
if [ ! -s "$file" ]; then
    echo "Het bestand $file bestaat niet of is leeg!" >&2
    exit 1
fi

#tellen hoeveel lijnen
count=$(wc -l < "$file")

#som berekenen
sum=$(awk '{t+=$1} END {print t}' "$file")

#gemiddelde berekenen met bc
avg=$(echo "scale=2; $sum / $count" | bc )

echo "Aantal getallen: $count"
echo "Som van de getallen: $sum"
echo "Gemiddelde van de getallen: $avg"

exit 0