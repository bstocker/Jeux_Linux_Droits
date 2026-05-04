#!/bin/bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${BLUE}[setup]${NC} $1"; }
ok()  { echo -e "${GREEN}[ok]${NC}    $1"; }

echo "================================================"
echo "   CTF Linux Droits - Initialisation"
echo "================================================"
echo ""

# Groupe et utilisateurs
log "Création du groupe ctfgroup et des utilisateurs alice/bob..."
sudo groupadd ctfgroup 2>/dev/null || true
sudo useradd -m -s /bin/bash -G ctfgroup alice 2>/dev/null || true
sudo useradd -m -s /bin/bash -G ctfgroup bob   2>/dev/null || true
ok "Utilisateurs créés (groupe: ctfgroup)"

# Structure
log "Création des répertoires ctf/..."
mkdir -p ctf/{public,secret,shared,bin}

# ── Challenge 1 & 6 ──────────────────────────────────
# secret/ appartient à root:ctfgroup avec permissions 750
# → bob (membre de ctfgroup) peut lire → MISCONFIGURATION à découvrir (ch.1)
# → après correction en 700, chmod 777 sur le fichier ne suffit pas (ch.6)
log "Challenge 1 – ctf/secret/"
echo "FLAG{gr0up_l34k_c0nf1g}" | sudo tee ctf/secret/flag.txt > /dev/null
sudo chown root:ctfgroup ctf/secret/flag.txt
sudo chmod 640 ctf/secret/flag.txt
sudo chown root:ctfgroup ctf/secret/
sudo chmod 750 ctf/secret/

# ── Challenge 2 ──────────────────────────────────────
# public/info.txt est world-writable → MISCONFIGURATION à corriger
log "Challenge 2 – ctf/public/"
echo "Bienvenue sur le serveur CTF." | sudo tee ctf/public/info.txt > /dev/null
sudo chown root:root ctf/public/info.txt
sudo chmod 666 ctf/public/info.txt
sudo chown root:root ctf/public/
sudo chmod 755 ctf/public/

# ── Challenge 3 & 4 ──────────────────────────────────
# shared/ sans setgid ni sticky bit → à configurer
log "Challenge 3/4 – ctf/shared/"
sudo chown root:ctfgroup ctf/shared/
sudo chmod 775 ctf/shared/

# ── Challenge 5 ──────────────────────────────────────
# run.sh avec SUID positionné sur un script shell → piège
log "Challenge 5 – ctf/bin/"
sudo tee ctf/bin/run.sh > /dev/null << 'SCRIPT'
#!/bin/bash
echo "FLAG{su1d_m4st3r}"
SCRIPT
sudo chown root:root ctf/bin/run.sh
sudo chmod 4755 ctf/bin/run.sh
sudo chown root:root ctf/bin/
sudo chmod 755 ctf/bin/

echo ""
ok "Environnement CTF prêt !"
echo ""
echo "  Utilisateurs : alice, bob  (groupe: ctfgroup)"
echo "  ctf/secret/  → mode 750, root:ctfgroup     (ch.1 & ch.6)"
echo "  ctf/public/  → info.txt mode 666           (ch.2)"
echo "  ctf/shared/  → mode 775, pas setgid/sticky (ch.3 & ch.4)"
echo "  ctf/bin/     → run.sh SUID shell            (ch.5)"
echo ""
echo "  Pour valider vos réponses : bash check.sh"
echo "================================================"
