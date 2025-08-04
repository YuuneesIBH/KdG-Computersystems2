# Uitgebreide Guide: Reguliere Expressies (Regex)

## Inhoudsopgave
1. [Wat zijn Reguliere Expressies?](#wat-zijn-reguliere-expressies)
2. [Soorten Regex](#soorten-regex)
3. [Basis Regex Symbolen](#basis-regex-symbolen)
4. [POSIX Karakterklassen](#posix-karakterklassen)
5. [Kwantificatoren](#kwantificatoren)
6. [Ankers](#ankers)
7. [Groepen en Haakjes](#groepen-en-haakjes)
8. [Bash Regex met =~ operator](#bash-regex-met--operator)
9. [BASH_REMATCH Array](#bash_rematch-array)
10. [Praktische Voorbeelden](#praktische-voorbeelden)
11. [Extended Glob](#extended-glob)
12. [Tips en Trucs](#tips-en-trucs)

## Wat zijn Reguliere Expressies?

Reguliere expressies (regex) zijn patronen die gebruikt worden om tekst te zoeken, matchen en manipuleren. Ze vormen een krachtige manier om complexe zoekpatronen te definiëren.

**Simpel voorbeeld:**
```
Tekst: "De kat zit op de mat"
Regex: "kat"
Match: "kat" (gevonden in de tekst)
```

## Soorten Regex

### 1. Basic Regex (BRE) - Oudste vorm
- Gebruikt door standaard `grep`
- Speciale karakters moeten ge-escaped worden: `\?` `\+` `\{` `\|` `\(` `\)`

```bash
# Basic regex voorbeeld
grep 'groen \| rood' bestand.txt  # Let op de backslash voor |
```

### 2. Extended Regex (ERE) - Moderne standaard
- Gebruikt door `egrep` en `bash`
- Geen escaping nodig voor speciale karakters

```bash
# Extended regex voorbeeld
grep -E "groen|rood" bestand.txt  # Geen backslash nodig
```

### 3. Perl Compatible Regex (PCRE) - Meest uitgebreid
- UTF-8 en Unicode support
- Gebruikt door Perl, Python, Java, JavaScript, C#
- Toegankelijk via `grep -P`

```bash
# PCRE voorbeeld
grep -P "café|naïve" bestand.txt  # Unicode karakters worden ondersteund
```

## Basis Regex Symbolen

### Enkele Karakters
| Symbool | Betekenis | Voorbeeld | Match |
|---------|-----------|-----------|-------|
| `.` | Elk willekeurig karakter | `a.c` | "abc", "axc", "a5c" |
| `\` | Escape karakter | `\.` | letterlijke punt "." |

**Voorbeeld:**
```bash
tekst="abc axc a5c a.c"
# Patroon: a.c
# Matches: "abc", "axc", "a5c", "a.c" (alle vier!)

# Voor letterlijke punt:
# Patroon: a\.c  
# Match: alleen "a.c"
```

### Karakterklassen met Vierkante Haakjes
| Patroon | Betekenis | Voorbeeld | Match |
|---------|-----------|-----------|-------|
| `[abc]` | Karakter a, b of c | `[abc]at` | "aat", "bat", "cat" |
| `[a-z]` | Kleine letters a t/m z | `[a-z]at` | "bat", "cat", niet "Bat" |
| `[A-Z]` | Hoofdletters A t/m Z | `[A-Z]at` | "Bat", "Cat", niet "bat" |
| `[0-9]` | Cijfers 0 t/m 9 | `[0-9]+` | "123", "7", "999" |
| `[a-zA-Z]` | Alle letters | `[a-zA-Z]+` | "Hello", "WORLD", "MiXeD" |
| `[^abc]` | NIET a, b of c | `[^abc]at` | "dat", "eat", niet "cat" |

**Uitgebreid voorbeeld:**
```bash
#!/bin/bash
tekst="cat bat rat 3at @at Cat"

# [abc]at matcht: cat, bat (niet rat, 3at, @at, Cat)
if [[ $tekst =~ [abc]at ]]; then
    echo "Gevonden: ${BASH_REMATCH[0]}"  # Output: cat
fi

# [^abc]at matcht: rat, 3at, @at (niet cat, bat, Cat)
if [[ $tekst =~ [^abc]at ]]; then
    echo "Gevonden: ${BASH_REMATCH[0]}"  # Output: rat
fi
```

## POSIX Karakterklassen

POSIX biedt voorgedefinieerde karakterklassen die universeel werken:

| Klasse | Betekenis | Equivalent | Voorbeeld |
|--------|-----------|------------|-----------|
| `[[:digit:]]` | Cijfers | `[0-9]` | "0", "5", "9" |
| `[[:alpha:]]` | Letters | `[a-zA-Z]` | "a", "Z", "m" |
| `[[:alnum:]]` | Letters en cijfers | `[a-zA-Z0-9]` | "a", "5", "Z" |
| `[[:space:]]` | Witruimte | spatie, tab, newline | " ", "\t", "\n" |
| `[[:blank:]]` | Spatie en tab | " " en "\t" | " ", "\t" |
| `[[:lower:]]` | Kleine letters | `[a-z]` | "a", "m", "z" |
| `[[:upper:]]` | Hoofdletters | `[A-Z]` | "A", "M", "Z" |
| `[[:print:]]` | Afdrukbare karakters | Alles behalve control chars | "a", "5", "!" |

**Praktisch voorbeeld:**
```bash
#!/bin/bash
tekst="Hello123 World! @#$"

# Alleen letters
if [[ $tekst =~ [[:alpha:]]+ ]]; then
    echo "Letters gevonden: ${BASH_REMATCH[0]}"  # Output: Hello
fi

# Letters en cijfers
if [[ $tekst =~ [[:alnum:]]+ ]]; then
    echo "Alfanumeriek: ${BASH_REMATCH[0]}"     # Output: Hello123
fi

# Alleen cijfers
if [[ $tekst =~ [[:digit:]]+ ]]; then
    echo "Cijfers: ${BASH_REMATCH[0]}"          # Output: 123
fi
```

## Kwantificatoren

Kwantificatoren bepalen hoeveel keer een patroon moet voorkomen:

| Symbool | Betekenis | Voorbeeld | Match |
|---------|-----------|-----------|-------|
| `*` | 0 of meer keer | `ab*c` | "ac", "abc", "abbc", "abbbc" |
| `+` | 1 of meer keer | `ab+c` | "abc", "abbc", niet "ac" |
| `?` | 0 of 1 keer (optioneel) | `ab?c` | "ac", "abc", niet "abbc" |
| `{n}` | Exact n keer | `a{3}` | "aaa", niet "aa" of "aaaa" |
| `{n,}` | n of meer keer | `a{2,}` | "aa", "aaa", "aaaa", niet "a" |
| `{n,m}` | Tussen n en m keer | `a{2,4}` | "aa", "aaa", "aaaa", niet "a" of "aaaaa" |

**Gedetailleerde voorbeelden:**
```bash
#!/bin/bash

# * betekent 0 of meer
tekst1="ac abc abbc abbbc"
# Patroon ab*c matcht: ac (0 b's), abc (1 b), abbc (2 b's), abbbc (3 b's)

# + betekent 1 of meer  
tekst2="ac abc abbc"
# Patroon ab+c matcht: abc, abbc (NIET ac - heeft geen b)

# ? betekent optioneel (0 of 1)
tekst3="color colour"
# Patroon colou?r matcht: color (0 u's), colour (1 u)

# Exacte aantallen
telefoonnummer="0123456789"
# Patroon [0-9]{10} matcht exact 10 cijfers

# Bereik
postcode="B-2000"
# Patroon B-[0-9]{4} matcht B- gevolgd door exact 4 cijfers

# Praktisch voorbeeld
if [[ "0123456789" =~ ^[0-9]{10}$ ]]; then
    echo "Geldig 10-cijferig nummer"
fi
```

## Ankers

Ankers bepalen de positie waar een match moet voorkomen:

| Symbool | Betekenis | Voorbeeld | Match |
|---------|-----------|-----------|-------|
| `^` | Begin van regel/string | `^Hello` | "Hello world", niet "Say Hello" |
| `$` | Einde van regel/string | `world$` | "Hello world", niet "world peace" |
| `^...$` | Hele regel/string | `^Hello$` | alleen exact "Hello" |

**Voorbeelden:**
```bash
#!/bin/bash

tekst="Hello world"

# Begint met Hello
if [[ $tekst =~ ^Hello ]]; then
    echo "Begint met Hello"  # Deze wordt uitgevoerd
fi

# Eindigt met world
if [[ $tekst =~ world$ ]]; then
    echo "Eindigt met world"  # Deze wordt uitgevoerd
fi

# Is exact "Hello"
if [[ $tekst =~ ^Hello$ ]]; then
    echo "Is exact Hello"    # Deze wordt NIET uitgevoerd
fi

# Praktisch: validatie van input
gebruikersinput="12345"
if [[ $gebruikersinput =~ ^[0-9]+$ ]]; then
    echo "Input bevat alleen cijfers"
fi
```

## Groepen en Haakjes

Haakjes `()` groeperen delen van een regex en slaan matches op:

```bash
#!/bin/bash

# Voorbeeld: adres parsen
adres="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"

# Regex met groepen (haakjes)
regex="([^,]+), ([[:alpha:]]+) ([[:digit:]]+), (.*) (.*)"

if [[ $adres =~ $regex ]]; then
    echo "Volledige match: ${BASH_REMATCH[0]}"
    echo "Groep 1 - Naam: ${BASH_REMATCH[1]}"
    echo "Groep 2 - Straat: ${BASH_REMATCH[2]}"
    echo "Groep 3 - Nummer: ${BASH_REMATCH[3]}"
    echo "Groep 4 - Postcode: ${BASH_REMATCH[4]}"
    echo "Groep 5 - Stad: ${BASH_REMATCH[5]}"
fi
```

**Output:**
```
Volledige match: Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen
Groep 1 - Naam: Karel de Grote-Hogeschool
Groep 2 - Straat: Nationalestraat
Groep 3 - Nummer: 5
Groep 4 - Postcode: B-2000
Groep 5 - Stad: Antwerpen
```

**Uitleg van de regex:**
- `([^,]+)`: Groep 1 - alles behalve komma's (voor de naam)
- `, `: letterlijke komma en spatie
- `([[:alpha:]]+)`: Groep 2 - alleen letters (straatnaam)
- ` `: letterlijke spatie
- `([[:digit:]]+)`: Groep 3 - alleen cijfers (huisnummer)
- `, `: letterlijke komma en spatie
- `(.*)`: Groep 4 - alles (postcode deel)
- ` `: letterlijke spatie
- `(.*)`: Groep 5 - alles (stad)

## Bash Regex met =~ operator

In Bash gebruik je de `=~` operator voor regex matching:

```bash
#!/bin/bash

# BELANGRIJK: regex variabele NOOIT met dubbele quotes!
content="Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"
regex="B-[0-9]{4}"  # GEEN dubbele quotes rond $regex in de if!

if [[ $content =~ $regex ]]; then
    echo "Postcode gevonden: ${BASH_REMATCH[0]}"
    exit 0
else 
    echo "Postcode niet gevonden" >&2
    exit 1
fi
```

**Waarom geen dubbele quotes rond regex?**
```bash
# FOUT - dubbele quotes breken de regex:
if [[ $content =~ "$regex" ]]; then  # FOUT!

# GOED - geen quotes:
if [[ $content =~ $regex ]]; then    # GOED!
```

## BASH_REMATCH Array

`BASH_REMATCH` is een ingebouwde array die match resultaten bevat:

- `${BASH_REMATCH[0]}`: De volledige match
- `${BASH_REMATCH[1]}`: Eerste groep (eerste paar haakjes)
- `${BASH_REMATCH[2]}`: Tweede groep, etc.

```bash
#!/bin/bash

tekst="Mijn email is jan.celis@kdg.be"
regex="([[:alnum:]]+)\.([[:alnum:]]+)@([[:alnum:]]+)\.([[:alpha:]]+)"

if [[ $tekst =~ $regex ]]; then
    echo "Volledige email: ${BASH_REMATCH[0]}"     # jan.celis@kdg.be
    echo "Voornaam: ${BASH_REMATCH[1]}"            # jan  
    echo "Achternaam: ${BASH_REMATCH[2]}"          # celis
    echo "Domein: ${BASH_REMATCH[3]}"              # kdg
    echo "TLD: ${BASH_REMATCH[4]}"                 # be
    
    # Array doorlopen
    for i in "${!BASH_REMATCH[@]}"; do
        echo "Match $i: ${BASH_REMATCH[i]}"
    done
fi
```

## Regex Patronen Stap-voor-Stap

### De Basis: regex= en BASH_REMATCH

```bash
#!/bin/bash

# Basis template voor regex testing
test_regex() {
    local tekst="$1"
    local regex="$2"
    local beschrijving="$3"
    
    echo "=== Testing: $beschrijving ==="
    echo "Tekst: '$tekst'"
    echo "Regex: '$regex'"
    
    if [[ $tekst =~ $regex ]]; then
        echo "✓ MATCH GEVONDEN!"
        echo "Volledige match [0]: '${BASH_REMATCH[0]}'"
        
        # Alle groepen doorlopen
        for i in $(seq 1 $((${#BASH_REMATCH[@]} - 1))); do
            if [[ -n "${BASH_REMATCH[i]}" ]]; then
                echo "Groep [$i]: '${BASH_REMATCH[i]}'"
            fi
        done
    else
        echo "✗ GEEN MATCH"
    fi
    echo ""
}
```

### Simpele Patronen Opbouwen

#### 1. Basis Woord Matching
```bash
#!/bin/bash

tekst="De kat zit op de mat"

# Simpelste regex - letterlijk woord
regex="kat"
[[ $tekst =~ $regex ]]
echo "Match: '${BASH_REMATCH[0]}'"  # Output: kat

# Case sensitive!
regex="Kat"
if [[ $tekst =~ $regex ]]; then
    echo "Gevonden: ${BASH_REMATCH[0]}"
else
    echo "Niet gevonden - case sensitive!"  # Deze wordt uitgevoerd
fi
```

#### 2. Cijfers Vinden
```bash
#!/bin/bash

tekst="Ik ben 25 jaar oud en woon op nummer 42"

# Een of meer cijfers
regex="[0-9]+"
[[ $tekst =~ $regex ]]
echo "Eerste cijfer(s): '${BASH_REMATCH[0]}'"  # Output: 25

# Alle cijfers vinden (globaal zoeken simuleren)
while [[ $tekst =~ $regex ]]; do
    echo "Gevonden: '${BASH_REMATCH[0]}'"
    # Verwijder de gevonden match om verder te zoeken
    tekst="${tekst/${BASH_REMATCH[0]}/XXX}"
done
```

#### 3. Woorden met Lengtebeperking
```bash
#!/bin/bash

tekst="a bb ccc dddd eeeee"

# Exact 3 letters
regex="[a-z]{3}"
[[ $tekst =~ $regex ]]
echo "Eerste 3-letter woord: '${BASH_REMATCH[0]}'"  # Output: ccc

# 2 tot 4 letters
regex="[a-z]{2,4}"
[[ $tekst =~ $regex ]]
echo "Eerste 2-4 letter woord: '${BASH_REMATCH[0]}'"  # Output: bb

# Minimum 4 letters
regex="[a-z]{4,}"
[[ $tekst =~ $regex ]]
echo "Eerste 4+ letter woord: '${BASH_REMATCH[0]}'"  # Output: dddd
```

### Groepen Gebruiken - Van Simpel naar Complex

#### 1. Eerste Groep
```bash
#!/bin/bash

naam="Jan Peeters"

# Voornaam opvangen in groep
regex="([A-Za-z]+) [A-Za-z]+"
[[ $naam =~ $regex ]]
echo "Volledige match: '${BASH_REMATCH[0]}'"  # Jan Peeters
echo "Voornaam: '${BASH_REMATCH[1]}'"         # Jan
```

#### 2. Meerdere Groepen
```bash
#!/bin/bash

naam="Jan Peeters"

# Beide namen opvangen
regex="([A-Za-z]+) ([A-Za-z]+)"
[[ $naam =~ $regex ]]
echo "Volledige match: '${BASH_REMATCH[0]}'"  # Jan Peeters
echo "Voornaam: '${BASH_REMATCH[1]}'"         # Jan
echo "Achternaam: '${BASH_REMATCH[2]}'"       # Peeters
```

#### 3. Optionele Groepen
```bash
#!/bin/bash

# Verschillende naam formaten
naam1="Jan Peeters"
naam2="Jan van der Berg"
naam3="Dr. Jan Peeters"

# Optionele titel, voornaam, optionele tussenvoegsel, achternaam
regex="(Dr\. |Prof\. )?([A-Za-z]+)( [a-z]+ [a-z]+)?( [A-Za-z]+)"

for naam in "$naam1" "$naam2" "$naam3"; do
    echo "Testing: '$naam'"
    if [[ $naam =~ $regex ]]; then
        echo "  Volledige match: '${BASH_REMATCH[0]}'"
        echo "  Titel: '${BASH_REMATCH[1]}'"
        echo "  Voornaam: '${BASH_REMATCH[2]}'"
        echo "  Tussenvoegsel: '${BASH_REMATCH[3]}'"
        echo "  Achternaam: '${BASH_REMATCH[4]}'"
    fi
    echo ""
done
```

### Datum en Tijd Patronen

#### 1. Nederlandse Datum (DD-MM-YYYY)
```bash
#!/bin/bash

datum="25-12-2023"

# Simpele datum
regex="([0-9]{2})-([0-9]{2})-([0-9]{4})"
[[ $datum =~ $regex ]]
echo "Volledige datum: '${BASH_REMATCH[0]}'"  # 25-12-2023
echo "Dag: '${BASH_REMATCH[1]}'"             # 25
echo "Maand: '${BASH_REMATCH[2]}'"           # 12
echo "Jaar: '${BASH_REMATCH[3]}'"            # 2023

# Datum validatie met betere regex
regex="^([0-3][0-9])-([0-1][0-9])-([0-9]{4})$"
if [[ $datum =~ $regex ]]; then
    dag="${BASH_REMATCH[1]}"
    maand="${BASH_REMATCH[2]}"
    jaar="${BASH_REMATCH[3]}"
    
    echo "Gevalideerde datum:"
    echo "  Dag: $dag (moet 01-31 zijn)"
    echo "  Maand: $maand (moet 01-12 zijn)"
    echo "  Jaar: $jaar"
fi
```

#### 2. Flexibele Datum Formaten
```bash
#!/bin/bash

datum_testen() {
    local datum="$1"
    echo "Testing datum: '$datum'"
    
    # DD-MM-YYYY
    regex="^([0-9]{1,2})-([0-9]{1,2})-([0-9]{4})$"
    if [[ $datum =~ $regex ]]; then
        echo "  DD-MM-YYYY formaat"
        echo "  Dag: ${BASH_REMATCH[1]}, Maand: ${BASH_REMATCH[2]}, Jaar: ${BASH_REMATCH[3]}"
        return
    fi
    
    # DD/MM/YYYY
    regex="^([0-9]{1,2})/([0-9]{1,2})/([0-9]{4})$"
    if [[ $datum =~ $regex ]]; then
        echo "  DD/MM/YYYY formaat"
        echo "  Dag: ${BASH_REMATCH[1]}, Maand: ${BASH_REMATCH[2]}, Jaar: ${BASH_REMATCH[3]}"
        return
    fi
    
    # YYYY-MM-DD (ISO)
    regex="^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$"
    if [[ $datum =~ $regex ]]; then
        echo "  ISO formaat (YYYY-MM-DD)"
        echo "  Jaar: ${BASH_REMATCH[1]}, Maand: ${BASH_REMATCH[2]}, Dag: ${BASH_REMATCH[3]}"
        return
    fi
    
    echo "  Onbekend datum formaat"
}

# Tests
datum_testen "25-12-2023"
datum_testen "25/12/2023"
datum_testen "2023-12-25"
datum_testen "invalid"
```

#### 3. Tijd Patronen
```bash
#!/bin/bash

tijd="14:30:45"

# HH:MM:SS
regex="^([0-2][0-9]):([0-5][0-9]):([0-5][0-9])$"
[[ $tijd =~ $regex ]]
echo "Tijd: '${BASH_REMATCH[0]}'"      # 14:30:45
echo "Uur: '${BASH_REMATCH[1]}'"       # 14
echo "Minuut: '${BASH_REMATCH[2]}'"    # 30
echo "Seconde: '${BASH_REMATCH[3]}'"   # 45

# Flexibele tijd (optionele seconden)
tijd2="14:30"
regex="^([0-2][0-9]):([0-5][0-9])(:([0-5][0-9]))?$"
[[ $tijd2 =~ $regex ]]
echo "Tijd: '${BASH_REMATCH[0]}'"      # 14:30
echo "Uur: '${BASH_REMATCH[1]}'"       # 14
echo "Minuut: '${BASH_REMATCH[2]}'"    # 30
echo "Seconden deel: '${BASH_REMATCH[3]}'"  # (leeg)
echo "Seconden: '${BASH_REMATCH[4]}'"       # (leeg)
```

### Contact Informatie Patronen

#### 1. Telefoonnummers
```bash
#!/bin/bash

# Nederlandse mobiele nummers
telefoon="06-12345678"
regex="^(06)-([0-9]{8})$"
[[ $telefoon =~ $regex ]]
echo "Mobiel nummer: '${BASH_REMATCH[0]}'"  # 06-12345678
echo "Prefix: '${BASH_REMATCH[1]}'"         # 06
echo "Nummer: '${BASH_REMATCH[2]}'"         # 12345678

# Flexibeler patroon
telefoon_test() {
    local tel="$1"
    echo "Testing: '$tel'"
    
    # 06-xxxxxxxx of 06 xxxxxxxx
    regex="^(06)[-\s]?([0-9]{8})$"
    if [[ $tel =~ $regex ]]; then
        echo "  Mobiel: prefix=${BASH_REMATCH[1]}, nummer=${BASH_REMATCH[2]}"
        return
    fi
    
    # 0xx-xxxxxxx (vaste lijn)
    regex="^(0[0-9]{2})[-\s]?([0-9]{7})$"
    if [[ $tel =~ $regex ]]; then
        echo "  Vast: netnummer=${BASH_REMATCH[1]}, nummer=${BASH_REMATCH[2]}"
        return
    fi
    
    echo "  Ongeldig telefoonnummer"
}

telefoon_test "06-12345678"
telefoon_test "06 12345678"
telefoon_test "010-1234567"
telefoon_test "010 1234567"
```

#### 2. Email Adressen Stap-voor-Stap
```bash
#!/bin/bash

# Stap 1: Basis email
email="jan@kdg.be"
regex="([a-z]+)@([a-z]+)\.([a-z]+)"
[[ $email =~ $regex ]]
echo "Email: '${BASH_REMATCH[0]}'"     # jan@kdg.be
echo "Gebruiker: '${BASH_REMATCH[1]}'" # jan
echo "Domein: '${BASH_REMATCH[2]}'"    # kdg
echo "TLD: '${BASH_REMATCH[3]}'"       # be

echo ""

# Stap 2: Met punt in naam
email="jan.peeters@kdg.be"
regex="([a-z]+\.?[a-z]+)@([a-z]+)\.([a-z]+)"
[[ $email =~ $regex ]]
echo "Email met punt: '${BASH_REMATCH[0]}'"
echo "Gebruiker: '${BASH_REMATCH[1]}'"
echo "Domein: '${BASH_REMATCH[2]}'"
echo "TLD: '${BASH_REMATCH[3]}'"

echo ""

# Stap 3: Flexibeler patroon
email="jan.peeters@student.kdg.be"
regex="([a-zA-Z0-9._-]+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,})"
[[ $email =~ $regex ]]
echo "Complexe email: '${BASH_REMATCH[0]}'"
echo "Gebruiker: '${BASH_REMATCH[1]}'"
echo "Volledig domein: '${BASH_REMATCH[2]}'"
echo "TLD: '${BASH_REMATCH[3]}'"
```

### Adres en Locatie Patronen

#### 1. Postcodes
```bash
#!/bin/bash

# Nederlandse postcode
postcode="1234 AB"
regex="^([0-9]{4})\s([A-Z]{2})$"
[[ $postcode =~ $regex ]]
echo "Postcode: '${BASH_REMATCH[0]}'"  # 1234 AB
echo "Cijfers: '${BASH_REMATCH[1]}'"   # 1234
echo "Letters: '${BASH_REMATCH[2]}'"   # AB

# Belgische postcode
postcode_be="B-2000"
regex="^([A-Z])-([0-9]{4})$"
[[ $postcode_be =~ $regex ]]
echo "Belgische postcode: '${BASH_REMATCH[0]}'"  # B-2000
echo "Land: '${BASH_REMATCH[1]}'"                # B
echo "Code: '${BASH_REMATCH[2]}'"                # 2000

# Flexibel voor beide
postcode_flexibel() {
    local pc="$1"
    echo "Testing postcode: '$pc'"
    
    # Nederlands: 1234 AB
    regex="^([0-9]{4})\s([A-Z]{2})$"
    if [[ $pc =~ $regex ]]; then
        echo "  Nederlands: ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        return
    fi
    
    # Belgisch: B-2000
    regex="^([A-Z])-([0-9]{4})$"
    if [[ $pc =~ $regex ]]; then
        echo "  Belgisch: ${BASH_REMATCH[1]}-${BASH_REMATCH[2]}"
        return
    fi
    
    echo "  Onbekend postcode formaat"
}

postcode_flexibel "1234 AB"
postcode_flexibel "B-2000"
postcode_flexibel "invalid"
```

#### 2. Volledig Adres Parsen
```bash
#!/bin/bash

adres="Nationalestraat 5, B-2000 Antwerpen"

# Stap voor stap opbouwen
echo "=== Adres parsen ==="
echo "Adres: '$adres'"

# Regex uitleg:
# ([^,]+) = alles behalve komma (straat + nummer)
# ,\s* = komma + optionele spaties
# ([A-Z]-[0-9]{4}) = postcode
# \s+ = spaties
# (.+) = rest (stad)

regex="([^,]+),\s*([A-Z]-[0-9]{4})\s+(.+)"
[[ $adres =~ $regex ]]

echo "Volledige match: '${BASH_REMATCH[0]}'"
echo "Straat + nummer: '${BASH_REMATCH[1]}'"
echo "Postcode: '${BASH_REMATCH[2]}'"
echo "Stad: '${BASH_REMATCH[3]}'"

echo ""

# Nu straat en nummer apart
straat_nummer="${BASH_REMATCH[1]}"
regex="([A-Za-z\s]+)\s([0-9]+[A-Za-z]?)"
[[ $straat_nummer =~ $regex ]]

echo "=== Straat details ==="
echo "Straatnaam: '${BASH_REMATCH[1]}'"
echo "Huisnummer: '${BASH_REMATCH[2]}'"
```

### Geavanceerde Patronen

#### 1. Log File Parsing
```bash
#!/bin/bash

logline="2023-12-25 14:30:45 [ERROR] User login failed for user: jan@kdg.be"

# Complete log entry parsen
regex="^([0-9]{4}-[0-9]{2}-[0-9]{2})\s([0-9]{2}:[0-9]{2}:[0-9]{2})\s\[([A-Z]+)\]\s(.+)$"
[[ $logline =~ $regex ]]

echo "=== Log Entry Parsing ==="
echo "Datum: '${BASH_REMATCH[1]}'"
echo "Tijd: '${BASH_REMATCH[2]}'"  
echo "Level: '${BASH_REMATCH[3]}'"
echo "Bericht: '${BASH_REMATCH[4]}'"

# Nu het bericht verder parsen voor email
bericht="${BASH_REMATCH[4]}"
regex=".*user:\s([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})"
if [[ $bericht =~ $regex ]]; then
    echo "Gevonden email: '${BASH_REMATCH[1]}'"
fi
```

#### 2. URL Components
```bash
#!/bin/bash

url="https://www.kdg.be/student/dashboard?user=123&page=2"

# URL volledig parsen
regex="^(https?)://([^/]+)(/[^?]*)?\??(.*)$"
[[ $url =~ $regex ]]

echo "=== URL Parsing ==="
echo "Protocol: '${BASH_REMATCH[1]}'"
echo "Domein: '${BASH_REMATCH[2]}'"
echo "Pad: '${BASH_REMATCH[3]}'"
echo "Query string: '${BASH_REMATCH[4]}'"

# Query parameters parsen
query="${BASH_REMATCH[4]}"
echo ""
echo "=== Query Parameters ==="

# Alle parameter=waarde paren vinden
while [[ $query =~ ([^&=]+)=([^&]*) ]]; do
    param="${BASH_REMATCH[1]}"
    waarde="${BASH_REMATCH[2]}"
    echo "Parameter '$param' = '$waarde'"
    
    # Verwijder deze match om verder te zoeken
    query="${query/${BASH_REMATCH[0]}/}"
    query="${query#&}"  # Verwijder leading &
done
```

### Praktische Voorbeelden

#### 1. Input Validatie Script
```bash
#!/bin/bash

valideer_input() {
    local waarde="$1"
    local type="$2"
    
    case $type in
        "email")
            regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
            beschrijving="email adres"
            ;;
        "telefoon")
            regex="^(06|0[1-9][0-9])[-\s]?[0-9]{7,8}$"
            beschrijving="telefoonnummer"
            ;;
        "postcode")
            regex="^[0-9]{4}\s[A-Z]{2}$"
            beschrijving="Nederlandse postcode"
            ;;
        "datum")
            regex="^[0-3][0-9]-[0-1][0-9]-[0-9]{4}$"
            beschrijving="datum (DD-MM-YYYY)"
            ;;
        *)
            echo "Onbekend validatie type: $type"
            return 1
            ;;
    esac
    
    if [[ $waarde =~ $regex ]]; then
        echo "✓ '$waarde' is een geldig $beschrijving"
        return 0
    else
        echo "✗ '$waarde' is geen geldig $beschrijving"
        return 1
    fi
}

# Tests
valideer_input "jan@kdg.be" "email"
valideer_input "06-12345678" "telefoon"
valideer_input "1234 AB" "postcode"
valideer_input "25-12-2023" "datum"
```

#### 2. Data Extractie Script
```bash
#!/bin/bash

# Simuleer bestand met contactgegevens
contactdata="
Jan Peeters, jan.peeters@kdg.be, 06-12345678, 1234 AB Amsterdam
Marie de Vries, marie@student.kdg.be, 010-7654321, 5678 CD Rotterdam
Dr. Peter van Berg, p.vberg@kdg.be, 06-87654321, 9012 EF Utrecht
"

echo "=== Contact Data Extractie ==="

# Elk contact regel voor regel verwerken
while IFS= read -r lijn; do
    # Skip lege regels
    [[ -z "$lijn" ]] && continue
    
    echo "Verwerking: $lijn"
    
    # Contact informatie parsen
    regex="([^,]+),\s*([^,]+),\s*([^,]+),\s*(.+)"
    if [[ $lijn =~ $regex ]]; then
        naam="${BASH_REMATCH[1]}"
        email="${BASH_REMATCH[2]}"
        telefoon="${BASH_REMATCH[3]}"
        adres="${BASH_REMATCH[4]}"
        
        echo "  Naam: $naam"
        echo "  Email: $email"
        echo "  Telefoon: $telefoon"
        echo "  Adres: $adres"
        
        # Extra validaties
        if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            echo "  ✓ Email geldig"
        else
            echo "  ✗ Email ongeldig"
        fi
        
        if [[ $telefoon =~ ^(06|0[1-9][0-9])[-\s]?[0-9]{7,8}$ ]]; then
            echo "  ✓ Telefoon geldig"
        else
            echo "  ✗ Telefoon ongeldig"
        fi
    fi
    echo ""
done <<< "$contactdata"
```

## Praktische Voorbeelden

### 1. Email Validatie (From Simple to Complex)

**Simpele email: `jan@kdg.be`**
```bash
regex="[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+"
```

**Met punt in naam: `jan.celis@kdg.be`**
```bash
# Optionele punt en naam deel: (naam.){0,2}naam
regex="([[:alnum:]]+\.){0,2}[[:alnum:]]+@[[:alnum:]]+\.[[:alpha:]]+"
```

**Met subdomein: `jan.celis@student.kdg.be`**
```bash
# Optionele subdomeinen: (sub.){1,3}
regex="([[:alnum:]]+\.){0,2}[[:alnum:]]+@([[:alnum:]]+\.){1,3}[[:alpha:]]+"
```

**Finale versie met 2-3 karakter TLD:**
```bash
#!/bin/bash
email="jan.celis@student.kdg.be"
regex="([[:alnum:]]+\.){0,2}[[:alnum:]]+@([[:alnum:]]+\.){1,3}[[:alpha:]]{2,3}"

if [[ $email =~ $regex ]]; then
    echo "Geldig email adres: $email"
else
    echo "Ongeldig email adres: $email"
fi
```

### 2. Telefoonnummer Validatie

```bash
#!/bin/bash

# Verschillende formaten accepteren
telefoon1="0123456789"      # 10 cijfers
telefoon2="012 34 56 789"   # Met spaties
telefoon3="012-34-56-789"   # Met streepjes
telefoon4="+32 12 34 56 78" # Internationaal

# Regex voor Nederlands formaat (10 cijfers, optionele scheiding)
regex="^(\+[0-9]{2} )?[0-9]{2,3}[ -]?[0-9]{2}[ -]?[0-9]{2}[ -]?[0-9]{2,3}$"

for telefoon in "$telefoon1" "$telefoon2" "$telefoon3" "$telefoon4"; do
    if [[ $telefoon =~ $regex ]]; then
        echo "✓ Geldig: $telefoon"
    else
        echo "✗ Ongeldig: $telefoon"
    fi
done
```

### 3. Datum Validatie (DD-MM-YYYY)

```bash
#!/bin/bash

datum_valideren() {
    local datum="$1"
    # DD-MM-YYYY formaat
    local regex="^([0-3][0-9])-([0-1][0-9])-([0-9]{4})$"
    
    if [[ $datum =~ $regex ]]; then
        local dag="${BASH_REMATCH[1]}"
        local maand="${BASH_REMATCH[2]}"
        local jaar="${BASH_REMATCH[3]}"
        
        echo "Datum: $datum"
        echo "Dag: $dag, Maand: $maand, Jaar: $jaar"
        
        # Extra validatie
        if (( dag >= 1 && dag <= 31 && maand >= 1 && maand <= 12 )); then
            echo "✓ Geldige datum"
        else
            echo "✗ Ongeldige dag of maand"
        fi
    else
        echo "✗ Fout formaat. Gebruik DD-MM-YYYY"
    fi
}

# Test
datum_valideren "25-12-2023"  # Geldig
datum_valideren "32-13-2023"  # Dag en maand te hoog
datum_valideren "25/12/2023"  # Fout scheidingsteken
```

### 4. URL Validatie

```bash
#!/bin/bash

url_valideren() {
    local url="$1"
    # Protocol://domein.tld/pad
    local regex="^(https?://)([[:alnum:].-]+)\.([[:alpha:]]{2,4})(/.*)?$"
    
    if [[ $url =~ $regex ]]; then
        echo "✓ Geldige URL: $url"
        echo "  Protocol: ${BASH_REMATCH[1]}"
        echo "  Domein: ${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
        echo "  Pad: ${BASH_REMATCH[4]:-"(geen pad)"}"
    else
        echo "✗ Ongeldige URL: $url"
    fi
}

# Tests
url_valideren "https://www.kdg.be/student"
url_valideren "http://kdg.be"
url_valideren "ftp://kdg.be"  # Zal falen - alleen http(s)
```

## Extended Glob

Extended glob patterns werken samen met parameter substitution:

```bash
#!/bin/bash

# Extended glob aanzetten
shopt -s extglob

tekst="   Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen   "

# Verschillende pattern matching
echo "Origineel: '$tekst'"

# Whitespace vooraan wegknippen
tekst_clean1=${tekst##*([[:space:]])}
echo "Vooraan clean: '$tekst_clean1'"

# Whitespace achteraan wegknippen  
tekst_clean2=${tekst_clean1%%*([[:space:]])}
echo "Achteraan clean: '$tekst_clean2'"

# Alles in één keer
tekst_clean=${tekst##*([[:space:]])}
tekst_clean=${tekst_clean%%*([[:space:]])}
echo "Volledig clean: '$tekst_clean'"

# Extended glob patterns:
# *(pattern)  - 0 of meer keer
# +(pattern)  - 1 of meer keer  
# ?(pattern)  - 0 of 1 keer
# @(pattern)  - exact 1 keer
# !(pattern)  - NIET pattern

shopt -u extglob  # Uitzetten
```

### Greedy vs Non-greedy matching

```bash
#!/bin/bash
shopt -s extglob

content=" Karel de Grote-Hogeschool, Nationalestraat 5, B-2000 Antwerpen"

# Non-greedy: eerste match
content_ungreedy=${content#*+([[:digit:]])}
echo "Non-greedy: '$content_ungreedy'"  # Output: ",B-2000 Antwerpen"

# Greedy: laatste match  
content_greedy=${content##*+([[:digit:]])}
echo "Greedy: '$content_greedy'"        # Output: " Antwerpen"

shopt -u extglob
```

**Uitleg:**
- `#` verwijdert de kortste match vanaf het begin
- `##` verwijdert de langste match vanaf het begin  
- `%` verwijdert de kortste match vanaf het einde
- `%%` verwijdert de langste match vanaf het einde

## Tips en Trucs

### 1. Regex Debuggen
```bash
#!/bin/bash

debug_regex() {
    local tekst="$1"
    local pattern="$2"
    
    echo "Tekst: '$tekst'"
    echo "Pattern: '$pattern'"
    
    if [[ $tekst =~ $pattern ]]; then
        echo "✓ MATCH gevonden!"
        echo "Volledige match: '${BASH_REMATCH[0]}'"
        
        # Alle groepen tonen
        for i in $(seq 1 $((${#BASH_REMATCH[@]} - 1))); do
            echo "Groep $i: '${BASH_REMATCH[i]}'"
        done
    else
        echo "✗ Geen match"
    fi
    echo "---"
}

# Test verschillende patronen
debug_regex "test123" "[0-9]+"
debug_regex "test123" "^[0-9]+$"
debug_regex "test123" "[a-z]+[0-9]+"
```

### 2. Case-insensitive Matching
```bash
#!/bin/bash

# Bash heeft geen ingebouwde case-insensitive regex
# Workaround: converteer naar lowercase

tekst="Hello World"
pattern="hello"

# Converteer naar lowercase voor vergelijking
tekst_lower=$(echo "$tekst" | tr '[:upper:]' '[:lower:]')

if [[ $tekst_lower =~ $pattern ]]; then
    echo "Case-insensitive match gevonden"
fi

# Of gebruik karakterklassen
if [[ $tekst =~ [Hh][Ee][Ll][Ll][Oo] ]]; then
    echo "Match met karakterklassen"
fi
```

### 3. Veelgebruikte Patronen
```bash
#!/bin/bash

# IPv4 adres (simpel)
ipv4_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

# Nederlandse postcode
postcode_pattern="^[0-9]{4} ?[A-Z]{2}$"

# Nederlandse BSN (9 cijfers)
bsn_pattern="^[0-9]{9}$"

# Hexadecimale kleurcode
hex_color_pattern="^#[0-9A-Fa-f]{6}$"

# Tijd (HH:MM)
tijd_pattern="^([0-1][0-9]|2[0-3]):[0-5][0-9]$"

# Test functie
test_patroon() {
    local waarde="$1"
    local patroon="$2"
    local beschrijving="$3"
    
    if [[ $waarde =~ $patroon ]]; then
        echo "✓ '$waarde' is een geldige $beschrijving"
    else
        echo "✗ '$waarde' is geen geldige $beschrijving"
    fi
}

# Tests
test_patroon "192.168.1.1" "$ipv4_pattern" "IPv4 adres"
test_patroon "1234 AB" "$postcode_pattern" "Nederlandse postcode"
test_patroon "123456789" "$bsn_pattern" "BSN"
test_patroon "#FF5733" "$hex_color_pattern" "hex kleurcode"
test_patroon "14:30" "$tijd_pattern" "tijd"
```

### 4. Performance Tips

```bash
#!/bin/bash

# GOED: Specifieke patronen
if [[ $tekst =~ ^[0-9]+$ ]]; then  # Alleen cijfers
    # ...
fi

# SLECHT: Te algemeen
if [[ $tekst =~ .* ]]; then        # Matcht alles
    # ...
fi

# GOED: Ankers gebruiken voor exacte matches
if [[ $email =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    # ...
fi

# GOED: Groepeer alleen wat je nodig hebt
regex="Name: ([[:alpha:]]+)"       # Alleen naam opslaan

# SLECHT: Onnodige groepen
regex="(Name: )([[:alpha:]]+)"     # "Name: " hoeft niet opgeslagen
```

## Samenvatting

Reguliere expressies zijn krachtige tools voor tekstverwerking. De belangrijkste punten:

1. **Gebruik de juiste regex variant** voor je use case
2. **Test altijd je patronen** met verschillende inputs  
3. **Gebruik ankers** (^ en $) voor exacte matches
4. **Groepeer alleen wat je nodig hebt** voor betere performance
5. **POSIX karakterklassen** zijn portabeler dan letterlijke bereiken
6. **Quotes vermijden** rond regex variabelen in Bash
7. **BASH_REMATCH array** bevat alle match resultaten

Met deze kennis kun je complexe tekstproblemen oplossen en robuuste validatie schrijven!