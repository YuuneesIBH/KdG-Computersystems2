# Bash: Bestanden Uitlezen en Verwerken

## Basis Bestand Uitlezen

### Met `cat` en `while read`
```bash
# Regel voor regel lezen
while IFS= read -r line; do
    echo "Gelezen: $line"
done < "bestand.txt"

# Of met cat
cat "bestand.txt" | while read -r line; do
    echo "Regel: $line"
done
```

### Met `mapfile` (moderne methode)
```bash
# Alle regels in array laden
mapfile -t lines < "bestand.txt"
for line in "${lines[@]}"; do
    echo "$line"
done
```

## IFS (Internal Field Separator)

IFS bepaalt hoe bash tekst opsplitst in velden.

### Standaard IFS
```bash
# Standaard: spatie, tab, newline
echo $IFS  # (meestal leeg weergegeven)

# Tonen van IFS karakters
printf '%q\n' "$IFS"  # $' \t\n'
```

### IFS Aanpassen
```bash
# Voor CSV bestanden (komma gescheiden)
IFS=',' read -r naam leeftijd stad <<< "Jan,25,Amsterdam"
echo "Naam: $naam, Leeftijd: $leeftijd, Stad: $stad"

# Voor colon-gescheiden bestanden (/etc/passwd)
IFS=':' read -r user x uid gid info home shell < /etc/passwd
```

### IFS Bewaren en Herstellen
```bash
# IFS opslaan
OLD_IFS="$IFS"

# IFS wijzigen
IFS=':'

# Je code hier...

# IFS herstellen
IFS="$OLD_IFS"
```

## AWK voor Tekstverwerking

### Basis AWK Syntaxis
```bash
# Kolom afdrukken
echo "jan 25 amsterdam" | awk '{print $1}'  # jan
echo "jan 25 amsterdam" | awk '{print $2}'  # 25
echo "jan 25 amsterdam" | awk '{print $NF}' # amsterdam (laatste kolom)
```

### AWK met Verschillende Scheidingstekens
```bash
# CSV bestand (komma als scheidingsteken)
echo "jan,25,amsterdam" | awk -F',' '{print $1}'

# Colon gescheiden (/etc/passwd)
awk -F':' '{print $1, $6}' /etc/passwd  # username en home directory

# Meerdere scheidingstekens
echo "jan:25,amsterdam" | awk -F'[:,]' '{print $1, $2, $3}'
```

### Praktische AWK Voorbeelden
```bash
# Geheugengebruik per proces (zoals in jouw voorbeeld)
ps -eo pid,rss,comm --no-headers | \
awk '{printf "%-6s %-8s %-30s\n", $1, $2, substr($3,1,30)}'

# Alleen processen boven bepaald geheugen
ps -eo pid,rss,comm --no-headers | \
awk '$2 > 10000 {print $1, $2, $3}'

# Som van getallen in kolom
cat numbers.txt | awk '{sum += $1} END {print sum}'
```

## Combinatie van IFS en AWK

### Bestand met Mixed Formatting
```bash
# bestand.txt bevat: "naam:jan,leeftijd:25,stad:amsterdam"
while IFS=':' read -r key value; do
    clean_value=$(echo "$value" | awk -F',' '{print $1}')
    echo "Key: $key, Value: $clean_value"
done < bestand.txt
```

## Praktische Voorbeelden

### CSV Bestand Verwerken
```bash
#!/bin/bash
# CSV met headers: naam,leeftijd,stad

# Met IFS
while IFS=',' read -r naam leeftijd stad; do
    [[ "$naam" == "naam" ]] && continue  # skip header
    echo "Persoon: $naam ($leeftijd jaar) woont in $stad"
done < data.csv

# Met AWK (eleganter)
awk -F',' 'NR>1 {printf "Persoon: %s (%s jaar) woont in %s\n", $1, $2, $3}' data.csv
```

### Log Bestanden Analyseren
```bash
# Apache access log format analyseren
awk '{print $1, $7, $9}' access.log | \  # IP, URL, status
sort | uniq -c | sort -nr | head -10     # Top 10 requests

# Fouten zoeken (status 4xx, 5xx)
awk '$9 >= 400 {print $1, $7, $9}' access.log
```

### Configuratie Bestanden Lezen
```bash
# key=value configuratie
while IFS='=' read -r key value; do
    # Skip comments en lege regels
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue
    
    echo "Config: $key = $value"
done < config.conf
```

## Geavanceerde Technieken

### Meerdere Bestanden Tegelijk
```bash
# Bestanden vergelijken
awk 'FNR==NR {a[NR]=$0; next} {print a[FNR], $0}' bestand1.txt bestand2.txt
```

### Conditionele Verwerking
```bash
# Verschillende acties per regel type
awk '
    /^ERROR/ {errors++; print "Fout gevonden:", $0}
    /^WARNING/ {warnings++}
    END {print "Fouten:", errors, "Waarschuwingen:", warnings}
' logfile.txt
```

### Complexe Field Splitting
```bash
# Datum en tijd splitsen: "2024-01-15 14:30:25"
echo "2024-01-15 14:30:25" | awk '{
    split($1, datum, "-")
    split($2, tijd, ":")
    print "Jaar:", datum[1], "Maand:", datum[2], "Dag:", datum[3]
    print "Uur:", tijd[1], "Minuut:", tijd[2], "Seconde:", tijd[3]
}'
```

## Tips en Best Practices

1. **IFS Altijd Herstellen**: Sla de originele IFS op en herstel deze
2. **read -r Gebruiken**: Voorkomt backslash interpretatie
3. **AWK voor Complexe Parsing**: Bij meerdere bewerkingen is AWK vaak beter dan meerdere bash-commando's
4. **Quote Variabelen**: Vooral bij bestandsnamen met spaties
5. **Error Handling**: Controleer of bestanden bestaan voordat je ze leest

```bash
# Veilig bestand lezen
if [[ -r "$filename" ]]; then
    while IFS= read -r line; do
        echo "$line"
    done < "$filename"
else
    echo "Kan bestand '$filename' niet lezen" >&2
    exit 1
fi
```