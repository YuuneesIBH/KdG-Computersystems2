# Oefening 6: Interactieve menu met case en ANSI-kleuren
# Opdracht:
#   - Toon een gekleurd menu (ANSI-escape codes).
#   - Lees keuze via read en gebruik case 1–3 en 0 om af te sluiten.
#   - Loop tot keuze 0.

#!/bin/bash
# Functie: Toont een interactief menu met kleuren en voert acties uit
# Auteur: younes.elazzouzi@student.kdg.be
# Versie: 0.1

version="0.1"

if [ "$1" = "--help" ]; then
    echo "Usage: $(basename $0) [--help | --version]"
    echo "Geeft de HTTP-status terug van een opgegeven URL."
    exit 0
fi

if [ "$1" = "--version" ]; then
    echo "$(basename $0) versie: $version"
    exit 0
fi

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

toon_menu() {
    kleur_output "1;34" "=============================="
    kleur_output "1;33" "  Interactief Menu (Kies 0–4) "
    kleur_output "1;34" "=============================="
    kleur_output "1;32" "1) Toon datum"
    kleur_output "1;36" "2) Toon huidige gebruikers"
    kleur_output "1;35" "3) Toon huidige map"
    kleur_output "1;33" "4) Toon alle ANSI kleurcombinaties"
    kleur_output "1;31" "0) Afsluiten"
    echo -n "Maak je keuze: "
}

while true; do
    toon_menu
    read keuze

    if ! [[ "$keuze" =~ ^[0-4]$ ]]; then
        log_error "Gelieve een keuze tussen 0 en 4 in te geven."
        echo ""
        continue
    fi

    case $keuze in
        1)
            kleur_output "1;32" "Datum: $(date)"
            ;;
        2)
            kleur_output "1;36" "Gebruikers: $(who)"
            ;;
        3)
            kleur_output "1;35" "Huidige directory: $(pwd)"
            ;;
        4)
            echo "Voorgrond (tekstkleur) vs Achtergrond"
            for fg in {30..37} {90..97}; do
                for bg in {40..47} {100..107}; do
                    echo -ne "\033[${fg};${bg}m ${fg};${bg} \033[0m "
                done
                echo
            done
            ;;
        0)
            kleur_output "1;31" "Tot ziens!"
            if [ ${#errors[@]} -gt 0 ]; then
                kleur_output "1;33" "Er werden fouten geregistreerd:"
                for err in "${errors[@]}"; do
                    kleur_output "1;31" "- $err"
                done
            fi
            exit 0
            ;;
    esac
    echo ""
done