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
