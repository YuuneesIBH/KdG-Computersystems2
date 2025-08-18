#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-17

if [ $# -ne 1 ]; then
  echo "Gebruik: $0 bestandsnaam" >&2
  exit 1
fi

bestand="$1"
count=0

IFS=$'\n'
for regel in $(cat "$bestand"); do
  count=$((count+1))
done
unset IFS

echo "$count $bestand"