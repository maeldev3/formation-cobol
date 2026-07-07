      ******************************************************************
      * PROGRAMME  : TP12CLI
      * OBJET      : TP12 - Tableaux (OCCURS)
      *              Gestion d'un tableau memoire de clients
      * NOTIONS    : OCCURS, INDEXED BY, SEARCH, SEARCH ALL
      * EXERCICES  : - stocker 20 clients
      *              - rechercher un client (par ID -> SEARCH ALL)
      *              - rechercher un client (par NOM -> SEARCH)
      *              - afficher tous les clients
      *              - compter les clients
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TP12CLI.
       AUTHOR. TP12-COBOL.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      ******************************************************************
      *  TABLEAU DES CLIENTS - OCCURS 20 - INDEXED BY IDX
      *  Cle croissante CLI-ID -> permet d'utiliser SEARCH ALL
      ******************************************************************
       01  WS-CLIENT-TABLE.
           05  CLIENT-ENTRY OCCURS 20 TIMES
                            ASCENDING KEY IS CLI-ID
                            INDEXED BY IDX.
               10  CLI-ID       PIC 9(3).
               10  CLI-NOM      PIC X(15).
               10  CLI-PRENOM   PIC X(15).
               10  CLI-VILLE    PIC X(15).
               10  CLI-SOLDE    PIC 9(6)V99.

      ******************************************************************
      *  VARIABLES DE TRAVAIL
      ******************************************************************
       01  WS-VARIABLES.
           05  WS-NB-CLIENTS    PIC 9(3)  VALUE 0.
           05  WS-CHOIX         PIC 9     VALUE 0.
           05  WS-CHOIX-RECH    PIC 9     VALUE 0.
           05  WS-ID-RECH       PIC 9(3)  VALUE 0.
           05  WS-NOM-RECH      PIC X(15) VALUE SPACES.
           05  WS-SOLDE-EDIT    PIC ZZZ,ZZ9.99.
           05  WS-COMPTEUR      PIC 9(3)  VALUE 0.

      ******************************************************************
      *  DONNEES DE DEMONSTRATION (chargement automatique)
      *  Utile pour tester rapidement sans saisie manuelle
      ******************************************************************
       01  WS-DEMO-FLAG         PIC X     VALUE 'N'.
           88  DEMO-CHARGEE     VALUE 'O'.

       PROCEDURE DIVISION.

      ******************************************************************
      *  PARAGRAPHE PRINCIPAL
      ******************************************************************
       MAIN-PARA.
           DISPLAY " ".
           DISPLAY "=================================================".
           DISPLAY "  TP12 - TABLEAUX (OCCURS) - GESTION CLIENTS     ".
           DISPLAY "=================================================".

           PERFORM UNTIL WS-CHOIX = 6
               PERFORM AFFICHER-MENU
               ACCEPT WS-CHOIX
               EVALUATE WS-CHOIX
                   WHEN 1
                       PERFORM CHARGER-DONNEES-DEMO
                   WHEN 2
                       PERFORM SAISIR-CLIENT
                   WHEN 3
                       PERFORM RECHERCHER-CLIENT
                   WHEN 4
                       PERFORM AFFICHER-TOUS-CLIENTS
                   WHEN 5
                       PERFORM COMPTER-CLIENTS
                   WHEN 6
                       DISPLAY "Fin du programme TP12."
                   WHEN OTHER
                       DISPLAY "*** Choix invalide, reessayez. ***"
               END-EVALUATE
           END-PERFORM.

           STOP RUN.

      ******************************************************************
      *  AFFICHAGE DU MENU
      ******************************************************************
       AFFICHER-MENU.
           DISPLAY " ".
           DISPLAY "-------------------------------------------------".
           DISPLAY "1. Charger 20 clients de demonstration".
           DISPLAY "2. Saisir un client (manuel, max 20)".
           DISPLAY "3. Rechercher un client (SEARCH / SEARCH ALL)".
           DISPLAY "4. Afficher tous les clients".
           DISPLAY "5. Compter les clients".
           DISPLAY "6. Quitter".
           DISPLAY "-------------------------------------------------".
           DISPLAY "Votre choix : " WITH NO ADVANCING.

      ******************************************************************
      *  EXERCICE 1 : STOCKER 20 CLIENTS
      *  Chargement automatique de 20 clients (donnees de demo)
      *  afin de manipuler directement le tableau OCCURS.
      ******************************************************************
       CHARGER-DONNEES-DEMO.
           IF DEMO-CHARGEE
               DISPLAY "Donnees de demo deja chargees."
           ELSE
               MOVE 0 TO WS-NB-CLIENTS
               PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > 20
                   ADD 1 TO WS-NB-CLIENTS
                   MOVE WS-NB-CLIENTS   TO CLI-ID(IDX)
                   STRING "NOM" DELIMITED BY SIZE
                       WS-NB-CLIENTS DELIMITED BY SIZE
                       INTO CLI-NOM(IDX)
                   STRING "PRENOM" DELIMITED BY SIZE
                       WS-NB-CLIENTS DELIMITED BY SIZE
                       INTO CLI-PRENOM(IDX)
                   STRING "VILLE" DELIMITED BY SIZE
                       WS-NB-CLIENTS DELIMITED BY SIZE
                       INTO CLI-VILLE(IDX)
                   COMPUTE CLI-SOLDE(IDX) = WS-NB-CLIENTS * 111.11
               END-PERFORM
               SET DEMO-CHARGEE TO TRUE
               DISPLAY "20 clients de demonstration ont ete charges."
           END-IF.

      ******************************************************************
      *  SAISIE MANUELLE D'UN CLIENT (ajout en fin de tableau)
      *  Les ID doivent rester croissants pour permettre SEARCH ALL.
      ******************************************************************
       SAISIR-CLIENT.
           IF WS-NB-CLIENTS >= 20
               DISPLAY "*** Tableau plein : 20 clients maximum. ***"
           ELSE
               ADD 1 TO WS-NB-CLIENTS
               SET IDX TO WS-NB-CLIENTS
               MOVE WS-NB-CLIENTS TO CLI-ID(IDX)

               DISPLAY "Nom du client     : " WITH NO ADVANCING
               ACCEPT CLI-NOM(IDX)
               DISPLAY "Prenom du client  : " WITH NO ADVANCING
               ACCEPT CLI-PRENOM(IDX)
               DISPLAY "Ville du client   : " WITH NO ADVANCING
               ACCEPT CLI-VILLE(IDX)
               DISPLAY "Solde du client   : " WITH NO ADVANCING
               ACCEPT CLI-SOLDE(IDX)

               SET DEMO-CHARGEE TO TRUE
               DISPLAY "Client N. " CLI-ID(IDX) " ajoute avec succes."
           END-IF.

      ******************************************************************
      *  EXERCICE 2 : RECHERCHER UN CLIENT
      *  Propose recherche par ID (SEARCH ALL) ou par NOM (SEARCH)
      *  ou par NOM (SEARCH - lineaire, sequentielle)
      ******************************************************************
       RECHERCHER-CLIENT.
           IF WS-NB-CLIENTS = 0
               DISPLAY "*** Aucun client enregistre. ***"
           ELSE
               DISPLAY "Recherche : 1-ID(SEARCH ALL) 2-Nom(SEARCH)"
               DISPLAY "Votre choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX-RECH
               EVALUATE WS-CHOIX-RECH
                   WHEN 1
                       PERFORM RECHERCHER-PAR-ID
                   WHEN 2
                       PERFORM RECHERCHER-PAR-NOM
                   WHEN OTHER
                       DISPLAY "*** Choix invalide. ***"
               END-EVALUATE
           END-IF.

      ******************************************************************
      *  RECHERCHE PAR ID -> SEARCH ALL (recherche binaire)
      *  Necessite un tableau trie sur la cle CLI-ID (ASCENDING KEY)
      ******************************************************************
       RECHERCHER-PAR-ID.
           DISPLAY "Entrez l'ID du client (1 a " WS-NB-CLIENTS ") : "
               WITH NO ADVANCING
           ACCEPT WS-ID-RECH

           SET IDX TO 1
           SEARCH ALL CLIENT-ENTRY
               AT END
                   DISPLAY "*** Client ID " WS-ID-RECH " non trouve ***"
               WHEN CLI-ID(IDX) = WS-ID-RECH
                   PERFORM AFFICHER-DETAIL-CLIENT
           END-SEARCH.

      ******************************************************************
      *  RECHERCHE PAR NOM -> SEARCH (recherche sequentielle/lineaire)
      ******************************************************************
       RECHERCHER-PAR-NOM.
           DISPLAY "Entrez le nom du client (ex: NOM005) : "
               WITH NO ADVANCING
           ACCEPT WS-NOM-RECH

           SET IDX TO 1
           SEARCH CLIENT-ENTRY
               AT END
                   DISPLAY "*** Client '" WS-NOM-RECH "' non trouve ***"
               WHEN CLI-NOM(IDX) = WS-NOM-RECH
                   PERFORM AFFICHER-DETAIL-CLIENT
           END-SEARCH.

      ******************************************************************
      *  AFFICHAGE DETAILLE D'UN CLIENT TROUVE
      ******************************************************************
       AFFICHER-DETAIL-CLIENT.
           MOVE CLI-SOLDE(IDX) TO WS-SOLDE-EDIT
           DISPLAY "----- CLIENT TROUVE -----".
           DISPLAY "ID      : " CLI-ID(IDX).
           DISPLAY "Nom     : " CLI-NOM(IDX).
           DISPLAY "Prenom  : " CLI-PRENOM(IDX).
           DISPLAY "Ville   : " CLI-VILLE(IDX).
           DISPLAY "Solde   : " WS-SOLDE-EDIT.
           DISPLAY "--------------------------".

      ******************************************************************
      *  EXERCICE 3 : AFFICHER TOUS LES CLIENTS
      ******************************************************************
       AFFICHER-TOUS-CLIENTS.
           IF WS-NB-CLIENTS = 0
               DISPLAY "*** Aucun client a afficher. ***"
           ELSE
               DISPLAY " "
               DISPLAY "========== LISTE DES CLIENTS =========="
               DISPLAY "ID  NOM         PRENOM      VILLE      SOLDE"
               DISPLAY "----------------------------------------"
               PERFORM VARYING IDX FROM 1 BY 1 UNTIL IDX > WS-NB-CLIENTS
                   MOVE CLI-SOLDE(IDX) TO WS-SOLDE-EDIT
                   DISPLAY CLI-ID(IDX) "  " CLI-NOM(IDX) "  "
                           CLI-PRENOM(IDX) "  " CLI-VILLE(IDX) "  "
                           WS-SOLDE-EDIT
               END-PERFORM
               DISPLAY "========================================"
           END-IF.

      ******************************************************************
      *  EXERCICE 4 : COMPTER LES CLIENTS
      ******************************************************************
       COMPTER-CLIENTS.
           DISPLAY " ".
           DISPLAY "Total clients enregistres : " WS-NB-CLIENTS.
