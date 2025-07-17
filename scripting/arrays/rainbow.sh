#!/bin/bash
# array-colour.sh: maak een array met random ANSI-kleurcodes [41–46],
# geef ‘m door aan functie show die een RxC-matrix tekent met
# voor- én achtergrondkleur, en ververs op toetsdruk.

# --- 0) Vraag afmetingen (deel d) ----------------------------
read -p "Aantal rijen: " rows
read -p "Aantal kolommen: " cols

# check
if (( rows<1 || cols<1 )); then
  echo "Rijen en kolommen moeten ≥ 1 zijn." >&2
  exit 1
fi

# totale grootte
total=$(( rows * cols ))

# --- 1) Array vullen met random achtergrondcodes (deel a) -----
declare -a colours
for ((i=0; i<total; i++)); do
  # random waarde 41–46
  colours[i]=$(( 41 + RANDOM % 6 ))
done

# --- 2) Functie show: tekent de matrix (deel b) -------------
# verwacht: naam van array, aantal rijen, aantal kolommen
show() {
  local -n arr=$1
  local R=$2 C=$3

  for ((r=0; r<R; r++)); do
    for ((c=0; c<C; c++)); do
      idx=$(( r*C + c ))
      bg=${arr[idx]}
      fg=$(( bg - 10 ))             # 31–36
      # 1 = bold, fg en bg; twee spaties als cel
      printf "\e[1;%d;%dm  \e[0m" "$fg" "$bg"
    done
    printf "\n"
  done
}

# --- 3) Toon en ververs bij toetsdruk (deel c) ------------
while true; do
  clear
  show colours "$rows" "$cols"
  read -n1 -r -p $'\nDruk op toets om nieuwe kleuren te tonen (q = quit)… ' key
  [[ $key == q ]] && { echo; exit 0; }
  # bij elke nieuwe iteratie moet de array opnieuw gevuld worden:
  for ((i=0; i<total; i++)); do
    colours[i]=$(( 41 + RANDOM % 6 ))
  done
done