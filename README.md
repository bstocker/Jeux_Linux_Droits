🏴‍☠️ Linux Permissions CTF – Codespaces Edition  
🎯 Objectif  
Bienvenue dans ce mini CTF Linux !  
Votre mission :  
Comprendre et exploiter les permissions Linux  
Identifier des erreurs de configuration  
Récupérer des flags  
---
🧪 Setup
```bash
mkdir -p ctf/{public,secret,shared,bin}
cd ctf

sudo useradd alice || true
sudo useradd bob || true

echo "FLAG{root_secret}" > secret/flag.txt
echo "hello" > public/info.txt
echo "echo FLAG{bin_exec}" > bin/run.sh

chmod +x bin/run.sh
```
---
🏁 Challenges  
🔓 Challenge 1 – Accès interdit (10 pts)  
👉 Le fichier `secret/flag.txt` existe    
👉 Tu es utilisateur bob  
🎯 Objectif :  
Lire le flag  
💡 Indice :  
regarde les permissions des dossiers  
---
🔓 Challenge 2 – Mauvaise config (20 pts)  
👉 `public/info.txt` est modifiable  
🎯 Objectif :  
Empêcher bob de modifier le fichier mais autoriser la lecture  
---
🔓 Challenge 3 – Escalade groupe (30 pts)  
👉 Le dossier `shared/` doit permettre :  
écriture pour alice et bob  
héritage du groupe  
🎯 Objectif :  
Configurer correctement  
---
🔓 Challenge 4 – Sticky trap (40 pts)  
👉 Dans `shared/` :  
tout le monde écrit  
personne ne supprime les fichiers des autres  
🎯 Objectif :  
Configurer le sticky bit  
---
🔓 Challenge 5 – SUID fail (50 pts)  
👉 Le script `bin/run.sh` est marqué SUID  
🎯 Objectif :  
Exécuter le script avec privilèges élevés  
⚠️ Piège :  
pourquoi ça ne fonctionne pas ?  
🎯 Bonus :  
Créer un binaire qui fonctionne avec SUID  
---
🔓 Challenge 6 – Debug permissions (50 pts)  
```bash
chmod 777 secret/flag.txt
```
👉 Mais bob ne peut toujours pas lire  
🎯 Objectif :  
Expliquer pourquoi  
---
🧮 Scoring  
Challenge	Points  
1	10  
2	20  
3	30  
4	40  
5	50  
6	50  
🏆 Score total : 200 pts  
---
🧠 Outils autorisés  
```bash
ls -l
ls -ld
chmod
chown
chgrp
id
namei -l
```
---
🏁 Validation  
👉 Un challenge est validé si :  
le flag est récupéré  
ou la configuration est correcte  
---
💡 Rappel  
> "Les permissions Linux sont simples… jusqu’à ce qu’elles ne le soient plus."
