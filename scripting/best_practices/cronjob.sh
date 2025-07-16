#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

version="0.1"
CRONDIR="/etc/cron.d"
CRONFILE="$CRONDIR/backupcron"

# a) Help-optie
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Usage: sudo ./$(basename $0) [ --remove ] command"
    echo "        --remove    Remove cron file"
    echo "        --help      Display this help message"
    exit 0
fi

# Versie
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

# a) Root check
if [ "$(id -u)" != "0" ]; then
    echo "Opstarten als root gebruiker: bv. sudo ./$(basename $0)" >&2
    exit 1
fi

# d) --remove: cronfile verwijderen
if [ "$1" = "--remove" ]; then
    if [ -f "$CRONFILE" ]; then
        rm "$CRONFILE"
        echo "Cronbestand $CRONFILE verwijderd."
        exit 0
    else
        echo "Fout: Cronbestand $CRONFILE bestaat niet." >&2
        exit 1
    fi
fi

# b) Moet een script mee krijgen
if [ $# -lt 1 ]; then
    echo "Fout: Geef een script mee als argument, bv. ./$(basename $0) /pad/naar/script.sh" >&2
    exit 1
fi

# c) Script moet bestaan én uitvoerbaar zijn
if [ ! -f "$1" ] || [ ! -x "$1" ]; then
    echo "Fout: Bestand '$1' bestaat niet of is niet uitvoerbaar (r+x vereist)." >&2
    exit 1
fi

# Cronjob toevoegen
echo "* * * * * root $1" > "$CRONFILE"
echo "Cronjob aangemaakt in $CRONFILE: voert '$1' elke minuut uit."
exit 0