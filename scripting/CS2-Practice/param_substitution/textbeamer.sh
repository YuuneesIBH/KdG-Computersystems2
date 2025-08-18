#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") "<tekst>" <aantal>
  
  <tekst>    : de string waarop de beamer loopt (quotes verplicht bij spaties)
  <aantal>   : hoe vaak L→R + R→L uitgevoerd wordt (positief geheel)

Voorbeeld:
  ./textbeamer.sh "wacht even" 3
EOF
  exit 1
}

# 1) Input valideren
[[ $# -eq 2 ]] || usage
text="$1"
times="$2"

if ! [[ $times =~ ^[1-9][0-9]*$ ]]; then
  echo "Fout: aantal moet een positief geheel zijn." >&2
  exit 1
fi

len=${#text}

# 2) Cursor verbergen en bij exit weer terugzetten
tput civis
trap 'tput cnorm; echo; exit' EXIT

# 3) Toon initiële string
echo -ne "$text"

# 4) Beamer-functie
beamer_pass() {
  local dir="$1" i start end step prefix char suffix char_up disp

  if [[ $dir == forward ]]; then
    start=0; end=$((len-1)); step=1
  else
    start=$((len-1)); end=0; step=-1
  fi

  i=$start
  while :; do
    prefix="${text:0:i}"
    char="${text:i:1}"
    # Portable uppercase van één teken:
    char_up=$(printf '%s' "$char" | tr '[:lower:]' '[:upper:]')
    suffix="${text:$((i+1))}"
    disp="${prefix}${char_up}${suffix}"

    echo -ne "\r$disp"
    sleep 0.1

    # Terug naar origineel
    echo -ne "\r$text"
    sleep 0.1

    (( i == end )) && break
    i=$((i+step))
  done
}

# 5) Herhaal times keer: forward + backward
for ((r=0; r<times; r++)); do
  beamer_pass forward
  beamer_pass backward
done

# 6) Afsluiten: cursor terug en nieuwe regel
echo
tput cnorm