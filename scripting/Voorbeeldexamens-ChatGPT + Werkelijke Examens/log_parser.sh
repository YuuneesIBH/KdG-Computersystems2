# Oefening 2: Log-parser met regex en pipes
# Opdracht:
#   - Lees een logfile via stdin of argument.
#   - Valideer dat het bestand bestaat en niet leeg is.
#   - Filter met grep -E alle error-regels (ERROR|WARN) en tel per type.
#   - Gebruik parameter substitution om .log naar .summary te wijzigen.
#   - Sla resultaten op in een associative array en formatteer output.
#   - Vraag via read door te gaan bij >100 errors.