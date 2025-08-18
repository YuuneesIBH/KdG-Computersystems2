#!/usr/bin/env bash
#
# autologin.sh – automatisch inloggen via SSH met Expect
#
# Usage:
#   autologin.sh <host> <user> <password>
#
# Exit codes:
#   0 Succes
#   1 Foutieve aanroep of mislukte controle

set -euo pipefail

### Kleuren definiëren (ANSI escapes)
readonly RED='31'    # foutmeldingen
readonly GREEN='32'  # successen
readonly YELLOW='33' # waarschuwingen
readonly BLUE='34'   # info

### Functie: tekst in kleur tonen
#   $1 = kleurcode (bijv. $RED, $GREEN, …)
#   rest = de te tonen tekst
print_color() {
  local color="$1"; shift
  echo -e "\e[${color}m$*\e[0m"
}

### Specifieke echo-functies
echo_info()    { print_color "$BLUE"   "[INFO] $*"; }
echo_warn()    { print_color "$YELLOW" "[WARN] $*"; }
echo_error()   { print_color "$RED"    "[ERROR] $*" >&2; }
echo_success() { print_color "$GREEN"  "[OK] $*"; }

### Functie: toon usage en stop
print_usage() {
  cat <<EOF
Usage: $(basename "$0") <host> <user> <password>

Automatisch inloggen op <host> als <user> via SSH, met automatische password-prompt.
EOF
  exit 1
}

### Functie: foutmelding en exit 1
error_exit() {
  echo_error "$1"
  exit 1
}

### Functie: controleer of ssh geïnstalleerd is
check_ssh_installed() {
  if ! command -v ssh >/dev/null 2>&1; then
    error_exit "ssh is niet geïnstalleerd. Installeer met: sudo apt-get install openssh-client"
  fi
  echo_info "ssh gevonden"
}

### Functie: check of de SSH-poort (22) open is op de server
test_ssh_server() {
  local host="$1"
  if ! command -v nc >/dev/null 2>&1; then
    error_exit "nc (netcat) is niet geïnstalleerd. Installeer met: sudo apt-get install netcat"
  fi
  if nc -z -w5 "$host" 22; then
    echo_info "SSH-poort 22 op $host is bereikbaar"
  else
    error_exit "Kan SSH-server op $host:22 niet bereiken"
  fi
}

### Functie: schrijf expect-script en voer het uit
create_and_run_expect() {
  local host="$1" user="$2" password="$3"
  cat > expect.sh <<EOF
#!/usr/bin/expect -f
set timeout 10
spawn ssh -o StrictHostKeyChecking=no \$env(USER)@\$env(HOST)
expect {
  "(yes/no)?" { send "yes\r"; exp_continue }
  "assword:"     { send "\$env(PASS)\r" }
}
interact
EOF

  chmod +x expect.sh
  export HOST="$host" USER="$user" PASS="$password"
  echo_info "Start Expect-login naar $user@$host"
  ./expect.sh
  rm -f expect.sh
  echo_success "Expect-login klaar"
}

### — Main —

# 1) Argumenten
if [[ $# -ne 3 ]]; then
  print_usage
fi

host="$1"
user="$2"
password="$3"

# 2) Checks
check_ssh_installed
test_ssh_server "$host"

# 3) Genereren en uitvoeren van Expect-login
create_and_run_expect "$host" "$user" "$password"