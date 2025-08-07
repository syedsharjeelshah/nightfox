# 📘 NIGHTFOX Usage Guide

## 🛠️ Dependencies

Make sure the following tools are installed:

- `whois`
- `dig`
- `host`
- `ping`
- (optional) `subfinder`

### 🔽 Install subfinder

```bash
sudo apt install subfinder -y
```

### 🚀 Basic Usage

```bash
./nightfox.sh -d example.com
```

### ➕ Optional Flags

```bash
./nightfox.sh -d example.com -o output/example.txt
./nightfox.sh -d example.com -w wordlists/custom.txt
```
### 📁 Auto Wordlist Feature

If rockyou_subs.txt is missing, it will be auto-generated using rockyou.txt (filtered).

### 📤 Output

All findings are logged to:

```bash
output/report.txt
```

### 📍 Notes

Use responsibly for authorized testing only

Recommended for Red Teamers, OSINT researchers, and bug bounty hunters









