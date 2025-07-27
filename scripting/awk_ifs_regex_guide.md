# AWK, IFS & REGEX - Complete In-Depth Guide

## Inhoudsopgave

1. [AWK - Advanced Text Processing](#awk---advanced-text-processing)
2. [IFS (Internal Field Separator)](#ifs-internal-field-separator)
3. [REGEX (Regular Expressions)](#regex-regular-expressions)

---

## AWK - Advanced Text Processing

### Wat is AWK?

AWK is een krachtige programmeertaal die speciaal ontworpen is voor tekstverwerking en het extraheren van gegevens uit gestructureerde bestanden. De naam komt van de achternamen van de makers: **A**ho, **W**einberger en **K**ernighan.

### Basis AWK Syntax

```bash
awk 'pattern { action }' input-file
awk 'BEGIN { action } pattern { action } END { action }' input-file
```

### AWK Basisbegrippen

#### Records en Fields
- **Record**: Een regel in het bestand (standaard gescheiden door newline)
- **Field**: Een veld binnen een record (standaard gescheiden door whitespace)

```bash
# Voorbeeld bestand: employees.txt
John Doe 30 Engineer 5000
Jane Smith 25 Manager 6000
Bob Johnson 35 Developer 4500
Alice Brown 28 Designer 4000
```

#### Built-in Variables

| Variable | Beschrijving |
|----------|--------------|
| `$0` | Hele record (volledige regel) |
| `$1, $2, $3...` | Eerste, tweede, derde veld, etc. |
| `NF` | Number of Fields (aantal velden in huidige record) |
| `NR` | Number of Records (regelnummer) |
| `FNR` | File Number of Records (regelnummer per bestand) |
| `FS` | Field Separator (veldscheidingsteken) |
| `RS` | Record Separator (recordscheidingsteken) |
| `OFS` | Output Field Separator |
| `ORS` | Output Record Separator |

### AWK Voorbeelden - Van Basic tot Advanced

#### 1. Basic Field Extraction

```bash
# Print eerste veld (naam)
awk '{print $1}' employees.txt
# Output:
# John
# Jane
# Bob
# Alice

# Print meerdere velden
awk '{print $1, $2, $4}' employees.txt
# Output:
# John Doe Engineer
# Jane Smith Manager
# Bob Johnson Developer
# Alice Brown Designer
```

#### 2. Werken met Field Separators

```bash
# Voor CSV bestand: data.csv
# John,Doe,30,Engineer,5000
# Jane,Smith,25,Manager,6000

# Set field separator naar komma
awk -F',' '{print $1, $4}' data.csv
# Of:
awk 'BEGIN {FS=","} {print $1, $4}' data.csv
```

#### 3. Pattern Matching

```bash
# Print regels waar salary > 4500
awk '$5 > 4500' employees.txt

# Print regels die "Manager" bevatten
awk '/Manager/' employees.txt

# Print regels waar age >= 30
awk '$3 >= 30' employees.txt

# Combinatie van patronen
awk '$3 >= 30 && $5 > 4000' employees.txt
```

#### 4. BEGIN en END Blokken

```bash
# Bereken totaal salary
awk 'BEGIN {total=0} {total+=$5} END {print "Total salary:", total}' employees.txt

# Met headers en formatting
awk 'BEGIN {
    print "=== SALARY REPORT ==="
    print "Name\t\tAge\tSalary"
    print "------------------------"
    total=0
} 
{
    printf "%-15s %d\t%d\n", $1" "$2, $3, $5
    total+=$5
} 
END {
    print "------------------------"
    print "Total salary:", total
    print "Average salary:", total/NR
}' employees.txt
```

#### 5. Advanced AWK Programming

```bash
# Groeperen per functie en berekenen gemiddelde salary
awk '{
    jobs[$4] += $5
    count[$4]++
} 
END {
    for (job in jobs) {
        printf "%s: Average salary = %.2f\n", job, jobs[job]/count[job]
    }
}' employees.txt
```

#### 6. String Functions in AWK

```bash
# length() - lengte van string
awk '{print $1, length($1)}' employees.txt

# substr() - substring
awk '{print substr($1, 1, 3)}' employees.txt  # Eerste 3 karakters

# toupper() en tolower()
awk '{print toupper($1)}' employees.txt

# gsub() - global substitution
awk '{gsub(/Engineer/, "Software Engineer"); print}' employees.txt

# match() en RSTART, RLENGTH
awk '{
    if (match($0, /[0-9]+/)) {
        print "Number found at position", RSTART, "length", RLENGTH
    }
}' employees.txt
```

#### 7. Mathematical Operations

```bash
# Bereken bonus (10% van salary)
awk '{print $1, $2, $5, $5*0.1}' employees.txt

# Rounding
awk '{printf "%s %s %.0f\n", $1, $2, $5*0.1}' employees.txt

# Math functions
awk 'BEGIN {print sqrt(16), sin(3.14159/2), int(4.7)}'
```

#### 8. Arrays in AWK

```bash
# Associative arrays
awk '{
    # Count occurrences per job
    job_count[$4]++
} 
END {
    for (job in job_count) {
        print job ":", job_count[job]
    }
}' employees.txt

# Multi-dimensional arrays (simulation)
awk '{
    # Store salary by job and name
    data[$4,$1] = $5
} 
END {
    for (key in data) {
        split(key, parts, SUBSEP)
        printf "Job: %s, Name: %s, Salary: %d\n", parts[1], parts[2], data[key]
    }
}' employees.txt
```

#### 9. Control Structures

```bash
# If-else statements
awk '{
    if ($5 > 5000) {
        print $1, $2, "High salary"
    } else if ($5 > 4000) {
        print $1, $2, "Medium salary"  
    } else {
        print $1, $2, "Low salary"
    }
}' employees.txt

# For loops
awk '{
    print "Record", NR ":"
    for (i=1; i<=NF; i++) {
        print "  Field", i ":", $i
    }
}' employees.txt

# While loops
awk '{
    i = 1
    while (i <= NF) {
        print "Field", i ":", $i
        i++
    }
}' employees.txt
```

#### 10. Advanced File Processing

```bash
# Process multiple files
awk 'FNR==1 {print "Processing file:", FILENAME} {print NR, $0}' file1.txt file2.txt

# Skip header lines
awk 'FNR > 1 {print $1, $5}' employees.txt

# Process specific line ranges
awk 'NR >= 2 && NR <= 4' employees.txt
```

---

## IFS (Internal Field Separator)

### Wat is IFS?

IFS (Internal Field Separator) is een bash shell variable die bepaalt hoe de shell velden splitst wanneer het input leest. Standaard is IFS ingesteld op whitespace (spatie, tab, newline).

### Standaard IFS Waarde

```bash
# Bekijk huidige IFS waarde
echo "[$IFS]"
# Of meer duidelijk:
printf '%q\n' "$IFS"
# Output: $' \t\n' (spatie, tab, newline)
```

### IFS in Practice

#### 1. Basic IFS Usage

```bash
#!/bin/bash
# Bestand: names.txt
# John Doe
# Jane Smith  
# Bob Johnson

# Standaard IFS (whitespace)
while read first last; do
    echo "First: $first, Last: $last"
done < names.txt
```

#### 2. IFS met CSV Files

```bash
#!/bin/bash
# Bestand: data.csv
# John,Doe,30,Engineer
# Jane,Smith,25,Manager

# Set IFS naar komma
IFS=','
while read name surname age job; do
    echo "Name: $name $surname, Age: $age, Job: $job"
done < data.csv

# Reset IFS
unset IFS
```

#### 3. IFS met Complexe Separators

```bash
#!/bin/bash
# Bestand: complex.txt
# John|Doe|30|Engineer|5000
# Jane|Smith|25|Manager|6000

# Set IFS naar pipe
IFS='|'
while read -r name surname age job salary; do
    echo "Employee: $name $surname"
    echo "Age: $age, Job: $job, Salary: $salary"
    echo "---"
done < complex.txt

unset IFS
```

#### 4. Multiple Separators

```bash
#!/bin/bash
# IFS met meerdere scheidingstekens
IFS=',;:'
data="john,doe;30:engineer"
read -r name surname age job <<< "$data"
echo "Name: $name, Surname: $surname, Age: $age, Job: $job"
```

#### 5. IFS in FOR Loops

```bash
#!/bin/bash
# Probleem zonder IFS aanpassing
files="file with spaces.txt|another file.txt|third file.txt"

# Verkeerd - split op spaties
for file in $files; do
    echo "File: [$file]"
done
# Output:
# File: [file]
# File: [with]
# File: [spaces.txt|another]
# ...

# Correct - IFS aanpassen
IFS='|'
for file in $files; do
    echo "File: [$file]"
done
# Output:
# File: [file with spaces.txt]
# File: [another file.txt]
# File: [third file.txt]

unset IFS
```

#### 6. IFS met Arrays

```bash
#!/bin/bash
data="apple,banana,cherry,date"

# Convert naar array met IFS
IFS=',' read -ra fruits <<< "$data"

# Print alle fruits
for fruit in "${fruits[@]}"; do
    echo "Fruit: $fruit"
done

# Reset IFS
unset IFS
```

#### 7. Bewaren en Herstellen van IFS

```bash
#!/bin/bash
# Best practice: bewaar originele IFS
OLDIFS="$IFS"

# Wijzig IFS
IFS=':'
# ... doe je werk ...

# Herstel originele IFS
IFS="$OLDIFS"
```

#### 8. IFS met /etc/passwd Processing

```bash
#!/bin/bash
# Process /etc/passwd file
OLDIFS="$IFS"
IFS=':'

while read -r username password uid gid gecos home shell; do
    if [[ $uid -ge 1000 ]]; then
        echo "Regular user: $username"
        echo "  Home: $home"
        echo "  Shell: $shell"
        echo "  ---"
    fi
done < /etc/passwd

IFS="$OLDIFS"
```

#### 9. Advanced IFS Techniques

```bash
#!/bin/bash
# Multi-character IFS (only first character used as separator)
IFS=':;'
data="a:b;c:d"
read -ra parts <<< "$data"
for part in "${parts[@]}"; do
    echo "Part: [$part]"
done

# Voor multi-character separators, gebruik andere methoden:
data="apple::banana::cherry"
IFS='::' read -ra fruits <<< "$data"  # Werkt NIET zoals verwacht

# Alternative:
fruits=($(echo "$data" | tr '::' '\n'))
for fruit in "${fruits[@]}"; do
    echo "Fruit: [$fruit]"
done
```

---

## REGEX (Regular Expressions)

### Wat zijn Regular Expressions?

Regular Expressions (regex) zijn patronen die gebruikt worden om tekst te matchen, zoeken en manipuleren. Ze vormen een krachtige tool voor tekstverwerking.

### Types of Regex

1. **Basic Regular Expressions (BRE)** - gebruikt door `grep`
2. **Extended Regular Expressions (ERE)** - gebruikt door `egrep` of `grep -E`
3. **Perl Compatible Regular Expressions (PCRE)** - gebruikt door `grep -P`

### Regex Metacharacters

#### 1. Basic Metacharacters

| Metacharacter | Beschrijving | Voorbeeld |
|---------------|--------------|-----------|
| `.` | Elk karakter (behalve newline) | `a.c` matches `abc`, `a1c`, `axc` |
| `*` | 0 of meer van voorgaand karakter | `ab*c` matches `ac`, `abc`, `abbc` |
| `+` | 1 of meer van voorgaand karakter | `ab+c` matches `abc`, `abbc` (niet `ac`) |
| `?` | 0 of 1 van voorgaand karakter | `ab?c` matches `ac`, `abc` |
| `^` | Begin van regel | `^abc` matches lijn die begint met `abc` |
| `$` | Einde van regel | `abc$` matches lijn die eindigt met `abc` |

#### 2. Character Classes

```bash
# [abc] - Match a, b, of c
echo "apple banana cherry" | grep -o '[abc]'

# [a-z] - Match elk lowercase letter
echo "Hello World 123" | grep -o '[a-z]'

# [A-Z] - Match elk uppercase letter
echo "Hello World 123" | grep -o '[A-Z]'

# [0-9] - Match elk digit
echo "Hello World 123" | grep -o '[0-9]'

# [^abc] - Match alles BEHALVE a, b, c
echo "apple banana cherry" | grep -o '[^abc]'
```

#### 3. Predefined Character Classes

```bash
# POSIX character classes
[[:alpha:]]     # Letters
[[:digit:]]     # Digits  
[[:alnum:]]     # Letters and digits
[[:space:]]     # Whitespace
[[:upper:]]     # Uppercase letters
[[:lower:]]     # Lowercase letters
[[:punct:]]     # Punctuation

# Voorbeelden:
echo "Hello World 123!" | grep -o '[[:digit:]]'
echo "Hello World 123!" | grep -o '[[:punct:]]'
```

#### 4. Quantifiers

```bash
# {n} - Exact n keer
echo "abbbbc" | grep 'ab\{3\}c'      # BRE syntax
echo "abbbbc" | grep -E 'ab{3}c'     # ERE syntax

# {n,} - n of meer keer  
echo "abbbbc" | grep -E 'ab{2,}c'

# {n,m} - tussen n en m keer
echo "abbbbc" | grep -E 'ab{2,4}c'
```

### Regex in Practice

#### 1. Email Validation

```bash
#!/bin/bash
email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'

emails=(
    "user@example.com"
    "invalid.email"
    "test@domain"
    "valid.email@test.co.uk"
)

for email in "${emails[@]}"; do
    if [[ $email =~ $email_regex ]]; then
        echo "$email - VALID"
    else
        echo "$email - INVALID"
    fi
done
```

#### 2. Phone Number Validation

```bash
#!/bin/bash
# Various phone formats
phone_patterns=(
    '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'           # 123-456-7890
    '^\([0-9]{3}\) [0-9]{3}-[0-9]{4}$'       # (123) 456-7890
    '^\+[0-9]{1,3} [0-9]{3}-[0-9]{3}-[0-9]{4}$' # +1 123-456-7890
)

phones=(
    "123-456-7890"
    "(123) 456-7890"
    "+1 123-456-7890"
    "invalid-phone"
)

for phone in "${phones[@]}"; do
    valid=false
    for pattern in "${phone_patterns[@]}"; do
        if [[ $phone =~ $pattern ]]; then
            valid=true
            break
        fi
    done
    
    if $valid; then
        echo "$phone - VALID"
    else
        echo "$phone - INVALID"
    fi
done
```

#### 3. Log File Analysis

```bash
#!/bin/bash
# Analyze Apache access log
log_file="access.log"

# IP address pattern
ip_pattern='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'

# Extract unique IP addresses
echo "=== Unique IP Addresses ==="
grep -oE "$ip_pattern" "$log_file" | sort | uniq -c | sort -nr

# Find 404 errors
echo -e "\n=== 404 Errors ==="
grep -E ' 404 ' "$log_file" | head -5

# Extract user agents
echo -e "\n=== User Agents ==="
grep -oE '"[^"]*"$' "$log_file" | sort | uniq -c | sort -nr | head -5
```

#### 4. Data Extraction met Regex Groups

```bash
#!/bin/bash
# Extract data using regex groups in different tools

# Met sed
echo "Name: John Doe, Age: 30" | sed -E 's/Name: ([^,]+), Age: ([0-9]+)/\1 is \2 years old/'

# Met awk en match()
echo "Phone: +1-123-456-7890" | awk '{
    if (match($0, /\+([0-9]+)-([0-9]{3})-([0-9]{3})-([0-9]{4})/, arr)) {
        print "Country:", arr[1]
        print "Area:", arr[2] 
        print "Exchange:", arr[3]
        print "Number:", arr[4]
    }
}'
```

#### 5. Advanced Regex Patterns

```bash
#!/bin/bash
# Complex regex patterns

# URL validation
url_regex='^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[a-zA-Z0-9./_-]*)?(\?[a-zA-Z0-9=&_-]*)?$'

# Date validation (YYYY-MM-DD)
date_regex='^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$'

# Credit card validation (simplified)
cc_regex='^[0-9]{4}[[:space:]-]?[0-9]{4}[[:space:]-]?[0-9]{4}[[:space:]-]?[0-9]{4}$'

# Test data
test_data=(
    "https://www.example.com/path?param=value"
    "2024-03-15"
    "1234 5678 9012 3456"
)

patterns=("$url_regex" "$date_regex" "$cc_regex")
types=("URL" "Date" "Credit Card")

for i in "${!test_data[@]}"; do
    data="${test_data[$i]}"
    pattern="${patterns[$i]}"
    type="${types[$i]}"
    
    if [[ $data =~ $pattern ]]; then
        echo "$type: '$data' - VALID"
    else
        echo "$type: '$data' - INVALID"
    fi
done
```

#### 6. Text Processing met Regex

```bash
#!/bin/bash
# Text cleaning and processing

text="   Hello,    World!   This is    a    test.   "

# Remove extra whitespace
echo "$text" | sed -E 's/[[:space:]]+/ /g' | sed -E 's/^[[:space:]]+|[[:space:]]+$//'

# Extract words only
echo "$text" | grep -oE '[[:alpha:]]+'

# Count words
echo "$text" | grep -oE '[[:alpha:]]+' | wc -l

# Replace patterns
echo "The phone number is 123-456-7890" | sed -E 's/[0-9]{3}-[0-9]{3}-[0-9]{4}/XXX-XXX-XXXX/'
```

#### 7. Regex in Different Contexts

```bash
#!/bin/bash
# Regex usage in different bash contexts

# In conditionals with =~
string="Hello123World"
if [[ $string =~ [0-9]+ ]]; then
    echo "String contains numbers"
fi

# In case statements
case "$string" in
    *[0-9]*) echo "Contains digits" ;;
    *) echo "No digits found" ;;
esac

# With parameter expansion
filename="document.pdf"
echo "Extension: ${filename##*.}"  # Extract extension

# Remove extension
echo "Name without extension: ${filename%.*}"
```

#### 8. Common Regex Patterns Library

```bash
#!/bin/bash
# Common regex patterns

declare -A patterns=(
    ["email"]='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    ["phone"]='^[0-9]{3}-[0-9]{3}-[0-9]{4}$'
    ["ip"]='^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'
    ["url"]='^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    ["date"]='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
    ["time"]='^[0-9]{2}:[0-9]{2}:[0-9]{2}$'
    ["username"]='^[a-zA-Z0-9_]{3,16}$'
    ["password"]='^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).{8,}$'
)

# Function to validate input
validate_input() {
    local pattern_name="$1"
    local input="$2"
    local pattern="${patterns[$pattern_name]}"
    
    if [[ -z "$pattern" ]]; then
        echo "Unknown pattern: $pattern_name"
        return 1
    fi
    
    if [[ $input =~ $pattern ]]; then
        echo "VALID $pattern_name: $input"
        return 0
    else
        echo "INVALID $pattern_name: $input"
        return 1
    fi
}

# Test the function
validate_input "email" "user@example.com"
validate_input "phone" "123-456-7890"
validate_input "ip" "192.168.1.1"
```

### Best Practices

#### 1. Performance Tips
- Gebruik anchors (`^` en `$`) wanneer mogelijk
- Vermijd greedy quantifiers wanneer niet nodig
- Test je regex met verschillende inputs

#### 2. Readability
- Gebruik whitespace en comments in complexe regex (waar ondersteund)
- Break complexe patterns op in kleinere delen
- Documenteer je regex patterns

#### 3. Security
- Valideer altijd input voordat je regex toepast
- Be careful met user-supplied regex patterns
- Test edge cases en malicious input

---

## Praktische Combinaties

### AWK + REGEX

```bash
#!/bin/bash
# AWK met regex patterns

# Find employees with names starting with 'J'
awk '/^J/ {print $1, $2, $5}' employees.txt

# Complex regex in AWK
awk '$0 ~ /Engineer|Manager/ && $5 > 4500 {print $1, $2, $4, $5}' employees.txt

# Using regex functions
awk '{
    if (match($0, /[0-9]+/)) {
        print "Salary found:", substr($0, RSTART, RLENGTH)
    }
}' employees.txt
```

### IFS + AWK

```bash
#!/bin/bash
# Process CSV with IFS and AWK
OLDIFS="$IFS"
IFS=','

awk -F',' '{
    for (i=1; i<=NF; i++) {
        gsub(/^[ \t]+|[ \t]+$/, "", $i)  # Trim whitespace
        printf "Field %d: [%s] ", i, $i
    }
    print ""
}' data.csv

IFS="$OLDIFS"
```

### Complete Example: Log Analysis Script

```bash
#!/bin/bash
# Complete log analysis combining AWK, IFS, and REGEX

log_file="$1"
if [[ ! -f "$log_file" ]]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

echo "=== LOG ANALYSIS REPORT ==="
echo "File: $log_file"
echo "Generated: $(date)"
echo

# IP analysis with AWK and regex
echo "=== TOP 10 IP ADDRESSES ==="
awk '{
    if (match($0, /^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/)) {
        ip = substr($0, RSTART, RLENGTH)
        count[ip]++
    }
}
END {
    for (ip in count) {
        print count[ip], ip
    }
}' "$log_file" | sort -nr | head -10

echo
echo "=== ERROR ANALYSIS ==="
# Error codes analysis
awk '{
    if (match($0, / [4-5][0-9][0-9] /)) {
        error_code = substr($0, RSTART+1, RLENGTH-2)
        errors[error_code]++
        total_requests++
    }
}
END {
    print "Total requests with errors:", total_requests
    for (code in errors) {
        printf "Error %s: %d (%.2f%%)\n", code, errors[code], (errors[code]/total_requests)*100
    }
}' "$log_file"

echo
echo "=== HOURLY TRAFFIC ==="
# Hourly traffic analysis using IFS and regex
awk '{
    # Extract timestamp - assuming format: [DD/Mon/YYYY:HH:MM:SS +timezone]
    if (match($0, /\[[^:]+:[0-9]{2}/)) {
        timestamp = substr($0, RSTART, RLENGTH)
        if (match(timestamp, /:[0-9]{2}/)) {
            hour = substr(timestamp, RSTART+1, 2)
            hourly[hour]++
        }
    }
}
END {
    print "Hour\tRequests"
    for (h=0; h<24; h++) {
        printf "%02d\t%d\n", h, hourly[sprintf("%02d", h)]+0
    }
}' "$log_file"
```

Deze uitgebreide guide geeft je alle tools die je nodig hebt om effectief te werken met AWK, IFS en REGEX in bash scripting!