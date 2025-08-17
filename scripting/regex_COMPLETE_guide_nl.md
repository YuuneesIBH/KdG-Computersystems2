# Bash Regex - Volgens COMPSYS2 Leerstof

## Soorten Regex

### POSIX 2.0 Regex

**Extended Regex (ERE)**
- Gebruikt door: `egrep`, `bash` (met `=~`)
- Moderne standaard
- Geen escaping nodig voor `? + { | ( )`

**Basic Regex (BRE)** - Oud
- Standaard `grep`
- Moet escapen: `? + { | ( )`
- Bijvoorbeeld: `grep 'groen \| rood'` (let op de backslash!)

**Perl Compatible Regex (PCRE)**
- UTF-8 en Unicode support
- Gebruikt door: perl, python, java, javascript, C#
- In bash: `grep -P`

### Vergelijking ERE vs BRE
```bash
# Extended regex (makkelijker)
grep -E "groen|rood" bestand.txt

# Basic regex (meer escaping)
grep 'groen \| rood' bestand.txt
```

## Basis Regex Expressies

### Karakter matching
- `.` - 1 willekeurig karakter
- `[a-z]` - karakter a tot z (kleine letters)
- `[0-9]` - cijfer 0 tot 9
- `[ab]` - karakter a OF karakter b

### Hoeveelheden (Quantifiers)
- `a{4}` - precies 4x de letter a
- `a{1,4}` - 1 tot 4x de letter a
- `+` - 1 tot n keer
- `*` - 0 tot n keer

### Posities
- `^` - begint met
- `$` - eindigt met

## POSIX Karakterklassen (Extended Regex)

**Gebruik deze in plaats van `\d`, `\w`, etc!**

- `[[:digit:]]` - een cijfer (0-9)
- `[[:space:]]` - spatie, tab, newline, return
- `[[:alnum:]]` - letters en cijfers
- `[[:alpha:]]` - alleen letters
- `[[:blank:]]` - spatie en tab
- `[[:lower:]]` - kleine letters
- `[[:print:]]` - afdrukbare karakters

## De `=~` Operator in Bash

### Basis gebruik
```bash
#!/bin/bash
content="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"
regex="B-[0-9]{4}"

if [[ $content =~ $regex ]]
then
    echo "postnummer gevonden"
    exit 0
else
    echo "postnummer niet gevonden" >&2
    exit 1
fi
```

### ⚠️ BELANGRIJK: 
**`$regex` is NOOIT met dubbele quotes bij `=~`!**

```bash
# GOED:
if [[ $content =~ $regex ]]

# FOUT:
if [[ $content =~ "$regex" ]]
```

## BASH_REMATCH Array

### Hele match ophalen
```bash
#!/bin/bash
content="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"
regex="B-[0-9]{4}"

[[ $content =~ $regex ]]
echo "${BASH_REMATCH[0]}"
# Output: B-2000
```

`${BASH_REMATCH[0]}` bevat altijd de hele match.

## Regex Groups (Haakjes)

### Groups maken met haakjes
```bash
content="Karel de Grote-Hogeschool, Nationalestraat 5,B-2000 Antwerpen"
regex="([- a-zA-Z]+), ([[:alpha:]]+) ([[:digit:]]+),(.*) (.*)"

[[ $content =~ $regex ]]

echo "Naam: ${BASH_REMATCH[1]}"
echo "Straat: ${BASH_REMATCH[2]} Nr: ${BASH_REMATCH[3]}"
echo "Postcode: ${BASH_REMATCH[4]} Stad: ${BASH_REMATCH[5]}"
```

**Output:**
```
Naam: Karel de Grote-Hogeschool
Straat: Nationalestraat Nr: 5
Postcode: B-2000 Stad: Antwerpen
```

### Hoe groups werken:
- `${BASH_REMATCH[0]}` = hele match
- `${BASH_REMATCH[1]}` = eerste group `()`
- `${BASH_REMATCH[2]}` = tweede group `()`
- enz...

## Email Regex Voorbeeld (Stap voor Stap)

