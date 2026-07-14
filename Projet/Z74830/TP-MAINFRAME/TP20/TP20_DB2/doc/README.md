# TP20 — COBOL + DB2

## Contenu du projet

```
TP20_DB2/
├── ddl/
│   └── DDL_CLIENTS.sql       → création de la table CLIENTS + données de test
├── copy/
│   └── CLICOPY.cpy           → copybook des host-variables (structure client)
├── source/
│   └── CLI0200.cbl           → programme COBOL-DB2 (SELECT/INSERT/UPDATE/DELETE/CURSOR)
├── jcl/
│   ├── CLI0200D.jcl          → exécute le DDL (crée la table)
│   ├── CLI0200C.jcl          → précompile + compile + link-edit
│   ├── CLI0200B.jcl          → bind du package et du plan DB2
│   └── CLI0200R.jcl          → exécute le programme
└── doc/
    └── README.md             → ce fichier
```

## Ordre d'exécution (important, ne pas sauter d'étape)

1. **`CLI0200D.jcl`** — crée la table `CLIENTS` dans DB2 (une seule fois)
2. **`CLI0200C.jcl`** — précompile le COBOL (extrait le SQL en DBRM), compile le
   COBOL "nettoyé", puis link-edite avec le module DB2 (`DSNELI`)
3. **`CLI0200B.jcl`** — bind : transforme le DBRM produit à l'étape 2 en objets
   DB2 exécutables (PACKAGE + PLAN). **Sans cette étape, le RUN échoue.**
4. **`CLI0200R.jcl`** — exécute le programme, qui doit afficher les résultats
   des 5 opérations (SELECT, INSERT, UPDATE, CURSOR, DELETE)

## Pourquoi une précompilation en plus de la compilation classique ?

Le compilateur COBOL standard (`IGYCRCTL`) ne comprend pas `EXEC SQL ... END-EXEC`.
Le précompilateur `DSNHPC` :
- lit le programme source
- remplace chaque bloc `EXEC SQL` par un appel COBOL classique (`CALL 'DSNHLI'...`)
- extrait le texte SQL dans un **DBRM** (Database Request Module), stocké séparément

C'est ce DBRM qui sera "bindé" à l'étape 3 pour devenir exploitable par DB2.

## Les concepts clés du programme CLI0200.cbl

| Élément | Rôle |
|---|---|
| `EXEC SQL INCLUDE SQLCA` | Zone de communication avec DB2 : contient `SQLCODE` (0 = OK, 100 = pas trouvé, négatif = erreur) |
| Host variables (`:CLI-ID`, `:CLI-NOM`...) | Variables COBOL utilisées côté SQL, précédées de `:` |
| `DECLARE CURSOR` | Déclare une requête retournant plusieurs lignes |
| `OPEN` / `FETCH` / `CLOSE` | Ouvre le curseur, lit ligne par ligne, ferme à la fin |
| `SQLCODE = 100` | Convention DB2 : "fin des données" (sur un FETCH) ou "pas trouvé" (sur un SELECT simple) |
| `COMMIT` / `ROLLBACK` | Valide ou annule les modifications (INSERT/UPDATE/DELETE) |

## Adapter à ton environnement

Avant de soumettre, remplace dans les JCL :
- `DSN1` → le vrai nom de ton subsystem DB2 (demande-le à l'administrateur ou vérifie
  dans la doc de ton environnement de formation)
- `BANK.*` → tes propres noms de datasets/PDS (ou chemins USS, voir variantes en
  commentaire dans `CLI0200C.jcl` et `CLI0200D.jcl`)
- `BANKPKG` / `BANKPLAN` → noms de package/plan (libres, mais restent cohérents
  entre le BIND et le RUN)

## Erreurs fréquentes de débutant sur ce TP

- **Oublier le BIND** après une modification du SQL → le RUN utilise l'ancien plan,
  les résultats semblent "figés" ou une erreur `-818`/`-805` apparaît
- **Oublier le COMMIT** → les données insérées/modifiées disparaissent en cas de
  rollback implicite (fin anormale du job)
- **Confondre `SQLCODE = 100` sur un SELECT simple et sur un FETCH** : les deux
  utilisent le même code, mais un SELECT simple ne doit être exécuté qu'une fois
  (sinon utiliser un curseur)
- **Host variable mal typée** par rapport à la colonne DB2 (ex: `DECIMAL(9,2)` côté
  table doit correspondre à `COMP-3` avec la bonne précision côté COBOL)

## Pour aller plus loin après ce TP

- Ajouter la gestion d'un `WHENEVER SQLERROR` pour centraliser la gestion d'erreurs
- Paramétrer le seuil de salaire via `LINKAGE SECTION` + `PARM` (comme au TP16)
- Combiner avec VSAM (TP19) : lire un fichier séquentiel et insérer chaque ligne en DB2
