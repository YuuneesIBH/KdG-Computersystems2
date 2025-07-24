# Oefening 5: HTTP-status checker met functies en exit codes
# Opdracht:
#   - Neem URL als argument en valideer met regex.
#   - Controleer bereikbaarheid met curl --head.
#   - Gebruik functie check_url die status ophaalt en >=400 als fout markeert.
#   - Return 0 bij OK, anders 2, stdout voor log, stderr voor fouten.

#!/bin/bash
#Functie: kijken of een URL bereikbaar is
#Arguments: URL nodig
#Author: younes
#Versie: 0.1

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Geeft de HTTP-status terug van een opgegeven URL."
    echo "Voorbeeld: $(basename $0) https://www.kdg.be"
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#controle op root 
if [ "$(id -u)" -ne 0 ]; then
    echo "Dit script moet als root worden uitgevoerd." >&2
    exit 1
fi

#controle op argument
if [ $# -lt 1 ]; then    
    echo "FOUT: je hebt geen argument meegegeven!" >&2
    exit 1
fi

url="$1"
declare -a fout_urls=()

#url controle met standaard url regex
if [[ ! "$url" =~ ^https?://[a-zA-Z0-9._-]+(\.[a-zA-Z]{2,})+.*$ ]]; then
    echo "FOUT: voer een geldige URL in: $url is niet geldig!" >&2
    fout_urls+=("$url (ongeldige syntax)")
else
    #functie voor URL check
    check_url() {
        local status
        status=$(curl -sI -o /dev/null -w "%{http_code}" "$1")

        echo "Statuscode: $status"

        if [ "$status" -ge 400 ]; then
            echo "FOUT: URL geeft foutmelding (status $status)." >&2
            return 2
        fi

        return 0
    }

    #resultaat functie controleren en eventueel aan foutarray toevoegen
    if ! check_url "$url"; then
        fout_urls+=("$url (status fout)")
    fi
fi

#fouten tonen aan de user
if [ "${#fout_urls[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${fout_urls[@]}"; do
        echo "$fout"
    done
    exit 2
fi

exit 0