      *================================================================
      * LOAN-MAIN.CBL - Loan Management System
      * Systeme de Gestion des Prets Bancaires
      * Projet #9 - GnuCOBOL
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOAN-MAIN.
       AUTHOR. GnuCOBOL-Banking-System.
       DATE-WRITTEN. 2026-06-09.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LOAN-FILE
               ASSIGN TO "data/LOANS.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS LN-ID
               ALTERNATE RECORD KEY IS LN-CLIENT-ID
                   WITH DUPLICATES
               FILE STATUS IS WS-FILE-STATUS.

           SELECT AMORT-FILE
               ASSIGN TO "data/AMORT.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AM-KEY
               FILE STATUS IS WS-AMORT-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO "data/REPORT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  LOAN-FILE.
       01  LOAN-RECORD.
           05  LN-ID               PIC X(10).
           05  LN-CLIENT-ID        PIC X(10).
           05  LN-CLIENT-NAME      PIC X(40).
           05  LN-AMOUNT           PIC 9(10)V99.
           05  LN-RATE-ANNUAL      PIC 9(3)V9(4).
           05  LN-DURATION-MONTHS  PIC 9(3).
           05  LN-START-DATE       PIC X(10).
           05  LN-STATUS           PIC X(01).
               88 LN-PENDING       VALUE 'D'.
               88 LN-APPROVED      VALUE 'A'.
               88 LN-REJECTED      VALUE 'R'.
               88 LN-ACTIVE        VALUE 'E'.
               88 LN-CLOSED        VALUE 'C'.
           05  LN-MONTHLY-PAYMENT  PIC 9(10)V99.
           05  LN-TOTAL-PAYMENT    PIC 9(12)V99.
           05  LN-TOTAL-INTEREST   PIC 9(12)V99.
           05  LN-PURPOSE          PIC X(30).
           05  LN-VALIDATED-BY     PIC X(20).
           05  LN-FILLER           PIC X(10).

       FD  AMORT-FILE.
       01  AMORT-RECORD.
           05  AM-KEY.
               10  AM-LOAN-ID      PIC X(10).
               10  AM-MONTH-NUM    PIC 9(3).
           05  AM-PAYMENT-DATE     PIC X(10).
           05  AM-MONTHLY-PAYMENT  PIC 9(10)V99.
           05  AM-PRINCIPAL-PART   PIC 9(10)V99.
           05  AM-INTEREST-PART    PIC 9(10)V99.
           05  AM-REMAINING-BALANCE PIC 9(12)V99.
           05  AM-STATUS           PIC X(01).
           05  AM-FILLER           PIC X(10).

       FD  REPORT-FILE.
       01  REPORT-LINE             PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX VALUE SPACES.
       01  WS-AMORT-STATUS         PIC XX VALUE SPACES.
       01  WS-REPORT-STATUS        PIC XX VALUE SPACES.

       01  WS-MENU-CHOICE          PIC 9 VALUE 0.
       01  WS-SUB-CHOICE           PIC 9 VALUE 0.
       01  WS-CONTINUE             PIC X VALUE 'Y'.
       01  WS-CONFIRM              PIC X VALUE 'N'.
       01  WS-EOF                  PIC X VALUE 'N'.

       01  WS-LOAN-ID-CTR          PIC 9(6) VALUE 100000.
       01  WS-NEW-LOAN-ID          PIC X(10).

      *--- Calcul mensualite ---
       01  WS-CAPITAL              PIC 9(10)V99.
       01  WS-RATE-MONTHLY         PIC 9(1)V9(8).
       01  WS-RATE-ANNUAL          PIC 9(3)V9(4).
       01  WS-DURATION             PIC 9(3).
       01  WS-MONTHLY-PMT          PIC 9(10)V99.
       01  WS-TOTAL-PMT            PIC 9(12)V99.
       01  WS-TOTAL-INT            PIC 9(12)V99.

      *--- Calcul intermediaire ---
       01  WS-CALC-1               PIC S9(10)V9(6) COMP.
       01  WS-CALC-2               PIC S9(10)V9(6) COMP.
       01  WS-CALC-3               PIC S9(10)V9(6) COMP.
       01  WS-POWER-RESULT         PIC S9(10)V9(6) COMP.
       01  WS-COUNTER              PIC 9(4) COMP.

      *--- Saisie ---
       01  WS-INPUT-ID             PIC X(10).
       01  WS-INPUT-NAME           PIC X(40).
       01  WS-INPUT-AMOUNT         PIC 9(10)V99.
       01  WS-INPUT-RATE           PIC 9(3)V9(2).
       01  WS-INPUT-DURATION       PIC 9(3).
       01  WS-INPUT-PURPOSE        PIC X(30).
       01  WS-INPUT-VALIDATOR      PIC X(20).
       01  WS-INPUT-DECISION       PIC X.

      *--- Affichage ---
       01  WS-DISP-AMOUNT          PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-RATE            PIC ZZ9.99.
       01  WS-DISP-PAYMENT         PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-TOTAL           PIC Z,ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-INT             PIC Z,ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-BALANCE         PIC Z,ZZZ,ZZZ,ZZ9.99.
       01  WS-LINE                 PIC X(70).

      *--- Amortissement ---
       01  WS-REMAINING            PIC S9(12)V99 COMP.
       01  WS-INT-PART             PIC S9(10)V99 COMP.
       01  WS-PRINC-PART           PIC S9(10)V99 COMP.
       01  WS-MONTH-IDX            PIC 9(3).
       01  WS-MONTH-DATE           PIC X(10).
       01  WS-START-YEAR           PIC 9(4).
       01  WS-START-MONTH          PIC 9(2).
       01  WS-CURR-YEAR            PIC 9(4).
       01  WS-CURR-MONTH           PIC 9(2).
       01  WS-CURR-DAY             PIC 9(2).

      *--- Statistiques ---
       01  WS-STAT-COUNT           PIC 9(5) VALUE 0.
       01  WS-STAT-PENDING         PIC 9(5) VALUE 0.
       01  WS-STAT-APPROVED        PIC 9(5) VALUE 0.
       01  WS-STAT-ACTIVE          PIC 9(5) VALUE 0.
       01  WS-STAT-TOTAL-AMT       PIC 9(14)V99 VALUE 0.

       01  WS-SEPARATOR-LINE.
           05  FILLER              PIC X(70) VALUE ALL '='.
       01  WS-DASH-LINE.
           05  FILLER              PIC X(70) VALUE ALL '-'.

       PROCEDURE DIVISION.

       000-MAIN.
           PERFORM 100-OPEN-FILES
           PERFORM 200-MAIN-MENU
               UNTIL WS-CONTINUE = 'N'
           PERFORM 900-CLOSE-FILES
           STOP RUN.

      *================================================================
       100-OPEN-FILES.
           OPEN I-O LOAN-FILE
           IF WS-FILE-STATUS = '35'
               OPEN OUTPUT LOAN-FILE
               CLOSE LOAN-FILE
               OPEN I-O LOAN-FILE
           END-IF
           OPEN I-O AMORT-FILE
           IF WS-AMORT-STATUS = '35'
               OPEN OUTPUT AMORT-FILE
               CLOSE AMORT-FILE
               OPEN I-O AMORT-FILE
           END-IF.

      *================================================================
       200-MAIN-MENU.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  LOAN MANAGEMENT SYSTEM - Gestion Prets Bancaires"
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  1. Nouvelle demande de pret"
           DISPLAY "  2. Valider / Rejeter une demande"
           DISPLAY "  3. Consulter un pret"
           DISPLAY "  4. Tableau d'amortissement"
           DISPLAY "  5. Liste des prets"
           DISPLAY "  6. Rapport et statistiques"
           DISPLAY "  7. Simulateur de mensualite"
           DISPLAY "  0. Quitter"
           DISPLAY WS-DASH-LINE
           DISPLAY "  Votre choix : " WITH NO ADVANCING
           ACCEPT WS-MENU-CHOICE
           EVALUATE WS-MENU-CHOICE
               WHEN 1  PERFORM 300-NEW-LOAN-REQUEST
               WHEN 2  PERFORM 400-VALIDATE-LOAN
               WHEN 3  PERFORM 500-CONSULT-LOAN
               WHEN 4  PERFORM 600-AMORTIZATION-TABLE
               WHEN 5  PERFORM 700-LIST-LOANS
               WHEN 6  PERFORM 800-STATISTICS-REPORT
               WHEN 7  PERFORM 750-SIMULATOR
               WHEN 0  MOVE 'N' TO WS-CONTINUE
               WHEN OTHER
                   DISPLAY "  Choix invalide!"
           END-EVALUATE.

      *================================================================
       300-NEW-LOAN-REQUEST.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  NOUVELLE DEMANDE DE PRET"
           DISPLAY WS-SEPARATOR-LINE

           DISPLAY "  ID Client (10 car.) : " WITH NO ADVANCING
           ACCEPT WS-INPUT-ID
           DISPLAY "  Nom complet client  : " WITH NO ADVANCING
           ACCEPT WS-INPUT-NAME
           DISPLAY "  Montant demande (MGA): " WITH NO ADVANCING
           ACCEPT WS-INPUT-AMOUNT
           DISPLAY "  Taux annuel (ex:12.50): " WITH NO ADVANCING
           ACCEPT WS-INPUT-RATE
           DISPLAY "  Duree en mois (1-360): " WITH NO ADVANCING
           ACCEPT WS-INPUT-DURATION
           DISPLAY "  Objet du pret        : " WITH NO ADVANCING
           ACCEPT WS-INPUT-PURPOSE

           PERFORM 310-COMPUTE-MONTHLY-PAYMENT

           MOVE WS-INPUT-AMOUNT  TO WS-DISP-AMOUNT
           MOVE WS-INPUT-RATE    TO WS-DISP-RATE
           MOVE WS-MONTHLY-PMT   TO WS-DISP-PAYMENT
           MOVE WS-TOTAL-PMT     TO WS-DISP-TOTAL
           MOVE WS-TOTAL-INT     TO WS-DISP-INT

           DISPLAY SPACES
           DISPLAY WS-DASH-LINE
           DISPLAY "  RECAPITULATIF DE LA DEMANDE"
           DISPLAY WS-DASH-LINE
           DISPLAY "  Capital emprunte  : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Taux annuel       : " WS-DISP-RATE " %"
           DISPLAY "  Duree             : " WS-INPUT-DURATION " mois"
           DISPLAY "  Mensualite        : " WS-DISP-PAYMENT " MGA"
           DISPLAY "  Total rembourse   : " WS-DISP-TOTAL " MGA"
           DISPLAY "  Total interets    : " WS-DISP-INT " MGA"
           DISPLAY WS-DASH-LINE
           DISPLAY "  Confirmer la demande? (O/N) : "
               WITH NO ADVANCING
           ACCEPT WS-CONFIRM

           IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
               PERFORM 320-SAVE-LOAN-REQUEST
               DISPLAY "  Demande enregistree avec ID: " WS-NEW-LOAN-ID
           ELSE
               DISPLAY "  Demande annulee."
           END-IF.

       310-COMPUTE-MONTHLY-PAYMENT.
           MOVE WS-INPUT-AMOUNT   TO WS-CAPITAL
           MOVE WS-INPUT-RATE     TO WS-RATE-ANNUAL
           MOVE WS-INPUT-DURATION TO WS-DURATION

           COMPUTE WS-RATE-MONTHLY = WS-RATE-ANNUAL / 100 / 12

           IF WS-RATE-MONTHLY = 0
               COMPUTE WS-MONTHLY-PMT =
                   WS-CAPITAL / WS-DURATION
           ELSE
               MOVE 1.0 TO WS-POWER-RESULT
               MOVE 0 TO WS-COUNTER
               PERFORM UNTIL WS-COUNTER >= WS-DURATION
                   COMPUTE WS-POWER-RESULT =
                       WS-POWER-RESULT * (1 + WS-RATE-MONTHLY)
                   ADD 1 TO WS-COUNTER
               END-PERFORM

               COMPUTE WS-CALC-1 =
                   WS-CAPITAL * WS-RATE-MONTHLY

               COMPUTE WS-CALC-2 =
                   1 - (1 / WS-POWER-RESULT)

               IF WS-CALC-2 > 0
                   COMPUTE WS-MONTHLY-PMT =
                       WS-CALC-1 / WS-CALC-2
               ELSE
                   COMPUTE WS-MONTHLY-PMT =
                       WS-CAPITAL / WS-DURATION
               END-IF
           END-IF

           COMPUTE WS-TOTAL-PMT =
               WS-MONTHLY-PMT * WS-DURATION
           COMPUTE WS-TOTAL-INT =
               WS-TOTAL-PMT - WS-CAPITAL.

       320-SAVE-LOAN-REQUEST.
           ADD 1 TO WS-LOAN-ID-CTR
           MOVE FUNCTION CURRENT-DATE TO WS-MONTH-DATE
           STRING "LN" DELIMITED SIZE
               WS-LOAN-ID-CTR DELIMITED SIZE
               INTO WS-NEW-LOAN-ID
           MOVE WS-NEW-LOAN-ID     TO LN-ID
           MOVE WS-INPUT-ID        TO LN-CLIENT-ID
           MOVE WS-INPUT-NAME      TO LN-CLIENT-NAME
           MOVE WS-INPUT-AMOUNT    TO LN-AMOUNT
           MOVE WS-INPUT-RATE      TO LN-RATE-ANNUAL
           MOVE WS-INPUT-DURATION  TO LN-DURATION-MONTHS
           MOVE WS-INPUT-PURPOSE   TO LN-PURPOSE
           MOVE 'D'                TO LN-STATUS
           MOVE WS-MONTHLY-PMT     TO LN-MONTHLY-PAYMENT
           MOVE WS-TOTAL-PMT       TO LN-TOTAL-PAYMENT
           MOVE WS-TOTAL-INT       TO LN-TOTAL-INTEREST
           MOVE WS-MONTH-DATE(1:10) TO LN-START-DATE
           MOVE SPACES             TO LN-VALIDATED-BY
           WRITE LOAN-RECORD
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY "  ERREUR ecriture: " WS-FILE-STATUS
           END-IF.

      *================================================================
       400-VALIDATE-LOAN.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  VALIDATION / REJET D'UNE DEMANDE"
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  ID du pret a traiter : " WITH NO ADVANCING
           ACCEPT WS-INPUT-ID

           MOVE WS-INPUT-ID TO LN-ID
           READ LOAN-FILE
               INVALID KEY
                   DISPLAY "  Pret non trouve: " WS-INPUT-ID
                   GO TO 400-EXIT
           END-READ

           IF NOT LN-PENDING
               DISPLAY "  Ce pret n'est pas en attente (statut: "
                   LN-STATUS ")"
               GO TO 400-EXIT
           END-IF

           MOVE LN-AMOUNT         TO WS-DISP-AMOUNT
           MOVE LN-RATE-ANNUAL    TO WS-DISP-RATE
           MOVE LN-MONTHLY-PAYMENT TO WS-DISP-PAYMENT
           MOVE LN-TOTAL-PAYMENT  TO WS-DISP-TOTAL
           MOVE LN-TOTAL-INTEREST TO WS-DISP-INT

           DISPLAY WS-DASH-LINE
           DISPLAY "  ID Pret    : " LN-ID
           DISPLAY "  Client     : " LN-CLIENT-NAME
           DISPLAY "  Montant    : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Taux       : " WS-DISP-RATE " %"
           DISPLAY "  Duree      : " LN-DURATION-MONTHS " mois"
           DISPLAY "  Mensualite : " WS-DISP-PAYMENT " MGA"
           DISPLAY "  Total      : " WS-DISP-TOTAL " MGA"
           DISPLAY "  Interet    : " WS-DISP-INT " MGA"
           DISPLAY "  Objet      : " LN-PURPOSE
           DISPLAY WS-DASH-LINE
           DISPLAY "  Validateur : " WITH NO ADVANCING
           ACCEPT WS-INPUT-VALIDATOR
           DISPLAY "  Decision (A=Approuve/R=Rejete) : "
               WITH NO ADVANCING
           ACCEPT WS-INPUT-DECISION

           EVALUATE WS-INPUT-DECISION
               WHEN 'A' WHEN 'a'
                   MOVE 'A' TO LN-STATUS
                   MOVE WS-INPUT-VALIDATOR TO LN-VALIDATED-BY
                   REWRITE LOAN-RECORD
                   DISPLAY "  Pret APPROUVE avec succes."
                   DISPLAY "  Generez tableau amortissement (option 4)"
               WHEN 'R' WHEN 'r'
                   MOVE 'R' TO LN-STATUS
                   MOVE WS-INPUT-VALIDATOR TO LN-VALIDATED-BY
                   REWRITE LOAN-RECORD
                   DISPLAY "  Pret REJETE."
               WHEN OTHER
                   DISPLAY "  Decision invalide - aucune modification."
           END-EVALUATE.
       400-EXIT. CONTINUE.

      *================================================================
       500-CONSULT-LOAN.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  CONSULTATION D'UN PRET"
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  ID du pret : " WITH NO ADVANCING
           ACCEPT WS-INPUT-ID

           MOVE WS-INPUT-ID TO LN-ID
           READ LOAN-FILE
               INVALID KEY
                   DISPLAY "  Pret non trouve: " WS-INPUT-ID
                   GO TO 500-EXIT
           END-READ

           MOVE LN-AMOUNT          TO WS-DISP-AMOUNT
           MOVE LN-RATE-ANNUAL     TO WS-DISP-RATE
           MOVE LN-MONTHLY-PAYMENT TO WS-DISP-PAYMENT
           MOVE LN-TOTAL-PAYMENT   TO WS-DISP-TOTAL
           MOVE LN-TOTAL-INTEREST  TO WS-DISP-INT

           DISPLAY WS-DASH-LINE
           DISPLAY "  ID Pret       : " LN-ID
           DISPLAY "  ID Client     : " LN-CLIENT-ID
           DISPLAY "  Nom Client    : " LN-CLIENT-NAME
           DISPLAY "  Montant       : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Taux annuel   : " WS-DISP-RATE " %"
           DISPLAY "  Duree         : " LN-DURATION-MONTHS " mois"
           DISPLAY "  Date debut    : " LN-START-DATE
           DISPLAY "  Mensualite    : " WS-DISP-PAYMENT " MGA"
           DISPLAY "  Total         : " WS-DISP-TOTAL " MGA"
           DISPLAY "  Total interet : " WS-DISP-INT " MGA"
           DISPLAY "  Objet         : " LN-PURPOSE
           DISPLAY "  Validateur    : " LN-VALIDATED-BY
           DISPLAY "  Statut        : "
           EVALUATE LN-STATUS
               WHEN 'D' DISPLAY "  En attente de validation"
               WHEN 'A' DISPLAY "  Approuve"
               WHEN 'R' DISPLAY "  Rejete"
               WHEN 'E' DISPLAY "  En cours (actif)"
               WHEN 'C' DISPLAY "  Cloture"
               WHEN OTHER DISPLAY "  Statut inconnu"
           END-EVALUATE
           DISPLAY WS-DASH-LINE.
       500-EXIT. CONTINUE.

      *================================================================
       600-AMORTIZATION-TABLE.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  TABLEAU D'AMORTISSEMENT"
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  ID du pret : " WITH NO ADVANCING
           ACCEPT WS-INPUT-ID

           MOVE WS-INPUT-ID TO LN-ID
           READ LOAN-FILE
               INVALID KEY
                   DISPLAY "  Pret non trouve: " WS-INPUT-ID
                   GO TO 600-EXIT
           END-READ

           IF LN-PENDING OR LN-REJECTED
               DISPLAY "  Pret non approuve - tableau impossible."
               GO TO 600-EXIT
           END-IF

           PERFORM 310-COMPUTE-MONTHLY-PAYMENT

           MOVE LN-AMOUNT          TO WS-CAPITAL
           MOVE LN-RATE-ANNUAL     TO WS-RATE-ANNUAL
           MOVE LN-DURATION-MONTHS TO WS-DURATION
           MOVE LN-AMOUNT          TO WS-REMAINING

           COMPUTE WS-RATE-MONTHLY = WS-RATE-ANNUAL / 100 / 12

           PERFORM 310-COMPUTE-MONTHLY-PAYMENT

           MOVE LN-MONTHLY-PAYMENT TO WS-MONTHLY-PMT
           MOVE LN-AMOUNT          TO WS-REMAINING

           DISPLAY WS-DASH-LINE
           DISPLAY "  Pret: " LN-ID "  Client: " LN-CLIENT-NAME
           MOVE LN-AMOUNT          TO WS-DISP-AMOUNT
           MOVE LN-RATE-ANNUAL     TO WS-DISP-RATE
           MOVE LN-MONTHLY-PAYMENT TO WS-DISP-PAYMENT
           DISPLAY "  Capital: " WS-DISP-AMOUNT
               "  Taux: " WS-DISP-RATE "%"
               "  Mensualite: " WS-DISP-PAYMENT
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  Mois  | Mensualite  | Capital    |"
               " Interets   | Solde"
           DISPLAY WS-SEPARATOR-LINE

           OPEN OUTPUT REPORT-FILE

           MOVE FUNCTION CURRENT-DATE TO WS-MONTH-DATE
           MOVE WS-MONTH-DATE(1:4)  TO WS-START-YEAR
           MOVE WS-MONTH-DATE(5:2)  TO WS-START-MONTH

           PERFORM VARYING WS-MONTH-IDX FROM 1 BY 1
               UNTIL WS-MONTH-IDX > WS-DURATION

               COMPUTE WS-INT-PART =
                   WS-REMAINING * WS-RATE-MONTHLY

               COMPUTE WS-PRINC-PART =
                   WS-MONTHLY-PMT - WS-INT-PART

               IF WS-MONTH-IDX = WS-DURATION
                   MOVE WS-REMAINING TO WS-PRINC-PART
                   COMPUTE WS-MONTHLY-PMT =
                       WS-PRINC-PART + WS-INT-PART
               END-IF

               COMPUTE WS-REMAINING =
                   WS-REMAINING - WS-PRINC-PART

               IF WS-REMAINING < 0
                   MOVE 0 TO WS-REMAINING
               END-IF

               MOVE WS-MONTHLY-PMT TO WS-DISP-PAYMENT
               MOVE WS-PRINC-PART  TO WS-DISP-AMOUNT
               MOVE WS-INT-PART    TO WS-DISP-RATE

               MOVE WS-INT-PART    TO AM-INTEREST-PART
               MOVE WS-PRINC-PART  TO AM-PRINCIPAL-PART
               MOVE WS-MONTHLY-PMT TO AM-MONTHLY-PAYMENT
               MOVE WS-REMAINING   TO AM-REMAINING-BALANCE
               MOVE LN-ID          TO AM-LOAN-ID
               MOVE WS-MONTH-IDX   TO AM-MONTH-NUM
               MOVE 'P'            TO AM-STATUS

               WRITE AMORT-RECORD
                   INVALID KEY
                       REWRITE AMORT-RECORD

               MOVE WS-REMAINING   TO WS-DISP-BALANCE

               DISPLAY "  " WS-MONTH-IDX
                   " | " WS-DISP-PAYMENT
                   " | " WS-DISP-AMOUNT
                   " | " WS-DISP-RATE
                   " | " WS-DISP-BALANCE

               MOVE "  " TO REPORT-LINE
               STRING
                   "  Mois " WS-MONTH-IDX
                   " Mensualite:" WS-DISP-PAYMENT
                   " Cap:" WS-DISP-AMOUNT
                   " Int:" WS-DISP-RATE
                   " Solde:" WS-DISP-BALANCE
                   DELIMITED SIZE
                   INTO REPORT-LINE
               WRITE REPORT-LINE

           END-PERFORM

           MOVE LN-TOTAL-PAYMENT  TO WS-DISP-TOTAL
           MOVE LN-TOTAL-INTEREST TO WS-DISP-INT
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  Total rembourse : " WS-DISP-TOTAL " MGA"
           DISPLAY "  Total interets  : " WS-DISP-INT " MGA"

           IF LN-APPROVED
               MOVE 'E' TO LN-STATUS
               REWRITE LOAN-RECORD
               DISPLAY "  Pret passe au statut ACTIF."
           END-IF

           CLOSE REPORT-FILE.
       600-EXIT. CONTINUE.

      *================================================================
       700-LIST-LOANS.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  LISTE DES PRETS"
           DISPLAY "  Filtre: 1=Tous 2=En attente 3=Approuves"
               " 4=Actifs"
           DISPLAY "  Choix filtre : " WITH NO ADVANCING
           ACCEPT WS-SUB-CHOICE
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  ID Pret   | Client              "
               "| Montant        | Statut"
           DISPLAY WS-DASH-LINE

           MOVE 'N'     TO WS-EOF
           MOVE SPACES  TO LN-ID
           START LOAN-FILE KEY >= LN-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ LOAN-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM 710-DISPLAY-LOAN-LINE
               END-READ
           END-PERFORM
           DISPLAY WS-SEPARATOR-LINE.

       710-DISPLAY-LOAN-LINE.
           EVALUATE WS-SUB-CHOICE
               WHEN 1 CONTINUE
               WHEN 2 IF NOT LN-PENDING GO TO 710-EXIT END-IF
               WHEN 3 IF NOT LN-APPROVED GO TO 710-EXIT END-IF
               WHEN 4 IF NOT LN-ACTIVE GO TO 710-EXIT END-IF
               WHEN OTHER CONTINUE
           END-EVALUATE
           MOVE LN-AMOUNT TO WS-DISP-AMOUNT
           DISPLAY "  " LN-ID
               " | " LN-CLIENT-NAME(1:20)
               " | " WS-DISP-AMOUNT
               " | " LN-STATUS.
       710-EXIT. CONTINUE.

      *================================================================
       750-SIMULATOR.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  SIMULATEUR DE MENSUALITE"
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  Capital (MGA)        : " WITH NO ADVANCING
           ACCEPT WS-INPUT-AMOUNT
           DISPLAY "  Taux annuel (%)      : " WITH NO ADVANCING
           ACCEPT WS-INPUT-RATE
           DISPLAY "  Duree (mois)         : " WITH NO ADVANCING
           ACCEPT WS-INPUT-DURATION

           PERFORM 310-COMPUTE-MONTHLY-PAYMENT

           MOVE WS-INPUT-AMOUNT TO WS-DISP-AMOUNT
           MOVE WS-INPUT-RATE   TO WS-DISP-RATE
           MOVE WS-MONTHLY-PMT  TO WS-DISP-PAYMENT
           MOVE WS-TOTAL-PMT    TO WS-DISP-TOTAL
           MOVE WS-TOTAL-INT    TO WS-DISP-INT

           DISPLAY WS-DASH-LINE
           DISPLAY "  === RESULTATS SIMULATION ==="
           DISPLAY "  Capital          : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Taux annuel      : " WS-DISP-RATE " %"
           DISPLAY "  Duree            : " WS-INPUT-DURATION " mois"
           DISPLAY "  Mensualite       : " WS-DISP-PAYMENT " MGA"
           DISPLAY "  Total rembourse  : " WS-DISP-TOTAL " MGA"
           DISPLAY "  Cout total credit: " WS-DISP-INT " MGA"
           DISPLAY WS-DASH-LINE.

      *================================================================
       800-STATISTICS-REPORT.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR-LINE
           DISPLAY "  RAPPORT ET STATISTIQUES"
           DISPLAY WS-SEPARATOR-LINE

           MOVE 0 TO WS-STAT-COUNT
           MOVE 0 TO WS-STAT-PENDING
           MOVE 0 TO WS-STAT-APPROVED
           MOVE 0 TO WS-STAT-ACTIVE
           MOVE 0 TO WS-STAT-TOTAL-AMT

           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO LN-ID
           START LOAN-FILE KEY >= LN-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ LOAN-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-STAT-COUNT
                       ADD LN-AMOUNT TO WS-STAT-TOTAL-AMT
                       IF LN-PENDING
                           ADD 1 TO WS-STAT-PENDING
                       END-IF
                       IF LN-APPROVED
                           ADD 1 TO WS-STAT-APPROVED
                       END-IF
                       IF LN-ACTIVE
                           ADD 1 TO WS-STAT-ACTIVE
                       END-IF
               END-READ
           END-PERFORM

           MOVE WS-STAT-TOTAL-AMT TO WS-DISP-TOTAL

           DISPLAY "  Nombre total de prets   : " WS-STAT-COUNT
           DISPLAY "  En attente validation   : " WS-STAT-PENDING
           DISPLAY "  Approuves               : " WS-STAT-APPROVED
           DISPLAY "  Actifs (en cours)       : " WS-STAT-ACTIVE
           DISPLAY "  Montant total porte     : " WS-DISP-TOTAL " MGA"
           DISPLAY WS-SEPARATOR-LINE.

      *================================================================
       900-CLOSE-FILES.
           CLOSE LOAN-FILE
           CLOSE AMORT-FILE
           DISPLAY SPACES
           DISPLAY "  Au revoir - Loan Management System"
           DISPLAY WS-SEPARATOR-LINE.
