#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Toon header
echo "TCP poorten:"

# Lees netstat-output in een bash-loop (geen grep/awk/cut)
while read -r proto recvq sendq local_addr remote_addr state _; do
    # Alleen tcp (incl. tcp6) en staat LISTEN
    if [[ $proto == tcp* && $state == LISTEN ]]; then
        # Haal alles na de laatste ':' → de poort
        echo "${local_addr##*:}"
    fi
done < <(netstat -tulpn 2>/dev/null)

exit 0