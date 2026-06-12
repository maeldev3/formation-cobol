=================================================================
  BANK STATEMENT GENERATOR - DOCUMENTATION COMPLETE
  Générateur de Relevés Bancaires COBOL/CICS/DB2/ISPF
=================================================================

STRUCTURE DU PROJET
-------------------
bank-statement/
├── cobol/
│   ├── BSTMTGEN.cbl    Programme CICS online (principal)
│   └── BSTMTBAT.cbl    Programme batch DB2
├── db2/
│   └── CREATE_TABLES.sql  DDL + données de test
├── cics/
│   └── CICS_DEFINITIONS.txt  Ressources CICS (trans, prog, maps)
├── jcl/
│   └── BSTMT_JCL.jcl   JCL compile/bind/execute
├── ispf/
│   ├── BSTMT_PANELS.pnl Panneaux ISPF
│   └── BSTMTEXC.rex     Exec REXX ISPF
└── README.txt           Cette documentation

=================================================================
FONCTIONNALITES
=================================================================

1. LECTURE DES TRANSACTIONS
   - Curseur DB2 sur BANKDB.TRANSACTIONS
   - Filtrage par compte et période
   - Tri chronologique (DATE + HEURE)
   - Chargement en table COBOL (max 100 lignes)

2. CALCUL DES SOLDES
   - Solde initial  = premier solde - premier montant
   - Solde final    = dernier solde après transaction
   - Total crédits  = CRE + DEP + VIR
   - Total débits   = DEB + RET + FRA

3. AFFICHAGE HISTORIQUE (ISPF)
   - Panel BSTM02 avec modèle scrollable
   - Colonnes : DATE / HEURE / TYPE / LIBELLE / MONTANT / SOLDE
   - Navigation PF7/PF8 (scroll haut/bas)

4. GENERATION RELEVÉ TEXTE
   - En-tête: identité client + n° compte + période
   - Détail: ligne par transaction formatée 80/133 cars
   - Pied de page: totaux + soldes
   - 3 sorties: ECRAN, IMPRIMANTE, FICHIER

=================================================================
TABLES DB2
=================================================================

BANKDB.CLIENTS
--------------
  CLIENT_ID       CHAR(10)    PK
  NOM             VARCHAR(40)
  PRENOM          VARCHAR(40)
  ADRESSE         VARCHAR(80)
  VILLE           VARCHAR(30)
  CODE_POSTAL     CHAR(5)
  NUM_COMPTE      CHAR(16/26) UNIQUE (IBAN)
  DATE_OUVERTURE  DATE
  STATUT          CHAR(1)     A=Actif, I=Inactif, S=Suspendu

BANKDB.TRANSACTIONS
-------------------
  TRANS_ID        CHAR(12)    PK
  NUM_COMPTE      CHAR(26)    FK -> CLIENTS
  DATE_TRANS      DATE
  HEURE_TRANS     TIME
  TYPE_TRANS      CHAR(3)     CRE/DEB/VIR/RET/DEP/FRA
  MONTANT         DECIMAL(15,2)
  SOLDE_APRES     DECIMAL(15,2)
  LIBELLE         VARCHAR(50)
  STATUT_TRANS    CHAR(1)     V=Valide, A=Annulé, R=Rejeté

=================================================================
TRANSACTIONS CICS
=================================================================

  BSTM  -> BSTMTGEN  (Génération relevé online)
  BSTV  -> BSTMTVIW  (Visualisation historique)

  COMMAREA structure:
  - CA-NUM-COMPTE   (26) : Numéro de compte IBAN
  - CA-DATE-DEBUT   (10) : Date début AAAA-MM-JJ
  - CA-DATE-FIN     (10) : Date fin   AAAA-MM-JJ
  - CA-RETURN-CODE   (4) : OK, NFND, SQLE
  - CA-MSG-ERREUR   (50) : Message erreur

  Temporary Storage Queue:
  - BSTMTQ   : Lignes du relevé (80 cars par enreg.)
  - BSTMTEQ  : Messages d'erreur

=================================================================
JCL - JOBS DISPONIBLES
=================================================================

  BSTMTCMP  : Compile/Link BSTMTGEN (CICS + DB2 + COBOL)
  BSTMTCMB  : Compile/Link BSTMTBAT (Batch + DB2 + COBOL)
  BSTMTBND  : DB2 Bind (PACKAGE + PLAN BSTMTPLN)
  BSTMTRUN  : Exécution batch BSTMTBAT
  BSTMTDDL  : Création tables DDL

  Ordre d'exécution initial:
    1. BSTMTDDL  -> Créer les tables
    2. BSTMTCMP  -> Compiler BSTMTGEN
    3. BSTMTCMB  -> Compiler BSTMTBAT
    4. BSTMTBND  -> Binder le plan DB2
    5. BSTMTRUN  -> Tester le batch

=================================================================
DATASETS REQUIS
=================================================================

  BANK.DEVLIB.SRCLIB     : Sources COBOL/REXX
  BANK.DEVLIB.DBRMLIB    : DBRMs DB2 (post-precompile)
  BANK.DEVLIB.PANELS     : Panneaux ISPF
  BANK.DEVLIB.TABLES     : Tables ISPF
  BANK.LOADLIB           : Load modules compilés

=================================================================
ISPF - INTERFACE UTILISATEUR
=================================================================

  Lancer: TSO %BSTMTEXC
  ou via ISPF option 6 (commandes TSO)

  MENUS:
  1 - Générer un relevé (compte + période + format)
  2 - Afficher historique transactions
  3 - Rechercher un client (nom ou compte)
  4 - Paramètres (max lignes, devise, séparateur CSV)
  X - Quitter

=================================================================
CODES RETOUR
=================================================================

  Batch (BSTMTBAT):
    0  = Normal, traitement OK
    4  = Avertissement (aucune transaction trouvée)
    8  = Erreur grave (SQL, fichier)
    12 = Erreur fatale

  Online (BSTMTGEN via COMMAREA):
    OK   = Traitement réussi
    NFND = Client non trouvé ou inactif
    SQLE = Erreur SQL (code dans MSG-ERREUR)

=================================================================
FIN DE DOCUMENTATION
=================================================================
