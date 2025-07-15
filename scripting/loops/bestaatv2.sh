#!/bin/bash

# Auteur: younes.elazzouzi0student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

bestand="/bin/df"

if [ ! -e "$bestand" ]; then
    echo "Bestand $bestand bestaat NIET!"
    exit 1
fi

#checken of leesbaar en uitvoerbaar
if [ ! -r "$bestand" ] && [ ! -x "$bestand" ]; then
    echo "Bestand $bestand is NIET leesbaar en/of uitvoerbaar!" 
    exit 2
fi

#alles ok? --> uitvoeren met -h
"$bestand" -h
exit 0