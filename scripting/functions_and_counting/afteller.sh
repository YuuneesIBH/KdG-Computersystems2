#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-17

count=60

while [ $count -ge 0 ]; do
    echo -ne "\r$count"
    # aftellen
    count=$((count-1))
    sleep 1
done