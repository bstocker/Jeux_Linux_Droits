# Jeu des droits Linux

> « Les permissions Linux sont simples… jusqu'à ce qu'elles ne le soient plus. »

Bienvenue dans ce petit jeu sur les **droits des fichiers sous Linux**.
En 5 étapes, vous allez apprendre à lire les droits, puis à les modifier pour
protéger ou partager des fichiers.

---

## Mise en route

1. Forkez ce dépôt, puis cliquez sur **Code** → **Create codespace on main**.
2. Attendez la fin de l'installation : le script `setup.sh` se lance tout seul.
3. Dans le terminal, vérifiez que tout est prêt :

```bash
whoami          # votre utilisateur (vscode)
id bob          # bob existe et fait partie du groupe ctfgroup
ls ctf/         # les dossiers des 5 étapes
```

À tout moment :

```bash
bash check.sh   # vérifier vos réponses et voir votre score
bash setup.sh   # tout remettre à zéro si vous êtes bloqué
```

### Les personnages

| Utilisateur | Groupe | Rôle |
|---|---|---|
| vous (`vscode`) | | l'administrateur, vous avez le droit d'utiliser `sudo` |
| `alice` | `ctfgroup` | membre de l'équipe |
| `bob` | `ctfgroup` | membre de l'équipe |
| `eve` | | une personne extérieure à l'équipe |

Pour lancer une commande **à la place de bob** :

```bash
sudo -u bob cat ctf/etape3/info.txt
```

---

## Rappel : lire les droits

```
$ ls -l ctf/etape1/rapport.txt
-rw-r----- 1 alice ctfgroup 17 oct. 15 10:00 rapport.txt
│└┬┘└┬┘└┬┘   └─┬─┘ └──┬───┘
│ │  │  │      │      └── groupe du fichier
│ │  │  │      └───────── propriétaire du fichier
│ │  │  └── droits des autres       (---  : rien)
│ │  └───── droits du groupe        (r--  : lire)
│ └──────── droits du propriétaire  (rw-  : lire et écrire)
└────────── type : - fichier, d dossier
```

| Lettre | Sur un fichier | Sur un dossier |
|---|---|---|
| `r` | lire le contenu | lister ce qu'il contient (`ls`) |
| `w` | modifier le contenu | créer ou supprimer des fichiers dedans |
| `x` | exécuter (programme, script) | **entrer** dedans (`cd`) et atteindre ses fichiers |

**En chiffres** : `r` = 4, `w` = 2, `x` = 1. On additionne pour chaque catégorie.
Exemple : `rw-r-----` → 4+2 / 4 / 0 → **640**.

---

## Étape 1 – Lire ls -l `10 pts`

Regardez les fichiers de l'étape 1 :

```bash
ls -l ctf/etape1/
```

