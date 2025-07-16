#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

searchdir="/proc/*/cmdline"

for bestand in $searchdir
do
    if [ ! -f "$bestand" ]; then
        echo "Bestand $bestand bestaat niet (meer)." >&2
        continue
    fi

    if [ ! -s "$bestand" ]; then
        echo "Bestand $bestand is leeg." >&2
        continue
    fi

     if tr '\0' ' ' < "$bestand" | grep -q "sbin"; then
        echo -n "$bestand: "
        tr '\0' ' ' < "$bestand"
    fi
done