### Stap 1: Basis email
```
jan.celis@kdg.be
```
Regex: `[[:alnum:]]+\.[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+`

### Stap 2: Punt optioneel maken
```
jancelis@kdg.be  (zonder punt)
```
Regex: `([[:alnum:]]+\.){0,2}[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+`

### Stap 3: Subdomeinen toevoegen
```
jan.celis@student.kdg.be
```
Regex: `([[:alnum:]]+\.){0,2}[[:alnum:]]+@([[:alnum:]]+\.){1,3}[[:alpha:]]+`

### Stap 4: Domein extensie beperken
```
jan.celis@student.kdg.be  (.be = 2-3 karakters)
```
Regex: `([[:alnum:]]+\.){0,2}[[:alnum:]]+@([[:alnum:]]+\.){1,3}[[:alpha:]]{2,3}`

## Parameter Substitution met Extended Glob

### Extglob activeren
```bash
#!/bin/bash
content=" Karel de Grote-Hogeschool, Nationalestraat 5,B-2000 Antwerpen"

# Extglob aanzetten
shopt -q -s extglob

# Ungreedy (eerste match)
content2=${content#*+([[:digit:]])}

# Greedy (laatste match) 
content=${content##*+([[:digit:]])}

# Extglob uitzetten
shopt -q -u extglob

echo "ungreedy: $content2"
echo "greedy: $content"
```

**Output:**
```
ungreedy: ,B-2000 Antwerpen
greedy: Antwerpen
```

### Parameter Substitution Operators
- `${var#pattern}` - verwijder kortste match van begin
- `${var##pattern}` - verwijder langste match van begin
- `${var%pattern}` - verwijder kortste match van eind
- `${var%%pattern}` - verwijder langste match van eind

## Praktische Bash Voorbeelden

### Postcode validatie
```bash
#!/bin/bash
validate_postcode() {
    local input="$1"
    local regex="^[[:alpha:]]-[[:digit:]]{4}$"
    
    if [[ $input =~ $regex ]]; then
        echo "Geldige postcode: $input"
        return 0
    else
        echo "Ongeldige postcode: $input"
        return 1
    fi
}

validate_postcode "B-2000"  # Geldig
validate_postcode "2000"    # Ongeldig
```

### Email extraheren
```bash
#!/bin/bash
text="Contact ons op info@kdg.be of admin@student.kdg.be"
regex="([[:alnum:]]+\.?[[:alnum:]]*)@([[:alnum:]]+\.)*[[:alpha:]]{2,3}"

while [[ $text =~ $regex ]]; do
    echo "Email gevonden: ${BASH_REMATCH[0]}"
    # Verwijder gevonden email om verder te zoeken
    text=${text/${BASH_REMATCH[0]}/}
done
```

### Log parsing voorbeelden

#### Standaard logline
```bash
#!/bin/bash
logline="2024-03-15 14:30:22 ERROR Database connection failed"
regex="^([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}) ([[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}) ([[:alpha:]]+) (.*)"

if [[ $logline =~ $regex ]]; then
    echo "Datum: ${BASH_REMATCH[1]}"
    echo "Tijd: ${BASH_REMATCH[2]}"
    echo "Level: ${BASH_REMATCH[3]}"
    echo "Bericht: ${BASH_REMATCH[4]}"
fi
```

#### Apache access log
```bash
logline='192.168.1.100 - - [15/Mar/2024:14:30:22 +0100] "GET /index.html HTTP/1.1" 200 1024'
regex="^([[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+) - - \[([^]]+)\] \"([A-Z]+) ([^ ]+) ([^\"]+)\" ([[:digit:]]+) ([[:digit:]]+)"

if [[ $logline =~ $regex ]]; then
    echo "IP: ${BASH_REMATCH[1]}"
    echo "Timestamp: ${BASH_REMATCH[2]}"
    echo "Method: ${BASH_REMATCH[3]}"
    echo "URL: ${BASH_REMATCH[4]}"
    echo "Protocol: ${BASH_REMATCH[5]}"
    echo "Status: ${BASH_REMATCH[6]}"
    echo "Size: ${BASH_REMATCH[7]}"
fi
```

