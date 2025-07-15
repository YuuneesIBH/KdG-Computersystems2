#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-15

#MacOS versie
adir="/usr/local/etc/httpd"
confs="$adir/httpd.conf $adir/extra/httpd-vhosts.conf"

#Ubuntu versie
#adir="/etc/apache2"
#confs="$adir/apache2.conf $adir/ports.conf"

if [ -z "$1" ]; then
    echo "Er werdt geen argument meegegeven!" >&2
    exit 1
fi

# -iHn i --> ignore case H --> show filename bij match n --> toon regelnummer in het bestand 
for bestand in $confs
do
    if [ -f "$bestand" ]; then  
        grep -iHn "$1" "$bestand"
    fi
done