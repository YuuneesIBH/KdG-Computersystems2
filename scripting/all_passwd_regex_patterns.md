# Alle Mogelijke Regex Patronen voor /etc/passwd

## 1. VELDEN EXTRAHEREN (Individueel)

### Username (1e veld)
```bash
regex='^([^:]+):'
# Output: root, daemon, bin, sys, sync, games, etc.
```

### Password placeholder (2e veld)
```bash
regex='^[^:]+:([^:]*):'
# Output: x, x, x, x, x, x (meestal allemaal 'x')
```

### UID (3e veld)
```bash
regex='^[^:]+:[^:]*:([^:]+):'
# Output: 0, 1, 2, 3, 4, 5, 6, etc.
```

### GID (4e veld)
```bash
regex='^[^:]+:[^:]*:[^:]+:([^:]+):'
# Output: 0, 1, 2, 3, 65534, 60, 12, etc.
```

### GECOS/Comment (5e veld)
```bash
regex='^[^:]+:[^:]*:[^:]+:[^:]+:([^:]*):'
# Output: root, daemon, bin, sys, sync, games, man, etc.
```

### Home Directory (6e veld)
```bash
regex='^[^:]+:[^:]*:[^:]+:[^:]+:[^:]*:([^:]*):'
# Output: /root, /usr/sbin, /bin, /dev, /bin, etc.
```

### Shell (7e veld) - zoals jij al gebruikt
```bash
regex=':([^:]+)$'
# Output: /bin/bash, /usr/sbin/nologin, /bin/sync, /bin/false
```

## 2. MEERDERE VELDEN COMBINEREN

### Username en UID
```bash
regex='^([^:]+):[^:]*:([^:]+):'
# BASH_REMATCH[1] = username, BASH_REMATCH[2] = UID
```

### Username en Shell
```bash
regex='^([^:]+):.*:([^:]+)$'
# BASH_REMATCH[1] = username, BASH_REMATCH[2] = shell
```

### UID en GID
```bash
regex='^[^:]+:[^:]*:([^:]+):([^:]+):'
# BASH_REMATCH[1] = UID, BASH_REMATCH[2] = GID
```

### Username, UID en Home
```bash
regex='^([^:]+):[^:]*:([^:]+):[^:]+:[^:]*:([^:]*):'
# BASH_REMATCH[1] = username, BASH_REMATCH[2] = UID, BASH_REMATCH[3] = home
```

### Alle 7 velden
```bash
regex='^([^:]+):([^:]*):([^:]+):([^:]+):([^:]*):([^:]*):([^:]*)$'
# BASH_REMATCH[1-7] = alle velden
```

## 3. GEFILTERDE EXTRACTIES

### Alleen system accounts (UID < 1000)
```bash
regex='^([^:]+):[^:]*:([0-9]{1,3}):'
# Voor UID 0-999
```

### Alleen reguliere gebruikers (UID >= 1000)
```bash
regex='^([^:]+):[^:]*:([1-9][0-9]{3,}):'
# Voor UID 1000+
```

### Accounts met login shells
```bash
regex='^([^:]+):.*:(/bin/bash|/bin/sh|/bin/zsh)$'
```

### Accounts met nologin
```bash
regex='^([^:]+):.*:(/usr/sbin/nologin)$'
```

### Accounts met /bin/false
```bash
regex='^([^:]+):.*:(/bin/false)$'
```

### Root account
```bash
regex='^(root):.*:(0):.*:(/root):'
```

### Systemd accounts
```bash
regex='^(systemd-[^:]+):'
```

## 4. PATTERN MATCHING

### Accounts met underscore
```bash
regex='^([^:]*_[^:]*):'
```

### Accounts eindigend op 'd'
```bash
regex='^([^:]*d):'
```

### Numerieke UID extractie
```bash
regex=':([0-9]+):[0-9]+:'
```

### Home directories in /var
```bash
regex='^([^:]+):.*:(/var/[^:]*):'
```

### Home directories in /home
```bash
regex='^([^:]+):.*:(/home/[^:]*):'
```

### Lege GECOS velden
```bash
regex='^([^:]+):[^:]*:[^:]+:[^:]+::'
```

## 5. GEAVANCEERDE PATRONEN

### UID en shell samen filteren
```bash
regex='^([^:]+):[^:]*:([0-9]+):[^:]+:[^:]*:[^:]*:(/usr/sbin/nologin)$'
# System accounts met nologin
```

### GECOS beschrijving extraheren
```bash
regex='^[^:]+:[^:]*:[^:]+:[^:]+:([^,:]*).*:'
# Eerste deel van GECOS (voor komma)
```

### Shell type detectie
```bash
regex=':([^/:]*/(bash|sh|zsh|fish|nologin|false))$'
# Shell naam zonder path
```

### Account categorie bepaling
```bash
regex='^([^:]+):[^:]*:([0-9]+):[^:]+:[^:]*:[^:]*:(.*/(bash|nologin|false))$'
# Username, UID en shell type
```

## 6. SPECIFIEKE MATCHES VOOR JOUW DATA

### Daemon accounts
```bash
regex='^([^:]+):.*daemon.*:'
```

### Backup/service accounts
```bash
regex='^(backup|list|irc|gnats|nobody):'
```

### Network services
```bash
regex='^(www-data|proxy|messagebus|dnsmasq|avahi):'
```

### Audio/Media services
```bash
regex='^(pulse|speech-dispatcher|colord):'
```

### TPM en security services
```bash
regex='^(tss|sssd|whoopsie):'
```

## 7. VALIDATIE PATRONEN

### Volledige regel validatie
```bash
regex='^[^:]+:[^:]*:[0-9]+:[0-9]+:[^:]*:[^:]*:[^:]*$'
```

### UID numeriek check
```bash
regex='^[^:]+:[^:]*:([0-9]+):[^:]+:'
```

### Geen lege username
```bash
regex='^([^:]{1,}):'
```

## 8. DEBUG/ANALYSIS PATRONEN

### Lege velden detecteren
```bash
regex='^([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*):([^:]*)$'
# Check voor lege captures
```

### Ongewone karakters
```bash
regex='([^a-zA-Z0-9_-])'
# Niet-standaard karakters
```

### Lange usernames
```bash
regex='^([^:]{20,}):'
# Usernames langer dan 19 karakters
```

## GEBRUIK IN JOUW SCRIPT:

Voor elk patroon gebruik je het zo:
```bash
if [[ $lijn =~ $regex ]]; then
    printf 'Captured: %s\n' "${BASH_REMATCH[1]}" >> "$output"
    # Voor meerdere captures: ${BASH_REMATCH[2]}, ${BASH_REMATCH[3]}, etc.
fi
```

**Tip:** Test altijd je regex met een paar regels eerst om te zien of je de verwachte output krijgt!