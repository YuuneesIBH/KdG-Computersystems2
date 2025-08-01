


# OEFENING: HTTP 404 Analyse via Bash Regex
# -----------------------------------------
# Gebruik een logfile access.log met regels in standaard Apache-indeling zoals:
#   192.168.1.10 - - [01/Aug/2025:13:00:00 +0200] "GET /index.html HTTP/1.1" 200 1234
#   10.0.0.5 - - [01/Aug/2025:13:02:01 +0200] "GET /contact.html HTTP/1.1" 404 321
#
# Doel:
# - Gebruik een regex met [[ $lijn =~ ... ]] om:
#   o Het pad (bijv. /contact.html) te extraheren
#   o De HTTP-statuscode te extraheren (bijv. 404)
# - Enkel regels met statuscode 404 worden verwerkt.
#
# Opdracht:
# 1. Lees het bestand access.log regel per regel in.
# 2. Gebruik een Bash regex om uit elke lijn het pad (na GET/POST) en statuscode te halen.
# 3. Sla voor elke 404-regel het pad op in een array (of tellende hash/map).
# 4. Als het pad al voorkomt, verhoog je de teller (je telt dus hoeveel keer elk pad 404 gaf).
# 5. Wegschrijven:
#    - Schrijf de resultaten naar het bestand "$0.tmp" in dit formaat:
#        /contact.html    2
#        /notfound        5
#        /login           1
#    - Gebruik een TAB als scheiding.
# 6. Sorteer het bestand zodat paden met de meeste fouten bovenaan staan.
# 7. Toon als output:
#      Dit is het script van JouwVoornaam JouwAchternaam.
#      PAD <tab> AANTAL
#      /notfound	5
#      /contact.html	2
#      ...
# 8. Toon alleen de top 5 foutpagina’s.
# 9. Toon onderaan:
#      TOTAAL AANTAL 404-REQUESTS: 123
# 10. Verwijder op het einde $0.tmp

# Noot: Gebruik associative arrays voor tellen mag, zolang je regex + BASH_REMATCH gebruikt.
# Noot 2: Gebruik geen externe tools voor de extractie. Enkel Bash regex.
# Noot 3: Gebruik printf of echo -e voor nette TAB-uitlijning als je wil.

# Voorbeeld correcte uitvoer Script:
# Dit is het script van Younes El Azzouzi.
# PAD	AANTAL
# /secret	8
# /contact.html	5
# /login	3
# /about	2
# /admin	1
# 
# TOTAAL AANTAL 404-REQUESTS: 19