#### Syslog formaat
```bash
logline="Mar 15 14:30:22 server01 sshd[1234]: Failed password for user admin from 192.168.1.50"
regex="^([[:alpha:]]+) ([[:digit:]]+) ([[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}) ([[:alnum:]]+) ([[:alnum:]]+)\[([[:digit:]]+)\]: (.*)"

if [[ $logline =~ $regex ]]; then
    echo "Maand: ${BASH_REMATCH[1]}"
    echo "Dag: ${BASH_REMATCH[2]}"
    echo "Tijd: ${BASH_REMATCH[3]}"
    echo "Hostname: ${BASH_REMATCH[4]}"
    echo "Process: ${BASH_REMATCH[5]}"
    echo "PID: ${BASH_REMATCH[6]}"
    echo "Bericht: ${BASH_REMATCH[7]}"
fi
```

#### Email log
```bash
logline="2024-03-15T14:30:22.123Z postfix/smtp[5678]: 4B1A23F4: to=<user@example.com>, relay=mx.example.com[1.2.3.4]:25, status=sent"
regex="^([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}\.[[:digit:]]+Z) ([[:alnum:]/]+)\[([[:digit:]]+)\]: ([[:alnum:]]+): to=<([^>]+)>, relay=([^[]+)\[([^]]+)\]:([[:digit:]]+), status=([[:alnum:]]+)"

if [[ $logline =~ $regex ]]; then
    echo "Timestamp: ${BASH_REMATCH[1]}"
    echo "Service: ${BASH_REMATCH[2]}"
    echo "PID: ${BASH_REMATCH[3]}"
    echo "Queue ID: ${BASH_REMATCH[4]}"
    echo "To: ${BASH_REMATCH[5]}"
    echo "Relay host: ${BASH_REMATCH[6]}"
    echo "Relay IP: ${BASH_REMATCH[7]}"
    echo "Port: ${BASH_REMATCH[8]}"
    echo "Status: ${BASH_REMATCH[9]}"
fi
```

#### Nginx error log
```bash
logline="2024/03/15 14:30:22 [error] 1234#0: *5678 connect() failed (111: Connection refused) while connecting to upstream"
regex="^([[:digit:]]{4}/[[:digit:]]{2}/[[:digit:]]{2}) ([[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}) \[([[:alpha:]]+)\] ([[:digit:]]+)#([[:digit:]]+): \*([[:digit:]]+) (.*)"

if [[ $logline =~ $regex ]]; then
    echo "Datum: ${BASH_REMATCH[1]}"
    echo "Tijd: ${BASH_REMATCH[2]}"
    echo "Level: ${BASH_REMATCH[3]}"
    echo "PID: ${BASH_REMATCH[4]}"
    echo "Worker: ${BASH_REMATCH[5]}"
    echo "Connection: ${BASH_REMATCH[6]}"
    echo "Bericht: ${BASH_REMATCH[7]}"
fi
```

#### Database log (MySQL)
```bash
logline="2024-03-15T14:30:22.123456Z 123 Query SELECT * FROM users WHERE id = 42"
regex="^([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}\.[[:digit:]]+Z) +([[:digit:]]+) +([[:alpha:]]+) +(.*)"

if [[ $logline =~ $regex ]]; then
    echo "Timestamp: ${BASH_REMATCH[1]}"
    echo "Connection ID: ${BASH_REMATCH[2]}"
    echo "Command: ${BASH_REMATCH[3]}"
    echo "Query: ${BASH_REMATCH[4]}"
fi
```

