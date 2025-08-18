#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.2
# Datum: 2025-07-17

# Functie die aftelt vanaf de meegegeven startwaarde
countdown() {
  local count=$1
  while [ "$count" -ge 0 ]; do
    echo -ne "\r$count"
    count=$((count - 1))
    sleep 1
  done
  echo    # newline na afloop
}

# --- hoofdscript ---
start=60
countdown "$start"