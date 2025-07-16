#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Backupt alle recent gewijzigde .sh-bestanden in een opgegeven directory."
    echo "Voorbeeld: $(basename $0)  "
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

if ! command -v ab >/dev/null; then
    echo "Het programma 'ab' is niet geïnstalleerd."
    read -p "Wens je apache2-utils te installeren? (y/n): " uservalidation

    if [ "$uservalidation" = "n" ]; then
        echo "Fout: ab is nodig om deze script uit te kunnen voeren!" >&2
        exit 1
    else
        apt-get update && apt-get install -y apache2-utils

        if [ $? -ne 0 ]; then
            echo "Fout: Installatie van apache2-utils mislukt." >&2
            exit 3
        fi
    fi
fi

url=${1:-"http://127.0.0.1/"}

if ! command -v curl >/dev/null; then
    echo "Fout: curl is niet geïnstalleerd. Installeer met: sudo apt-get install curl" >&2
    exit 2
fi

curl -o /dev/null --silent --head --connect-timeout 2 "$url"
if [ $? -ne 0 ]; then
    echo "Fout: De URL $url is niet bereikbaar." >&2
    exit 2
fi

ab -n 100 -kc 10 "$url"