#### Firewall log
```bash
logline="Mar 15 14:30:22 firewall kernel: [12345.678] DROP IN=eth0 OUT= MAC=aa:bb:cc:dd:ee:ff SRC=192.168.1.100 DST=10.0.0.1 LEN=60 PROTO=TCP SPT=12345 DPT=22"
regex="^([[:alpha:]]+) +([[:digit:]]+) +([[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}) +([[:alnum:]]+) +([[:alnum:]]+): +\[([[:digit:].]+)\] +([[:alpha:]]+) +IN=([[:alnum:]]*) +OUT=([[:alnum:]]*) .* SRC=([[:digit:].]+) +DST=([[:digit:].]+) .* PROTO=([[:alpha:]]+) +SPT=([[:digit:]]+) +DPT=([[:digit:]]+)"

if [[ $logline =~ $regex ]]; then
    echo "Datum: ${BASH_REMATCH[1]} ${BASH_REMATCH[2]} ${BASH_REMATCH[3]}"
    echo "Action: ${BASH_REMATCH[7]}"
    echo "Interface IN: ${BASH_REMATCH[8]}"
    echo "Interface OUT: ${BASH_REMATCH[9]}"
    echo "Source IP: ${BASH_REMATCH[10]}"
    echo "Dest IP: ${BASH_REMATCH[11]}"
    echo "Protocol: ${BASH_REMATCH[12]}"
    echo "Source Port: ${BASH_REMATCH[13]}"
    echo "Dest Port: ${BASH_REMATCH[14]}"
fi
```

## Belangrijke Tips

### 1. Test je regex
```bash
# Maak een test functie
test_regex() {
    local text="$1"
    local pattern="$2"
    
    if [[ $text =~ $pattern ]]; then
        echo "✓ Match: '${BASH_REMATCH[0]}'"
    else
        echo "✗ Geen match"
    fi
}

test_regex "B-2000" "^[[:alpha:]]-[[:digit:]]{4}$"
```

### 2. Debug met echo
```bash
regex="B-[0-9]{4}"
echo "Regex: $regex"
echo "Text: $content"
[[ $content =~ $regex ]] && echo "Match: ${BASH_REMATCH[0]}"
```

### 3. Gebruik grep voor files
```bash
# Zoek alle emails in een bestand
grep -E '[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+' emails.txt

# Met line numbers
grep -n -E '[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+' emails.txt
```

## Veelgemaakte Fouten

### 1. Quotes bij =~
```bash
# FOUT:
if [[ $content =~ "$regex" ]]

# GOED:
if [[ $content =~ $regex ]]
```

### 2. Vergeten escapen van punt
```bash
# FOUT: . matcht elk karakter
regex="kdg.be"

# GOED: \. matcht letterlijke punt
regex="kdg\.be"
```

### 3. Wrong regex type
```bash
# Dit werkt NIET in bash:
regex="\d+\w+"

# Dit werkt WEL:
regex="[[:digit:]]+[[:alnum:]]+"
```

## Oefeningen

### Basis
1. Maak regex voor Nederlandse telefoon: `06-12345678`
2. Valideer tijd formaat: `14:30`
3. Match IP adres: `192.168.1.1`

### Advanced
1. Extract naam en voornaam uit: "Achternaam, Voornaam"
2. Parse log: "2024-03-15 ERROR: Connection failed"
3. Valideer IBAN: "BE12 3456 7890 1234"

### Antwoorden
```bash
# Basis
1. regex="^06-[[:digit:]]{8}$"
2. regex="^[[:digit:]]{1,2}:[[:digit:]]{2}$"
3. regex="^[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}$"

# Advanced
1. regex="([[:alpha:]]+), ([[:alpha:]]+)"
2. regex="([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}) ([[:alpha:]]+): (.*)"
3. regex="^[[:alpha:]]{2}[[:digit:]]{2} [[:digit:]]{4} [[:digit:]]{4} [[:digit:]]{4}$"
```

## Samenvatting

- Gebruik **Extended Regex (ERE)** in bash met `=~`
- Gebruik **POSIX karakterklassen**: `[[:digit:]]`, `[[:alnum:]]`, etc.
- **Nooit quotes** rond `$regex` bij `=~`
- **Groups** met haakjes: `${BASH_REMATCH[1]}`, `${BASH_REMATCH[2]}`
- **Test altijd** je regex voordat je het gebruikt

Regex in bash is anders dan "gewone" regex - hou je aan de POSIX standaard en je zit goed!