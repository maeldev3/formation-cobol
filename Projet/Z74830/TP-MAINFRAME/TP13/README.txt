====================================================================
TP13 - TRI EN MEMOIRE (BUBBLE SORT) SANS DFSORT
IBM Z ID : Z74830
====================================================================

CONTENU DU ZIP
---------------
TRI13.cbl      -> Le programme COBOL (bubble sort par ID, NOM, SALAIRE)
TRI13JOB.jcl   -> JCL pour compiler et exécuter TRI13
LOADDATA.jcl   -> JCL pour charger les données de test dans le PDS
CLIENTS.DAT    -> Fichier de données de test (8 clients, non trié)
README.txt     -> Ce fichier

STRUCTURE DE L'ENREGISTREMENT CLIENT (34 caractères, format fixe)
-------------------------------------------------------------------
Position  1- 5  : CLI-ID       PIC 9(5)     (identifiant numérique)
Position  6-25  : CLI-NOM      PIC X(20)    (nom, complété par espaces)
Position 26-34  : CLI-SALAIRE  PIC 9(7)V99  (salaire, 2 décimales
                                              implicites, ex: 002500000
                                              = 25000.00)

====================================================================
ETAPE 1 - PREPARER LES DATASETS SOUS TK5 (via c3270 / ISPF)
====================================================================

1. Connecte-toi avec ton userid (ex: HERC01).
2. Va dans ISPF option 3.2 (Data Set Utility) et crée (Option A) :

   a) HERC01.COBOL.SOURCE   (si pas déjà fait)
      RECFM=FB, LRECL=80, BLKSIZE=3120, Directory blocks=5

   b) HERC01.COBOL.DATA     (nouveau, pour les données)
      RECFM=FB, LRECL=34, BLKSIZE=3400, Directory blocks=5

   c) HERC01.COBOL.JCL      (si pas déjà fait)
      RECFM=FB, LRECL=80, BLKSIZE=3120, Directory blocks=5

====================================================================
ETAPE 2 - TRANSFERER LES FICHIERS DANS TK5
====================================================================

Le plus simple : transfert par FTP (si activé sous TK5) vers les
membres suivants, en TEXTE (ASCII, pas binaire) :

   TRI13.cbl      -> HERC01.COBOL.SOURCE(TRI13)
   TRI13JOB.jcl   -> HERC01.COBOL.JCL(TRI13JOB)
   LOADDATA.jcl   -> HERC01.COBOL.JCL(LOADDATA)

Si tu n'as pas de FTP configuré, tu peux copier-coller le contenu de
chaque fichier directement dans l'éditeur ISPF (option 2 - Edit) en
créant les membres manuellement. Le code COBOL et le JCL sont déjà
indentés correctement (colonnes 8/12 respectées), donc un simple
copier-coller ligne par ligne doit fonctionner.

====================================================================
ETAPE 3 - CHARGER LES DONNEES DE TEST
====================================================================

1. Une fois HERC01.COBOL.DATA créé (étape 1b) ET le membre
   LOADDATA soumis, va dans l'éditeur sur HERC01.COBOL.JCL(LOADDATA)
2. Tape SUBMIT (ou SUB) en ligne de commande.
3. Vérifie dans SDSF que le job s'est terminé avec RC=0000.
   Cela crée le membre HERC01.COBOL.DATA(CLIENTS) avec les 8 lignes
   de test.

====================================================================
ETAPE 4 - COMPILER ET EXECUTER LE PROGRAMME
====================================================================

1. Ouvre HERC01.COBOL.JCL(TRI13JOB).
2. Tape SUBMIT.
3. Va dans SDSF (option S) pour suivre le job TRI13JOB.
4. Vérifie les steps :
   - COBOL (compilation) : RC=0000 ou 0004 attendu
   - LKED (édition de liens) : RC=0000
   - GO (exécution) : c'est ici que s'affiche le résultat

RESULTAT ATTENDU (SYSOUT du step GO)
-------------------------------------
Le programme affiche 4 blocs :
   1. Ordre original (tel que lu dans CLIENTS)
   2. Trié par ID (croissant)
   3. Trié par NOM (ordre alphabétique)
   4. Trié par SALAIRE (décroissant, du plus haut au plus bas)

====================================================================
CE QUE TU APPRENDS DANS CET EXERCICE
====================================================================

- Déclarer un TABLEAU en COBOL avec OCCURS et INDEXED BY
- Lire un fichier séquentiel et le charger en mémoire (table)
- Écrire une boucle imbriquée (PERFORM VARYING ... PERFORM VARYING)
- Implémenter l'algorithme du BUBBLE SORT "à la main" (sans DFSORT)
- Comparer des champs alphanumériques (NOM), numériques (ID,
  SALAIRE) et effectuer des échanges (swap) via une variable
  temporaire
- Afficher le contenu d'une table via DISPLAY

PISTE POUR ALLER PLUS LOIN
---------------------------
- Modifier le tri par SALAIRE pour qu'il soit croissant au lieu de
  décroissant (inverser le test IF).
- Ajouter un compteur du nombre d'échanges effectués par le bubble
  sort pour visualiser sa complexité.
- Essayer un tri plus optimisé (ex: tri à bulles avec drapeau
  d'arrêt anticipé si aucun échange n'a eu lieu dans une passe).
