#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") -cN-M [bestand]

Emuleert \`cut -cN-M\`.  
• Leest van STDIN als je géén bestand meegeeft.  
• Leest uit [bestand] als je het als tweede argument opgeeft.  
Voorbeeld:
  ./cut.sh -c5-7 /etc/passwd
  echo "abcdefg" | ./cut.sh -c2-4
EOF
  exit 1
}

# 1) Parameter & range parsen
[[ $# -ge 1 ]] || usage

opt="$1"
if [[ "$opt" =~ ^-c([0-9]+)-([0-9]+)$ ]]; then
  start="${BASH_REMATCH[1]}"
  end="${BASH_REMATCH[2]}"
  shift
else
  echo "Fout: geef een range op met -c, bv. -c5-7" >&2
  usage
fi

# Validatie
if (( start < 1 || end < start )); then
  echo "Ongeldige range: $start-$end" >&2
  exit 1
fi

# Bash substring is 0-gebaseerd
offset=$((start - 1))
length=$((end - start + 1))

# 2) Functie die van stdin knipt
cut_chars() {
  local off="$1" len="$2" line
  while IFS= read -r line; do
    # geeft lege regel als de lijn korter is dan off
    printf '%s\n' "${line:off:len}"
  done
}

# 3) Input afhandelen: bestand of STDIN
if [[ $# -ge 1 ]]; then
  infile="$1"
  if [[ ! -f "$infile" ]]; then
    echo "Fout: bestand '$infile' bestaat niet." >&2
    exit 1
  fi
  cut_chars "$offset" "$length" < "$infile"
else
  cut_chars "$offset" "$length"
fi

exit 0