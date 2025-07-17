#!/bin/bash
# array-punten.sh: leest studentnamen en scores in, toont gemiddelde (1 decimaal),
# en wie de hoogste en laagste score behaalde.

# ---------------------------------------------------
# Declaratie van lege arrays (bash arrays, hoofdstuk "Bash Arrays")
# ---------------------------------------------------
declare -a namen
declare -a scores

# ---------------------------------------------------
# 1) Input lus: vraag naam en score
# ---------------------------------------------------
while true; do
  # lees naam (STDIN = kanaal 0)
  read -p "Naam student (x om te stoppen): " naam

  # c) stop als naam 'x'
  [[ "$naam" == "x" ]] && break

  # a) naam mag niet leeg zijn
  if [[ -z "$naam" ]]; then
    echo "Naam mag niet leeg zijn." >&2      # >&2 → bericht naar STDERR (kanaal 2)
    continue
  fi

  # b) vraag score ­(0–20) en valideren
  while true; do
    read -p "Score voor $naam (0-20): " score
    # numeriek met optional komma, en tussen 0 en 20
    if [[ "$score" =~ ^[0-9]+([.][0-9]+)?$ ]] \
       && (( $(echo "$score >= 0" | bc -l) )) \
       && (( $(echo "$score <= 20" | bc -l) )); then
      break
    else
      echo "Score moet een getal tussen 0 en 20 zijn." >&2
    fi
  done

  # voeg toe aan de arrays
  namen+=("$naam")
  scores+=("$score")
done

# ---------------------------------------------------
# 2) Berekeningen
# ---------------------------------------------------
# controle: minstens 1 invoer
count=${#scores[@]}
if (( count == 0 )); then
  echo "Geen studenten ingevoerd." >&2
  exit 1
fi

# bereken som
sum=0
for s in "${scores[@]}"; do
  sum=$(echo "$sum + $s" | bc -l)
done

# gemiddelde met 1 decimaal (scale=1)
avg=$(echo "scale=1; $sum / $count" | bc -l)

# zoek hoogste en laagste score
max=${scores[0]}; min=${scores[0]}
idx_max=0; idx_min=0

for i in "${!scores[@]}"; do
  s=${scores[i]}
  if (( $(echo "$s > $max" | bc -l) )); then
    max=$s; idx_max=$i
  fi
  if (( $(echo "$s < $min" | bc -l) )); then
    min=$s; idx_min=$i
  fi
done

# ---------------------------------------------------
# 3) Output resultaten
# ---------------------------------------------------
echo "Gemiddelde score: $avg"
echo "Hoogste score: ${namen[idx_max]} ($max)"
echo "Laagste score: ${namen[idx_min]} ($min)"