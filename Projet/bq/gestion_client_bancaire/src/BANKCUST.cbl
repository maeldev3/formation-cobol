      *================================================================*
      * PROGRAM:    BANKCUST                                           *
      * DESCRIPTION: Bank Customer Management System                  *
      * AUTHOR:      Senior COBOL Developer                           *
      * DATE:        2025                                              *
      * VERSION:     1.0.0                                             *
      *                                                                *
      * FONCTIONNALITES:                                               *
      *   - Creation client                                            *
      *   - Modification client                                        *
      *   - Suppression client                                         *
      *   - Recherche client                                           *
      *   - Gestion profils (STANDARD/PREMIUM/CORPORATE)              *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKCUST.
       AUTHOR. SENIOR-DEV.
       DATE-WRITTEN. 2025-01-01.
       DATE-COMPILED.

      *----------------------------------------------------------------*
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-MAINFRAME.
       OBJECT-COMPUTER. IBM-MAINFRAME.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE
               ASSIGN TO "data/CUSTFILE.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CUST-ID
               ALTERNATE RECORD KEY IS CUST-NOM
                   WITH DUPLICATES
               FILE STATUS IS WS-FILE-STATUS.

           SELECT AUDIT-FILE
               ASSIGN TO "data/AUDITLOG.dat"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-AUDIT-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO "data/CUSTRPT.txt"
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.

      *----------------------------------------------------------------*
       DATA DIVISION.
       FILE SECTION.

      *--- FICHIER CLIENT INDEXE ---*
       FD  CUSTOMER-FILE
           LABEL RECORDS ARE STANDARD
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 300 CHARACTERS.

       01  CUSTOMER-RECORD.
           05  CUST-ID              PIC 9(8).
           05  CUST-NOM             PIC X(30).
           05  CUST-PRENOM          PIC X(25).
           05  CUST-DATE-NAIS       PIC 9(8).
           05  CUST-CNI             PIC X(15).
           05  CUST-TELEPHONE       PIC X(15).
           05  CUST-EMAIL           PIC X(50).
           05  CUST-ADRESSE.
               10  CUST-RUE         PIC X(50).
               10  CUST-VILLE       PIC X(30).
               10  CUST-CODE-POST   PIC X(10).
               10  CUST-PAYS        PIC X(20).
           05  CUST-PROFIL          PIC X(10).
               88  PROFIL-STANDARD  VALUE "STANDARD".
               88  PROFIL-PREMIUM   VALUE "PREMIUM".
               88  PROFIL-CORPORATE VALUE "CORPORATE".
           05  CUST-SOLDE           PIC S9(12)V99 COMP-3.
           05  CUST-DATE-OUVERTURE  PIC 9(8).
           05  CUST-DATE-MAJ        PIC 9(8).
           05  CUST-STATUT          PIC X(1).
               88  STATUT-ACTIF     VALUE "A".
               88  STATUT-INACTIF   VALUE "I".
               88  STATUT-BLOQUE    VALUE "B".
           05  CUST-NB-COMPTES      PIC 9(3).
           05  FILLER               PIC X(10).

      *--- FICHIER AUDIT ---*
       FD  AUDIT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 150 CHARACTERS.

       01  AUDIT-RECORD.
           05  AUD-DATE-HEURE       PIC X(14).
           05  AUD-OPERATION        PIC X(10).
           05  AUD-CUST-ID          PIC 9(8).
           05  AUD-DESCRIPTION      PIC X(80).
           05  AUD-OPERATEUR        PIC X(20).
           05  FILLER               PIC X(18).

      *--- FICHIER RAPPORT ---*
       FD  REPORT-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 132 CHARACTERS.

       01  REPORT-LINE              PIC X(132).

      *================================================================*
       WORKING-STORAGE SECTION.

      *--- CONSTANTES ---*
       01  WS-CONSTANTS.
           05  WS-MAX-CLIENTS       PIC 9(8)  VALUE 99999999.
           05  WS-PROG-VERSION      PIC X(10) VALUE "V1.0.0".
           05  WS-PROG-NAME         PIC X(20) VALUE "BANKCUST".

      *--- STATUTS FICHIERS ---*
       01  WS-FILE-STATUS           PIC X(2) VALUE SPACES.
       01  WS-AUDIT-STATUS          PIC X(2) VALUE SPACES.
       01  WS-REPORT-STATUS         PIC X(2) VALUE SPACES.

      *--- CODES RETOUR ---*
       01  WS-RETURN-CODE           PIC S9(4) COMP.
           88  RC-OK                VALUE 0.
           88  RC-NOT-FOUND         VALUE 4.
           88  RC-DUPLICATE         VALUE 8.
           88  RC-FILE-ERROR        VALUE 12.
           88  RC-VALIDATION-ERROR  VALUE 16.

      *--- DONNEES DATE/HEURE ---*
       01  WS-CURRENT-DATE.
           05  WS-CURR-YEAR         PIC 9(4).
           05  WS-CURR-MONTH        PIC 9(2).
           05  WS-CURR-DAY          PIC 9(2).
       01  WS-CURRENT-TIME.
           05  WS-CURR-HOUR         PIC 9(2).
           05  WS-CURR-MIN          PIC 9(2).
           05  WS-CURR-SEC          PIC 9(2).
       01  WS-DATE-NUMERIC          PIC 9(8).
       01  WS-DATETIME-STR          PIC X(14).

      *--- VARIABLES MENU ---*
       01  WS-MENU-CHOICE           PIC X(1).
       01  WS-SUBMENU-CHOICE        PIC X(1).
       01  WS-CONTINUE              PIC X(1) VALUE "Y".
           88  CONTINUE-YES         VALUE "Y" "y".

      *--- VARIABLES TRAVAIL ---*
       01  WS-SEARCH-ID             PIC 9(8).
       01  WS-SEARCH-NOM            PIC X(30).
       01  WS-TEMP-ID               PIC 9(8).
       01  WS-CONFIRM               PIC X(1).
       01  WS-FOUND-FLAG            PIC X(1).
           88  RECORD-FOUND         VALUE "Y".
           88  RECORD-NOT-FOUND     VALUE "N".
       01  WS-COUNTER               PIC 9(8) VALUE ZEROS.
       01  WS-TOTAL-SOLDE           PIC S9(15)V99 COMP-3.
       01  WS-NEXT-ID               PIC 9(8) VALUE ZEROS.

      *--- MESSAGES ERREUR ---*
       01  WS-ERROR-MSG             PIC X(80) VALUE SPACES.
       01  WS-INFO-MSG              PIC X(80) VALUE SPACES.

      *--- OPERATEUR ---*
       01  WS-OPERATEUR             PIC X(20) VALUE "SYSTEM".

      *--- ZONE SAISIE TEMPORAIRE ---*
       01  WS-INPUT-BUFFER          PIC X(100) VALUE SPACES.

      *--- ECRAN DONNEES CLIENT (SAISIE) ---*
       01  WS-CLIENT-INPUT.
           05  IN-ID                PIC 9(8).
           05  IN-NOM               PIC X(30).
           05  IN-PRENOM            PIC X(25).
           05  IN-DATE-NAIS         PIC 9(8).
           05  IN-CNI               PIC X(15).
           05  IN-TELEPHONE         PIC X(15).
           05  IN-EMAIL             PIC X(50).
           05  IN-RUE               PIC X(50).
           05  IN-VILLE             PIC X(30).
           05  IN-CODE-POST         PIC X(10).
           05  IN-PAYS              PIC X(20).
           05  IN-PROFIL            PIC X(10).
           05  IN-SOLDE             PIC S9(12)V99 COMP-3.
           05  IN-STATUT            PIC X(1).

      *--- COMPTEURS STATISTIQUES ---*
       01  WS-STATS.
           05  STAT-TOTAL-CLIENTS   PIC 9(8) VALUE 0.
           05  STAT-ACTIFS          PIC 9(8) VALUE 0.
           05  STAT-INACTIFS        PIC 9(8) VALUE 0.
           05  STAT-BLOQUES         PIC 9(8) VALUE 0.
           05  STAT-STANDARD        PIC 9(8) VALUE 0.
           05  STAT-PREMIUM         PIC 9(8) VALUE 0.
           05  STAT-CORPORATE       PIC 9(8) VALUE 0.

      *--- AFFICHAGE SOLDE ---*
       01  WS-SOLDE-DISPLAY         PIC -ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-TOTAL-DISPLAY         PIC -ZZZ,ZZZ,ZZZ,ZZZ,ZZ9.99.

      *--- RAPPORT LIGNES ---*
       01  WS-RPT-HEADER1.
           05  FILLER PIC X(40) VALUE
               "================================================".
           05  FILLER PIC X(52) VALUE
               "============================================".
       01  WS-RPT-HEADER2.
           05  FILLER PIC X(20) VALUE SPACES.
           05  FILLER PIC X(40) VALUE
               "BANK CUSTOMER MANAGEMENT SYSTEM - RAPPORT".
           05  FILLER PIC X(72) VALUE SPACES.
       01  WS-RPT-COL-HDR.
           05  FILLER PIC X(10) VALUE "ID      ".
           05  FILLER PIC X(32) VALUE "NOM                  PRENOM      ".
           05  FILLER PIC X(12) VALUE "PROFIL    ".
           05  FILLER PIC X(8)  VALUE "STATUT".
           05  FILLER PIC X(20) VALUE "  SOLDE".
           05  FILLER PIC X(50) VALUE SPACES.
       01  WS-RPT-DETAIL.
           05  RPT-ID               PIC 9(8).
           05  FILLER               PIC X(2) VALUE SPACES.
           05  RPT-NOM              PIC X(20).
           05  FILLER               PIC X(2) VALUE SPACES.
           05  RPT-PRENOM           PIC X(15).
           05  FILLER               PIC X(2) VALUE SPACES.
           05  RPT-PROFIL           PIC X(10).
           05  FILLER               PIC X(2) VALUE SPACES.
           05  RPT-STATUT           PIC X(1).
           05  FILLER               PIC X(4) VALUE SPACES.
           05  RPT-SOLDE            PIC -ZZZ,ZZZ,ZZ9.99.
           05  FILLER               PIC X(54) VALUE SPACES.

      *================================================================*
       PROCEDURE DIVISION.

      *================================================================*
       0000-MAIN.
      *================================================================*
           PERFORM 1000-INIT
           PERFORM 2000-MAIN-MENU UNTIL NOT CONTINUE-YES
           PERFORM 9000-FINALIZE
           STOP RUN.

      *================================================================*
       1000-INIT.
      *================================================================*
           PERFORM 1100-GET-DATETIME
           PERFORM 1200-OPEN-FILES
           PERFORM 1300-DISPLAY-BANNER
           .

       1100-GET-DATETIME.
           MOVE FUNCTION CURRENT-DATE(1:8)  TO WS-DATE-NUMERIC
           MOVE WS-DATE-NUMERIC(1:4)        TO WS-CURR-YEAR
           MOVE WS-DATE-NUMERIC(5:2)        TO WS-CURR-MONTH
           MOVE WS-DATE-NUMERIC(7:2)        TO WS-CURR-DAY
           MOVE FUNCTION CURRENT-DATE(9:6)  TO WS-CURRENT-TIME
           STRING WS-DATE-NUMERIC DELIMITED SIZE
                  WS-CURRENT-TIME(1:6) DELIMITED SIZE
               INTO WS-DATETIME-STR
           .

       1200-OPEN-FILES.
           OPEN I-O CUSTOMER-FILE
           IF WS-FILE-STATUS = "35"
               OPEN OUTPUT CUSTOMER-FILE
               CLOSE CUSTOMER-FILE
               OPEN I-O CUSTOMER-FILE
           END-IF
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERREUR OUVERTURE FICHIER CLIENT: "
                       WS-FILE-STATUS
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF

           OPEN EXTEND AUDIT-FILE
           IF WS-AUDIT-STATUS NOT = "00" AND
              WS-AUDIT-STATUS NOT = "35"
               DISPLAY "ERREUR OUVERTURE FICHIER AUDIT: "
                       WS-AUDIT-STATUS
           END-IF
           .

       1300-DISPLAY-BANNER.
           DISPLAY " "
           DISPLAY "======================================================="
           DISPLAY "       BANK CUSTOMER MANAGEMENT SYSTEM v1.0.0          "
           DISPLAY "       Systeme de Gestion des Clients Bancaires         "
           DISPLAY "======================================================="
           DISPLAY " "
           .

      *================================================================*
       2000-MAIN-MENU.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== MENU PRINCIPAL ==================================="
           DISPLAY "  1. Creer un nouveau client"
           DISPLAY "  2. Modifier un client"
           DISPLAY "  3. Supprimer un client"
           DISPLAY "  4. Rechercher un client"
           DISPLAY "  5. Lister tous les clients"
           DISPLAY "  6. Gestion des profils"
           DISPLAY "  7. Rapport et statistiques"
           DISPLAY "  8. Configurer operateur"
           DISPLAY "  0. Quitter"
           DISPLAY "======================================================"
           DISPLAY "Votre choix: " WITH NO ADVANCING
           ACCEPT WS-MENU-CHOICE

           EVALUATE WS-MENU-CHOICE
               WHEN "1"  PERFORM 3000-CREATE-CUSTOMER
               WHEN "2"  PERFORM 4000-UPDATE-CUSTOMER
               WHEN "3"  PERFORM 5000-DELETE-CUSTOMER
               WHEN "4"  PERFORM 6000-SEARCH-CUSTOMER
               WHEN "5"  PERFORM 7000-LIST-CUSTOMERS
               WHEN "6"  PERFORM 8000-MANAGE-PROFILE
               WHEN "7"  PERFORM 8500-REPORTS-STATS
               WHEN "8"  PERFORM 8700-SET-OPERATOR
               WHEN "0"
                   MOVE "N" TO WS-CONTINUE
               WHEN OTHER
                   DISPLAY "CHOIX INVALIDE. Veuillez reessayer."
           END-EVALUATE
           .

      *================================================================*
       3000-CREATE-CUSTOMER.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== CREATION NOUVEAU CLIENT =========================="
           PERFORM 3100-GET-NEXT-ID
           PERFORM 3200-INPUT-CUSTOMER-DATA
           IF RC-VALIDATION-ERROR
               DISPLAY "CREATION ANNULEE - Donnees invalides."
               GO TO 3000-EXIT
           END-IF
           PERFORM 3300-WRITE-CUSTOMER
           IF RC-OK
               DISPLAY "CLIENT CREE AVEC SUCCES - ID: " IN-ID
               PERFORM 9100-WRITE-AUDIT THRU 9100-EXIT
           ELSE
               DISPLAY "ERREUR CREATION CLIENT: " WS-ERROR-MSG
           END-IF
           3000-EXIT.
           EXIT.

       3100-GET-NEXT-ID.
           MOVE ZEROS TO WS-NEXT-ID
           MOVE HIGH-VALUES TO CUSTOMER-RECORD
           START CUSTOMER-FILE KEY >= CUST-ID
           IF WS-FILE-STATUS = "00"
               PERFORM UNTIL WS-FILE-STATUS NOT = "00"
                   READ CUSTOMER-FILE NEXT
                       NOT AT END
                           IF CUST-ID > WS-NEXT-ID
                               MOVE CUST-ID TO WS-NEXT-ID
                           END-IF
                   AT END
                       CONTINUE
                   END-READ
               END-PERFORM
           END-IF
           ADD 1 TO WS-NEXT-ID
           MOVE WS-NEXT-ID TO IN-ID
           DISPLAY "ID CLIENT ASSIGNE: " IN-ID
           .

       3200-INPUT-CUSTOMER-DATA.
           MOVE ZERO         TO WS-RETURN-CODE
           INITIALIZE IN-NOM IN-PRENOM IN-DATE-NAIS
                      IN-CNI IN-TELEPHONE IN-EMAIL
                      IN-RUE IN-VILLE IN-CODE-POST
                      IN-PAYS IN-PROFIL IN-STATUT

           DISPLAY "--- INFORMATIONS PERSONNELLES ---"
           DISPLAY "Nom de famille     : " WITH NO ADVANCING
           ACCEPT IN-NOM
           PERFORM 3210-VALIDATE-NOM
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "Prenom             : " WITH NO ADVANCING
           ACCEPT IN-PRENOM
           PERFORM 3220-VALIDATE-PRENOM
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "Date naissance     : (AAAAMMJJ) "
                   WITH NO ADVANCING
           ACCEPT IN-DATE-NAIS
           PERFORM 3230-VALIDATE-DATE
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "Numero CNI/Passport: " WITH NO ADVANCING
           ACCEPT IN-CNI
           PERFORM 3240-VALIDATE-CNI
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "--- COORDONNEES ---"
           DISPLAY "Telephone          : " WITH NO ADVANCING
           ACCEPT IN-TELEPHONE

           DISPLAY "Email              : " WITH NO ADVANCING
           ACCEPT IN-EMAIL
           PERFORM 3250-VALIDATE-EMAIL
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "Rue/Adresse        : " WITH NO ADVANCING
           ACCEPT IN-RUE
           DISPLAY "Ville              : " WITH NO ADVANCING
           ACCEPT IN-VILLE
           DISPLAY "Code Postal        : " WITH NO ADVANCING
           ACCEPT IN-CODE-POST
           DISPLAY "Pays               : " WITH NO ADVANCING
           ACCEPT IN-PAYS

           DISPLAY "--- INFORMATIONS BANCAIRES ---"
           DISPLAY "Profil (STANDARD/PREMIUM/CORPORATE): "
                   WITH NO ADVANCING
           ACCEPT IN-PROFIL
           PERFORM 3260-VALIDATE-PROFIL
           IF RC-VALIDATION-ERROR GO TO 3200-EXIT END-IF

           DISPLAY "Solde initial      : " WITH NO ADVANCING
           ACCEPT IN-SOLDE

           MOVE "A"              TO IN-STATUT
           3200-EXIT.
           EXIT.

       3210-VALIDATE-NOM.
           IF IN-NOM = SPACES
               DISPLAY "ERREUR: Le nom ne peut pas etre vide."
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           .

       3220-VALIDATE-PRENOM.
           IF IN-PRENOM = SPACES
               DISPLAY "ERREUR: Le prenom ne peut pas etre vide."
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           .

       3230-VALIDATE-DATE.
           IF IN-DATE-NAIS = ZEROS
               DISPLAY "ERREUR: Date naissance invalide."
               MOVE 16 TO WS-RETURN-CODE
               GO TO 3230-EXIT
           END-IF
           IF IN-DATE-NAIS(5:2) < 01 OR IN-DATE-NAIS(5:2) > 12
               DISPLAY "ERREUR: Mois invalide (01-12)."
               MOVE 16 TO WS-RETURN-CODE
               GO TO 3230-EXIT
           END-IF
           IF IN-DATE-NAIS(7:2) < 01 OR IN-DATE-NAIS(7:2) > 31
               DISPLAY "ERREUR: Jour invalide (01-31)."
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           3230-EXIT.
           EXIT.

       3240-VALIDATE-CNI.
           IF IN-CNI = SPACES
               DISPLAY "ERREUR: CNI/Passport obligatoire."
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           .

       3250-VALIDATE-EMAIL.
           IF FUNCTION FIND(IN-EMAIL, "@") = 0
               DISPLAY "ERREUR: Email invalide (@ manquant)."
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           .

       3260-VALIDATE-PROFIL.
           IF IN-PROFIL NOT = "STANDARD" AND
              IN-PROFIL NOT = "PREMIUM"  AND
              IN-PROFIL NOT = "CORPORATE"
               DISPLAY "ERREUR: Profil invalide."
               DISPLAY "Valeurs acceptees: STANDARD / PREMIUM / CORPORATE"
               MOVE 16 TO WS-RETURN-CODE
           END-IF
           .

       3300-WRITE-CUSTOMER.
           INITIALIZE CUSTOMER-RECORD
           MOVE IN-ID           TO CUST-ID
           MOVE IN-NOM          TO CUST-NOM
           MOVE IN-PRENOM       TO CUST-PRENOM
           MOVE IN-DATE-NAIS    TO CUST-DATE-NAIS
           MOVE IN-CNI          TO CUST-CNI
           MOVE IN-TELEPHONE    TO CUST-TELEPHONE
           MOVE IN-EMAIL        TO CUST-EMAIL
           MOVE IN-RUE          TO CUST-RUE
           MOVE IN-VILLE        TO CUST-VILLE
           MOVE IN-CODE-POST    TO CUST-CODE-POST
           MOVE IN-PAYS         TO CUST-PAYS
           MOVE IN-PROFIL       TO CUST-PROFIL
           MOVE IN-SOLDE        TO CUST-SOLDE
           MOVE IN-STATUT       TO CUST-STATUT
           MOVE WS-DATE-NUMERIC TO CUST-DATE-OUVERTURE
           MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
           MOVE 1               TO CUST-NB-COMPTES

           WRITE CUSTOMER-RECORD
           EVALUATE WS-FILE-STATUS
               WHEN "00"
                   MOVE 0 TO WS-RETURN-CODE
               WHEN "22"
                   MOVE 8 TO WS-RETURN-CODE
                   MOVE "ID CLIENT DEJA EXISTANT" TO WS-ERROR-MSG
               WHEN OTHER
                   MOVE 12 TO WS-RETURN-CODE
                   STRING "ERREUR ECRITURE FICHIER: " WS-FILE-STATUS
                       DELIMITED SIZE INTO WS-ERROR-MSG
           END-EVALUATE
           .

      *================================================================*
       4000-UPDATE-CUSTOMER.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== MODIFICATION CLIENT =============================="
           DISPLAY "ID du client a modifier: " WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           PERFORM 4100-READ-FOR-UPDATE
           IF RECORD-NOT-FOUND
               DISPLAY "CLIENT INTROUVABLE - ID: " WS-SEARCH-ID
               GO TO 4000-EXIT
           END-IF
           PERFORM 4200-DISPLAY-CURRENT
           PERFORM 4300-UPDATE-MENU
           4000-EXIT.
           EXIT.

       4100-READ-FOR-UPDATE.
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           EVALUATE WS-FILE-STATUS
               WHEN "00"  MOVE "Y" TO WS-FOUND-FLAG
               WHEN "23"  MOVE "N" TO WS-FOUND-FLAG
               WHEN OTHER
                   MOVE "N" TO WS-FOUND-FLAG
                   DISPLAY "ERREUR LECTURE: " WS-FILE-STATUS
           END-EVALUATE
           .

       4200-DISPLAY-CURRENT.
           DISPLAY "--- DONNEES ACTUELLES ---"
           DISPLAY "ID            : " CUST-ID
           DISPLAY "Nom           : " CUST-NOM
           DISPLAY "Prenom        : " CUST-PRENOM
           DISPLAY "Date Nais.    : " CUST-DATE-NAIS
           DISPLAY "CNI           : " CUST-CNI
           DISPLAY "Telephone     : " CUST-TELEPHONE
           DISPLAY "Email         : " CUST-EMAIL
           DISPLAY "Rue           : " CUST-RUE
           DISPLAY "Ville         : " CUST-VILLE
           DISPLAY "Code Postal   : " CUST-CODE-POST
           DISPLAY "Pays          : " CUST-PAYS
           DISPLAY "Profil        : " CUST-PROFIL
           MOVE CUST-SOLDE TO WS-SOLDE-DISPLAY
           DISPLAY "Solde         : " WS-SOLDE-DISPLAY
           DISPLAY "Statut        : " CUST-STATUT
           DISPLAY "Date Ouvert.  : " CUST-DATE-OUVERTURE
           DISPLAY "Derniere MAJ  : " CUST-DATE-MAJ
           .

       4300-UPDATE-MENU.
           DISPLAY " "
           DISPLAY "=== CHAMP A MODIFIER ================================="
           DISPLAY "  1. Nom et Prenom"
           DISPLAY "  2. Coordonnees (tel/email)"
           DISPLAY "  3. Adresse"
           DISPLAY "  4. Profil"
           DISPLAY "  5. Statut"
           DISPLAY "  6. Solde"
           DISPLAY "  0. Annuler"
           DISPLAY "======================================================"
           DISPLAY "Choix: " WITH NO ADVANCING
           ACCEPT WS-SUBMENU-CHOICE

           EVALUATE WS-SUBMENU-CHOICE
               WHEN "1"  PERFORM 4310-UPDATE-NAMES
               WHEN "2"  PERFORM 4320-UPDATE-CONTACTS
               WHEN "3"  PERFORM 4330-UPDATE-ADDRESS
               WHEN "4"  PERFORM 4340-UPDATE-PROFILE
               WHEN "5"  PERFORM 4350-UPDATE-STATUS
               WHEN "6"  PERFORM 4360-UPDATE-SOLDE
               WHEN "0"  DISPLAY "MODIFICATION ANNULEE."
                         GO TO 4300-EXIT
               WHEN OTHER DISPLAY "CHOIX INVALIDE."
                          GO TO 4300-EXIT
           END-EVALUATE

           IF WS-SUBMENU-CHOICE NOT = "0"
               PERFORM 4400-REWRITE-CUSTOMER
           END-IF
           4300-EXIT.
           EXIT.

       4310-UPDATE-NAMES.
           DISPLAY "Nouveau nom    : " WITH NO ADVANCING
           ACCEPT CUST-NOM
           DISPLAY "Nouveau prenom : " WITH NO ADVANCING
           ACCEPT CUST-PRENOM
           .

       4320-UPDATE-CONTACTS.
           DISPLAY "Nouveau telephone : " WITH NO ADVANCING
           ACCEPT CUST-TELEPHONE
           DISPLAY "Nouveau email     : " WITH NO ADVANCING
           ACCEPT CUST-EMAIL
           .

       4330-UPDATE-ADDRESS.
           DISPLAY "Nouvelle rue        : " WITH NO ADVANCING
           ACCEPT CUST-RUE
           DISPLAY "Nouvelle ville      : " WITH NO ADVANCING
           ACCEPT CUST-VILLE
           DISPLAY "Nouveau code postal : " WITH NO ADVANCING
           ACCEPT CUST-CODE-POST
           DISPLAY "Nouveau pays        : " WITH NO ADVANCING
           ACCEPT CUST-PAYS
           .

       4340-UPDATE-PROFILE.
           DISPLAY "Nouveau profil (STANDARD/PREMIUM/CORPORATE): "
                   WITH NO ADVANCING
           ACCEPT CUST-PROFIL
           MOVE CUST-PROFIL TO IN-PROFIL
           PERFORM 3260-VALIDATE-PROFIL
           IF RC-VALIDATION-ERROR
               DISPLAY "PROFIL INVALIDE - MODIFICATION ANNULEE."
               MOVE "STANDARD" TO CUST-PROFIL
           END-IF
           .

       4350-UPDATE-STATUS.
           DISPLAY "Nouveau statut (A=Actif/I=Inactif/B=Bloque): "
                   WITH NO ADVANCING
           ACCEPT CUST-STATUT
           IF CUST-STATUT NOT = "A" AND
              CUST-STATUT NOT = "I" AND
              CUST-STATUT NOT = "B"
               DISPLAY "STATUT INVALIDE."
               MOVE "A" TO CUST-STATUT
           END-IF
           .

       4360-UPDATE-SOLDE.
           DISPLAY "Nouveau solde: " WITH NO ADVANCING
           ACCEPT CUST-SOLDE
           .

       4400-REWRITE-CUSTOMER.
           MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
           REWRITE CUSTOMER-RECORD
           EVALUATE WS-FILE-STATUS
               WHEN "00"
                   DISPLAY "CLIENT MIS A JOUR AVEC SUCCES."
                   MOVE 0 TO WS-RETURN-CODE
                   MOVE "UPDATE" TO AUD-OPERATION
                   MOVE WS-SEARCH-ID TO IN-ID
                   PERFORM 9100-WRITE-AUDIT THRU 9100-EXIT
               WHEN OTHER
                   DISPLAY "ERREUR MISE A JOUR: " WS-FILE-STATUS
                   MOVE 12 TO WS-RETURN-CODE
           END-EVALUATE
           .

      *================================================================*
       5000-DELETE-CUSTOMER.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== SUPPRESSION CLIENT ==============================="
           DISPLAY "ID du client a supprimer: " WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS = "23"
               DISPLAY "CLIENT INTROUVABLE - ID: " WS-SEARCH-ID
               GO TO 5000-EXIT
           END-IF
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERREUR LECTURE: " WS-FILE-STATUS
               GO TO 5000-EXIT
           END-IF
           DISPLAY "--- CLIENT A SUPPRIMER ---"
           DISPLAY "ID     : " CUST-ID
           DISPLAY "Nom    : " CUST-NOM
           DISPLAY "Prenom : " CUST-PRENOM
           DISPLAY "Profil : " CUST-PROFIL
           MOVE CUST-SOLDE TO WS-SOLDE-DISPLAY
           DISPLAY "Solde  : " WS-SOLDE-DISPLAY
           DISPLAY " "
           DISPLAY "CONFIRMER SUPPRESSION? (O/N): " WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM = "O" OR WS-CONFIRM = "o"
               DELETE CUSTOMER-FILE RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "CLIENT SUPPRIME AVEC SUCCES."
                   MOVE "DELETE" TO AUD-OPERATION
                   MOVE WS-SEARCH-ID TO IN-ID
                   PERFORM 9100-WRITE-AUDIT THRU 9100-EXIT
               ELSE
                   DISPLAY "ERREUR SUPPRESSION: " WS-FILE-STATUS
               END-IF
           ELSE
               DISPLAY "SUPPRESSION ANNULEE."
           END-IF
           5000-EXIT.
           EXIT.

      *================================================================*
       6000-SEARCH-CUSTOMER.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== RECHERCHE CLIENT ================================="
           DISPLAY "  1. Recherche par ID"
           DISPLAY "  2. Recherche par Nom"
           DISPLAY "  3. Recherche par Profil"
           DISPLAY "  4. Recherche par Statut"
           DISPLAY "======================================================"
           DISPLAY "Choix: " WITH NO ADVANCING
           ACCEPT WS-SUBMENU-CHOICE

           EVALUATE WS-SUBMENU-CHOICE
               WHEN "1"  PERFORM 6100-SEARCH-BY-ID
               WHEN "2"  PERFORM 6200-SEARCH-BY-NOM
               WHEN "3"  PERFORM 6300-SEARCH-BY-PROFILE
               WHEN "4"  PERFORM 6400-SEARCH-BY-STATUS
               WHEN OTHER DISPLAY "CHOIX INVALIDE."
           END-EVALUATE
           .

       6100-SEARCH-BY-ID.
           DISPLAY "ID Client: " WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS = "00"
               PERFORM 4200-DISPLAY-CURRENT
           ELSE
               DISPLAY "AUCUN CLIENT TROUVE AVEC ID: " WS-SEARCH-ID
           END-IF
           .

       6200-SEARCH-BY-NOM.
           DISPLAY "Nom (ou debut du nom): " WITH NO ADVANCING
           ACCEPT WS-SEARCH-NOM
           MOVE WS-SEARCH-NOM TO CUST-NOM
           MOVE ZEROS          TO WS-COUNTER

           START CUSTOMER-FILE KEY >= CUST-NOM
           IF WS-FILE-STATUS = "00" OR WS-FILE-STATUS = "02"
               PERFORM UNTIL WS-FILE-STATUS NOT = "00" AND
                             WS-FILE-STATUS NOT = "02"
                   READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
                   IF WS-FILE-STATUS = "00" OR
                      WS-FILE-STATUS = "02"
                       IF CUST-NOM(1:FUNCTION LENGTH(
                           FUNCTION TRIM(WS-SEARCH-NOM))) =
                          FUNCTION TRIM(WS-SEARCH-NOM)
                           ADD 1 TO WS-COUNTER
                           PERFORM 6500-DISPLAY-SUMMARY
                       ELSE
                           MOVE "99" TO WS-FILE-STATUS
                       END-IF
                   END-IF
               END-PERFORM
           END-IF

           IF WS-COUNTER = 0
               DISPLAY "AUCUN CLIENT TROUVE POUR: " WS-SEARCH-NOM
           ELSE
               DISPLAY WS-COUNTER " CLIENT(S) TROUVE(S)."
           END-IF
           MOVE "00" TO WS-FILE-STATUS
           .

       6300-SEARCH-BY-PROFILE.
           DISPLAY "Profil (STANDARD/PREMIUM/CORPORATE): "
                   WITH NO ADVANCING
           ACCEPT IN-PROFIL
           MOVE ZEROS TO WS-COUNTER
           MOVE LOW-VALUES TO CUST-ID

           START CUSTOMER-FILE KEY >= CUST-ID
           PERFORM UNTIL WS-FILE-STATUS = "10"
               READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   IF CUST-PROFIL = IN-PROFIL
                       ADD 1 TO WS-COUNTER
                       PERFORM 6500-DISPLAY-SUMMARY
                   END-IF
               END-IF
           END-PERFORM

           IF WS-COUNTER = 0
               DISPLAY "AUCUN CLIENT AVEC PROFIL: " IN-PROFIL
           ELSE
               DISPLAY WS-COUNTER " CLIENT(S) TROUVE(S)."
           END-IF
           MOVE "00" TO WS-FILE-STATUS
           .

       6400-SEARCH-BY-STATUS.
           DISPLAY "Statut (A=Actif/I=Inactif/B=Bloque): "
                   WITH NO ADVANCING
           ACCEPT IN-STATUT
           MOVE ZEROS TO WS-COUNTER
           MOVE LOW-VALUES TO CUST-ID

           START CUSTOMER-FILE KEY >= CUST-ID
           PERFORM UNTIL WS-FILE-STATUS = "10"
               READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   IF CUST-STATUT = IN-STATUT
                       ADD 1 TO WS-COUNTER
                       PERFORM 6500-DISPLAY-SUMMARY
                   END-IF
               END-IF
           END-PERFORM

           IF WS-COUNTER = 0
               DISPLAY "AUCUN CLIENT AVEC STATUT: " IN-STATUT
           ELSE
               DISPLAY WS-COUNTER " CLIENT(S) TROUVE(S)."
           END-IF
           MOVE "00" TO WS-FILE-STATUS
           .

       6500-DISPLAY-SUMMARY.
           MOVE CUST-SOLDE TO WS-SOLDE-DISPLAY
           DISPLAY "ID:" CUST-ID
               " | " CUST-NOM " " CUST-PRENOM
               " | " CUST-PROFIL
               " | " CUST-STATUT
               " | " WS-SOLDE-DISPLAY
           .

      *================================================================*
       7000-LIST-CUSTOMERS.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== LISTE TOUS LES CLIENTS ==========================="
           MOVE ZEROS TO WS-COUNTER
           MOVE ZEROS TO WS-TOTAL-SOLDE
           MOVE LOW-VALUES TO CUST-ID

           DISPLAY "ID       | NOM                   | PRENOM"
               "          | PROFIL    | S | SOLDE"
           DISPLAY "---------|----------------------"
               "-|------------|-----------|---|----------"

           START CUSTOMER-FILE KEY >= CUST-ID
           PERFORM UNTIL WS-FILE-STATUS = "10"
               READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   ADD 1 TO WS-COUNTER
                   ADD CUST-SOLDE TO WS-TOTAL-SOLDE
                   PERFORM 6500-DISPLAY-SUMMARY
               END-IF
           END-PERFORM

           MOVE WS-TOTAL-SOLDE TO WS-TOTAL-DISPLAY
           DISPLAY "------------------------------------------------------"
           DISPLAY "TOTAL: " WS-COUNTER " CLIENT(S) | SOLDE TOTAL: "
                   WS-TOTAL-DISPLAY
           MOVE "00" TO WS-FILE-STATUS
           .

      *================================================================*
       8000-MANAGE-PROFILE.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== GESTION DES PROFILS =============================="
           DISPLAY "  1. Promouvoir STANDARD -> PREMIUM"
           DISPLAY "  2. Promouvoir PREMIUM  -> CORPORATE"
           DISPLAY "  3. Retrograder CORPORATE -> PREMIUM"
           DISPLAY "  4. Retrograder PREMIUM  -> STANDARD"
           DISPLAY "  5. Voir criteres profils"
           DISPLAY "  0. Retour"
           DISPLAY "======================================================"
           DISPLAY "Choix: " WITH NO ADVANCING
           ACCEPT WS-SUBMENU-CHOICE

           EVALUATE WS-SUBMENU-CHOICE
               WHEN "1"  PERFORM 8100-PROMOTE-STD-PREM
               WHEN "2"  PERFORM 8200-PROMOTE-PREM-CORP
               WHEN "3"  PERFORM 8300-DEMOTE-CORP-PREM
               WHEN "4"  PERFORM 8400-DEMOTE-PREM-STD
               WHEN "5"  PERFORM 8450-SHOW-CRITERIA
               WHEN "0"  CONTINUE
               WHEN OTHER DISPLAY "CHOIX INVALIDE."
           END-EVALUATE
           .

       8100-PROMOTE-STD-PREM.
           DISPLAY "ID client STANDARD a promouvoir: " WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "CLIENT INTROUVABLE."
               GO TO 8100-EXIT
           END-IF
           IF NOT PROFIL-STANDARD
               DISPLAY "CE CLIENT N'EST PAS STANDARD (profil: "
                        CUST-PROFIL ")."
               GO TO 8100-EXIT
           END-IF
           IF CUST-SOLDE < 1000000
               DISPLAY "SOLDE INSUFFISANT (min 10,000.00 requis)."
               GO TO 8100-EXIT
           END-IF
           MOVE "PREMIUM" TO CUST-PROFIL
           MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
           REWRITE CUSTOMER-RECORD
           IF WS-FILE-STATUS = "00"
               DISPLAY "PROFIL CHANGE: STANDARD -> PREMIUM pour "
                       CUST-NOM " " CUST-PRENOM
           END-IF
           8100-EXIT.
           EXIT.

       8200-PROMOTE-PREM-CORP.
           DISPLAY "ID client PREMIUM a promouvoir: " WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "CLIENT INTROUVABLE."
               GO TO 8200-EXIT
           END-IF
           IF NOT PROFIL-PREMIUM
               DISPLAY "CE CLIENT N'EST PAS PREMIUM (profil: "
                        CUST-PROFIL ")."
               GO TO 8200-EXIT
           END-IF
           IF CUST-SOLDE < 10000000
               DISPLAY "SOLDE INSUFFISANT (min 100,000.00 requis)."
               GO TO 8200-EXIT
           END-IF
           MOVE "CORPORATE" TO CUST-PROFIL
           MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
           REWRITE CUSTOMER-RECORD
           IF WS-FILE-STATUS = "00"
               DISPLAY "PROFIL CHANGE: PREMIUM -> CORPORATE pour "
                       CUST-NOM " " CUST-PRENOM
           END-IF
           8200-EXIT.
           EXIT.

       8300-DEMOTE-CORP-PREM.
           DISPLAY "ID client CORPORATE a retrograder: "
                   WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "CLIENT INTROUVABLE."
               GO TO 8300-EXIT
           END-IF
           IF NOT PROFIL-CORPORATE
               DISPLAY "CE CLIENT N'EST PAS CORPORATE."
               GO TO 8300-EXIT
           END-IF
           DISPLAY "CONFIRMER RETROGRADATION? (O/N): "
                   WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM = "O" OR WS-CONFIRM = "o"
               MOVE "PREMIUM" TO CUST-PROFIL
               MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
               REWRITE CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "PROFIL CHANGE: CORPORATE -> PREMIUM"
               END-IF
           END-IF
           8300-EXIT.
           EXIT.

       8400-DEMOTE-PREM-STD.
           DISPLAY "ID client PREMIUM a retrograder: "
                   WITH NO ADVANCING
           ACCEPT WS-SEARCH-ID
           MOVE WS-SEARCH-ID TO CUST-ID
           READ CUSTOMER-FILE INTO CUSTOMER-RECORD
               KEY IS CUST-ID
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "CLIENT INTROUVABLE."
               GO TO 8400-EXIT
           END-IF
           IF NOT PROFIL-PREMIUM
               DISPLAY "CE CLIENT N'EST PAS PREMIUM."
               GO TO 8400-EXIT
           END-IF
           DISPLAY "CONFIRMER RETROGRADATION? (O/N): "
                   WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM = "O" OR WS-CONFIRM = "o"
               MOVE "STANDARD" TO CUST-PROFIL
               MOVE WS-DATE-NUMERIC TO CUST-DATE-MAJ
               REWRITE CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   DISPLAY "PROFIL CHANGE: PREMIUM -> STANDARD"
               END-IF
           END-IF
           8400-EXIT.
           EXIT.

       8450-SHOW-CRITERIA.
           DISPLAY " "
           DISPLAY "=== CRITERES D'ELIGIBILITE PROFILS ==================="
           DISPLAY " "
           DISPLAY "STANDARD  : Compte de base, solde minimum requis."
           DISPLAY "            - Acces aux services bancaires standard"
           DISPLAY "            - Taux standard sur credits"
           DISPLAY " "
           DISPLAY "PREMIUM   : Solde >= 10,000.00"
           DISPLAY "            - Conseiller dedie"
           DISPLAY "            - Taux preferentiels"
           DISPLAY "            - Carte Gold"
           DISPLAY " "
           DISPLAY "CORPORATE : Solde >= 100,000.00"
           DISPLAY "            - Gestionnaire de fortune prive"
           DISPLAY "            - Produits d'investissement exclusifs"
           DISPLAY "            - Services internationaux"
           DISPLAY "======================================================"
           .

      *================================================================*
       8500-REPORTS-STATS.
      *================================================================*
           DISPLAY " "
           DISPLAY "=== RAPPORTS ET STATISTIQUES ========================="
           DISPLAY "  1. Statistiques generales"
           DISPLAY "  2. Generer rapport complet (fichier)"
           DISPLAY "  0. Retour"
           DISPLAY "======================================================"
           DISPLAY "Choix: " WITH NO ADVANCING
           ACCEPT WS-SUBMENU-CHOICE

           EVALUATE WS-SUBMENU-CHOICE
               WHEN "1"  PERFORM 8510-DISPLAY-STATS
               WHEN "2"  PERFORM 8600-GENERATE-REPORT
               WHEN "0"  CONTINUE
               WHEN OTHER DISPLAY "CHOIX INVALIDE."
           END-EVALUATE
           .

       8510-DISPLAY-STATS.
           INITIALIZE WS-STATS
           MOVE ZEROS TO WS-TOTAL-SOLDE
           MOVE LOW-VALUES TO CUST-ID
           START CUSTOMER-FILE KEY >= CUST-ID
           PERFORM UNTIL WS-FILE-STATUS = "10"
               READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   ADD 1 TO STAT-TOTAL-CLIENTS
                   ADD CUST-SOLDE TO WS-TOTAL-SOLDE
                   IF STATUT-ACTIF    ADD 1 TO STAT-ACTIFS    END-IF
                   IF STATUT-INACTIF  ADD 1 TO STAT-INACTIFS  END-IF
                   IF STATUT-BLOQUE   ADD 1 TO STAT-BLOQUES   END-IF
                   IF PROFIL-STANDARD  ADD 1 TO STAT-STANDARD  END-IF
                   IF PROFIL-PREMIUM   ADD 1 TO STAT-PREMIUM   END-IF
                   IF PROFIL-CORPORATE ADD 1 TO STAT-CORPORATE END-IF
               END-IF
           END-PERFORM
           MOVE WS-TOTAL-SOLDE TO WS-TOTAL-DISPLAY
           DISPLAY " "
           DISPLAY "====== STATISTIQUES GENERALES ========================"
           DISPLAY "  Total clients  : " STAT-TOTAL-CLIENTS
           DISPLAY "  -- Par statut --"
           DISPLAY "  Actifs          : " STAT-ACTIFS
           DISPLAY "  Inactifs        : " STAT-INACTIFS
           DISPLAY "  Bloques         : " STAT-BLOQUES
           DISPLAY "  -- Par profil --"
           DISPLAY "  Standard        : " STAT-STANDARD
           DISPLAY "  Premium         : " STAT-PREMIUM
           DISPLAY "  Corporate       : " STAT-CORPORATE
           DISPLAY "  -- Financier --"
           DISPLAY "  Solde total     : " WS-TOTAL-DISPLAY
           DISPLAY "======================================================"
           MOVE "00" TO WS-FILE-STATUS
           .

       8600-GENERATE-REPORT.
           OPEN OUTPUT REPORT-FILE
           IF WS-REPORT-STATUS NOT = "00"
               DISPLAY "ERREUR OUVERTURE RAPPORT: " WS-REPORT-STATUS
               GO TO 8600-EXIT
           END-IF

           MOVE WS-RPT-HEADER1 TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-RPT-HEADER2 TO REPORT-LINE
           WRITE REPORT-LINE
           STRING "DATE: " WS-CURR-DAY "/" WS-CURR-MONTH
                  "/" WS-CURR-YEAR "   HEURE: "
                  WS-CURR-HOUR ":" WS-CURR-MIN
                  DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-RPT-HEADER1 TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-RPT-COL-HDR TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE WS-RPT-HEADER1 TO REPORT-LINE
           WRITE REPORT-LINE

           MOVE ZEROS TO WS-COUNTER
           MOVE ZEROS TO WS-TOTAL-SOLDE
           MOVE LOW-VALUES TO CUST-ID
           START CUSTOMER-FILE KEY >= CUST-ID
           PERFORM UNTIL WS-FILE-STATUS = "10"
               READ CUSTOMER-FILE NEXT INTO CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   ADD 1 TO WS-COUNTER
                   ADD CUST-SOLDE TO WS-TOTAL-SOLDE
                   INITIALIZE WS-RPT-DETAIL
                   MOVE CUST-ID     TO RPT-ID
                   MOVE CUST-NOM(1:20) TO RPT-NOM
                   MOVE CUST-PRENOM(1:15) TO RPT-PRENOM
                   MOVE CUST-PROFIL TO RPT-PROFIL
                   MOVE CUST-STATUT TO RPT-STATUT
                   MOVE CUST-SOLDE  TO RPT-SOLDE
                   MOVE WS-RPT-DETAIL TO REPORT-LINE
                   WRITE REPORT-LINE
               END-IF
           END-PERFORM

           MOVE WS-RPT-HEADER1 TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE SPACES TO REPORT-LINE
           STRING "TOTAL: " WS-COUNTER " CLIENT(S)"
               DELIMITED SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           CLOSE REPORT-FILE
           DISPLAY "RAPPORT GENERE: data/CUSTRPT.txt ("
                   WS-COUNTER " clients)"
           MOVE "00" TO WS-FILE-STATUS
           8600-EXIT.
           EXIT.

      *================================================================*
       8700-SET-OPERATOR.
      *================================================================*
           DISPLAY "Nom operateur courant: " WS-OPERATEUR
           DISPLAY "Nouveau nom operateur: " WITH NO ADVANCING
           ACCEPT WS-OPERATEUR
           DISPLAY "OPERATEUR DEFINI: " WS-OPERATEUR
           .

      *================================================================*
       9000-FINALIZE.
      *================================================================*
           CLOSE CUSTOMER-FILE
           CLOSE AUDIT-FILE
           DISPLAY " "
           DISPLAY "Au revoir. Fichiers fermes proprement."
           DISPLAY "======================================================="
           .

      *================================================================*
       9100-WRITE-AUDIT.
      *================================================================*
           MOVE WS-DATETIME-STR  TO AUD-DATE-HEURE
           IF AUD-OPERATION = SPACES
               MOVE "CREATE" TO AUD-OPERATION
           END-IF
           MOVE IN-ID            TO AUD-CUST-ID
           STRING "CLIENT ID:" IN-ID " OP:" AUD-OPERATION
               " PAR:" WS-OPERATEUR
               DELIMITED SIZE INTO AUD-DESCRIPTION
           MOVE WS-OPERATEUR     TO AUD-OPERATEUR
           WRITE AUDIT-RECORD
           MOVE SPACES TO AUD-OPERATION
           9100-EXIT.
           EXIT.

      *--- FIN PROGRAMME ---*
