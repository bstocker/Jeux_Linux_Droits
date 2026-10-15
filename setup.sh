#!/bin/bash
# Prépare le jeu : crée les utilisateurs et le dossier ctf/.
# Relancer ce script remet le jeu à zéro (vos réponses dans reponses.txt sont conservées).
set -e
cd "$(dirname "$0")"

MOI=$(id -un)          # votre utilisateur (vscode dans Codespaces)

echo "================================================"
echo "   Jeu des droits Linux – Installation"
echo "================================================"

# ── Utilisateurs ─────────────────────────────────────
# alice et bob font partie de l'équipe « ctfgroup », eve n'en fait pas partie.
echo "Création des utilisateurs alice, bob et eve..."
sudo groupadd -f ctfgroup
for utilisateur in alice bob eve; do
    id "$utilisateur" &>/dev/null || sudo useradd -m -s /bin/bash "$utilisateur"
done
sudo usermod -aG ctfgroup alice
sudo usermod -aG ctfgroup bob

# ── Dossier ctf/ tout neuf ───────────────────────────
sudo rm -rf ctf
mkdir -p ctf/etape1 ctf/etape2 ctf/etape3 ctf/etape4/secret ctf/etape5/projet
chmod 755 ctf ctf/etape1 ctf/etape2 ctf/etape3 ctf/etape4 ctf/etape5

# ── Étape 1 : lire ls -l ─────────────────────────────
echo "Rapport d'alice." | sudo tee ctf/etape1/rapport.txt > /dev/null
sudo chown alice:ctfgroup ctf/etape1/rapport.txt
sudo chmod 640 ctf/etape1/rapport.txt

echo "Notes personnelles de bob." | sudo tee ctf/etape1/notes.txt > /dev/null
sudo chown bob:bob ctf/etape1/notes.txt
sudo chmod 600 ctf/etape1/notes.txt

echo "Affiche publique." | sudo tee ctf/etape1/affiche.txt > /dev/null
sudo chown root:root ctf/etape1/affiche.txt
sudo chmod 644 ctf/etape1/affiche.txt

# ── Étape 2 : un script qui ne s'exécute pas ─────────
cat > ctf/etape2/bonjour.sh << 'SCRIPT'
#!/bin/bash
echo "Bravo, le script s'exécute ! FLAG{chm0d_u+x}"
SCRIPT
chmod 644 ctf/etape2/bonjour.sh

# ── Étape 3 : un fichier modifiable par tout le monde ─
echo "Bienvenue sur le serveur." > ctf/etape3/info.txt
chmod 666 ctf/etape3/info.txt

# ── Étape 4 : un dossier secret fermé ────────────────
echo "FLAG{tr4v3rs33_d3_d0ss13r}" > ctf/etape4/secret/flag.txt
chmod 644 ctf/etape4/secret/flag.txt
sudo chgrp ctfgroup ctf/etape4/secret ctf/etape4/secret/flag.txt
chmod 700 ctf/etape4/secret

# ── Étape 5 : un dossier de projet commun ────────────
chmod 755 ctf/etape5/projet

# ── Fichier de réponses (créé une seule fois) ────────
if [ ! -f reponses.txt ]; then
    cat > reponses.txt << 'REPONSES'
# Étape 1 – Remplacez chaque ... par votre réponse, puis lancez : bash check.sh
Q1=...
Q2=...
Q3=...
Q4=...
Q5=...
REPONSES
fi

# ── Vérification : les autres utilisateurs doivent atteindre le dossier ─
if ! sudo -u eve test -x "$PWD/ctf"; then
    echo ""
    echo "ATTENTION : alice, bob et eve ne peuvent pas entrer dans $PWD."
    echo "Un des dossiers parents leur est fermé (essayez : namei -l $PWD)."
    echo "Placez le projet ailleurs (par exemple dans /tmp) ou lancez-le dans Codespaces."
    exit 1
fi

echo ""
echo "Jeu prêt !"
echo "  Vous êtes : $MOI"
echo "  Autres utilisateurs : alice, bob (groupe ctfgroup) et eve (hors groupe)"
echo "  Les exercices sont dans le README, vos fichiers dans ctf/"
echo "  Pour vérifier vos réponses : bash check.sh"
echo "  Pour tout recommencer     : bash setup.sh"
echo "================================================"
