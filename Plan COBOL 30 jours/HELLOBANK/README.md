# PROJET HELLOBANK - COBOL / JCL BATCH MAINFRAME
**Niveau : Débutant**
**User ID : Z74830**

## 1. Objectif du projet

`HELLOBANK` est un programme COBOL batch simple qui simule la gestion
de comptes bancaires :
- Lecture d'un fichier de **clients** (numéro de compte, nom, solde initial)
- Lecture d'un fichier de **transactions** (dépôts `D` / retraits `W`)
- Calcul du solde final de chaque client
- Production d'un **rapport** (fichier séquentiel) avec le détail par
  client et les totaux généraux

C'est un exercice classique pour apprendre :
- la structure d'un programme COBOL (FD, WORKING-STORAGE, PROCEDURE DIVISION)
- la lecture séquentielle de plusieurs fichiers en parallèle (rupture de contrôle)
- la compilation/link-edit et l'exécution en JCL batch sur z/OS

## 2. Contenu du zip

```
HELLOBANK/
├── src/
│   └── HELLOBANK.cbl       -> Programme COBOL source
├── jcl/
│   ├── ALLOCATE.jcl        -> Création des datasets (à lancer une seule fois)
│   ├── COMPLINK.jcl        -> Compilation + Link-edit du programme
│   └── RUNBANK.jcl         -> Exécution batch du programme
├── data/
│   ├── CLIENTS.txt         -> Jeu de données clients (exemple, 80 car./ligne)
│   └── TRANS.txt           -> Jeu de données transactions (exemple, 80 car./ligne)
└── README.md               -> Ce fichier
```

## 3. Format des enregistrements (80 caractères, fixe FB)

### CLIENTS (CL-ACCOUNT-ID / CL-NAME / CL-BALANCE)
| Colonnes | Champ          | Type           | Exemple              |
|----------|----------------|----------------|-----------------------|
| 1-5      | N° de compte   | 9(5)           | 00001                 |
| 6-25     | Nom du client  | X(20)          | ANDRIAMANANA HERY    |
| 26-34    | Solde initial  | 9(7)V99 (cts)  | 000150000 = 1 500,00  |
| 35-80    | Filler         | X(46)          | (espaces)             |

### TRANSACTIONS (TR-ACCOUNT-ID / TR-TYPE / TR-AMOUNT)
| Colonnes | Champ          | Type           | Exemple              |
|----------|----------------|----------------|-----------------------|
| 1-5      | N° de compte   | 9(5)           | 00001                 |
| 6        | Type           | X(1) D ou W    | D                      |
| 7-15     | Montant        | 9(7)V99 (cts)  | 000050000 = 500,00     |
| 16-80    | Filler         | X(65)          | (espaces)              |

⚠️ **Important** : les deux fichiers doivent être **triés par numéro de
compte croissant** (le programme fait une rupture de contrôle simple,
sans tri interne).

## 4. Tester le projet

### 4.1 Test local rapide (sans mainframe), AVANT de déployer

Un script `test_local.sh` est fourni pour valider la **logique du
programme** sur votre PC/Mac/Linux, avec le compilateur libre
**GnuCOBOL**, avant de toucher au mainframe.

```bash
# Installer GnuCOBOL (une seule fois)
sudo apt-get install gnucobol3        # Ubuntu/Debian
brew install gnu-cobol                # macOS

# Lancer le test
chmod +x test_local.sh
./test_local.sh
```

✅ Ce projet a été testé avec ce script : le rapport produit est
exactement celui montré en section 5 ci-dessous (11 800,00 de total,
5 clients).

⚠️ Le script crée une **copie temporaire** du `.cbl` avec
`ORGANIZATION IS LINE SEQUENTIAL` au lieu de `SEQUENTIAL`, car
GnuCOBOL a besoin de ce mode pour lire un fichier texte classique
(avec retours à la ligne). **Le fichier livré dans `src/HELLOBANK.cbl`
n'est pas modifié** — il reste en `ORGANIZATION IS SEQUENTIAL`, qui
est la bonne instruction pour les datasets z/OS à blocs fixes (FB),
sans retour à la ligne. Ne changez donc rien avant de l'envoyer au
mainframe.

