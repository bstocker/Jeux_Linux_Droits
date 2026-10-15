#!/bin/bash
# Vérifie chaque étape en testant ce qui se passe vraiment :
# « bob peut-il lire ce fichier ? » plutôt que de décoder les chiffres des droits.
cd "$(dirname "$0")"

VERT='\033[0;32m'
ROUGE='\033[0;31m'
JAUNE='\033[1;33m'
BLEU='\033[0;34m'
NC='\033[0m'

SCORE=0
BONUS=0

titre()  { echo -e "${JAUNE}$1${NC}"; }
reussi() { echo -e "  ${VERT}✓ Réussi${NC} – $1"; SCORE=$((SCORE + $2)); }
rate()   { echo -e "  ${ROUGE}✗ Pas encore${NC} – $1"; }
indice() { echo -e "  ${BLEU}💡 Indice :${NC} $1"; }

# peut <utilisateur> <lire|ecrire|entrer> <chemin>
# Exemple : peut bob lire ctf/etape3/info.txt
# On passe par le « test » intégré à bash : sur certaines images, le programme
# /usr/bin/test ignore les groupes secondaires et se trompe pour bob.
peut() {
    case "$2" in
        lire)   sudo -u "$1" bash -c 'test -r "$0"' "$3" ;;
        ecrire) sudo -u "$1" bash -c 'test -w "$0"' "$3" ;;
        entrer) sudo -u "$1" bash -c 'test -x "$0"' "$3" ;;
    esac
}

# Créer un fichier dans un dossier demande d'y écrire ET d'y entrer.
peut_creer_dans() { peut "$1" ecrire "$2" && peut "$1" entrer "$2"; }

# Affiche « oui » si la commande réussit, « non » sinon.
oui_non() { if "$@"; then echo "oui"; else echo "non"; fi; }

# Lit la réponse Qn dans reponses.txt (sans espaces, en minuscules).
reponse() { grep "^$1=" reponses.txt 2>/dev/null | cut -d= -f2 | tr -d ' ' | tr 'A-Z' 'a-z'; }

if [ ! -d ctf ]; then
    echo "Le dossier ctf/ n'existe pas : lancez d'abord  bash setup.sh"
    exit 1
fi

echo "================================================"
echo "   Jeu des droits Linux – Vérification"
echo "================================================"
echo ""

# ── Étape 1 – Lire ls -l ─────────────────────────────
titre "Étape 1 – Lire ls -l (10 pts)"
# Les bonnes réponses sont calculées à partir des vrais fichiers.
ATTENDU_Q1=$(stat -c "%U" ctf/etape1/rapport.txt)
ATTENDU_Q2=$(oui_non peut bob lire ctf/etape1/rapport.txt)
ATTENDU_Q3=$(oui_non peut bob ecrire ctf/etape1/rapport.txt)
ATTENDU_Q4=$(oui_non peut alice lire ctf/etape1/notes.txt)
ATTENDU_Q5=$(stat -c "%a" ctf/etape1/affiche.txt)

BONNES=0
for q in Q1 Q2 Q3 Q4 Q5; do
    attendu_var="ATTENDU_$q"
    if [ "$(reponse $q)" = "${!attendu_var}" ]; then
        BONNES=$((BONNES + 1))
    else
        rate "$q incorrecte ou pas encore remplie"
    fi
done
if [ "$BONNES" -eq 5 ]; then
    reussi "5 bonnes réponses sur 5" 10
else
    indice "$BONNES/5 bonnes réponses. Relisez le rappel en haut du README."
fi
echo ""

# ── Étape 2 – Rendre un script exécutable ────────────
titre "Étape 2 – Rendre un script exécutable (10 pts)"
if [ -x ctf/etape2/bonjour.sh ]; then
    reussi "bonjour.sh est exécutable" 10
else
    rate "bonjour.sh n'est pas exécutable"
    indice "Quelle lettre veut dire « exécuter » ? Et qui doit avoir ce droit ?"
fi
echo ""

# ── Étape 3 – Protéger un fichier ────────────────────
titre "Étape 3 – Protéger un fichier (10 pts)"
if ! peut bob lire ctf/etape3/info.txt; then
    rate "bob ne peut plus lire info.txt : vous avez retiré trop de droits"
    indice "Il faut seulement empêcher d'écrire, pas de lire."
elif peut bob ecrire ctf/etape3/info.txt; then
    rate "bob peut encore modifier info.txt"
    indice "Regardez les 3 derniers caractères de ls -l : ce sont les droits des « autres »."
else
    reussi "bob peut lire info.txt mais plus le modifier" 10
fi
echo ""

# ── Étape 4 – Ouvrir un dossier à son équipe ─────────
titre "Étape 4 – Ouvrir un dossier à son équipe (10 pts)"
if ! peut bob lire ctf/etape4/secret/flag.txt; then
    rate "bob ne peut pas lire ctf/etape4/secret/flag.txt"
    indice "Le fichier est en rw-r--r--… le problème vient-il vraiment du fichier ?"
    indice "Essayez : namei -l ctf/etape4/secret/flag.txt"
elif peut eve lire ctf/etape4/secret/flag.txt; then
    rate "bob peut lire le flag… mais eve aussi ! Le secret est ouvert à tout le monde"
    indice "Ouvrez le dossier au groupe seulement, pas aux « autres »."
else
    reussi "bob lit le flag, eve reste dehors" 10
fi
echo ""

# ── Étape 5 – Un dossier de projet commun ────────────
titre "Étape 5 – Un dossier de projet commun (10 pts)"
PROJET=ctf/etape5/projet
if [ "$(stat -c "%G" $PROJET)" != "ctfgroup" ]; then
    rate "le groupe de projet/ n'est pas ctfgroup (actuel : $(stat -c "%G" $PROJET))"
    indice "Une commande permet de changer le groupe d'un fichier : chgrp."
elif ! peut_creer_dans alice $PROJET || ! peut_creer_dans bob $PROJET; then
    rate "alice et bob ne peuvent pas encore créer de fichiers dans projet/"
    indice "Le groupe est bon. Quel droit manque-t-il au groupe ?"
elif peut_creer_dans eve $PROJET; then
    rate "eve peut aussi créer des fichiers dans projet/ : c'est trop ouvert"
else
    reussi "alice et bob peuvent travailler dans projet/, eve non" 10
fi
echo ""

# ── Bonus ─────────────────────────────────────────────
titre "Bonus (5 pts chacun)"
if [ -g $PROJET ]; then
    reussi "setgid activé sur projet/" 0; BONUS=$((BONUS + 5))
else
    rate "setgid pas encore activé sur projet/"
    indice "Utilisez sudo pour chaque chmod du bonus (sudo chmod g+s ...)."
fi
if [ -k $PROJET ]; then
    reussi "sticky bit activé sur projet/" 0; BONUS=$((BONUS + 5))
else
    rate "sticky bit pas encore activé sur projet/"
fi
echo ""

# ── Score ─────────────────────────────────────────────
echo "================================================"
if [ "$SCORE" -eq 50 ]; then
    echo -e "   Score : ${VERT}${SCORE} / 50 pts${NC} 🏆   Bonus : +${BONUS} / 10"
else
    echo -e "   Score : ${SCORE} / 50 pts   Bonus : +${BONUS} / 10"
fi
echo "================================================"
