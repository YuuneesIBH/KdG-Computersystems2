# POSIX Regex Uitgelegd voor Beginners

## Wat is POSIX Regex?

POSIX staat voor "Portable Operating System Interface" en is een standaard die ervoor zorgt dat regex (reguliere expressies) op dezelfde manier werken op verschillende Unix-achtige systemen. Het is de basis voor veel regex implementaties in Linux en macOS.

## De Verschillende Soorten Regex

### 1. Basic Regex (BRE) - De Oudere Standaard
- Gebruikt door standaard `grep`
- Speciale karakters zoals `?`, `+`, `{`, `|`, `(`, `)` moeten "escaped" worden met een backslash `\`
- Voorbeeld: `grep 'groen \| rood' bestand.txt`

### 2. Extended Regex (ERE) - De Moderne Standaard
- Gebruikt door `egrep` en `bash`
- Speciale karakters werken direct zonder escaping
- Voorbeeld: `grep -E "groen|rood" bestand.txt`

### 3. Perl Compatible Regex (PCRE)
- Ondersteuning voor UTF-8 en Unicode
- Gebruikt in veel programmeertalen
- Voorbeeld: `grep -P` in Linux

## Basis Regex Symbolen

| Symbool | Betekenis | Voorbeeld |
|---------|-----------|-----------|
| `.` | Elk willekeurig karakter | `a.b` matcht "aab", "abb", "acb" |
| `*` | 0 of meer keer het vorige karakter | `ab*` matcht "a", "ab", "abbb" |
| `+` | 1 of meer keer het vorige karakter | `ab+` matcht "ab", "abbb", maar niet "a" |
| `?` | 0 of 1 keer het vorige karakter | `ab?` matcht "a" en "ab" |
| `^` | Begin van de regel | `^hallo` matcht alleen "hallo" aan het begin |
| `$` | Einde van de regel | `hallo$` matcht alleen "hallo" aan het einde |
| `\|` | OF operator | `rood\|groen` matcht "rood" of "groen" |

## Karakter Klassen

### Basis Karakter Klassen
```bash
[a-z]     # Alle kleine letters van a tot z
[A-Z]     # Alle hoofdletters van A tot Z
[0-9]     # Alle cijfers van 0 tot 9
[ab]      # Alleen de letters 'a' of 'b'
[^0-9]    # Alles BEHALVE cijfers (^ = NOT)
```

### POSIX Karakter Klassen (Aanbevolen!)
```bash
[[:digit:]]  # Een cijfer (0-9)
[[:alpha:]]  # Een letter (a-z, A-Z)
[[:alnum:]]  # Letter of cijfer
[[:space:]]  # Spatie, tab, newline, return
[[:blank:]]  # Alleen spatie en tab
[[:lower:]]  # Kleine letters
[[:upper:]]  # Hoofdletters
[[:print:]]  # Afdrukbare karakters
```

## Herhaling Specificaties

```bash
a{4}      # Precies 4 keer 'a'
a{1,4}    # Tussen 1 en 4 keer 'a'
a{3,}     # Minimaal 3 keer 'a'
a{,5}     # Maximaal 5 keer 'a'
```

## Praktische Voorbeelden

### 1. Postcode Validatie (België)
```bash
#!/bin/bash
content="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"
regex="B-[0-9]{4}"

if [[ $content =~ $regex ]]; then
    echo "Belgische postcode gevonden: ${BASH_REMATCH[0]}"
else
    echo "Geen geldige Belgische postcode gevonden"
fi
```

### 2. Email Adres Validatie (Basis)
```bash
# Simpel email patroon
regex="[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]{2,3}"

# Uitgebreider email patroon met punten in naam
regex="([[:alnum:]]+\.){0,2}[[:alnum:]]+@([[:alnum:]]+\.){1,3}[[:alpha:]]{2,3}"
```

## Groepen (Groups) in Bash

Groepen stellen je in staat om delen van je match op te slaan:

```bash
#!/bin/bash
content="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"
regex="([- a-zA-Z]+), ([[:alpha:]]+) ([[:digit:]]+), (.*) (.*)"

if [[ $content =~ $regex ]]; then
    echo "Organisatie: ${BASH_REMATCH[1]}"
    echo "Straat: ${BASH_REMATCH[2]}"
    echo "Huisnummer: ${BASH_REMATCH[3]}"
    echo "Postcode: ${BASH_REMATCH[4]}"
    echo "Stad: ${BASH_REMATCH[5]}"
fi
```

## Belangrijke Tips voor Beginners

### 1. Escaping in Bash
```bash
# GOED - Gebruik enkele quotes of escape speciale karakters
regex='[0-9]+'
regex="[0-9]+"

# FOUT - Dubbele quotes kunnen problemen geven met variabelen
regex="$variable[0-9]+"  # Dit kan onverwacht gedrag geven
```

### 2. Testing van Regex
Test je regex altijd stap voor stap:
```bash
# Start simpel
regex="[0-9]"           # Match 1 cijfer
regex="[0-9]+"          # Match 1 of meer cijfers  
regex="B-[0-9]+"        # Match B- gevolgd door cijfers
regex="B-[0-9]{4}"      # Match B- gevolgd door precies 4 cijfers
```

### 3. Debugging
Gebruik `echo` om te zien wat er gematcht wordt:
```bash
if [[ $content =~ $regex ]]; then
    echo "Hele match: '${BASH_REMATCH[0]}'"
    echo "Groep 1: '${BASH_REMATCH[1]}'"
    echo "Groep 2: '${BASH_REMATCH[2]}'"
fi
```

## Veelgemaakte Fouten

1. **Vergeten van quotes**: `regex=[0-9]+` → `regex="[0-9]+"`
2. **Verkeerde escaping**: In ERE gebruik je `|` niet `\|`
3. **Greedy matching**: `.*` matcht zoveel mogelijk, gebruik `.*?` voor non-greedy
4. **Case sensitivity**: Regex is hoofdlettergevoelig, gebruik `[Aa]` voor beide

## Handige Tools voor Testing

- Online: regex101.com (selecteer POSIX ERE flavor)
- Command line: `grep -E "jouw_regex" testbestand.txt`
- Bash: Test in een klein script voordat je het in een groter systeem gebruikt

## Samenvattend

POSIX regex is krachtig maar kan intimiderend zijn. Begin met simpele patronen en bouw ze langzaam uit. Gebruik de POSIX karakter klassen waar mogelijk - ze zijn draagbaarder en leesbaarder dan bereiken zoals `[a-z]`.