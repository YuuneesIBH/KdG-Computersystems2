#Oefening EXAMEN: Lijn-per-lijn berekening op verschillende CPU's met bc
# Opdracht:
#   - Het script krijgt als argument een bestaande, niet-lege inputfile.
#   - Het script mag NIET als root worden uitgevoerd (foutmelding en exit 1).
#   - Check of het commando “bc” beschikbaar is; anders toon foutmelding en stop.
#   - Gebruik een functie “maxcpu” om het aantal unieke processoren op te halen via:
#         ps xo cpuid,cmd
#     en toon het totaal aantal beschikbare CPU’s.
#   - Lees de inputfile lijn per lijn in.
#   - Elke lijn bevat een berekening tussen aanhalingstekens die direct naar `bc -l` gestuurd kan worden.
#   - Gebruik `taskset --cpu-list N` om elke berekening op een andere processor uit te voeren.
#     Voorbeeld: `taskset --cpu-list 3 sh -c "echo 'l(10)' | bc -l"`
#   - Begin met CPU 0, dan CPU 1, … en herhaal indien nodig in ronde.
#   - Toon telkens het taskset-commando dat je gaat uitvoeren.
#   - Toon het resultaat van de berekening.
#   - Zet het gebruikte CPU-nummer in **groen** (kleurcode `\033[1;32m`).
#   - Volg de best practices:
#         - Gebruik van shebang `#!/bin/bash`
#         - Versie en help ondersteunen
#         - Commentaar
#         - Exitcodes (0 bij OK, 1 bij fouten)
#         - Inputvalidatie

#!/bin/bash

#Functie: awk leren en dingen tonen
#Author: younes
#versie: 0.1

starttijd=$(date +%s)

#functie om in kleur te tonen
kleur_output() {
    local kleurcode=$1
    local tekst=$2
    echo -e "\033[${kleurcode}m${tekst}\033[0m"
}

declare -a errors

#functie om errors te adden aan array
log_error() {
    local fout="$1"
    errors+=("$fout")
    kleur_output "1;31" "$fout" >&2
}

version="0.1"

#help tonen if needed OR als er geen arguments worden gegeven!
if [ "$1" = "--help" ] || [ "$#" -ne 1 ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Voert per lijn een bc-berekening uit op een aparte CPU met taskset."
    echo "Voorbeeld: $(basename $0)"
    exit 0
fi

#version tonen if needed
if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

input="$1"

#control of het bestand bestaat anders exit 1
if [ ! -s "$input" ]; then
    log_error "Het bestand bestaat NIET!"
    exit 1
fi

#script mag NIET als root uitgevoerd worden
if [[ "$(id -u)" -eq 0 ]]; then
    log_error "Je mag het script NIET als root uitvoeren!"
    exit 1
fi

#controle of bc beschikbaar is
command -v bc >/dev/null || (log_error "bc is niet beschikbaar!" && exit 1)

max_cpu() {
    ps xo cpuid,cmd | awk 'NR>1 {print $1}' | sort -n | uniq | wc -l
}


total_cpus=$(max_cpu)
echo "Aantal beschikbare CPU's: $total_cpus"

cpu=0

IFS=$'\n'

while IFS= read -r lijn; do
    kleur_output "1;32" ">> CPU $cpu uitvoeren: taskset --cpu-list $cpu sh -c \"echo '$lijn' | bc -l\""
    taskset --cpu-list "$cpu" sh -c "echo '$lijn' | bc -l"

    ((cpu = (cpu + 1) % total_cpus))
done < "$input"

#fouten tonen aan de user
if [ "${#errors[@]}" -gt 0 ]; then
    echo "--- Fouten ---"
    for fout in "${errors[@]}"; do
        echo "$fout"
    done
    exit 2
fi

endtijd=$(date +%s)
totaal=$((endtijd - starttijd))
echo "Script uitgevoerd in $totaal seconden."

exit 0