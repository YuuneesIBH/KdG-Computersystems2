#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") <hostname>

Voert \`nslookup\` uit op <hostname> en geeft alleen de "Name:"-regel
terug via een regex‐groep.
EOF
  exit 1
}

[[ $# -eq 1 ]] || usage
host="$1"

# Doe de lookup
if ! output=$(nslookup "$host" 2>/dev/null); then
  echo "Fout: nslookup mislukt voor '$host'." >&2
  exit 1
fi

# Parse alleen de Name:-regel
while IFS= read -r line; do
  if [[ $line =~ ^Name:[[:space:]]+(.+)$ ]]; then
    echo "Name: ${BASH_REMATCH[1]}"
    exit 0
  fi
done <<<"$output"

echo "Geen 'Name:'-regel gevonden in nslookup‐output." >&2
exit 1