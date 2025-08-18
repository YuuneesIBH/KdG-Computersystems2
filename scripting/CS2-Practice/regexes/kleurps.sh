#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Zet extglob aan voor geavanceerde globs in parameter substitution
shopt -q -s extglob

# ANSI-kleurcodes
readonly RED='\e[31m'
readonly BLUE='\e[34m'
readonly RESET='\e[0m'

# Header (optioneel)
echo -e "${RED}PID${RESET} ${BLUE}COMMAND${RESET}"

# Loop over elke regel uit ps (zonder header), veilig op regels gesplitst
for line in $(ps -eo pid,args --no-headers); do
  # PID = alles vóór de eerste opeenvolging van spaties
  pid=${line%%+([[:space:]])*}
  # CMD = alles ná die spaties
  cmd=${line#${pid}+([[:space:]])}

  # Print met kleur
  echo -e "${RED}${pid}${RESET} ${BLUE}${cmd}${RESET}"
done

# Schakel extglob weer uit
shopt -q -u extglob