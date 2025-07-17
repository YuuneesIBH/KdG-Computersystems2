#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-17

# Eenvoudig script om een IP of domein op een Mercator-kaart te zetten.

if [ $# -ne 1 ]; then
  echo "Gebruik: $0 <ip_of_domein>" >&2
  exit 1
fi

# Parameters
input="$1"
db="/usr/share/GeoIP/GeoLiteCity.dat"
map="geolocate.jpg"
out="geolocatenew.jpg"
mapWidth=2058
mapHeight=1746

# 1) latitude en longitude ophalen
line=$(geoiplookup -f "$db" "$input" | cut -d: -f2)
# gebruik NF-3 en NF-2 omdat de laatste velden resp. latitude en longitude zijn
read lat lon < <(echo "$line" | awk -F, '{ print $(NF-3) , $(NF-2) }')

# 2) Mercator-projectie berekenen met bc
pi=$(echo "scale=10; 4*a(1)" | bc -l)
latRad=$(echo "scale=10; $lat * $pi / 180" | bc -l)
sum=$(echo "scale=10; $pi/4 + $latRad/2" | bc -l)
mercN=$(echo "scale=10; l( s($sum) / c($sum) )" | bc -l)

x=$(echo "scale=2; ($lon + 180) * ($mapWidth / 360)" | bc -l)
y=$(echo "scale=2; $mapHeight/2 - ($mapWidth * $mercN) / (2 * $pi)" | bc -l)
ycircle=$(echo "scale=2; $y + 10" | bc -l)

# 3) Marker tekenen met ImageMagick
convert -page ${mapWidth}x${mapHeight} "$map" \
  -fill red -draw "circle ${x},${y} ${x},${ycircle}" \
  -layers flatten "$out"

echo "Nieuw kaartje met marker: $out"