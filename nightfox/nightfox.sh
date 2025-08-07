#!/bin/bash

# ──────────────[ Color Config ]───────────────
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;97m'
RESET='\033[0m'

# ──────────────[ Banner ]───────────────
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║              🦊 NIGHTFOX v1.1               ║"
echo -e "${YELLOW}║   Stealthy OSINT Recon Tool (Bash Edition)  ║"
echo -e "${WHITE}║   Author: ${RED}Syed Sharjeel Zaidi${WHITE}                    ║"
echo -e "${CYAN}║   GitHub: ${WHITE}github.com/syedsharjeelshah         ${CYAN}║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RESET}"

# ──────────────[ Safety Settings ]───────────────
set -e
trap 'echo -e "\n${RED}[!] Interrupted. Exiting...${RESET}"; exit 1' SIGINT

# ──────────────[ Default Variables ]───────────────
domain=""
output="output/report.txt"
custom_wordlist=""
default_wordlist="wordlists/rockyou_subs.txt"

# ──────────────[ Parse CLI Arguments ]───────────────
while getopts "d:o:w:" opt; do
  case $opt in
    d) domain=$OPTARG ;;
    o) output=$OPTARG ;;
    w) custom_wordlist=$OPTARG ;;
    *) echo -e "${RED}Usage: $0 -d <domain> [-o outputfile] [-w wordlist]${RESET}"; exit 1 ;;
  esac
done

if [ -z "$domain" ]; then
  echo -e "${RED}❌ Please provide a domain using -d${RESET}"
  echo "Usage: $0 -d <domain> [-o outputfile] [-w wordlist]"
  exit 1
fi

# ──────────────[ Select Wordlist ]───────────────
if [[ -n "$custom_wordlist" ]]; then
  wordlist="$custom_wordlist"
else
  wordlist="$default_wordlist"
fi

# ──────────────[ Auto-Generate Wordlist if Missing ]───────────────
if [ ! -f "$wordlist" ]; then
  echo -e "${YELLOW}[!] Wordlist not found: $wordlist${RESET}"

  if [[ "$wordlist" == "$default_wordlist" ]]; then
    echo "[*] Attempting to auto-generate wordlist from rockyou.txt..."

    mkdir -p wordlists

    if [ -f /usr/share/wordlists/rockyou.txt ]; then
      cat /usr/share/wordlists/rockyou.txt | \
      tr '[:upper:]' '[:lower:]' | \
      tr -cd '[:alnum:]\n' | \
      awk 'length >= 3 && length <= 20' | \
      sort -u > "$default_wordlist"

      echo -e "${GREEN}[+] Generated wordlist at $default_wordlist${RESET}"
    else
      echo -e "${RED}❌ rockyou.txt not found at /usr/share/wordlists/rockyou.txt${RESET}"
      echo "Please install it or provide a custom wordlist with -w"
      exit 1
    fi
  else
    echo -e "${RED}❌ Custom wordlist not found: $wordlist${RESET}"
    exit 1
  fi
fi

# ──────────────[ Create Output Folder ]───────────────
mkdir -p "$(dirname "$output")"
echo "[+] Starting NIGHTFOX OSINT scan on $domain" | tee "$output"
echo "-------------------------------------------" | tee -a "$output"
sleep 1

# ──────────────[ WHOIS INFO ]───────────────
echo -e "\n🔍 WHOIS Info for $domain:" | tee -a "$output"
whois "$domain" 2>/dev/null | grep -Ei "Registrant|Registrar|Name Server|Creation Date|Expiry|Status|Email" | tee -a "$output"

# ──────────────[ DNS RECORDS ]───────────────
echo -e "\n🌐 DNS Records for $domain:" | tee -a "$output"

echo -e "\n[A Record]" | tee -a "$output"
dig +short A "$domain" | tee -a "$output"

echo -e "\n[MX Record]" | tee -a "$output"
dig +short MX "$domain" | tee -a "$output"

echo -e "\n[NS Record]" | tee -a "$output"
dig +short NS "$domain" | tee -a "$output"

echo -e "\n[TXT Record]" | tee -a "$output"
dig +short TXT "$domain" | tee -a "$output"

# ──────────────[ REVERSE IP LOOKUP ]───────────────
echo -e "\n🧠 Reverse Lookup:" | tee -a "$output"
ip=$(dig +short A "$domain" | head -n1)
if [[ ! -z "$ip" ]]; then
  host "$ip" | tee -a "$output"
else
  echo "No IP found for reverse lookup." | tee -a "$output"
fi

# ──────────────[ SUBDOMAIN ENUMERATION ]───────────────
echo -e "\n🌐 Subdomain Enumeration:" | tee -a "$output"

# Passive subfinder
if command -v subfinder &> /dev/null; then
  echo "[*] Passive enum via subfinder..." | tee -a "$output"
  subfinder -d "$domain" -silent | tee -a "$output"
else
  echo "[!] subfinder not installed. Skipping passive." | tee -a "$output"
fi

# Brute-force with wordlist
echo -e "\n[*] Brute-force using wordlist: $wordlist" | tee -a "$output"

while read sub; do
  full="$sub.$domain"
  ping -c 1 -W 1 "$full" &> /dev/null
  if [ $? -eq 0 ]; then
    echo "[+] Found: $full" | tee -a "$output"
  fi
done < "$wordlist"

# ──────────────[ DONE ]───────────────
echo -e "\n✅ NIGHTFOX OSINT scan complete for $domain." | tee -a "$output"

