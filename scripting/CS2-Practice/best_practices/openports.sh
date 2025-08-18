#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

if [ "$(id -u)" != "0" ]; then
    echo "Fout: script moet als root worden uitgevoerd!" >&2
    exit 1
fi

if ! command -v nc >/dev/null; then
    echo "Fout: netcat (nc) is niet geïnstalleerd. Installeer via: sudo apt-get install netcat" >&2
    exit 1
fi

#starten met een kleine luisterende poort
nc -l 13 &

errorlog="/var/log/error_$(basename $0).log"

for poort in $(seq 1 100)
do
    resultaat=$(lsof -nPi tcp:$poort 2>>"$errorlog" | grep -i LISTEN)

    if [ -n "$resultaat" ]; then
        echo "Poort $poort is in gebruik door:"
        echo "$resultaat"
        echo "------------------------"
    fi
done
exit 0