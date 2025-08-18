#!/usr/bin/env bash

bestand="users.csv"

# Maak het bestand aan
echo "jcelis,Jan Celis" > "$bestand"
echo "pboedt,Piet Boedt" >> "$bestand"

# Zet IFS alleen op newline (geen spaties of tabs!)
IFS=$'\n'

# Loop over elke regel in het bestand
for lijn in $(cat "$bestand"); do
  echo "$lijn"
done

# Zet IFS terug naar de standaardwaarde
unset IFS