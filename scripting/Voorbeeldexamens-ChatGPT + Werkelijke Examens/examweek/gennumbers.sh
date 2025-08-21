#!/bin/bash
# Functie: optellen van gegenereerde cijfers

# Genereer getallen en schrijf naar bestand
getallen=$(shuf -i 1-100 -n 5)
echo "Gegenereerde getallen: $getallen"

som=0
for g in $getallen; do
    som=$((som + g))   # optellen
done

echo "De som is: $som"