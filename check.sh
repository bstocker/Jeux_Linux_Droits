#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCORE=0

pass() { echo -e "  ${GREEN}✓ VALIDÉ${NC} – $1"; SCORE=$((SCORE + $2)); }
fail() { echo -e "  ${RED}✗ ÉCHEC${NC}  – $1"; }
hint() { echo -e "  ${BLUE}💡${NC} $1"; }
info() { echo -e "  ${BLUE}ℹ${NC}  $1"; }

echo "================================================"
echo "   CTF Linux Droits – Validation"
echo "================================================"
echo ""

# ── Challenge 1 – Accès interdit ─────────────────────
echo -e "${YELLOW}${BOLD}Challenge 1 – Accès interdit (10 pts)${NC}"
if sudo -u bob cat ctf/secret/flag.txt 2>/dev/null | grep -q "FLAG{"; then
    FLAG=$(sudo -u bob cat ctf/secret/flag.txt)
    pass "bob peut lire ctf/secret/flag.txt → $FLAG" 10
else
    fail "bob ne peut pas lire ctf/secret/flag.txt"
    hint "Commandes utiles : id, ls -ld ctf/secret/, ls -l ctf/secret/flag.txt"
    hint "Êtes-vous bien dans le groupe ctfgroup ? Vérifiez avec : groups bob"
fi
echo ""

# ── Challenge 2 – Mauvaise config ────────────────────
echo -e "${YELLOW}${BOLD}Challenge 2 – Mauvaise config (20 pts)${NC}"
FILE_MODE=$(stat -c "%a" ctf/public/info.txt 2>/dev/null || echo "000")
OTHERS_BITS=$(( 8#$FILE_MODE & 7 ))
if [ $(( OTHERS_BITS & 2 )) -eq 0 ]; then
    pass "info.txt n'est plus modifiable par others (mode: $FILE_MODE)" 20
else
    fail "info.txt est encore world-writable (mode: $FILE_MODE)"
    hint "Solution : sudo chmod o-w ctf/public/info.txt"
fi
echo ""

# ── Challenge 3 – Escalade groupe ────────────────────
echo -e "${YELLOW}${BOLD}Challenge 3 – Escalade groupe (30 pts)${NC}"
SHARED_MODE=$(stat -c "%a" ctf/shared/ 2>/dev/null || echo "000")
SHARED_GRP=$(stat -c "%G" ctf/shared/ 2>/dev/null || echo "?")
HAS_SETGID=$(( (8#$SHARED_MODE & 02000) != 0 ))
CH3_OK=1

if [ "$SHARED_GRP" != "ctfgroup" ]; then
    fail "shared/ n'appartient pas à ctfgroup (actuel: $SHARED_GRP)"
    hint "Solution : sudo chown :ctfgroup ctf/shared/"
    CH3_OK=0
fi
if [ "$HAS_SETGID" -eq 0 ]; then
    fail "shared/ n'a pas le setgid bit (mode: $SHARED_MODE)"
    hint "Solution : sudo chmod g+s ctf/shared/"
    CH3_OK=0
fi
if [ "$CH3_OK" -eq 1 ]; then
    pass "shared/ a le setgid bit et appartient à ctfgroup" 30
fi
echo ""

# ── Challenge 4 – Sticky trap ────────────────────────
echo -e "${YELLOW}${BOLD}Challenge 4 – Sticky trap (40 pts)${NC}"
SHARED_MODE=$(stat -c "%a" ctf/shared/ 2>/dev/null || echo "000")
HAS_STICKY=$(( (8#$SHARED_MODE & 01000) != 0 ))
if [ "$HAS_STICKY" -ne 0 ]; then
    pass "shared/ a le sticky bit (mode: $SHARED_MODE)" 40
else
    fail "shared/ n'a pas le sticky bit (mode: $SHARED_MODE)"
    hint "Solution : sudo chmod +t ctf/shared/"
fi
echo ""

# ── Challenge 5 – SUID fail ──────────────────────────
echo -e "${YELLOW}${BOLD}Challenge 5 – SUID fail (50 pts)${NC}"
echo -e "  ${BLUE}Challenge conceptuel + bonus${NC}"
RUN_MODE=$(stat -c "%a" ctf/bin/run.sh 2>/dev/null || echo "?")
info "run.sh a le SUID positionné (mode: $RUN_MODE)"
info "Mais le noyau Linux ignore le SUID sur les scripts shell."
info "Seuls les binaires ELF compilés peuvent utiliser le SUID."
echo ""

if [ -f ctf/bin/run_suid ] && [ $(( (8#$(stat -c "%a" ctf/bin/run_suid 2>/dev/null || echo 0)) & 04000 )) -ne 0 ]; then
    pass "Bonus : binaire SUID compilé trouvé dans ctf/bin/run_suid" 50
else
    info "Bonus : compilez un binaire C avec SUID pour gagner les 50 pts"
    hint "Exemple : gcc -o ctf/bin/run_suid ctf/bin/run_suid.c"
    hint "         sudo chown root ctf/bin/run_suid && sudo chmod 4755 ctf/bin/run_suid"
fi
echo ""

# ── Challenge 6 – Debug permissions ──────────────────
echo -e "${YELLOW}${BOLD}Challenge 6 – Debug permissions (50 pts)${NC}"
echo -e "  ${BLUE}Challenge conceptuel${NC}"
SECRET_MODE=$(stat -c "%a" ctf/secret/ 2>/dev/null || echo "?")
FLAG_MODE=$(stat -c "%a" ctf/secret/flag.txt 2>/dev/null || echo "?")
info "Permissions actuelles : secret/=$(${SECRET_MODE}) flag.txt=$FLAG_MODE"
info "Règle fondamentale : les permissions d'un fichier ne s'appliquent"
info "que si chaque répertoire parent est traversable (bit x)."
info "Un chmod 777 sur flag.txt ne sert à rien si secret/ est en 700."
hint "Outil : namei -l ctf/secret/flag.txt"

SECRET_OTHERS=$(( 8#$SECRET_MODE & 7 ))
if [ $(( SECRET_OTHERS & 1 )) -eq 0 ] && [ "$FLAG_MODE" = "777" ]; then
    pass "Bonne configuration démontrée : dir restrictive + fichier 777 = accès bloqué" 50
else
    hint "Pour démontrer : sudo chmod 700 ctf/secret/ && sudo chmod 777 ctf/secret/flag.txt"
    hint "Puis vérifiez que bob ne peut toujours pas lire."
fi
echo ""

# ── Score ─────────────────────────────────────────────
echo "================================================"
if [ "$SCORE" -eq 200 ]; then
    echo -e "   Score : ${GREEN}${BOLD}${SCORE} / 200 pts – Parfait ! 🏆${NC}"
elif [ "$SCORE" -ge 100 ]; then
    echo -e "   Score : ${YELLOW}${BOLD}${SCORE} / 200 pts${NC}"
else
    echo -e "   Score : ${RED}${BOLD}${SCORE} / 200 pts${NC}"
fi
echo "================================================"
