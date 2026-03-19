#!/bin/sh

echo "[+] Creating users"
adduser -D alice 2>/dev/null || true
adduser -D bob 2>/dev/null || true

echo "[+] Setting up flags"

echo "FLAG{secret_root}" > ctf/secret/flag.txt
chmod 700 ctf/secret

echo "FLAG{public_read}" > ctf/public/info.txt
chmod 666 ctf/public/info.txt

echo "echo FLAG{SUID_FAIL}" > ctf/bin/run.sh
chmod +x ctf/bin/run.sh

echo "[+] Done"
