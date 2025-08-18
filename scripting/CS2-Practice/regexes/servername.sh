#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Configuratiebestand
CONF='/etc/apache2/apache2.conf'

usage() {
  cat <<-EOF >&2
Usage: $(basename "$0") <ServerName>

Controleert of in $CONF al een ServerName staat.  
Bestaat deze al, dan wordt de bestaande regel getoond.  
Anders wordt 'ServerName <ServerName>' toegevoegd aan het einde.
EOF
  exit 1
}

# 1) Argument- en bestandscheck
[[ $# -eq 1 ]] || usage
servername="$1"

if [[ ! -f "$CONF" ]]; then
  echo "Fout: configbestand '$CONF' niet gevonden." >&2
  exit 1
fi

# 2) Bestaande ServerName zoeken (regex: begin van regel, opt. spaties, 'ServerName' gevolgd door woordgrens)
if grep -qE '^[[:space:]]*ServerName[[:space:]]+\S+' "$CONF"; then
  echo "⚙️  ServerName is al ingesteld in $CONF:"
  grep -E '^[[:space:]]*ServerName[[:space:]]+\S+' "$CONF"
  exit 0
fi

# 3) Toevoegen als het nog niet bestaat
echo "➕ Voeg 'ServerName $servername' toe aan $CONF"
{
  echo ""
  echo "# Toegevoegd door $(basename "$0") op $(date +'%Y-%m-%d %H:%M:%S')"
  echo "ServerName $servername"
} | sudo tee -a "$CONF" >/dev/null

echo "✅ ServerName $servername toegevoegd."
exit 0