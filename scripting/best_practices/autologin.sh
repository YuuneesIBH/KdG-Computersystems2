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

if [ "$(id -u)" != "0" ]; then
    echo "Fout: script moet als root worden uitgevoerd!" >&2
    exit 1
fi

#3 argumenten worden er verwacht 
if [ $# -ne 3 ]; then
    echo "Usage: ./autologin.sh hostname username password" >&2
    exit 1
fi

host=$1
username=$2
password=$3

if ! command -v ssh >/dev/null; then
    echo "Fout: ssh is niet geïnstalleerd. Installeer via: sudo apt-get install openssh-client" >&2
    exit 1
fi

if ! command -v nc >/dev/null; then
    echo "Fout: netcat is niet geïnstalleerd. Installeer via: sudo apt-get install netcat" >&2
    exit 1
fi

sudo service ssh restart

if ! nc -w 1 $host 22 >/dev/null 2>/dev/null; then
    echo "Fout: ssh-service reageert niet op $host poort 22." >&2
    exit 1
fi

#expect script aanmaken 
echo "Expect script wordt gegenereerd..."
cat > ./expect.sh << EOF
#!/usr/bin/expect -f
set timeout 20
set username "$username"
set paswoord "$password"
spawn ssh -o "StrictHostKeyChecking no" \$username@$host
expect "*assword:*"
send \$paswoord\r
interact
exit
EOF

chmod +x ./expect.sh

echo "Verbinding maken met $host als gebruiker $username..."
./expect.sh