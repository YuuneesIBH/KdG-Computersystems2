#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

paswoord="supersecret"

read -s -p "Password: " guess
echo

if [ "$guess" = "$paswoord" ]; then
    echo "Je bent ingelogd!"
    exit 0
else 
    echo "Verkeerde entry!" >&2
    exit 1
fi