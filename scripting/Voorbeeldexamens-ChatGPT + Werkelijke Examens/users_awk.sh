#Oefening 2: Gebruikersanalyse en archiveren
# Opdracht:
#   - Toon helptekst bij --help of foutief aantal argumenten (>1).
#   - Gebruik /etc/passwd als inputbestand.
#   - Lees het bestand regel per regel en haal met IFS of awk volgende velden op:
#       loginnaam, UID, shell.
#   - Toon elk resultaat in kleur per kolom: login = blauw, UID = geel, shell = groen.
#   - Sla de platte (niet-gekleurde) output op in een bestand genaamd:
#       passwd_analyse_YYYYMMDD_HHMMSS.log
#   - Maak een gzip-tar-archief van het logbestand: passwd_analyse_YYYYMMDD_HHMMSS.tar.gz
#   - Toon achteraf de namen van beide aangemaakte bestanden.
#   - Voorzie --version met versienummer.
#   - Voorzie best practices (shebang, foutcodes, commentaar, exit 0).


