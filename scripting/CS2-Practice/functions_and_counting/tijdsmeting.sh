#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-17

# begin­tijd in nanoseconden
start=$(date +%s%N)

# toon een zenity-waarschuwing met de huidige date
zenity --warning --title "Hallo" --text "`date`"

# eind­tijd in nanoseconden
end=$(date +%s%N)

# bereken duur
duur=$((end - start))

# toon resultaat
echo "Tijd in nanoseconden:  $duur"
echo "Tijd in milliseconden: $((duur / 1000000))"
echo "Tijd in seconden:      $((duur / 1000000000))"