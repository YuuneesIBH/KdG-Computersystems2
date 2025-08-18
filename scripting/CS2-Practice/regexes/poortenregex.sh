#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

echo "TCP poorten:"

# Lees de output van netstat, regel voor regel
while read -r proto recvq sendq local_addr remote_addr state _; do
  # Filter: alleen TCP(6) en LISTEN
  if [[ $proto == tcp* && $state == LISTEN ]]; then
    # Regex: alles vóór de laatste ':' negeren, vang de poort in groep 1
    if [[ $local_addr =~ :([0-9]+)$ ]]; then
      echo "${BASH_REMATCH[1]}"
    fi
  fi
done < <(netstat -tulpn 2>/dev/null)

exit 0