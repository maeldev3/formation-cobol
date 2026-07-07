# TP12 — Tableaux (OCCURS) en COBOL

Projet COBOL complet pour le TP12 : manipulation d'un tableau mémoire
de clients avec `OCCURS`, `INDEXED BY`, `SEARCH` et `SEARCH ALL`.

## Contenu du projet

```
TP12/
├── COBOL/
│   └── TP12CLI.cbl      -> Programme COBOL principal (source, format fixe)
├── JCL/
│   └── TP12CLI.jcl      -> JCL d'exemple pour compiler/exécuter sous z/OS
├── DOC/
│   └── (notes complémentaires)
└── README.md
```

## Notions mises en œuvre

| Notion         | Où dans le code                                              |
|----------------|---------------------------------------------------------------|
| `OCCURS`       | `CLIENT-ENTRY OCCURS 20 TIMES` dans `WS-CLIENT-TABLE`         |
| `INDEXED BY`   | `INDEXED BY IDX`                                              |
| `ASCENDING KEY`| `ASCENDING KEY IS CLI-ID` (nécessaire pour `SEARCH ALL`)      |
| `SEARCH`       | Paragraphe `RECHERCHER-PAR-NOM` (recherche séquentielle)      |
| `SEARCH ALL`   | Paragraphe `RECHERCHER-PAR-ID` (recherche binaire, table triée)|

## Structure du tableau

```cobol
01  WS-CLIENT-TABLE.
    05  CLIENT-ENTRY OCCURS 20 TIMES
                     ASCENDING KEY IS CLI-ID
                     INDEXED BY IDX.
        10  CLI-ID       PIC 9(3).
        10  CLI-NOM      PIC X(15).
        10  CLI-PRENOM   PIC X(15).
        10  CLI-VILLE    PIC X(15).
        10  CLI-SOLDE    PIC 9(6)V99.
```

> Le sujet demandait un tableau `CLIENT 1` à `CLIENT 100`. Le code est
> dimensionné à 20 (comme le demandent les exercices : "stocker 20
> clients"). Il suffit de changer `OCCURS 20 TIMES` en
> `OCCURS 100 TIMES` (et la borne `20` dans les boucles) pour repasser
> à 100 clients sans autre modification.

## Exercices couverts

1. **Stocker 20 clients**
   - Option `1` du menu : charge automatiquement 20 clients de
     démonstration dans le tableau (utile pour tester rapidement).
   - Option `2` du menu : saisie manuelle client par client (ID,
     nom, prénom, ville, solde), jusqu'à 20 clients maximum.

2. **Rechercher un client**
   - Option `3` du menu, avec deux sous-choix :
     - **1 - Par ID** → utilise `SEARCH ALL` (recherche binaire,
       nécessite un tableau trié — garanti ici car les ID sont
       attribués de façon croissante).
     - **2 - Par nom** → utilise `SEARCH` classique (recherche
       séquentielle linéaire).

3. **Afficher tous les clients**
   - Option `4` du menu : parcourt le tableau avec
     `PERFORM VARYING IDX ... UNTIL IDX > WS-NB-CLIENTS` et affiche
     chaque client.

4. **Compter les clients**
   - Option `5` du menu : affiche `WS-NB-CLIENTS`, le nombre réel de
     clients actuellement stockés dans le tableau.

## Compilation et exécution

### Sur PC (GnuCOBOL) — pour tester rapidement

```bash
cobc -x -std=ibm -o TP12CLI TP12CLI.cbl
./TP12CLI
```

Le programme a été compilé et testé avec succès avec GnuCOBOL 4
(format fixe, dialecte IBM) : chargement des 20 clients, recherche
par ID (`SEARCH ALL`), recherche par nom (`SEARCH`), affichage complet
et comptage fonctionnent tous correctement.

### Sur mainframe z/OS (IBM Enterprise COBOL)

Un JCL d'exemple est fourni dans `JCL/TP12CLI.jcl`. Il enchaîne :
1. **Compilation + Link-Edit** via la procédure cataloguée `IGYWCL`
   (à adapter selon votre installation : nom de la procédure,
   dataset source, load library...).
2. **Exécution** du programme avec des cartes `SYSIN` simulant les
   choix du menu (charger, rechercher, afficher, compter, quitter).

Adaptez les noms de datasets (`VOTRE.SOURCE.COBOL`,
`VOTRE.LOAD.LIBRARY`) à votre environnement TSO/ISPF réel.

## Utilisation du menu

```
1. Charger 20 clients de demonstration
2. Saisir un client (manuel, max 20)
3. Rechercher un client (SEARCH / SEARCH ALL)
4. Afficher tous les clients
5. Compter les clients
6. Quitter
```

Astuce : commencez toujours par l'option **1** pour charger des
données de test, puis testez les options **3** (recherche), **4**
(affichage) et **5** (comptage).
