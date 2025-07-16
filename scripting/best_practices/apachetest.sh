#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [url]"
    echo "Geeft een benchmark van een apache webserver."
    exit 0
fi

error_geen_ab="Fout in $0: het programma 'ab' is niet geïnstalleerd."
error_url="de url is niet bereikbaar"

command -v ab >/dev/null || { echo "$error_geen_ab" >&2; exit 1; }

#gebruik een standaard URL als er geen wordt meegegeven
url=${1:-"http://127.0.0.1/"}

curl -o /dev/null --silent --head --connect-timeout 2 ${url}
if [ $? -ne 0 ]; then
    echo "$error_url" >&2
    exit 2
fi

#benchmark uitvoeren
ab -n 100 -kc 10 "$url"