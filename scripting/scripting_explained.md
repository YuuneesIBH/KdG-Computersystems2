# Computersystemen 2 - Linux Complete Guide

## Inhoudsopgave

1. [Vakinleiding](#vakinleiding)
2. [Inleiding Scripting](#inleiding-scripting)
3. [Loops en Flow Control](#loops-en-flow-control)
4. [Best Practices](#best-practices)
5. [Bash Functies en Tellen](#bash-functies-en-tellen)
6. [Parameter Substitution](#parameter-substitution)
7. [Bash Arrays](#bash-arrays)
8. [Regex](#regex)
9. [Compileren](#compileren)
10. [AutoConf & Automake](#autoconf--automake)

---

## Vakinleiding

### Studiefiche
- **Computersystemen 2** bestaat uit 3 onderdelen:
  - Linux - Theorie **30%**
  - Linux - Labo Bash scripting **40%** (laptop)
  - Linux - Containers **30%** (laptop)

**Belangrijk:** Deze zijn GEEN samengestelde opleidingsonderdelen! Bij 2de zit moet je alle 3 de vakken opnieuw afleggen.

### Hoe werkt de cursus?
- **"Begeleide zelfstudie"**
- Voorbeelden in de cursus
- ZELF oefeningen oplossen (per hoofdstuk)
- GEEN oplossingen ter beschikking

### Probleem oplossen (in volgorde):
1. Cursus en referenties
2. Google
3. Vrienden en sympathisanten
4. De meester

### Wat heb je nodig?
- **Linux** (liefst debian based: Ubuntu, Mint, Debian, Gentoo,...)
- Versie >=22.04
- Andere mag ook MAAR zonder ondersteuning van de meester
- Liefst Native of Virtueel (Vmware/Virtualbox)
- **Zorg voor een backup van je virtuele schijf!**
- Minimum: 20 GB schijf, 4GB RAM, 4 processoren
- NAT en Host Only netwerkkaart
- Als alles werkt: schakel updates UIT

### Wat gaan we doen?
- Vervolg Linux scripting Computersystemen 1
- Bash scripting
- Herhaling lussen (if, for, while,...)
- Bash best practices
- Bash gevorderd
- Regex
- (Compileren)

### Examen (bash)
- 2 uitgebreide oefeningen oplossen, gelijkaardig aan de cursusoefeningen
- GEEN internet toegelaten buiten de elektronische leeromgeving (Canvas)
- Aanrader: netwerk verbinding uitschakelen tijdens examen
- XMON tool draaien
- WEL boeken, pdf's, voorbeelden, ... op jou schijf
- Backup meenemen van je bestanden (USB stick/schijf)
- Eventueel LiveDVD/USB meenemen

### Materiaal
- Labo Cursus: CS2-Linux.pdf → PDF met voorbeelden
- Labo Slides: Per hoofdstuk
- Labo Oefeningen: Oefeningen per hoofdstuk in aparte PDF

---

## Inleiding Scripting

### Basis Commando's

#### Commando's
- `echo`: tekst-output tonen op scherm
- `cat`: inhoud tonen van een bestand
- `cut`: knippen; met velden en separators
- `sort`: sorteren bestandsinhoud
- `uniq`: tonen dubbele of niet dubbele lijnen
- `wc`: tellen van lijnen, woorden, karakters
- `head`: eerste n lijnen tonen
- `tail`: laatste n lijnen tonen
- `grep`: zoeken op patronen in bestand (ook met regex)
- `find`: zoeken naar bepaalde bestanden

### Pipes en Redirection

#### Input, Output en Error kanalen
- **STDIN, STDOUT, STDERR** (0, 1, 2 resp.)

```bash
echo "hello" > tekst.txt         # STDOUT naar bestand (of 1>)
mkdir test 2> error.txt          # STDERR naar bestand
mkdir test &> error.txt          # STDOUT en STDERR
mkdir test 2> /dev/null          # STDERR niet tonen
echo "fout" >&2                  # STDOUT naar STDERR (of 1>&2)
```

#### Pipes
```bash
# STDOUT van commando ps naar STDIN van grep
ps -ef | grep apache

# STDIN van file, STDOUT naar grep en sort
tr 'a-z' 'A-Z' < /etc/services |grep -vE '^#' |sort
```

### Aanraders
- **Vorige commando's**: Pijl naar boven
- **Command completion**: Tab of bij meerdere mogelijkheden (2x Tab)

### Shell Script

#### Uitvoeren
- Eerste lijn is `#!/bin/bash`
- Bestand is executable: `chmod +x bestand.sh`
- Runnen met `./bestand.sh` (of met `bestand.sh` indien directory in `$PATH`)

#### Debug
- Optie `-x` gebruiken bij opstarten: `bash -x ./debug.sh`
- Of eerste regel van script de optie `-x` toevoegen: `#!/bin/bash -x`
- Of, stap voor stap door het script:
```bash
#!/bin/bash
set -x
trap read debug
```

### Shellcheck - www.shellcheck.net

#### Ubuntu installatie
```bash
sudo apt-get update; sudo apt-get install shellcheck
```

#### Gebruik
```bash
jancelis@jancelis-lpt:~$ shellcheck script.sh
In script.sh line 6:
while [ $input -gt 0]
      ^-- SC1009 (info): The mentioned syntax error was in this while loop.
      ^-- SC1073 (error): Couldn't parse this test expression. Fix to allow more checks.
                      ^-- SC1020 (error): You need a space before the ].
      ^-- SC1072 (error): Missing space before ]. Fix any mentioned problems and try again.
```

#### Integratie in vim
```bash
sudo apt-get update; sudo apt-get install git vim
mkdir -p ~/.vim/pack/git-plugins/start
git clone https://github.com/dense-analysis/ale.git ~/.vim/pack/git-plugins/start/ale
```

### Variabelen

#### Basis gebruik
```bash
mijnvar="hello"          # zonder $, geen spaties
echo $mijnvar            # met $
read mijnvar             # zonder $
echo "$mijnvarworld"     # werkt niet
echo "${mijnvar}world"   # string concat werkt
```

### Quotes

#### Hardquotes vs. Softquotes
```bash
echo "$a"    # variabele wordt geïnterpreteerd
echo '$a'    # letterlijk $a
```

#### Backquotes
```bash
# Backquotes voeren het commando eerst uit en vullen de output in
echo "Er zijn `wc -l </etc/passwd` users"

# Voorkeur $() i.p.v. ``
echo "Er zijn $(wc -l </etc/passwd) users"
```

### Voorbeeld Script
```bash
#!/bin/bash
# Functie: Toont versie van Ubuntu
osversie=$(cat /etc/os-release |grep 'PRETTY' | cut -d\" -f 2)
echo "Dit toestel draait ${osversie}"
```

**Output:**
```
Dit toestel draait Ubuntu 24.04.3 LTS
```

### Bash Parameters
- `$0`: bestandsnaam
- `$1, $2, $3,...`: 1ste, 2de, 3de argument
- `$#`: aantal argumenten

---

## Loops en Flow Control

### IF Statement

#### Basis IF
```bash
#!/bin/bash
# Functie: Als /etc/passwd bestaat de inhoud tonen
if test -f "/etc/passwd"
then
    cat /etc/passwd
fi
```

#### IF met [ ]
```bash
if [ -f "/etc/passwd" ]
then
    cat /etc/passwd
fi
```

**Goede regel:** ALTIJD spatie voor én na `[ ]`

#### IF-ELSE
```bash
if [ -f "/etc/passwd" ]
then
    cat /etc/passwd
else
    echo "Not a regular file"
fi
```

#### One-liner
```bash
a=1 ; b=2 ; if [ $a -eq $b ] ; then echo "equal" ; else echo "not equal" ; fi
```

### WHILE Loop

#### Basis WHILE
```bash
#!/bin/bash
teller=0
while [ $teller -lt 10 ]
do
    echo -n "$teller "
    let teller+=1    # eentje bijtellen
done
echo -e "\nEinde"
```

#### WHILE met file reading
```bash
#!/bin/bash
while read lijn
do
    echo "$lijn"
done < /etc/passwd
```

### Bash Operators uit "man test"

#### Vergelijken
| **String** | **Numeriek** | **Betekenis** |
|------------|--------------|---------------|
| `x = y`    | `x -eq y`    | gelijk |
| `x != y`   | `x -ne y`    | niet gelijk |
| `x > y`    | `x -gt y`    | groter |
| `x < y`    | `x -lt y`    | kleiner |
| `x >= y`   | `x -ge y`    | groter/gelijk |
| `-n x`     | -            | niet leeg |
| `-z x`     | -            | leeg(zero) |

#### Bestanden nakijken
- `-d`: is directory
- `-f`: is file
- `-e`: bestand bestaat (exists)
- `-r`: leesrechten op bestand
- `-s`: bestaat en niet leeg
- `-w`: schrijfrechten op bestand
- `-x`: exe rechten op bestand

### FOR Loop

#### Commando output met FOR
```bash
#!/bin/bash
# Functie: lijst tonen van bestanden in een directory
directory="/usr/share/backgrounds"
for bestand in $(ls $directory)
do
    echo "Bestand: $bestand"
done
```

#### Uitlezen van een bestand
```bash
#!/bin/bash
# Functie: Elke lijn passwd bestand tonen
bestand="/etc/passwd"
for lijn in $(cat /etc/passwd)
do
    echo "$lijn"
done
```

### FOR en IFS (Internal Field Separator)

#### Probleem
De Bash for loop split op elke whitespace (spatie, tab of newline).

#### Oplossing
```bash
# Opzetten bij het begin van je script
IFS=$'\n'

# Je for loop hier

# Afzetten op het eind van je script
unset IFS
```

---

## Best Practices

### Overzicht Best Practices
- Eerste lijn
- Help
- Inputvalidatie
- Exit code
- Variabelen
- Commentaar
- Root-rechten
- Fouten naar STDERR
- Fouten bevatten nodige info

### Basis Script Setup

#### De eerste lijn
```bash
script="script.sh"
echo '#!/bin/bash' > ${script}
echo "echo \"Hello\"" >> ${script}
chmod +x ${script}
```

Voor andere talen:
- Perl: `#!/usr/bin/perl`
- Python: `#!/usr/bin/python`

### Argumenten en --help voorzien
```bash
#!/bin/bash
# Functie: drukt eerste argument af
if [ $# -lt 1 -o "$1" = "--help" ] ; then
    echo "Usage: `basename $0` arg1 "
    echo "Example: `basename $0` Hallo "
    exit 1
fi
echo "Eerste argument is $1"
```

### Input Validatie

#### Integer validatie
```bash
#!/bin/bash
# Functie: Test of de input een integer getal is
echo "Geef een getal: "
read getal
if [ "$getal" -eq "$getal" ] 2>/dev/null; then
    # Geeft normaal integer expression expected
    echo $getal is een getal
else
    echo $getal is geen getal
fi
```

#### Bestand validatie
```bash
#!/bin/bash
# Functie: Toont een niet leeg en bestaand bestand
echo "Geef de bestandsnaam: "
read bestandsnaam
if [ -s "$bestandsnaam" ]; then
    cat "$bestandsnaam"
else
    echo "$bestandsnaam" werd niet gevonden
fi
```

### Juiste Exit Code
```bash
#!/bin/bash
# Functie: Aanmaken directory
directory="test"
mkdir "$directory"
if [ $? -ne 0 ] ; then
    echo "$directory aanmaken niet gelukt" >&2
    exit 1
else
    echo "$directory aanmaken gelukt"
    exit 0
fi
```

**Exit code 0** als alles ok is, **niet 0** bij falen.

### Variabelen Naamgeving

#### Conventies
- Alle **omgevingsvariabelen** zijn in **HOOFDLETTERS** (zie met `env`)
- Al je eigen, **niet geexporteerde variabelen** zijn in **kleine_letters**

```bash
# Functie: toont hoeveel plaats je $HOME gebruikt
warning_du="Uw homedir $HOME is bijna vol"
schijfruimte_home=$(du $HOME| cut -f1)
echo -n "Homedir $HOME van user $USER "
echo "bevat $schijfruimte_home bytes"
if [ $schijfruimte_home -lt 100000 ]; then
    echo "$warning_du"
fi
```

### Commentaar
```bash
#!/bin/bash
# Functie: Zoekt naar grote bestanden
# In een bepaalde directory
# Arguments: Arg1 is een directory
# Auteur: jan.celis@kdg.be
# Copyright: 2024 GNU v3 jan.celis@kdg.be
# Versie: 0.1
# Requires: Standaard shell find commando
if [ -d "$1" ]; then
    find "$1" -type f -size +100M
fi
```

### Sudo gebruik
```bash
#!/bin/bash
if [ "$(id -u)" != "0" ]; then
    echo "Dit moet je als root uitvoeren" >&2
    exit 1
fi
sudo cat /etc/shadow
```

### Fouten naar STDERR
```bash
#!/bin/bash
# Functie: Wanneer users.csv niet bestaat
# eindigen met een foutboodschap
input_bestand="users.csv"
if ! [ -f $input_bestand ]; then
    echo "$input_bestand bestaat niet" >&2
    exit 1
fi
```

**Kanalen:** STDIN, STDOUT en STDERR (nummers 0, 1 en 2)

### Fouten met programma en functienaam
```bash
#!/bin/bash
# Functie: Geeft een foutbericht bij volle schijf
err_df="Fout in $0:Je schijf is vol"
func_df()
{
    df_percent=$(df /|tr -s ' ' |cut -d' ' -f5|tail -n1)
    if [ "$df_percent" = "100%" ]; then
        echo "$err_df" >&2
    fi
}
func_df
```

### Dependencies

#### Commando bestaan controleren
```bash
error_geen_ab="Het programma ab is niet geïnstalleerd"
command -v ab >/dev/null || (echo $error_geen_ab >&2 && exit 1);
which ab >/dev/null || (echo $error_geen_ab >&2 && exit 1);
```

#### URL bereikbaarheid
```bash
error_url="de url is niet bereikbaar"
curl -o /dev/null --silent --head --connect-timeout 1 ${url}
if [ $? -ne 0 ]; then
    echo ${error_url} && exit 1
fi
```

#### Pakket van commando vinden
```bash
jancelis@kdguntu:~$ which ab
/usr/bin/ab
jancelis@kdguntu:~$ dpkg -S /usr/bin/ab
apache2-utils: /usr/bin/ab
```

---

## Bash Functies en Tellen

### Functies

#### Basis functie
```bash
#!/bin/bash
# Functie: Declaratie van de function "functie"
# Oproepen van functie
function functie(){
    echo "Dit is de functie"
}
functie
```

#### Functie eigenschappen
- Een functie **MOET gedefinieerd zijn VOOR** je ze gebruikt
- Een functie **mag NIET leeg zijn** (ook niet enkel commentaar)
- De argumenten `$1, $2,...` zijn **NIET** de argumenten van het script maar van de functie

#### Functie met argument
```bash
#!/bin/bash
# Functie: Tonen van het argument in kleur
# kleuren van output
reset='\033[0m'    # Vergeet NIET te resetten
                   # of alles blijft gekleurd!
rood='\033[0;31m'
function tooninkleur() {
    echo -e "\e$rood $1 \e$reset"
}
tooninkleur "Hallo"
tooninkleur "Tamelijk rood"
```

### Bash Kleuren

#### Kleur Codes
| **Kleur** | **Foreground Code** | **Background Code** |
|-----------|---------------------|---------------------|
| Default   | 39                  | 49                  |
| Black     | 30                  | 40                  |
| Red       | 31                  | 41                  |
| Green     | 32                  | 42                  |
| Yellow    | 33                  | 43                  |
| Blue      | 34                  | 44                  |
| White     | 97                  | 107                 |

#### Stijl Codes
| **Code** | **Beschrijving** |
|----------|------------------|
| 0        | Reset/Normal     |
| 1        | Bold             |
| 2        | Dim              |
| 3        | Italic           |
| 4        | Underlined       |
| 5        | Blink            |

#### Extra info
- The ANSI escape sequences set screen attributes, such as bold text, and color of foreground and background.
- DOS batch files commonly used ANSI escape codes for color output, and so can Bash scripts.
- Referenties:
  - http://tldp.org/LDP/abs/html/colorizing.html
  - http://misc.flogisoft.com/bash/tip_colors_and_formatting

### Return waarde

#### Boolean return (gelukt/niet gelukt)
```bash
function checkexist(){
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}
if checkexist "/etc/passwd" ; then echo passwd ok; fi
```

#### String return via echo
```bash
#!/bin/bash
# Functie: "Return" waarde functie is een string
function tooninkleur() {
    local reset='\033[0m'
    local rood='\033[0;31m'
    echo -e "\e$rood $1 \e$reset"
}
resultaat=$(tooninkleur "ok")
# of resultaat=`tooninkleur "ok"`
echo $resultaat
```

### Tellen

#### Basis bewerkingen
**Operators:** `+ - / * % **` (plus, min, delen, maal, mod, expon.)

#### Met expr
```bash
a=1
b=2
som=$(expr $a + $b)
```

#### Met let
```bash
let "som=$a+$b"
```

#### In bash
```bash
som=$(($a+$b))
echo $som
```

**Opmerking:** `echo $((3/2))` → geeft 1
Voor komma getallen gebruik je `bc`

### Bash tellen met bc

#### Simpel script
```bash
#!/bin/bash
echo '6.5 / 2.7' | bc
```

#### Parameters
- `scale` = aantal getallen na de komma (geen afronding!)
- Conversie talstelsels:
  - `obase` = output basis
  - `ibase` = input basis

#### Voorbeelden
```bash
# Decimaal 256 naar binair
echo "obase=2;256" | bc

# Binair naar hex
echo "obase=16;ibase=2;11111111" | bc
```

### Bash tellen bc -l

#### Optie -l of --mathlib
```bash
a=1;b=2

echo "$a / $b" | bc
echo "scale=10; $a / $b" | bc

echo "Decimaal-> Binair"
echo "obase=2; $b" | bc

echo "Binair -> Decimaal"
echo "ibase=2; 10101100" | bc

echo "Logaritme"
echo "l(1000)" | bc -l

echo "Cosinus"
echo "c(1000)" | bc -l

echo "PI"
echo "scale=1000;4*a(1)" | bc -l
```

---

## Parameter Substitution

### Overzicht
- Interne variabelen
- Variabelen
- Replace
- Substring
- Trim
- Lengte
- Upper/lower

### Interne variabelen voorbeeld
```bash
#!/bin/bash
echo Dit moeder script heet $0
echo Argument 1 is $1
# eindeloos kind proces schrijven en opstarten
echo '#!/bin/bash' > child.sh
echo 'while true; do echo "kind $$"; sleep 1; done' >> child.sh
echo Laatste argument: $_    # Dit is echo van de lijn hiervoor
chmod +x child.sh ; ./child.sh &    # Opstarten in achtergrond
sleep 2                            # moeder slaapt 2 seconden
echo kind nr $! wordt door moeder afgemaakt
kill $!                           # PID laatste achtergrondproces (child.sh)
echo moeder $0 nr $$ pleegt zelfmoord
kill $$
```

### Gebruik van IFS en $@
```bash
#!/bin/bash
# Args: Arg $1 is een bestand
# OF via stdin
IFS=$'\n'
for lijn in $(cat "$@")
do
    echo $lijn
done
unset IFS
```

**Oproepen met:**
```bash
cat /etc/passwd | ./script.sh
# of
./script.sh /etc/passwd
```

### Variabele ${var}
```bash
var="hallo"
echo "$varmetdezoo"      # werkt niet
echo "${var}metdezoo"    # werkt wel!
```

### Default waarde ${var:-default}
```bash
#!/bin/bash
# Functie: Zoeken naar bestanden > 10MB
# Args: Arg $1 MAG meegegeven worden
# Als $1 leeg is, krijgt het een default waarde
default_waarde="10"
size=${1:-$default_waarde}    # of =${1:-10}
find . -iname "*" -size "+${size}M"
```

### Lege variabelen error ${var?error_message}
```bash
#!/bin/bash
# Functie: Grote bestanden vinden
# Args: Arg $1 MOET meegegeven worden
# $1 leeg => einde met exit code 1
size=${1?"Usage: `basename $0` ARGUMENT"}
# Script komt enkel hier wanneer $1 werd ingevuld
find . -iname "*" -size "+${size}M"
```

Een variabele die leeg is geeft:
- foutbericht op kanaal 2
- eindigt met exit 1

### Replace ${var/zoekterm/vervangterm}
```bash
#!/bin/bash
# Functie: Replace in een string
url="http://www.kdg.be/index.html"
echo String ${url}
echo Vervang 1 keer kdg door student: ${url/kdg/student}
echo Vervang alle keren ht door f: ${url//ht/f}
echo Vervang begin met http door ftp: ${url/#http/ftp}
echo Vervang einde met html met aspx: ${url/%html/aspx}
```

### Substring ${var:positie:lengte}
```bash
#!/bin/bash
url="http://www.kdg.be/index.html"
echo String ${url}
echo Eerste 7 karakters knippen: ${url:7}
# Haakjes of spatie is escape van positie
echo Laatste 4 karakters knippen: ${url: -4}
# of echo Laatste 4 karakters: ${url:(-4)}
echo Eerste 4 karakters weergeven: ${url:0:4}
echo Karakter 8 tot 18 weergeven: ${url:7:10}
```

### Trim
```bash
#!/bin/bash
# Functie: Verwijder gedeelte string voor/achteraan
# greedy en ungreedy
url="http://www.kdg.be/index.html"
# Verwijder korste substring http:// vooraan:
echo ${url#http://}
# Verwijder langste substring http*. vooraan:
echo ${url##http*.}
# Verw. korste substring non-greedy .* achteraan:
echo ${url%.*}
# Verw. langste substring greedy .* achteraan:
echo ${url%%.*}
```

### Lengte string
```bash
#!/bin/bash
url="http://www.kdg.be/index.html"
echo Lengte van de string: ${#url}
```

### Uppercase/lowercase
```bash
#!/bin/bash
url="http://www.kdg.be/index.html"
echo Alles uppercase: ${url^^}
echo Alles lowercase: ${url,,}
```

---

## Bash Arrays

### Array Warning
- **Not supported by all shells!**
- Info for "bash" shell
- Other shells might have quirks or no support.

### Array Declaration

#### Implicit
```bash
ARRAY[INDEXNR]=value
ARRAY=(value1 value2 ... valueN)
```

#### Explicit
```bash
declare -a ARRAYNAME
```

**Eigenschappen:**
- Not type dependent: Array content can be mixed
- No spaces around equal sign.

### Array Reference

#### Index
- Index = zero-based, one-dimensional
- `echo $reeks` gives first element

#### Reference elements
```bash
reeks=("one" "two" "three")
echo ${reeks[0]}    # gives "one"
```

#### Set
```bash
reeks[3]=four
```

#### Unset
```bash
unset reeks[1]      # element
unset reeks         # whole array
```

#### Add
```bash
reeks+=("test" 1 2 3)
```

### Array Reference - Alle elementen

```bash
# All elements as 1 string
echo ${reeks[*]}    # gives "one two three"

# All elements individually
echo ${reeks[@]}

# Indexes
echo ${!reeks[@]}

# Get total number of elements
echo "assArray contains ${#assArray[*]} elements"
```

**So you can use string-functions (as seen)**

### Loop through Array
```bash
for i in ${reeks[@]}
do
    echo $i
done
```

### Arrays and Functions

#### "Pass by elements"
```bash
#!/bin/bash
function showArray() {
    arr=($@)
    for i in "${arr[@]}"; do echo "$i" ; done
}
array=("one" "two" "three")
showArray "${array[@]}"
```

**Proces:**
- pass array as last argument
- first retrieve the other elements
- `$@` = all remaining arguments = array

#### "Pass by elements" met shift
```bash
#!/bin/bash
function showArray() {
    msg=$1
    shift    # shift to left, original $1 gets lost
    arr=($@)
    for i in "${arr[@]}"; do echo "$msg $i" ; done
}
array=("one" "two" "three")
showArray "Showing" "${array[@]}"
```

Use `shift` to skip previous arguments (e.g. `shift 6` will skip first 6 arguments)

#### "Pass by elements" extra - Retrieve from function
```bash
#!/bin/bash
function createArray() {
    echo "one" "two" "three"
}
if [ -z "$array" ]; then array=("leeg");fi
echo "Array: ${array[@]}"    # geeft "leeg"
array+=($(createArray))
echo "Array: ${array[@]}"
```

- `array+=($(createArray))`
- `array`=name of array in main program
- `createArray`=function which outputs values

#### "Pass by name/reference"
```bash
function showArray() {
    local -n arr="$1"    # -n pass by name!
    for i in "${!arr[@]}"; do
        echo ${arr[$i]}
        arr[$i]="test$i"    # you can even overwrite the array
    done
}
array=("one" "two" "three")
showArray array
for x in ${!array[@]}; do
    echo "$x = ${array[$x]}"
done
```

### Associative Array

#### Since bash v4
```bash
bash --version
```

#### Declaration
```bash
declare -A assocARRAY
```

#### Usage
```bash
# use strings instead of index
assocARRAY[name]=Peter
assocARRAY[colour]=red

declare -A assocARRAY2=( [HDD]=Samsung [Monitor]=Dell [Keyboard]=A4Tech )
```

**Set, add, remove etc… = same as normal array**

### References
- https://www.shell-tips.com/bash/arrays/#gsc.tab=0
- https://www.gnu.org/software/bash/manual/html_node/Arrays.html
- https://tldp.org/LDP/Bash-Beginners-Guide/html/sect_10_02.html
- https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
- https://linuxhint.com/associative_array_bash/

---

## Regex

### Overzicht
- Soorten
- Expressies
- =~ operator
- Groups
- Extglob

### Soorten Regex

#### POSIX2.0 Regex

**Extended Regex (ERE)**
- egrep/bash

**Oud: Basic Regex(BRE)**
- escapen van `? + { | ( en )`
- standaard grep (zie CS1…)

**Perl Compatible Regex (PCRE)**
- UTF-8 en UNICODE support
- perl/python/java/javascript/c#
- grep -P

### Extended en Basic Regex Voorbeeld

#### Extended regex met grep (egrep)
```bash
grep -E "groen|rood" bestand.txt
```

#### Basic regex met grep
```bash
grep 'groen \| rood' bestand.txt
```

### Regex Expressies

#### Basis expressies
- `.` = 1 karakter
- `[a