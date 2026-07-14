# TP19 — VSAM KSDS — CLIENTS.VSAM

Programme COBOL mainframe qui gère un fichier **VSAM KSDS** `CLIENTS.VSAM`
et démontre les cinq verbes demandés : **READ, WRITE, REWRITE, DELETE, START**.

Environnement visé : IBM Z Xplore (userid `Z74830`, système `S0W1`),
codage via VS Code + Zowe Explorer.

## Fichiers du projet

| Fichier          | Rôle                                                             |
|-------------------|-------------------------------------------------------------------|
| `CLIENTREC.cpy`   | Copybook de l'enregistrement VSAM (136 octets, clé `CLI-ID` 9 car.)|
| `CTLREC.cpy`      | Copybook de la carte de contrôle SYSIN (80 octets)                |
| `CLIGEST.cbl`     | Programme COBOL principal                                         |
| `DEFCLI.jcl`      | JCL IDCAMS : DEFINE CLUSTER du VSAM KSDS `CLIENTS.VSAM`            |
| `CLGCLI.jcl`      | JCL IGYWCLG : compile + link-édite + exécute, avec cartes SYSIN    |

## Enregistrement CLIENTS.VSAM (136 octets)

```
CLI-ID           PIC 9(9)             clé primaire, positions 1-9
CLI-NOM          PIC X(20)
CLI-PRENOM       PIC X(20)
CLI-ADRESSE      PIC X(30)
CLI-VILLE        PIC X(20)
CLI-TELEPHONE    PIC X(14)
CLI-SOLDE        PIC S9(7)V99 COMP-3
CLI-DATE-MAJ     PIC X(8)
FILLER           PIC X(10)
```

## Carte de contrôle SYSIN (80 octets, pilote le programme)

```
Colonne  1      : CTL-ACTION   (W/R/U/D/S)
Colonnes 2-10   : CTL-CLI-ID   PIC 9(9)
Colonnes 11-30  : CTL-NOM      PIC X(20)
Colonnes 31-50  : CTL-PRENOM   PIC X(20)
Colonnes 51-70  : CTL-VILLE    PIC X(20)
Colonnes 71-77  : CTL-SOLDE    PIC 9(7)
Colonnes 78-80  : CTL-NBR      PIC 9(3)  (utilisé par START = nb d'enreg. à lire)
```

Actions :
- `W` → **WRITE** : ajoute un client (NOM, PRENOM, VILLE, SOLDE requis)
- `R` → **READ** : consulte un client par sa clé (`CTL-CLI-ID`)
- `U` → **REWRITE** : relit puis met à jour VILLE + SOLDE d'un client existant
- `D` → **DELETE** : supprime un client par sa clé
- `S` → **START** : positionne sur la clé donnée puis enchaîne `CTL-NBR` `READ NEXT`

## Étapes d'exécution

### 1. Créer le cluster VSAM
Soumettre `DEFCLI.jcl`. Ce job supprime le cluster s'il existe déjà
(`DELETE ... SET MAXCC=0` neutralise le code retour si le cluster n'existe pas encore),
puis le redéfinit :
- `RECORDSIZE(136 136)` = longueur fixe de `CLIENT-RECORD`
- `KEYS(9 0)` = clé de 9 octets à l'offset 0 (`CLI-ID`)

### 2. Uploader les sources (Zowe Explorer)
Dans Zowe Explorer, uploader :
- `CLIENTREC.cpy` et `CTLREC.cpy` → PDS `Z74830.COBOL.COPYLIB`
- `CLIGEST.cbl` → membre `CLIGEST` du PDS `Z74830.COBOL.SOURCE`

Adapter ces noms de dataset si votre COPYLIB/SOURCE portent d'autres noms.

### 3. Compiler, lier et exécuter
Soumettre `CLGCLI.jcl`. Ce job utilise la procédure cataloguée `IGYWCLG`
(déjà validée dans vos projets précédents) :
- étape `COBOL` : compile avec `SYSLIB` pointant vers la COPYLIB
- étape `LKED` : édite les liens vers `Z74830.LOAD(CLIGEST)`
- étape `GO` : exécute le programme avec :
  - `CLIENTVS` = DD du fichier VSAM (nom du ddname utilisé dans le `SELECT`)
  - `SYSIN` = les 9 cartes de démonstration (5 WRITE, 1 READ, 1 REWRITE,
    1 DELETE, 1 START qui parcourt 5 enregistrements)

### 4. Lire les résultats
Le rapport SYSOUT de l'étape `GO` affiche, pour chaque carte, le statut
de l'opération (OK/KO) et un bilan final avec les compteurs
(écritures, lectures, modifications, suppressions, parcours, erreurs).

## Points d'attention appris sur ce système

- Les `DD *` instream restent en **FB LRECL=80** ; toute carte de contrôle
  doit être calée exactement sur ces 80 colonnes (RECFM non modifiable,
  cf. IEFC009I déjà rencontré).
- Le `DELETE` sur fichier indexé DYNAMIC se fait par **positionnement de clé
  puis DELETE direct**, sans READ préalable obligatoire.
- Le `REWRITE`, à l'inverse, **exige une lecture préalable réussie** du même
  enregistrement (sinon FS différent de '00' et rejet logique).
- `START ... KEY IS NOT LESS THAN` suivi de `READ ... NEXT RECORD` est le
  couple standard pour parcourir un VSAM KSDS à partir d'une clé donnée.
