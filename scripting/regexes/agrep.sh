#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DICT="/usr/share/dict/words"

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") <woord>

Zoekt <woord> exact in $DICT.  
– Als het woord er staat: toont “FOUND:” + het woord.  
– Anders: toont “Did you mean:” + alle woorden met maximaal 1 afwijking (met agrep -1).
EOF
  exit 1
}

# 1) Input validatie
[[ $# -eq 1 ]] || usage
woord="$1"

# 2) Check of dict & agrep beschikbaar zijn
if [[ ! -f "$DICT" ]]; then
  echo "Fout: woordenboek $DICT niet gevonden." >&2
  exit 1
fi
if ! command -v agrep >/dev/null; then
  echo "Fout: agrep niet geïnstalleerd." >&2
  exit 1
fi

# 3) Exact match?
if grep -Fxq -- "$woord" "$DICT"; then
  echo "FOUND:"
  echo "$woord"
else
  echo "Did you mean:"
  # -1 = max. 1 edit (invoeging/verwijdering/substitutie), toont ook kortere/langer
  agrep -1 -- "$woord" "$DICT"
fi

exit 0