#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

echo "Hieronder de  gewone gebruikers op het systeem:"

IFS=$'\n'

for lijn in $(cat /etc/passwd)
do
    username=$(echo "$lijn" | cut -d: -f1)
    uid=$(echo "$lijn" | cut -d: -f3)

    #eerst valideren of het een getal is
    if [ "$uid" -eq "$uid" ] 2>/dev/null; then
        if [ "$uid" -ge 1000 ]; then
            echo "$username"
        fi
    fi
done

unset IFS