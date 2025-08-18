#!/bin/bash
# array-pw-simpel.sh: lees naam en UID, sla op in een assoc array, en toon alfabetisch

declare -A pwmap

# 1) Inlezen in een assoc array (naam → uid)
while IFS=: read -r name _ uid _; do
  pwmap["$name"]=$uid
done < /etc/passwd

# 2) Sorteren en tonen
# - printf geeft alle keys één per regel
# - sort zet ze alfabetisch
# - in de loop echoën we naam = uid
for user in $(printf '%s\n' "${!pwmap[@]}" | sort); do
  echo "$user = ${pwmap[$user]}"
done