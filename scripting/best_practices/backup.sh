#!/bin/bash

# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1
# Datum: 2025-07-16

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Backupt alle recent gewijzigde .sh-bestanden in een opgegeven directory."
    echo "Voorbeeld: $(basename $0)  "
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

#checken of script als root is opgestart
if [ "$(id -u)" != "0" ]; then
    echo "Opstarten als root gebruiker: bv. sudo ./$(basename $0)" >&2
    exit 1
fi

#STDERR meldingen wegschrijven 
errorlog="/var/log/error_$(basename $0).log"

#alle meldingen van STDOUT voor geen errormeldingen
backuplog="/var/log/backup_$(basename $0).log"

directory=${1:-/home}

if [ ! -d "$directory" ]; then
    echo "Opstarten met een directory als eerste argument: bv. sudo ./$(basename $0) /home" >&2
    exit 1
fi

timestamp=$(date +%Y_%m_%d_%H_%M_%S)
backupfile="Backup_${timestamp}.tar.gz"

#sh files zoeken en de errors wegschrijven in file
sh_files=$(find "$directory" -type f -name "*.sh" -mtime -1 2>>"$errorlog")

if [ -n "$sh_files" ]; then
    tar -czvf "$backupfile" $sh_files 1>>"$backuplog" 2>>"$errorlog"
fi