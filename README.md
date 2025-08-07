# 🦊 NIGHTFOX v1.1

Stealthy Bash-based OSINT Reconnaissance Tool  

Built with ❤️ by Syed Sharjeel Zaidi

(https://github.com/syedsharjeelshah)

## 🔥 Features
- WHOIS Lookup
- DNS Enumeration (A, MX, NS, TXT)
- Reverse IP Lookup
- Subdomain Enumeration
  - Passive via subfinder
  - Brute-force via rockyou (auto-generated)
- CLI flags
- Auto logging and wordlist handling
  
## 📦 Requirements
- Bash (Linux)
- `whois`, `dig`, `host`, `ping`
- Optional: [`subfinder`](https://github.com/projectdiscovery/subfinder)

## 🛠️ Installation

```bash
git clone https://github.com/syedsharjeelshah/nightfox.git
cd nightfox
chmod +x nightfox.sh
```

## 🚀 Usage

```bash
./nightfox.sh -d example.com
./nightfox.sh -d example.com -o output/example.txt
./nightfox.sh -d example.com -w wordlists/custom.txt
```
