#!/usr/bin/env bash
#
# tijdsmeting.sh – meet de uitvoeringstijd van een commando
#
# Usage:
#   tijdsmeting.sh [-h|--help] <commando> [args...]
#
# Exit codes:
#   0 Succes
#   1 Onjuist gebruik

set -euo pipefail

print_help() {
  cat <<EOF
Usage: $(basename "$0") [-h|--help] <commando> [args...]

Meet de duur van <commando> in nano-, milli- en seconden.

Options:
  -h, --help    Toon deze help en stop.
EOF
}

# — Argumenten parsen —
if [[ $# -eq 0 ]]; then
  echo "Fout: geen commando opgegeven." >&2
  print_help >&2
  exit 1
fi

case "$1" in
  -h|--help)
    print_help
    exit 0
    ;;
esac

# Verzamelen van commando + args
cmd=( "$@" )

# Functie die het commando runt en de duur meet
measure() {
  local start end duur
  start=$(date +%s%N)

  # Uitvoeren van het meegegeven commando
  "${cmd[@]}"

  end=$(date +%s%N)
  duur=$(( end - start ))

  echo "Tijd in nanoseconden:   ${duur}"
  echo "Tijd in milliseconden:  $(( duur / 1000000 ))"
  echo "Tijd in seconden:       $(( duur / 1000000000 ))"
}

# — Main —
measure