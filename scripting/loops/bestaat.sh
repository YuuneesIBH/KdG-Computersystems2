#!/bin/bash

# Functie: Controleert of /bin/df uitvoerbaar is, en voert het uit met -h
# Auteur: younes.elazzouzi0student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

bestand="/bin/df"

if [ -x "$bestand" ]; then 
    $bestand -h
    exit 0
else
    echo "Het bestand $bestand is NIET gevonden!"
    exit
fi