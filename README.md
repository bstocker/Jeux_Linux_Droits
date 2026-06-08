# CTF Linux Droits – Codespaces Edition

> "Les permissions Linux sont simples… jusqu'à ce qu'elles ne le soient plus."

Bienvenue dans ce mini CTF pédagogique sur les **permissions Linux**.  
Votre mission : comprendre et exploiter les droits, identifier des misconfigurations, et récupérer des flags.

---

## Mise en route

### 1. Lancer le projet dans Codespaces

- Forkez / clonez ce dépôt
- Cliquez sur **Code** → **Create codespace on main**
- Le script `./setup.sh` s'exécute automatiquement et configure tout l'environnement

### 2. Vérifier l'environnement

```bash
# Vérifier que les utilisateurs existent
id alice
id bob

# Vérifier la structure des dossiers
ls -lR ctf/
```

### 3. Valider vos réponses

```bash
bash check.sh
```

---

## Challenges

| # | Nom | Points |
|---|-----|--------|
| 1 | Accès interdit | 10 |
| 2 | Mauvaise config | 20 |
| 3 | Escalade groupe | 30 |
| 4 | Sticky trap | 40 |
| 5 | SUID fail | 50 |
| 6 | Debug permissions | 50 |
| | **Total** | **200** |

---

### Challenge 1 – Accès interdit `10 pts`

**Contexte :** Le fichier `ctf/secret/flag.txt` contient un flag. Vous êtes connecté en tant que `bob`.

**Objectif :** Lire le flag.

**Indice :** Regardez attentivement les permissions du répertoire `secret/` et le groupe auquel appartient `bob`.

```bash
ls -ld ctf/secret/
ls -l ctf/secret/flag.txt
id bob
```

---

### Challenge 2 – Mauvaise config `20 pts`

**Contexte :** `ctf/public/info.txt` est modifiable par n'importe qui.

**Objectif :** Corriger les permissions pour que `bob` puisse **lire** le fichier mais **pas l'écrire**.

**Vérification :**
```bash
# Avant correction
sudo -u bob bash -c "echo test >> ctf/public/info.txt"  # doit réussir

# Après correction
sudo -u bob bash -c "echo test >> ctf/public/info.txt"  # doit échouer
sudo -u bob cat ctf/public/info.txt                     # doit réussir
```

---

### Challenge 3 – Escalade groupe `30 pts`

**Contexte :** Le dossier `ctf/shared/` doit permettre à `alice` et `bob` d'écrire des fichiers en **héritant automatiquement du groupe** `ctfgroup`.

**Objectif :** Configurer correctement `ctf/shared/` avec le bon groupe et le **setgid bit**.

**Comportement attendu :**
```bash
sudo -u alice touch ctf/shared/fichier_alice.txt
stat -c "%G" ctf/shared/fichier_alice.txt  # doit afficher ctfgroup
```

**Commandes utiles :**
```bash
chmod g+s  # activer le setgid bit
chown :groupe  # changer le groupe propriétaire
```

---

### Challenge 4 – Sticky trap `40 pts`

**Contexte :** `ctf/shared/` autorise tout le monde à écrire, mais `bob` peut supprimer les fichiers d'`alice`.

**Objectif :** Configurer le **sticky bit** pour que chacun ne puisse supprimer que ses propres fichiers.

**Comportement attendu :**
```bash
sudo -u alice touch ctf/shared/alice.txt
sudo -u bob rm ctf/shared/alice.txt  # doit être refusé
```

**Commande :**
```bash
chmod +t ctf/shared/
```

> Le sticky bit est reconnaissable au `t` à la fin : `drwxrwxrwt`

---

### Challenge 5 – SUID fail `50 pts`

**Contexte :** Le script `ctf/bin/run.sh` est marqué SUID (`chmod 4755`).

**Objectif :** Exécuter le script avec les privilèges de `root`.

**Constat :**
```bash
ls -l ctf/bin/run.sh    # affiche -rwsr-xr-x
./ctf/bin/run.sh        # le script s'exécute mais PAS en tant que root
```

**Question :** Pourquoi le SUID ne fonctionne-t-il pas sur ce script ?

<details>
<summary>Réponse</summary>

Le noyau Linux **ignore le bit SUID sur les scripts shell** (fichiers texte avec shebang).  
Cette protection existe depuis les années 90 pour éviter des race conditions dangereuses.  
Seuls les **binaires ELF compilés** peuvent bénéficier du SUID.

</details>

**Bonus :** Créez un binaire C avec SUID qui affiche le flag.

```c
// ctf/bin/run_suid.c
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Effectif UID: %d\n", geteuid());
    printf("FLAG{su1d_m4st3r}\n");
    return 0;
}
```

```bash
gcc -o ctf/bin/run_suid ctf/bin/run_suid.c
sudo chown root ctf/bin/run_suid
sudo chmod 4755 ctf/bin/run_suid
./ctf/bin/run_suid  # s'exécute en tant que root
```

---

### Challenge 6 – Debug permissions `50 pts`

**Contexte :** Un administrateur a exécuté la commande suivante pour rendre le flag lisible par tous :

```bash
sudo chmod 777 ctf/secret/flag.txt
```

Pourtant, `bob` ne peut **toujours pas** lire le fichier.

**Objectif :** Expliquer pourquoi l'accès est toujours refusé.

**Investigation :**
```bash
namei -l ctf/secret/flag.txt
ls -ld ctf/secret/
ls -l ctf/secret/flag.txt
```

<details>
<summary>Réponse</summary>

Les permissions d'un fichier ne s'appliquent que si **chaque répertoire parent est traversable** (bit `x`).  
Si `ctf/secret/` est en mode `700` (propriétaire root), `bob` ne peut pas y entrer,  
quel que soit le mode du fichier à l'intérieur.

**Règle :** Pour accéder à `/a/b/c`, il faut le bit `x` sur `/a/`, `/a/b/`, puis les droits sur `c`.

</details>

---

## Outils de référence

```bash
ls -l          # afficher les permissions d'un fichier
ls -ld         # afficher les permissions d'un répertoire
stat -c "%a"   # afficher les permissions en octal
id             # afficher l'utilisateur et ses groupes
groups <user>  # groupes d'un utilisateur
namei -l       # décomposer les permissions sur un chemin complet
chmod          # modifier les permissions
chown          # modifier le propriétaire
chgrp          # modifier le groupe
```

### Rappel des notations

| Notation | Description |
|----------|-------------|
| `rwxr-xr-x` | owner=rwx, group=r-x, others=r-x |
| `chmod 755` | équivalent octal |
| `chmod u+x` | ajouter x au propriétaire |
| `chmod g+s` | setgid bit |
| `chmod +t`  | sticky bit |
| `chmod 4755` | SUID + 755 |

---

## Validation

```bash
bash check.sh
```

Un challenge est validé si :
- le flag est récupéré, **ou**
- la configuration demandée est correcte