Puis répondez dans le fichier `reponses.txt` (ouvrez-le dans l'éditeur) :

| | Question | Exemple de réponse |
|---|---|---|
| Q1 | Qui est le propriétaire de `rapport.txt` ? | un nom d'utilisateur |
| Q2 | bob peut-il **lire** `rapport.txt` ? | `oui` ou `non` |
| Q3 | bob peut-il **modifier** `rapport.txt` ? | `oui` ou `non` |
| Q4 | alice peut-elle **lire** `notes.txt` ? | `oui` ou `non` |
| Q5 | Quels sont les droits de `affiche.txt` en chiffres ? | 3 chiffres, comme `640` |

Exemple de ligne remplie : `Q1=alice`

<details>
<summary>Indice</summary>

Pour savoir à quelle catégorie bob appartient, demandez-vous dans l'ordre :
est-il le propriétaire ? Sinon, est-il dans le groupe du fichier (`id bob`) ?
Sinon, il fait partie des « autres ».

</details>

---

## Étape 2 – Rendre un script exécutable `10 pts`

Le script `ctf/etape2/bonjour.sh` refuse de se lancer :

```bash
./ctf/etape2/bonjour.sh
# bash: ./ctf/etape2/bonjour.sh: Permission denied
```

**Objectif :** rendre le script exécutable pour vous, puis le lancer pour obtenir le flag.

**Commande utile :** `chmod` (voir `man chmod`).

<details>
<summary>Indice</summary>

`chmod` accepte une forme lisible : **qui** (`u` propriétaire, `g` groupe, `o` autres),
puis `+` ou `-`, puis **quel droit** (`r`, `w`, `x`).

</details>

---

## Étape 3 – Protéger un fichier `10 pts`

Le fichier `ctf/etape3/info.txt` peut être modifié par **n'importe qui**.
Essayez :

```bash
sudo -u bob bash -c "echo 'bob était là' >> ctf/etape3/info.txt"
cat ctf/etape3/info.txt
```

**Objectif :** que bob puisse toujours **lire** le fichier, mais plus le **modifier**.

<details>
<summary>Indice</summary>

bob n'est ni le propriétaire, ni dans le groupe du fichier : il fait partie des « autres ».
Retirez seulement le droit qui pose problème.

</details>

---

## Étape 4 – Ouvrir un dossier à son équipe `10 pts`

Le fichier `ctf/etape4/secret/flag.txt` est en `rw-r--r--` : tout le monde devrait pouvoir le lire.
Et pourtant :

```bash
sudo -u bob cat ctf/etape4/secret/flag.txt
# cat: ctf/etape4/secret/flag.txt: Permission denied
```

**Objectif :** que bob (membre de `ctfgroup`) puisse lire le flag,
mais **pas eve** (qui n'est pas dans le groupe).

**Commande utile :** `namei -l ctf/etape4/secret/flag.txt` affiche les droits de chaque dossier du chemin.

<details>
<summary>Indice</summary>

Pour atteindre un fichier, il faut pouvoir **entrer** dans chaque dossier du chemin.
Quel droit permet d'entrer dans un dossier ? Et à qui faut-il le donner ?

</details>

---

## Étape 5 – Un dossier de projet commun `10 pts`

alice et bob veulent travailler ensemble dans `ctf/etape5/projet/`.

**Objectif :** qu'alice et bob puissent tous les deux **créer des fichiers** dans `projet/`,
mais **pas eve**.

**Commandes utiles :** `chgrp` (changer le groupe), `chmod`.
Comme vous n'êtes pas membre de `ctfgroup`, `chgrp` doit être lancé avec `sudo`.

Testez :

```bash
sudo -u alice touch ctf/etape5/projet/alice.txt   # doit marcher
sudo -u eve touch ctf/etape5/projet/eve.txt       # doit être refusé
```

<details>
<summary>Indice</summary>

Deux choses à faire : donner le dossier au bon groupe, puis donner à ce groupe le droit d'écrire.

</details>

---

## Bonus `5 pts chacun`

Pour aller plus loin, toujours sur `ctf/etape5/projet/` :

> ⚠️ Lancez **toutes** les commandes `chmod` du bonus avec `sudo`. Vous n'êtes pas membre de
> `ctfgroup` : sans `sudo`, Linux retire le setgid en silence à chaque `chmod`.

**Bonus A – setgid.** Créez un fichier en tant qu'alice et regardez son groupe avec `ls -l`.
On voudrait que les nouveaux fichiers appartiennent automatiquement au groupe `ctfgroup`.
Cherchez le **setgid** dans `man chmod` (`chmod g+s`).

**Bonus B – sticky bit.** En l'état, bob peut **supprimer** les fichiers d'alice :

```bash
sudo -u alice touch ctf/etape5/projet/a_garder.txt
sudo -u bob rm ctf/etape5/projet/a_garder.txt
```

Activez le **sticky bit** (`chmod +t`) pour que chacun ne puisse supprimer que ses propres fichiers.
C'est ce que fait le dossier `/tmp` : regardez `ls -ld /tmp`.

**Question de réflexion (sans points) – le SUID.** Le bit SUID (`chmod u+s`) permet à un programme
de s'exécuter avec les droits de son propriétaire, quel que soit l'utilisateur qui le lance.
Regardez `ls -l /usr/bin/passwd` : pourquoi cette commande en a-t-elle besoin ?

<details>
<summary>Réponse</summary>

`passwd` doit modifier `/etc/shadow`, qui n'est modifiable que par root.
Grâce au SUID, n'importe quel utilisateur peut changer son propre mot de passe :
le programme s'exécute alors avec les droits de root.
C'est puissant, donc dangereux. Par sécurité, Linux ignore d'ailleurs le SUID sur les scripts shell.

</details>

---

## Aide-mémoire

```bash
ls -l fichier          # droits d'un fichier
ls -ld dossier         # droits d'un dossier (et non de son contenu)
stat -c "%a" fichier   # droits en chiffres
id bob                 # utilisateur et groupes de bob
namei -l chemin        # droits de chaque dossier d'un chemin
chmod u+x fichier      # ajouter un droit (u, g, o / r, w, x)
chmod o-w fichier      # retirer un droit
chmod 640 fichier      # fixer les droits en chiffres
chgrp groupe fichier   # changer le groupe
sudo -u bob commande   # lancer une commande en tant que bob
```
