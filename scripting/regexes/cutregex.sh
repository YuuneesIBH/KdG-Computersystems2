#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") -cN-M [bestand]

Emuleert 'cut -cN-M': knip karakters N tot M uit elke regel.
• Bij geen bestand: lees van STDIN.
• Met bestand als tweede argument: lees daaruit.

Voorbeeld:
  ./cutregex.sh -c5-7 /etc/passwd
  echo "abcdefg" | ./cutregex.sh -c2-4
EOF
  exit 1
}

# 1) Parameter parsing met regex-groepen
[[ $# -ge 1 ]] || usage
opt="$1"

if [[ $opt =~ ^-c([0-9]+)-([0-9]+)$ ]]; then
  start=${BASH_REMATCH[1]}
  end=${BASH_REMATCH[2]}
  shift
else
  echo "Fout: ongeldig interval; gebruik -cN-M" >&2
  usage
fi

# 2) Validatie interval
if (( start < 1 || end < start )); then
  echo "Ongeldige range: $start-$end" >&2
  exit 1
fi
# Bereken Bash-substring‐waarden (0-based)
offset=$(( start - 1 ))
length=$(( end - start + 1 ))

# 3) Functie die knipt uit STDIN
cut_chars() {
  local off="$1" len="$2" line
  while IFS= read -r line; do
    printf '%s\n' "${line:off:len}"
  done
}

# 4) Input behandelen
if [[ $# -ge 1 ]]; then
  infile="$1"
  [[ -f "$infile" ]] || { echo "Fout: bestand '$infile' bestaat niet." >&2; exit 1; }
  cut_chars "$offset" "$length" < "$infile"
else
  cut_chars "$offset" "$length"
fi

exit 0