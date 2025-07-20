# Oefening 5: HTTP-status checker met functies en exit codes
# Opdracht:
#   - Neem URL als argument en valideer met regex.
#   - Controleer bereikbaarheid met curl --head.
#   - Gebruik functie check_url die status ophaalt en >=400 als fout markeert.
#   - Return 0 bij OK, anders 2, stdout voor log, stderr voor fouten.