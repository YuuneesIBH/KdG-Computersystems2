#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Vraag het wachtwoord (geen echo)
read -rsp "Voer paswoord in: " pw
echo

# 1) Minimale lengte check
if (( ${#pw} < 8 )); then
    echo "Paswoord ongeldig"
    exit 0
fi

# 2) Regex: ^[A-Z] → hoofdletter aan begin; .* → willekeurige tekens; [0-9]{2}$ → twee cijfers op einde
if [[ $pw =~ ^[A-Z].*[0-9]{2}$ ]]; then
    echo "Paswoord geldig"
else
    echo "Paswoord ongeldig"
fi