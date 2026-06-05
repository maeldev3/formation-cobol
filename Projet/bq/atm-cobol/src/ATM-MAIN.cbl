      *================================================================*
      *  ATM-MAIN.CBL - SYSTÈME ATM BANCAIRE                          *
      *  Projet #7 : ATM Banking System                               *
      *  Compilateur : GnuCOBOL                                       *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-MAIN.
       AUTHOR. SYSTEME-BANCAIRE.
       DATE-WRITTEN. 2026-06-05.
       DATE-COMPILED. 2026-06-05.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENTS ASSIGN TO "data/CLIENTS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CLIENT-ID
               ALTERNATE RECORD KEY IS CLIENT-NOM
                   WITH DUPLICATES
               FILE STATUS IS WS-FS-CLIENTS.

           SELECT FICHIER-COMPTES ASSIGN TO "data/COMPTES.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS COMPTE-ID
               ALTERNATE RECORD KEY IS COMPTE-NUMERO
               FILE STATUS IS WS-FS-COMPTES.

           SELECT FICHIER-CARTES ASSIGN TO "data/CARTES.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CARTE-ID
               ALTERNATE RECORD KEY IS CARTE-NUMERO
               FILE STATUS IS WS-FS-CARTES.

           SELECT FICHIER-SESSIONS ASSIGN TO "data/SESSIONS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS SESSION-ID
               FILE STATUS IS WS-FS-SESSIONS.

           SELECT FICHIER-TRANSACTIONS ASSIGN TO "data/TRANSACT.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRANS-ID
               FILE STATUS IS WS-FS-TRANS.

       DATA DIVISION.
       FILE SECTION.

      *--- FICHIER CLIENTS ---
       FD  FICHIER-CLIENTS.
       01  ENREG-CLIENT.
           05  CLIENT-ID           PIC 9(5).
           05  CLIENT-NOM          PIC X(50).
           05  CLIENT-PRENOM       PIC X(50).
           05  CLIENT-NAISSANCE    PIC X(10).
           05  CLIENT-ADRESSE      PIC X(100).
           05  CLIENT-TEL          PIC X(20).

      *--- FICHIER COMPTES ---
       FD  FICHIER-COMPTES.
       01  ENREG-COMPTE.
           05  COMPTE-ID           PIC 9(5).
           05  COMPTE-CLIENT-ID    PIC 9(5).
           05  COMPTE-NUMERO       PIC X(24).
           05  COMPTE-TYPE         PIC X(10).
           05  COMPTE-SOLDE        PIC S9(13)V99.
           05  COMPTE-PLAFOND      PIC S9(8)V99.
           05  COMPTE-DATE-OUV     PIC X(10).
           05  COMPTE-ACTIF        PIC 9.

      *--- FICHIER CARTES ---
       FD  FICHIER-CARTES.
       01  ENREG-CARTE.
           05  CARTE-ID            PIC 9(5).
           05  CARTE-COMPTE-ID     PIC 9(5).
           05  CARTE-NUMERO        PIC X(19).
           05  CARTE-PIN           PIC X(4).
           05  CARTE-EXPIRATION    PIC X(10).
           05  CARTE-ACTIF         PIC 9.
           05  CARTE-TENTATIVES    PIC 9.
           05  CARTE-BLOQUE        PIC 9.

      *--- FICHIER SESSIONS ---
       FD  FICHIER-SESSIONS.
       01  ENREG-SESSION.
           05  SESSION-ID          PIC 9(8).
           05  SESSION-CARTE-ID    PIC 9(5).
           05  SESSION-DEBUT       PIC X(19).
           05  SESSION-FIN         PIC X(19).
           05  SESSION-STATUT      PIC X(10).

      *--- FICHIER TRANSACTIONS ---
       FD  FICHIER-TRANSACTIONS.
       01  ENREG-TRANSACTION.
           05  TRANS-ID            PIC 9(10).
           05  TRANS-SESSION-ID    PIC 9(8).
           05  TRANS-TYPE          PIC X(15).
           05  TRANS-MONTANT       PIC S9(13)V99.
           05  TRANS-DATETIME      PIC X(19).
           05  TRANS-SOLDE-AVANT   PIC S9(13)V99.
           05  TRANS-SOLDE-APRES   PIC S9(13)V99.
           05  TRANS-STATUT        PIC X(10).

       WORKING-STORAGE SECTION.
      *--- FILE STATUS ---
       01  WS-FS-CLIENTS           PIC XX VALUE SPACES.
       01  WS-FS-COMPTES           PIC XX VALUE SPACES.
       01  WS-FS-CARTES            PIC XX VALUE SPACES.
       01  WS-FS-SESSIONS          PIC XX VALUE SPACES.
       01  WS-FS-TRANS             PIC XX VALUE SPACES.

      *--- ÉTAT DE LA SESSION ---
       01  WS-SESSION.
           05  WS-AUTHENTIFIE      PIC 9 VALUE 0.
           05  WS-SESSION-ID       PIC 9(8) VALUE 0.
           05  WS-CARTE-ID-ACTIF   PIC 9(5) VALUE 0.
           05  WS-COMPTE-ID-ACTIF  PIC 9(5) VALUE 0.
           05  WS-CLIENT-NOM-ACTIF PIC X(50) VALUE SPACES.
           05  WS-SOLDE-ACTIF      PIC S9(13)V99 VALUE 0.
           05  WS-PLAFOND-ACTIF    PIC S9(8)V99 VALUE 0.
           05  WS-PIN-TENTATIVES   PIC 9 VALUE 0.

      *--- VARIABLES DE TRAVAIL ---
       01  WS-TRAVAIL.
           05  WS-CHOIX            PIC X VALUE SPACE.
           05  WS-MONTANT-SAISI    PIC S9(13)V99 VALUE 0.
           05  WS-NUMERO-CARTE     PIC X(19) VALUE SPACES.
           05  WS-PIN-SAISI        PIC X(4) VALUE SPACES.
           05  WS-CONTINUER        PIC 9 VALUE 1.
           05  WS-NB-LIGNES        PIC 99 VALUE 0.
           05  WS-TRANS-COUNT      PIC 9(10) VALUE 0.
           05  WS-SESSION-COUNT    PIC 9(8) VALUE 0.
           05  WS-DATETIME-NOW     PIC X(19) VALUE SPACES.

      *--- AFFICHAGE MONTANT ---
       01  WS-AFFICHAGE.
           05  WS-MONTANT-AFF      PIC ZZZ.ZZZ.ZZ9,99.
           05  WS-SOLDE-AFF        PIC ZZZ.ZZZ.ZZ9,99.
           05  WS-PLAFOND-AFF      PIC ZZZ.ZZ9,99.

      *--- CONSTANTES ÉCRAN ---
       01  WS-ECRAN.
           05  WS-LIGNE-TITRE      PIC X(60)
               VALUE "================================================".
           05  WS-LIGNE-SIMPLE     PIC X(60)
               VALUE "-----------------------------------------------".
           05  WS-BANQUE           PIC X(60)
               VALUE "    *** BANQUE CENTRALE - ATM ***              ".
           05  WS-VERSION          PIC X(60)
               VALUE "         v1.0  |  GnuCOBOL 3.x             ".

      *--- MINI-RELEVÉ ---
       01  WS-RELEVE-ENTETE        PIC X(60)
           VALUE "  DATE/HEURE       TYPE          MONTANT    SOLDE".

       01  WS-MAX-TRANS            PIC 99 VALUE 5.
       01  WS-TRANS-INDEX          PIC 99 VALUE 0.
       01  TAB-TRANSACTIONS.
           05  TAB-TRANS OCCURS 5 TIMES.
               10  TT-TYPE         PIC X(15).
               10  TT-MONTANT      PIC S9(13)V99.
               10  TT-DATETIME     PIC X(19).
               10  TT-SOLDE-APRES  PIC S9(13)V99.

      *--- MESSAGE ---
       01  WS-MSG                  PIC X(70) VALUE SPACES.
       01  WS-MSG2                 PIC X(70) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PARA.
           PERFORM INIT-FICHIERS
           PERFORM CHARGER-DONNEES-DEMO
           MOVE 1 TO WS-CONTINUER

           PERFORM UNTIL WS-CONTINUER = 0
               PERFORM ECRAN-ACCUEIL
               IF WS-CONTINUER = 1
                   PERFORM SAISIE-CARTE
               END-IF
               IF WS-AUTHENTIFIE = 1
                   PERFORM MENU-PRINCIPAL
                   PERFORM FERMER-SESSION
               END-IF
           END-PERFORM

           PERFORM FERMER-FICHIERS
           STOP RUN.

      *================================================================*
      *  INITIALISATION DES FICHIERS                                   *
      *================================================================*
       INIT-FICHIERS.
           OPEN I-O FICHIER-CLIENTS
           IF WS-FS-CLIENTS = "35"
               OPEN OUTPUT FICHIER-CLIENTS
               CLOSE FICHIER-CLIENTS
               OPEN I-O FICHIER-CLIENTS
           END-IF

           OPEN I-O FICHIER-COMPTES
           IF WS-FS-COMPTES = "35"
               OPEN OUTPUT FICHIER-COMPTES
               CLOSE FICHIER-COMPTES
               OPEN I-O FICHIER-COMPTES
           END-IF

           OPEN I-O FICHIER-CARTES
           IF WS-FS-CARTES = "35"
               OPEN OUTPUT FICHIER-CARTES
               CLOSE FICHIER-CARTES
               OPEN I-O FICHIER-CARTES
           END-IF

           OPEN I-O FICHIER-SESSIONS
           IF WS-FS-SESSIONS = "35"
               OPEN OUTPUT FICHIER-SESSIONS
               CLOSE FICHIER-SESSIONS
               OPEN I-O FICHIER-SESSIONS
           END-IF

           OPEN I-O FICHIER-TRANSACTIONS
           IF WS-FS-TRANS = "35"
               OPEN OUTPUT FICHIER-TRANSACTIONS
               CLOSE FICHIER-TRANSACTIONS
               OPEN I-O FICHIER-TRANSACTIONS
           END-IF.

      *================================================================*
      *  CHARGEMENT DES DONNEES DE DEMO                              *
      *================================================================*
       CHARGER-DONNEES-DEMO.
      *-- Client 1 : Dupont Jean --
           MOVE 1            TO CLIENT-ID
           MOVE "DUPONT"     TO CLIENT-NOM
           MOVE "Jean"       TO CLIENT-PRENOM
           MOVE "1980-05-12" TO CLIENT-NAISSANCE
           MOVE "12 rue de Paris, 75001 Paris" TO CLIENT-ADRESSE
           MOVE "0612345678" TO CLIENT-TEL
           WRITE ENREG-CLIENT
               INVALID KEY REWRITE ENREG-CLIENT

      *-- Client 2 : Martin Sophie --
           MOVE 2            TO CLIENT-ID
           MOVE "MARTIN"     TO CLIENT-NOM
           MOVE "Sophie"     TO CLIENT-PRENOM
           MOVE "1992-09-23" TO CLIENT-NAISSANCE
           MOVE "45 avenue des Champs, 69000 Lyon" TO CLIENT-ADRESSE
           MOVE "0698765432" TO CLIENT-TEL
           WRITE ENREG-CLIENT
               INVALID KEY REWRITE ENREG-CLIENT

      *-- Compte 1 : Dupont COURANT --
           MOVE 1                         TO COMPTE-ID
           MOVE 1                         TO COMPTE-CLIENT-ID
           MOVE "FR7612345000012345678901" TO COMPTE-NUMERO
           MOVE "COURANT"                 TO COMPTE-TYPE
           MOVE 1250,75                   TO COMPTE-SOLDE
           MOVE 300,00                    TO COMPTE-PLAFOND
           MOVE "2020-01-15"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE
               INVALID KEY REWRITE ENREG-COMPTE

      *-- Compte 2 : Dupont EPARGNE --
           MOVE 2                         TO COMPTE-ID
           MOVE 1                         TO COMPTE-CLIENT-ID
           MOVE "FR7612345000012345678902" TO COMPTE-NUMERO
           MOVE "EPARGNE"                 TO COMPTE-TYPE
           MOVE 5000,00                   TO COMPTE-SOLDE
           MOVE 500,00                    TO COMPTE-PLAFOND
           MOVE "2020-01-15"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE
               INVALID KEY REWRITE ENREG-COMPTE

      *-- Compte 3 : Martin COURANT --
           MOVE 3                         TO COMPTE-ID
           MOVE 2                         TO COMPTE-CLIENT-ID
           MOVE "FR7698765000012345678903" TO COMPTE-NUMERO
           MOVE "COURANT"                 TO COMPTE-TYPE
           MOVE 850,30                    TO COMPTE-SOLDE
           MOVE 200,00                    TO COMPTE-PLAFOND
           MOVE "2021-03-20"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE
               INVALID KEY REWRITE ENREG-COMPTE

      *-- Carte 1 : pour Compte 1 --
           MOVE 1                    TO CARTE-ID
           MOVE 1                    TO CARTE-COMPTE-ID
           MOVE "4978 1234 5678 9012" TO CARTE-NUMERO
           MOVE "1234"               TO CARTE-PIN
           MOVE "2028-12-31"         TO CARTE-EXPIRATION
           MOVE 1                    TO CARTE-ACTIF
           MOVE 0                    TO CARTE-TENTATIVES
           MOVE 0                    TO CARTE-BLOQUE
           WRITE ENREG-CARTE
               INVALID KEY REWRITE ENREG-CARTE

      *-- Carte 2 : pour Compte 2 --
           MOVE 2                    TO CARTE-ID
           MOVE 2                    TO CARTE-COMPTE-ID
           MOVE "4978 2345 6789 0123" TO CARTE-NUMERO
           MOVE "1111"               TO CARTE-PIN
           MOVE "2027-10-31"         TO CARTE-EXPIRATION
           MOVE 1                    TO CARTE-ACTIF
           MOVE 0                    TO CARTE-TENTATIVES
           MOVE 0                    TO CARTE-BLOQUE
           WRITE ENREG-CARTE
               INVALID KEY REWRITE ENREG-CARTE

      *-- Carte 3 : pour Compte 3 --
           MOVE 3                    TO CARTE-ID
           MOVE 3                    TO CARTE-COMPTE-ID
           MOVE "4978 3456 7890 1234" TO CARTE-NUMERO
           MOVE "4321"               TO CARTE-PIN
           MOVE "2026-05-31"         TO CARTE-EXPIRATION
           MOVE 1                    TO CARTE-ACTIF
           MOVE 0                    TO CARTE-TENTATIVES
           MOVE 0                    TO CARTE-BLOQUE
           WRITE ENREG-CARTE
               INVALID KEY REWRITE ENREG-CARTE.

      *================================================================*
      *  ECRAN D'ACCUEIL                                             *
      *================================================================*
       ECRAN-ACCUEIL.
           MOVE 0 TO WS-AUTHENTIFIE
           MOVE SPACES TO WS-MSG WS-MSG2
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "          ____    _   _ __  __  "
           DISPLAY "         / __ \  | | | |  \/  | "
           DISPLAY "        / / _` | | |_| | |\/| | "
           DISPLAY "       | | (_| | |  _  | |  | | "
           DISPLAY "        \ \__,_| |_| |_|_|  |_| "
           DISPLAY "         \____/                  "
           DISPLAY " "
           DISPLAY WS-BANQUE
           DISPLAY WS-VERSION
           DISPLAY " "
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "  Bienvenue sur le terminal de paiement bancaire."
           DISPLAY "  Ce système est sécurisé et surveillé 24h/24."
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY "  CARTES DE TEST DISPONIBLES :"
           DISPLAY "  [1] 4978 1234 5678 9012   PIN:1234 COURANT"
           DISPLAY "  [2] 4978 2345 6789 0123   PIN:1111 EPARGNE"
           DISPLAY "  [3] 4978 3456 7890 1234   PIN:4321 COURANT"
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Appuyez sur ENTREE pour insérer votre carte..."
           DISPLAY "  (ou tapez Q pour quitter)"
           ACCEPT WS-CHOIX
           IF WS-CHOIX = "Q" OR WS-CHOIX = "q"
               MOVE 0 TO WS-CONTINUER
           END-IF.

      *================================================================*
      *  SAISIE ET VALIDATION DE LA CARTE                              *
      *================================================================*
       SAISIE-CARTE.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "            INSERTION DE CARTE                     "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Numéro de carte (ex: 4978 1234 5678 9012) :"
           ACCEPT WS-NUMERO-CARTE

           MOVE WS-NUMERO-CARTE TO CARTE-NUMERO
           READ FICHIER-CARTES KEY IS CARTE-NUMERO
               INVALID KEY
                   DISPLAY " "
                   DISPLAY "  [ERREUR] Carte non reconnue."
                   DISPLAY "  Vérifiez le numéro et réessayez."
                   PERFORM PAUSE-ECRAN
                   EXIT PARAGRAPH
               NOT INVALID KEY
                   CONTINUE
           END-READ

      *-- Vérification carte bloquée --
           IF CARTE-BLOQUE = 1
               DISPLAY " "
               DISPLAY "  [BLOQUEE] Cette carte est bloquée."
               DISPLAY "  Contactez votre conseiller bancaire."
               PERFORM PAUSE-ECRAN
               EXIT PARAGRAPH
           END-IF

      *-- Vérification carte active --
           IF CARTE-ACTIF = 0
               DISPLAY " "
               DISPLAY "  [INACTIVE] Cette carte est désactivée."
               PERFORM PAUSE-ECRAN
               EXIT PARAGRAPH
           END-IF

      *-- Sauvegarde des infos carte --
           MOVE CARTE-ID TO WS-CARTE-ID-ACTIF
           MOVE CARTE-COMPTE-ID TO WS-COMPTE-ID-ACTIF
           MOVE CARTE-TENTATIVES TO WS-PIN-TENTATIVES

      *-- Saisie du PIN --
           PERFORM SAISIE-PIN.

       SAISIE-PIN.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "            SAISIE DU CODE PIN                     "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Carte : " WS-NUMERO-CARTE
           DISPLAY " "

           IF WS-PIN-TENTATIVES > 0
               DISPLAY "  Attention: " WS-PIN-TENTATIVES
                   " tentative(s) échouée(s)"
               DISPLAY " "
           END-IF

           DISPLAY "  Entrez votre code PIN (4 chiffres) :"
           ACCEPT WS-PIN-SAISI

           IF WS-PIN-SAISI = CARTE-PIN
               MOVE 0 TO WS-PIN-TENTATIVES
               MOVE 0 TO CARTE-TENTATIVES
               REWRITE ENREG-CARTE
               PERFORM OUVRIR-SESSION
               MOVE 1 TO WS-AUTHENTIFIE
           ELSE
               ADD 1 TO WS-PIN-TENTATIVES
               MOVE WS-PIN-TENTATIVES TO CARTE-TENTATIVES
               REWRITE ENREG-CARTE

               IF WS-PIN-TENTATIVES >= 3
                   MOVE 1 TO CARTE-BLOQUE
                   REWRITE ENREG-CARTE
                   DISPLAY " "
                   DISPLAY "  [BLOQUEE] 3 tentatives incorrectes."
                   DISPLAY "  Votre carte est maintenant bloquée."
                   DISPLAY "  Contactez votre banque au 39 00."
                   PERFORM PAUSE-ECRAN
               ELSE
                   DISPLAY " "
                   DISPLAY "  [ERREUR] Code PIN incorrect."
                   MOVE 3 TO WS-NB-LIGNES
                   SUBTRACT WS-PIN-TENTATIVES FROM WS-NB-LIGNES
                   DISPLAY "  Il vous reste " WS-NB-LIGNES " essai(s)."
                   PERFORM PAUSE-ECRAN
                   PERFORM SAISIE-PIN
               END-IF
           END-IF.

      *================================================================*
      *  OUVERTURE DE SESSION                                          *
      *================================================================*
       OUVRIR-SESSION.
           MOVE FUNCTION CURRENT-DATE TO WS-DATETIME-NOW

           ADD 1 TO WS-SESSION-COUNT
           MOVE WS-SESSION-COUNT TO SESSION-ID
           MOVE WS-CARTE-ID-ACTIF TO SESSION-CARTE-ID
           MOVE WS-DATETIME-NOW TO SESSION-DEBUT
           MOVE SPACES TO SESSION-FIN
           MOVE "ACTIVE" TO SESSION-STATUT
           WRITE ENREG-SESSION
               INVALID KEY REWRITE ENREG-SESSION
           MOVE SESSION-ID TO WS-SESSION-ID

      *-- Chargement des infos du compte --
           MOVE WS-COMPTE-ID-ACTIF TO COMPTE-ID
           READ FICHIER-COMPTES KEY IS COMPTE-ID
           MOVE COMPTE-SOLDE TO WS-SOLDE-ACTIF
           MOVE COMPTE-PLAFOND TO WS-PLAFOND-ACTIF

      *-- Chargement des infos client --
           MOVE COMPTE-CLIENT-ID TO CLIENT-ID
           READ FICHIER-CLIENTS KEY IS CLIENT-ID
           STRING FUNCTION TRIM(CLIENT-PRENOM)
               " " FUNCTION TRIM(CLIENT-NOM)
               DELIMITED SIZE
               INTO WS-CLIENT-NOM-ACTIF.

      *================================================================*
      *  MENU PRINCIPAL                                                *
      *================================================================*
       MENU-PRINCIPAL.
           PERFORM UNTIL WS-AUTHENTIFIE = 0
               PERFORM AFFICHER-MENU
               EVALUATE WS-CHOIX
                   WHEN "1"
                       PERFORM OP-RETRAIT
                   WHEN "2"
                       PERFORM OP-DEPOT
                   WHEN "3"
                       PERFORM OP-CONSULTATION
                   WHEN "4"
                       PERFORM OP-MINI-RELEVE
                   WHEN "5"
                       PERFORM OP-CHANGEMENT-PIN
                   WHEN "0"
                       MOVE 0 TO WS-AUTHENTIFIE
                   WHEN OTHER
                       MOVE "  Option invalide. Veuillez réessayer."
                           TO WS-MSG
               END-EVALUATE
           END-PERFORM.

       AFFICHER-MENU.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY WS-BANQUE
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY "  Bonjour, " FUNCTION TRIM(WS-CLIENT-NOM-ACTIF)
           DISPLAY "  Session: " WS-SESSION-ID
               "    Compte: " COMPTE-TYPE
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "    MENU PRINCIPAL"
           DISPLAY " "
           DISPLAY "    [1]  Retrait d'espèces"
           DISPLAY "    [2]  Dépôt"
           DISPLAY "    [3]  Consultation de solde"
           DISPLAY "    [4]  Mini-relevé (5 dernières op.)"
           DISPLAY "    [5]  Changement de PIN"
           DISPLAY "    [0]  Fin de session"
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           IF WS-MSG NOT = SPACES
               DISPLAY WS-MSG
               DISPLAY " "
               MOVE SPACES TO WS-MSG
           END-IF
           DISPLAY "  Votre choix : "
           ACCEPT WS-CHOIX.

      *================================================================*
      *  OPERATION : RETRAIT                                         *
      *================================================================*
       OP-RETRAIT.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "           RETRAIT D'ESPECES                    "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           MOVE WS-PLAFOND-ACTIF TO WS-PLAFOND-AFF
           DISPLAY "  Solde disponible : " WS-SOLDE-AFF " EUR"
           DISPLAY "  Plafond de retrait: " WS-PLAFOND-AFF " EUR"
           DISPLAY " "
           DISPLAY "  Montants rapides:"
           DISPLAY "  [1] 20 EUR   [2] 50 EUR   [3] 100 EUR"
           DISPLAY "  [4] 150 EUR  [5] 200 EUR  [A] Autre montant"
           DISPLAY "  [0] Retour"
           DISPLAY " "
           DISPLAY "  Votre choix : "
           ACCEPT WS-CHOIX

           EVALUATE WS-CHOIX
               WHEN "1"  MOVE 20   TO WS-MONTANT-SAISI
               WHEN "2"  MOVE 50   TO WS-MONTANT-SAISI
               WHEN "3"  MOVE 100  TO WS-MONTANT-SAISI
               WHEN "4"  MOVE 150  TO WS-MONTANT-SAISI
               WHEN "5"  MOVE 200  TO WS-MONTANT-SAISI
               WHEN "A"
               WHEN "a"
                   DISPLAY "  Entrez le montant (multiple de 10) :"
                   ACCEPT WS-MONTANT-SAISI
               WHEN "0"
                   EXIT PARAGRAPH
               WHEN OTHER
                   MOVE "  Option invalide." TO WS-MSG
                   EXIT PARAGRAPH
           END-EVALUATE

      *-- Validation du montant --
           IF WS-MONTANT-SAISI <= 0
               MOVE "  [ERREUR] Montant invalide." TO WS-MSG
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION MOD(WS-MONTANT-SAISI, 10) NOT = 0
               MOVE "  [ERREUR] Le montant doit être multiple de 10."
                   TO WS-MSG
               EXIT PARAGRAPH
           END-IF

           IF WS-MONTANT-SAISI > WS-PLAFOND-ACTIF
               MOVE "  [REFUSE] Dépasse le plafond de retrait."
                   TO WS-MSG
               EXIT PARAGRAPH
           END-IF

           IF WS-MONTANT-SAISI > WS-SOLDE-ACTIF
               MOVE "  [REFUSE] Solde insuffisant."
                   TO WS-MSG
               EXIT PARAGRAPH
           END-IF

      *-- Confirmation --
           MOVE WS-MONTANT-SAISI TO WS-MONTANT-AFF
           DISPLAY " "
           DISPLAY "  Confirmer le retrait de " WS-MONTANT-AFF " EUR ?"
           DISPLAY "  [O]ui  [N]on"
           ACCEPT WS-CHOIX

           IF WS-CHOIX NOT = "O" AND WS-CHOIX NOT = "o"
               EXIT PARAGRAPH
           END-IF

      *-- Exécution du retrait --
           SUBTRACT WS-MONTANT-SAISI FROM WS-SOLDE-ACTIF
           MOVE WS-SOLDE-ACTIF TO COMPTE-SOLDE
           MOVE WS-COMPTE-ID-ACTIF TO COMPTE-ID
           READ FICHIER-COMPTES KEY IS COMPTE-ID
           MOVE WS-SOLDE-ACTIF TO COMPTE-SOLDE
           REWRITE ENREG-COMPTE

      *-- Enregistrement transaction --
           PERFORM ENREGISTRER-TRANSACTION
               THROUGH ENREGISTRER-TRANSACTION-FIN

           MOVE WS-MONTANT-SAISI TO WS-MONTANT-AFF
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           DISPLAY " "
           DISPLAY "  *** RETRAIT EFFECTUÉ ***"
           DISPLAY " "
           DISPLAY "  Montant retiré : " WS-MONTANT-AFF " EUR"
           DISPLAY "  Nouveau solde  : " WS-SOLDE-AFF " EUR"
           DISPLAY " "
           DISPLAY "  Veuillez prendre vos billets."
           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  OPERATION : DEPOT                                           *
      *================================================================*
       OP-DEPOT.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "           DEPOT D'ESPECES                       "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           DISPLAY "  Solde actuel : " WS-SOLDE-AFF " EUR"
           DISPLAY " "
           DISPLAY "  Entrez le montant à déposer (EUR) :"
           ACCEPT WS-MONTANT-SAISI

           IF WS-MONTANT-SAISI <= 0
               MOVE "  [ERREUR] Montant invalide." TO WS-MSG
               EXIT PARAGRAPH
           END-IF

      *-- Confirmation --
           MOVE WS-MONTANT-SAISI TO WS-MONTANT-AFF
           DISPLAY " "
           DISPLAY "  Confirmer le dépôt de " WS-MONTANT-AFF " EUR ?"
           DISPLAY "  [O]ui  [N]on"
           ACCEPT WS-CHOIX

           IF WS-CHOIX NOT = "O" AND WS-CHOIX NOT = "o"
               EXIT PARAGRAPH
           END-IF

      *-- Exécution du dépôt --
           ADD WS-MONTANT-SAISI TO WS-SOLDE-ACTIF
           MOVE WS-COMPTE-ID-ACTIF TO COMPTE-ID
           READ FICHIER-COMPTES KEY IS COMPTE-ID
           MOVE WS-SOLDE-ACTIF TO COMPTE-SOLDE
           REWRITE ENREG-COMPTE

           PERFORM ENREGISTRER-TRANSACTION
               THROUGH ENREGISTRER-TRANSACTION-FIN

           MOVE WS-MONTANT-SAISI TO WS-MONTANT-AFF
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           DISPLAY " "
           DISPLAY "  *** DÉPÔT EFFECTUÉ ***"
           DISPLAY " "
           DISPLAY "  Montant déposé : " WS-MONTANT-AFF " EUR"
           DISPLAY "  Nouveau solde  : " WS-SOLDE-AFF " EUR"
           DISPLAY " "
           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  OPERATION : CONSULTATION                                    *
      *================================================================*
       OP-CONSULTATION.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "           CONSULTATION DE SOLDE                   "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Titulaire : " FUNCTION TRIM(WS-CLIENT-NOM-ACTIF)
           DISPLAY "  Compte    : " COMPTE-NUMERO
           DISPLAY "  Type      : " COMPTE-TYPE
           DISPLAY "  Ouvert le : " COMPTE-DATE-OUV
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           MOVE WS-PLAFOND-ACTIF TO WS-PLAFOND-AFF
           DISPLAY " "
           DISPLAY "  SOLDE DISPONIBLE : " WS-SOLDE-AFF " EUR"
           DISPLAY " "
           DISPLAY "  Plafond retrait  : " WS-PLAFOND-AFF " EUR"
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE

      *-- Enregistrement de la consultation --
           MOVE SPACES TO WS-CHOIX
           PERFORM ENREGISTRER-TRANSACTION
               THROUGH ENREGISTRER-TRANSACTION-FIN

           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  OPERATION : MINI-RELEVE                                     *
      *================================================================*
       OP-MINI-RELEVE.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "           MINI-RELEVE DE COMPTE                 "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY "  Titulaire : " FUNCTION TRIM(WS-CLIENT-NOM-ACTIF)
           DISPLAY "  Compte    : " COMPTE-NUMERO
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY WS-RELEVE-ENTETE
           DISPLAY WS-LIGNE-SIMPLE

      *-- Lecture des 5 dernières transactions de la session --
           MOVE 0 TO WS-TRANS-INDEX
           MOVE 1 TO TRANS-ID
           START FICHIER-TRANSACTIONS KEY >= TRANS-ID

           PERFORM UNTIL WS-TRANS-INDEX >= WS-MAX-TRANS
               READ FICHIER-TRANSACTIONS NEXT
                   AT END
                       EXIT PERFORM
                   NOT AT END
                       IF TRANS-SESSION-ID = WS-SESSION-ID
                           ADD 1 TO WS-TRANS-INDEX
                           MOVE TRANS-TYPE TO
                               TT-TYPE(WS-TRANS-INDEX)
                           MOVE TRANS-MONTANT TO
                               TT-MONTANT(WS-TRANS-INDEX)
                           MOVE TRANS-DATETIME TO
                               TT-DATETIME(WS-TRANS-INDEX)
                           MOVE TRANS-SOLDE-APRES TO
                               TT-SOLDE-APRES(WS-TRANS-INDEX)
                       END-IF
               END-READ
           END-PERFORM

           IF WS-TRANS-INDEX = 0
               DISPLAY "  Aucune transaction dans cette session."
           ELSE
               PERFORM VARYING WS-NB-LIGNES FROM 1 BY 1
                   UNTIL WS-NB-LIGNES > WS-TRANS-INDEX
                   MOVE TT-MONTANT(WS-NB-LIGNES) TO WS-MONTANT-AFF
                   MOVE TT-SOLDE-APRES(WS-NB-LIGNES) TO WS-SOLDE-AFF
                   DISPLAY "  "
                       TT-DATETIME(WS-NB-LIGNES)(1:16)
                       "  "
                       TT-TYPE(WS-NB-LIGNES)
                       "  "
                       WS-MONTANT-AFF
                       "  "
                       WS-SOLDE-AFF
               END-PERFORM
           END-IF

           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           MOVE WS-SOLDE-ACTIF TO WS-SOLDE-AFF
           DISPLAY "  SOLDE ACTUEL : " WS-SOLDE-AFF " EUR"
           DISPLAY " "
           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  OPERATION : CHANGEMENT DE PIN                               *
      *================================================================*
       OP-CHANGEMENT-PIN.
           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "           CHANGEMENT DE CODE PIN                  "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Entrez votre PIN actuel :"
           ACCEPT WS-PIN-SAISI

           MOVE WS-CARTE-ID-ACTIF TO CARTE-ID
           READ FICHIER-CARTES KEY IS CARTE-ID

           IF WS-PIN-SAISI NOT = CARTE-PIN
               MOVE "  [ERREUR] PIN actuel incorrect." TO WS-MSG
               EXIT PARAGRAPH
           END-IF

           DISPLAY "  Entrez votre nouveau PIN (4 chiffres) :"
           ACCEPT WS-PIN-SAISI

           IF FUNCTION LENGTH(FUNCTION TRIM(WS-PIN-SAISI)) NOT = 4
               MOVE "  [ERREUR] PIN invalide (4 chiffres requis)."
                   TO WS-MSG
               EXIT PARAGRAPH
           END-IF

           MOVE WS-PIN-SAISI TO CARTE-PIN
           REWRITE ENREG-CARTE

           DISPLAY " "
           DISPLAY "  *** PIN modifié avec succès ***"
           DISPLAY "  Votre nouveau code est actif immédiatement."
           DISPLAY " "
           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  ENREGISTREMENT D'UNE TRANSACTION                              *
      *================================================================*
       ENREGISTRER-TRANSACTION.
           ADD 1 TO WS-TRANS-COUNT
           MOVE WS-TRANS-COUNT TO TRANS-ID
           MOVE WS-SESSION-ID TO TRANS-SESSION-ID
           MOVE FUNCTION CURRENT-DATE TO TRANS-DATETIME
           EVALUATE WS-CHOIX
               WHEN "1"  MOVE "RETRAIT"      TO TRANS-TYPE
               WHEN "2"  MOVE "DEPOT"        TO TRANS-TYPE
               WHEN "3"  MOVE "CONSULTATION" TO TRANS-TYPE
               WHEN OTHER MOVE "CONSULTATION" TO TRANS-TYPE
           END-EVALUATE
           MOVE WS-MONTANT-SAISI TO TRANS-MONTANT
           ADD WS-SOLDE-ACTIF WS-MONTANT-SAISI
               GIVING TRANS-SOLDE-AVANT
           MOVE WS-SOLDE-ACTIF TO TRANS-SOLDE-APRES
           MOVE "OK" TO TRANS-STATUT
           WRITE ENREG-TRANSACTION
               INVALID KEY CONTINUE.
       ENREGISTRER-TRANSACTION-FIN.
           CONTINUE.

      *================================================================*
      *  FERMETURE DE SESSION                                          *
      *================================================================*
       FERMER-SESSION.
           MOVE WS-SESSION-ID TO SESSION-ID
           READ FICHIER-SESSIONS KEY IS SESSION-ID
           MOVE FUNCTION CURRENT-DATE TO SESSION-FIN
           MOVE "FERMEE" TO SESSION-STATUT
           REWRITE ENREG-SESSION

           PERFORM EFFACER-ECRAN
           DISPLAY WS-LIGNE-TITRE
           DISPLAY " "
           DISPLAY "              FIN DE SESSION                       "
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           DISPLAY "  Merci d'avoir utilisé notre service."
           DISPLAY "  Au revoir, " FUNCTION TRIM(WS-CLIENT-NOM-ACTIF)
           DISPLAY " "
           DISPLAY "  N'oubliez pas de reprendre votre carte."
           DISPLAY " "
           DISPLAY WS-LIGNE-SIMPLE
           DISPLAY " "
           PERFORM PAUSE-ECRAN.

      *================================================================*
      *  FERMETURE DES FICHIERS                                        *
      *================================================================*
       FERMER-FICHIERS.
           CLOSE FICHIER-CLIENTS
           CLOSE FICHIER-COMPTES
           CLOSE FICHIER-CARTES
           CLOSE FICHIER-SESSIONS
           CLOSE FICHIER-TRANSACTIONS.

      *================================================================*
      *  UTILITAIRES                                                   *
      *================================================================*
       EFFACER-ECRAN.
           DISPLAY SPACE.

       PAUSE-ECRAN.
           DISPLAY "  Appuyez sur ENTREE pour continuer..."
           ACCEPT WS-CHOIX.
