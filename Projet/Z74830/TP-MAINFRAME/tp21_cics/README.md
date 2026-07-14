# TP21 — CICS : Écran MENU

## Contenu du projet

```
tp21_cics/
├── bms/
│   └── MENUSET.bms      → Source BMS du mapset (l'écran)
├── cobol/
│   ├── MENU00.cbl       → Programme principal (affiche le menu, aiguille)
│   ├── AJOU00.cbl       → Squelette option 1 - Ajouter
│   ├── MODI00.cbl       → Squelette option 2 - Modifier
│   ├── SUPP00.cbl       → Squelette option 3 - Supprimer
│   └── RECH00.cbl       → Squelette option 4 - Rechercher
├── jcl/
│   ├── ASSEMBMS.jcl     → JCL d'assemblage du mapset (BMS → map + copybook)
│   └── COMPCBL.jcl      → JCL de compilation/link des programmes COBOL-CICS
├── csd/
│   └── DEFCSD.txt       → Commandes CEDA/DFHCSDUP pour définir PROGRAM,
│                          MAPSET et TRANSACTION dans CICS
└── README.md
```

## 1. BMS (Basic Mapping Support)

`MENUSET.bms` décrit l'écran physique (positions, longueurs, attributs des
champs) grâce aux macros assembleur :

- `DFHMSD` : début/fin du **mapset** (le fichier qui regroupe une ou
  plusieurs maps).
- `DFHMDI` : définit une **map** à l'intérieur du mapset (taille de
  l'écran, position de départ).
- `DFHMDF` : définit **chaque champ** (libellé, zone de saisie, zone
  message...) avec ses attributs (`PROT`/`UNPROT`, `NUM`, `BRT`,
  `ASKIP`, etc.).

L'assemblage de ce fichier (voir `ASSEMBMS.jcl`) produit :
1. Un **module load** de la map (utilisé à l'exécution par CICS pour
   afficher l'écran).
2. Un **copybook COBOL** (nommé ici `MENUMAP`) contenant la structure
   symbolique des champs — c'est ce copybook qui est inclus dans le
   programme via `COPY MENUMAP.`

## 2. La MAP (structure symbolique)

Chaque champ de saisie généré par BMS produit dans le copybook 3 zones
(suffixes automatiques) :
- `xxxxI` : zone d'**entrée** (Input) — ce que l'utilisateur a saisi.
- `xxxxO` : zone de **sortie** (Output) — ce qu'on envoie à l'écran.
- `xxxxL`, `xxxxF`, `xxxxA` : longueur saisie, flag "modifié", attribut.

Exemple utilisé dans `MENU00.cbl` :
- `CHOIXI OF MENUMAPI` → récupère le chiffre tapé par l'utilisateur.
- `MSGO OF MENUMAPO` → dépose un message d'erreur à l'écran.

## 3. EXEC CICS — commandes utilisées

| Commande                        | Rôle dans le TP                                    |
|----------------------------------|-----------------------------------------------------|
| `EXEC CICS SEND MAP`             | Affiche l'écran MENU (option `ERASE` au 1er appel). |
| `EXEC CICS RECEIVE MAP`          | Récupère la saisie de l'utilisateur (le choix).     |
| `EXEC CICS HANDLE CONDITION`     | Intercepte l'erreur `MAPFAIL` (Enter sans saisie).  |
| `EXEC CICS XCTL PROGRAM(...)`    | Transfère le contrôle vers AJOU00/MODI00/SUPP00/RECH00 selon le choix, sans possibilité de retour direct (contrairement à LINK). |
| `EXEC CICS RETURN TRANSID(...)`  | Termine la tâche en la rendant "pseudo-conversationnelle" : CICS réaffichera l'écran au prochain Enter avec la COMMAREA conservée. |
| `EXEC CICS SEND TEXT`            | Message simple (écran de sortie / squelettes).      |

### Logique de MENU00
1. Si `EIBCALEN = 0` (premier appel de la transaction) → on envoie
   l'écran vierge.
2. Sinon → on relit ce que l'utilisateur a tapé, on regarde la touche
   pressée (`EIBAID`) :
   - `PF3` → fin de transaction.
   - `ENTER` → on analyse le chiffre saisi et on appelle (`XCTL`) le
     bon programme (1→AJOU00, 2→MODI00, 3→SUPP00, 4→RECH00, 0→fin).
   - toute autre touche → message d'erreur, réaffichage de l'écran.

## 4. Programmes cibles (squelettes)

`AJOU00`, `MODI00`, `SUPP00` et `RECH00` sont des **squelettes** :
ils affichent un message et repartent (`XCTL`) vers `MENU00`. Chacun
contient en commentaire (`TODO`) l'commande CICS attendue pour
implémenter réellement l'opération sur un fichier VSAM :
- Ajouter → `EXEC CICS WRITE FILE(...)`
- Modifier → `EXEC CICS READ ... UPDATE` puis `EXEC CICS REWRITE`
- Supprimer → `EXEC CICS DELETE FILE(...)`
- Rechercher → `EXEC CICS READ FILE(...)`

À vous de créer les maps BMS correspondantes (`AJOUMAP`, `MODIMAP`,
`SUPPMAP`, `RECHMAP`) et de brancher le fichier VSAM utilisé dans
votre exercice (nom défini par `EXEC CICS DEFINE FILE` côté
administration CICS).

## 5. Mise en œuvre

1. Assembler la map : soumettre `jcl/ASSEMBMS.jcl` (adapter les DSN).
2. Compiler/lier les 5 programmes COBOL : soumettre `jcl/COMPCBL.jcl`
   (à répéter par programme, ou dupliquer le step).
3. Définir les ressources CICS (programmes, mapset, transaction) avec
   les commandes de `csd/DEFCSD.txt` (CEDA ou DFHCSDUP).
4. Lancer la transaction `MENU` depuis l'écran CICS.

> ⚠️ Les noms de DSN (`VOTRE.HLQ...`) et le nom exact des procédures
> catalogées (`DFHMAPS`, proc de compilation COBOL-CICS) dépendent de
> l'installation z/OS de votre établissement : demandez ces valeurs à
> votre formateur si elles diffèrent.
