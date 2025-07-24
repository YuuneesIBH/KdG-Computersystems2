# Oefening 3: Backup-script met loops en arrays
# Opdracht:
#   - Neem een lijst directories als argumenten.
#   - Valideer elke directory.
#   - Maak per directory tar-archief in /backup met datumstamp.
#   - Gebruik een array voor fouten.
#   - Loop en verwijder archieven ouder dan 7 dagen.
#   - Return 0 bij succes, anders 1.

#!/bin/bash
# Functie: Maakt per opgegeven directory een tar-backup in /backup
# In een bepaalde directory
# Arguments: Directorynamen als argumenten
# Auteur: jan.celis@kdg.be
# Copyright: 2024 GNU v3 jan.celis@kdg.be
# Versie: 0.1
# Requires: Standaard shell find commando

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Maakt per opgegeven directory een tar-backup in /backup met datumstempel."
    echo "Voorbeeld: $(basename $0)  "
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

#checken of een dir is /backup
backup_dir="/backup"
if [ ! -d "$backup_dir" ]; then
    echo "Backup directory $backup_dir bestaat niet. Maak deze aan."
    mkdir -p "$backup_dir" || {
        echo "Fout in $0: kon $backup_dir niet aanmaken." >&2
        exit 1
    }
fi

#controle of er argumenten zijn meegegeven
if [ "$#" -eq 0 ]; then
    echo "Gebruik: $(basename "$0") <directory1> <directory2> ..." >&2
    exit 1
fi

#fouten bijhouden in een array
declare -a fouten

datum=$(date +%Y%m%d)
for dir in "$@"; do
    if [ -d "$dir" ]; then
        base=$(basename "$dir")
        archief="$backup_dir/${base}_$datum.tar.gz"

        tar -czf "$archief" "$dir" || {
            fouten+=("$dir")
            echo "FOUT: backup mislukt voor $dir" >&2
        }     
    else 
        fouten+=("$dir")
        echo "FOUT: $dir is geen geldige directory" >&2 #STDERR melding 
    fi
done

#verwijderen van archieven ouder dan 7 dagen 
find "$backup_dir" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;

#resultaten tonen aan de gebruiker

if [ "${#fouten[@]}" -eq 0 ]; then
    echo "Alle backups zijn succesvol voltooid."
    exit 0
else 
    echo "Sommige backups zijn mislukt!"
    for fout in "${fouten[@]}"; do
        echo "- $fout" >&2
    done
    exit 1
fi