### 4.2 Test réel sur mainframe (z/OS)

Une fois le test local validé, suivez la section 5 ci-dessous pour
soumettre les JCL sur le vrai mainframe (ALLOCATE → COMPLINK → RUNBANK)
et vérifier le résultat via SDSF.

## 5. Étapes d'installation sur le mainframe

### Étape 1 — Transférer les fichiers
Transférez (FTP/SFTP, Zowe, ou copier/coller en ISPF edit) :
- `src/HELLOBANK.cbl` → membre `HELLOBNK` du PDS `Z74830.HELLOBNK.COBOL`
- `data/CLIENTS.txt`  → dataset séquentiel `Z74830.HELLOBNK.CLIENTS`
- `data/TRANS.txt`    → dataset séquentiel `Z74830.HELLOBNK.TRANS`

Si le transfert se fait en mode texte ASCII→EBCDIC, vérifiez que le
fichier reste bien en **RECFM=FB, LRECL=80** sans retours chariot
supplémentaires.

### Étape 2 — Allouer les datasets
Soumettez **une seule fois** : `jcl/ALLOCATE.jcl`
> Adaptez les paramètres `UNIT=` et `VOL=` selon les normes de votre
> shop (ils ont été volontairement omis pour rester génériques —
> beaucoup de mainframes z/OS utilisent le SMS, donc souvent inutiles).

### Étape 3 — Compiler et linker le programme
Soumettez : `jcl/COMPLINK.jcl`
> Le nom de PROC `IGYWCL` est la procédure standard IBM Enterprise
> COBOL pour compiler + linker en une seule étape. Si votre
> établissement utilise une autre PROC (ex: `COBUCLG`, `DB2COB`,
> proc maison), remplacez `IGYWCL` par le nom approprié — demandez
> à votre support technique mainframe si besoin.

Vérifiez dans SDSF/SYSPRINT qu'il n'y a **pas d'erreur de compilation**
(code retour `RC=0000` ou `RC=0004` max).

### Étape 4 — Exécuter le programme
Soumettez : `jcl/RUNBANK.jcl`

Le rapport sera créé dans `Z74830.HELLOBNK.REPORT`.
Consultez-le en ISPF (option 3.4 puis édition/affichage du dataset).

## 6. Résultat attendu (avec le jeu de données fourni)

✅ Sortie réellement obtenue lors du test (`./test_local.sh`) :

```
   HELLOBANK - RAPPORT DE COMPTES

ID   NOM CLIENT          SOLDE INITIAL  DEPOTS         RETRAITS       SOLDE FINAL

00001 ANDRIAMANANA HERY         1,500.00          500.00          200.00        1,800.00
00002 RABE LALAINA                500.00        1,000.00            0.00        1,500.00
00003 RAKOTO FANOMEZANTSOA      3,000.00            0.00        1,500.00        1,500.00
00004 RASOA NOROVOLOLONA            0.00            0.00            0.00            0.00
00005 RAJOELINA TOJO            7,500.00          250.00          750.00        7,000.00

NOMBRE DE CLIENTS :     5          TOTAL DES SOLDES :         11,800.00
```

## 7. Pistes d'évolution (pour progresser)

- Ajouter un contrôle : refuser un retrait si le solde devient négatif
- Trier les fichiers en JCL avec `SORT` (DFSORT) avant l'exécution
- Remplacer les fichiers séquentiels par des fichiers VSAM (KSDS)
- Ajouter une copybook commune (`COPY` dans `Z74830.HELLOBNK.COPY`)
  pour partager les layouts entre plusieurs programmes
- Ajouter la gestion des SYSOUT/abends avec un step `IDCAMS` de
  vérification avant le run

---
*Projet pédagogique créé pour Z74830 — niveau débutant COBOL/JCL batch.*
