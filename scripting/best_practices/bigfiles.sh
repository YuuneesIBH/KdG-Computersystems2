#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

scriptversie="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Zoekt grote bestanden."
    echo "Voorbeeld: $(basename $0)  "
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $scriptversie"
    exit 0
fi

# default values als geen argumenten meegegeven
pad=${1:-"/"}
size=${2:-10}

find "$pad" -type f -size "+${size}M" -exec stat -c '%s %n' {} \;