      *================================================================
      * BATCH-MAIN.CBL - Orchestrateur Batch Bancaire
      * Bank Batch Processing System - Projet #10
      * Traitement nocturne : interets, frais, rapports
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-MAIN.
       AUTHOR. GnuCOBOL-Banking-System.
       DATE-WRITTEN. 2026-06-09.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO "data/ACCOUNTS.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AC-ID
               ALTERNATE RECORD KEY IS AC-CLIENT-ID
                   WITH DUPLICATES
               FILE STATUS IS WS-ACC-STATUS.

           SELECT TRANS-FILE
               ASSIGN TO "data/TRANSACTIONS.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TR-KEY
               FILE STATUS IS WS-TRN-STATUS.

           SELECT BATCH-LOG
               ASSIGN TO "logs/BATCH.log"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-LOG-STATUS.

           SELECT BATCH-RPT
               ASSIGN TO "logs/BATCH_REPORT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

           SELECT PARAM-FILE
               ASSIGN TO "data/PARAMS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PRM-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  AC-ID               PIC X(12).
           05  AC-CLIENT-ID        PIC X(10).
           05  AC-CLIENT-NAME      PIC X(40).
           05  AC-TYPE             PIC X(03).
               88 AC-IS-COURANT    VALUE 'CRT'.
               88 AC-IS-EPARGNE    VALUE 'EPG'.
               88 AC-IS-PROFES     VALUE 'PRO'.
           05  AC-BALANCE          PIC S9(12)V99.
           05  AC-INTEREST-RATE    PIC 9(02)V9(04).
           05  AC-OVERDRAFT-LIMIT  PIC S9(10)V99.
           05  AC-STATUS           PIC X(01).
               88 AC-ACTIVE        VALUE 'A'.
               88 AC-DORMANT       VALUE 'D'.
               88 AC-BLOCKED       VALUE 'B'.
               88 AC-CLOSED        VALUE 'C'.
           05  AC-LAST-BATCH-DATE  PIC X(10).
           05  AC-LAST-INTEREST    PIC S9(12)V99.
           05  AC-LAST-FEE         PIC S9(10)V99.
           05  AC-MONTHLY-FEES     PIC 9(08)V99.
           05  AC-OPEN-DATE        PIC X(10).
           05  AC-FILLER           PIC X(20).

       FD  TRANS-FILE.
       01  TRANS-RECORD.
           05  TR-KEY.
               10  TR-ACCOUNT-ID   PIC X(12).
               10  TR-DATE         PIC X(10).
               10  TR-SEQ          PIC 9(06).
           05  TR-TYPE             PIC X(03).
           05  TR-AMOUNT           PIC S9(12)V99.
           05  TR-BALANCE-AFTER    PIC S9(12)V99.
           05  TR-DESCRIPTION      PIC X(40).
           05  TR-BATCH-ID         PIC X(20).
           05  TR-FILLER           PIC X(10).

       FD  BATCH-LOG.
       01  LOG-LINE                PIC X(200).

       FD  BATCH-RPT.
       01  RPT-LINE                PIC X(132).

       FD  PARAM-FILE.
       01  PARAM-LINE              PIC X(80).

       WORKING-STORAGE SECTION.
       01  WS-ACC-STATUS           PIC XX VALUE SPACES.
       01  WS-TRN-STATUS           PIC XX VALUE SPACES.
       01  WS-LOG-STATUS           PIC XX VALUE SPACES.
       01  WS-RPT-STATUS           PIC XX VALUE SPACES.
       01  WS-PRM-STATUS           PIC XX VALUE SPACES.

      *--- Date/Heure batch ---
       01  WS-DATETIME             PIC X(21).
       01  WS-BATCH-DATE           PIC X(10).
       01  WS-BATCH-YEAR           PIC 9(04).
       01  WS-BATCH-MONTH          PIC 9(02).
       01  WS-BATCH-DAY            PIC 9(02).
       01  WS-BATCH-TIME           PIC X(08).
       01  WS-BATCH-ID             PIC X(20).

      *--- Parametres batch ---
       01  WS-PARAM-INT-RATE-CRT   PIC 9(02)V9(04) VALUE 0.00.
       01  WS-PARAM-INT-RATE-EPG   PIC 9(02)V9(04) VALUE 3.50.
       01  WS-PARAM-INT-RATE-PRO   PIC 9(02)V9(04) VALUE 0.00.
       01  WS-PARAM-FEE-MONTHLY    PIC 9(08)V99 VALUE 5000.00.
       01  WS-PARAM-FEE-OVERDRAFT  PIC 9(08)V99 VALUE 15000.00.
       01  WS-PARAM-OVERDRAFT-RATE PIC 9(02)V9(04) VALUE 18.00.
       01  WS-PARAM-DORMANT-DAYS   PIC 9(04) VALUE 0365.
       01  WS-PARAM-FEE-DORMANT    PIC 9(08)V99 VALUE 2500.00.

      *--- Compteurs ---
       01  WS-CTR-ACCOUNTS         PIC 9(07) VALUE 0.
       01  WS-CTR-INTEREST         PIC 9(07) VALUE 0.
       01  WS-CTR-FEES             PIC 9(07) VALUE 0.
       01  WS-CTR-OVERDRAFT        PIC 9(07) VALUE 0.
       01  WS-CTR-DORMANT          PIC 9(07) VALUE 0.
       01  WS-CTR-ERRORS           PIC 9(07) VALUE 0.
       01  WS-CTR-SKIPPED          PIC 9(07) VALUE 0.

      *--- Totaux ---
       01  WS-TOT-INTEREST-PAID    PIC S9(14)V99 VALUE 0.
       01  WS-TOT-FEES-COLLECTED   PIC S9(14)V99 VALUE 0.
       01  WS-TOT-OVERDRAFT-INT    PIC S9(14)V99 VALUE 0.

      *--- Calculs interets ---
       01  WS-DAYS-IN-YEAR         PIC 9(03) VALUE 365.
       01  WS-INTEREST-AMOUNT      PIC S9(12)V99.
       01  WS-DAILY-RATE           PIC 9(01)V9(10).
       01  WS-CALC-INTEREST        PIC S9(14)V9(06).
       01  WS-CALC-FEE             PIC S9(10)V99.
       01  WS-OVERDRAFT-INT        PIC S9(10)V99.

      *--- Controle flux ---
       01  WS-EOF                  PIC X VALUE 'N'.
       01  WS-MENU-CHOICE          PIC 9 VALUE 0.
       01  WS-CONTINUE             PIC X VALUE 'Y'.
       01  WS-CONFIRM              PIC X VALUE 'N'.

      *--- Transaction sequence ---
       01  WS-TRN-SEQ              PIC 9(06) VALUE 0.

      *--- Affichage ---
       01  WS-DISP-AMOUNT          PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-BALANCE         PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-DISP-RATE            PIC ZZ9.9999.

       01  WS-SEP.
           05  FILLER  PIC X(70) VALUE ALL '='.
       01  WS-DASH.
           05  FILLER  PIC X(70) VALUE ALL '-'.

       01  WS-LOG-BUFFER           PIC X(200).
       01  WS-RPT-BUFFER           PIC X(132).

       01  WS-PHASE                PIC X(30).
       01  WS-START-TIME           PIC X(21).
       01  WS-END-TIME             PIC X(21).

       PROCEDURE DIVISION.

       000-MAIN.
           PERFORM 010-INIT
           PERFORM 020-MAIN-MENU
               UNTIL WS-CONTINUE = 'N'
           PERFORM 099-FINALIZE
           STOP RUN.

      *================================================================
       010-INIT.
           MOVE FUNCTION CURRENT-DATE TO WS-DATETIME
           MOVE WS-DATETIME(1:4)  TO WS-BATCH-YEAR
           MOVE WS-DATETIME(5:2)  TO WS-BATCH-MONTH
           MOVE WS-DATETIME(7:2)  TO WS-BATCH-DAY
           MOVE WS-DATETIME(9:2)  TO WS-BATCH-TIME(1:2)
           MOVE ':'               TO WS-BATCH-TIME(3:1)
           MOVE WS-DATETIME(11:2) TO WS-BATCH-TIME(4:2)
           MOVE ':'               TO WS-BATCH-TIME(6:1)
           MOVE WS-DATETIME(13:2) TO WS-BATCH-TIME(7:2)
           STRING WS-BATCH-YEAR "-" WS-BATCH-MONTH
               "-" WS-BATCH-DAY
               DELIMITED SIZE INTO WS-BATCH-DATE
           STRING "BATCH-" WS-BATCH-DATE
               "-" WS-BATCH-TIME(1:5)
               DELIMITED SIZE INTO WS-BATCH-ID

           OPEN I-O ACCOUNT-FILE
           IF WS-ACC-STATUS = '35'
               OPEN OUTPUT ACCOUNT-FILE
               CLOSE ACCOUNT-FILE
               OPEN I-O ACCOUNT-FILE
           END-IF

           OPEN I-O TRANS-FILE
           IF WS-TRN-STATUS = '35'
               OPEN OUTPUT TRANS-FILE
               CLOSE TRANS-FILE
               OPEN I-O TRANS-FILE
           END-IF

           OPEN EXTEND BATCH-LOG
           IF WS-LOG-STATUS NOT = '00'
               OPEN OUTPUT BATCH-LOG
           END-IF.

      *================================================================
       020-MAIN-MENU.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  BANK BATCH PROCESSING SYSTEM"
           DISPLAY "  Traitement Batch Bancaire - " WS-BATCH-DATE
           DISPLAY WS-SEP
           DISPLAY "  --- OPERATIONS BATCH ---"
           DISPLAY "  1. Lancer batch COMPLET (nuit)"
           DISPLAY "  2. Calcul interets uniquement"
           DISPLAY "  3. Prelevement frais uniquement"
           DISPLAY "  4. Traitement decouverts"
           DISPLAY "  5. Detection comptes dormants"
           DISPLAY "  --- GESTION COMPTES ---"
           DISPLAY "  6. Creer un compte"
           DISPLAY "  7. Consulter un compte"
           DISPLAY "  8. Liste des comptes"
           DISPLAY "  9. Rapport batch precedent"
           DISPLAY "  0. Quitter"
           DISPLAY WS-DASH
           DISPLAY "  Votre choix : " WITH NO ADVANCING
           ACCEPT WS-MENU-CHOICE
           EVALUATE WS-MENU-CHOICE
               WHEN 1  PERFORM 100-FULL-BATCH
               WHEN 2  PERFORM 200-INTEREST-BATCH
               WHEN 3  PERFORM 300-FEES-BATCH
               WHEN 4  PERFORM 400-OVERDRAFT-BATCH
               WHEN 5  PERFORM 500-DORMANT-BATCH
               WHEN 6  PERFORM 600-CREATE-ACCOUNT
               WHEN 7  PERFORM 700-CONSULT-ACCOUNT
               WHEN 8  PERFORM 800-LIST-ACCOUNTS
               WHEN 9  PERFORM 900-SHOW-REPORT
               WHEN 0  MOVE 'N' TO WS-CONTINUE
               WHEN OTHER
                   DISPLAY "  Choix invalide."
           END-EVALUATE.

      *================================================================
      * BATCH COMPLET NOCTURNE
      *================================================================
       100-FULL-BATCH.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  BATCH COMPLET - TRAITEMENT NOCTURNE"
           DISPLAY "  Date batch : " WS-BATCH-DATE
           DISPLAY "  ID batch   : " WS-BATCH-ID
           DISPLAY WS-SEP
           DISPLAY "  Confirmer le lancement? (O/N) : "
               WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM NOT = 'O' AND WS-CONFIRM NOT = 'o'
               DISPLAY "  Batch annule."
               GO TO 100-EXIT
           END-IF

           MOVE FUNCTION CURRENT-DATE TO WS-START-TIME
           MOVE 0 TO WS-CTR-ACCOUNTS
           MOVE 0 TO WS-CTR-INTEREST
           MOVE 0 TO WS-CTR-FEES
           MOVE 0 TO WS-CTR-OVERDRAFT
           MOVE 0 TO WS-CTR-DORMANT
           MOVE 0 TO WS-CTR-ERRORS
           MOVE 0 TO WS-TOT-INTEREST-PAID
           MOVE 0 TO WS-TOT-FEES-COLLECTED
           MOVE 0 TO WS-TOT-OVERDRAFT-INT

           PERFORM 110-LOG-BATCH-START
           OPEN OUTPUT BATCH-RPT

           DISPLAY "  [1/5] Calcul des interets..."
           MOVE "INTERETS" TO WS-PHASE
           PERFORM 200-INTEREST-BATCH-CORE

           DISPLAY "  [2/5] Prelevement des frais..."
           MOVE "FRAIS MENSUELS" TO WS-PHASE
           PERFORM 300-FEES-BATCH-CORE

           DISPLAY "  [3/5] Traitement decouverts..."
           MOVE "DECOUVERTS" TO WS-PHASE
           PERFORM 400-OVERDRAFT-BATCH-CORE

           DISPLAY "  [4/5] Detection comptes dormants..."
           MOVE "DORMANTS" TO WS-PHASE
           PERFORM 500-DORMANT-BATCH-CORE

           DISPLAY "  [5/5] Generation rapport..."
           MOVE FUNCTION CURRENT-DATE TO WS-END-TIME
           PERFORM 150-WRITE-BATCH-REPORT

           CLOSE BATCH-RPT
           PERFORM 120-LOG-BATCH-END

           DISPLAY WS-SEP
           DISPLAY "  BATCH TERMINE AVEC SUCCES"
           DISPLAY "  Comptes traites   : " WS-CTR-ACCOUNTS
           DISPLAY "  Interets calcules : " WS-CTR-INTEREST
           DISPLAY "  Frais preleves    : " WS-CTR-FEES
           DISPLAY "  Decouverts traites: " WS-CTR-OVERDRAFT
           DISPLAY "  Dormants detectes : " WS-CTR-DORMANT
           DISPLAY "  Erreurs           : " WS-CTR-ERRORS
           MOVE WS-TOT-INTEREST-PAID   TO WS-DISP-AMOUNT
           DISPLAY "  Total interets    : " WS-DISP-AMOUNT " MGA"
           MOVE WS-TOT-FEES-COLLECTED  TO WS-DISP-AMOUNT
           DISPLAY "  Total frais       : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Rapport: logs/BATCH_REPORT.txt"
           DISPLAY WS-SEP.
       100-EXIT. CONTINUE.

       110-LOG-BATCH-START.
           STRING "DEBUT BATCH " WS-BATCH-ID
               " le " WS-BATCH-DATE
               " a " WS-BATCH-TIME
               DELIMITED SIZE INTO WS-LOG-BUFFER
           WRITE LOG-LINE FROM WS-LOG-BUFFER.

       120-LOG-BATCH-END.
           STRING "FIN BATCH " WS-BATCH-ID
               " - Comptes:" WS-CTR-ACCOUNTS
               " Int:" WS-CTR-INTEREST
               " Frais:" WS-CTR-FEES
               " Err:" WS-CTR-ERRORS
               DELIMITED SIZE INTO WS-LOG-BUFFER
           WRITE LOG-LINE FROM WS-LOG-BUFFER.

       150-WRITE-BATCH-REPORT.
           WRITE RPT-LINE FROM WS-SEP
           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  RAPPORT BATCH NOCTURNE - " WS-BATCH-DATE
               " - ID: " WS-BATCH-ID
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           WRITE RPT-LINE FROM WS-SEP
           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  RESUME DES TRAITEMENTS"
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-DASH

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Comptes traites       : "
               WS-CTR-ACCOUNTS
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Interets calcules     : "
               WS-CTR-INTEREST
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE WS-TOT-INTEREST-PAID TO WS-DISP-AMOUNT
           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Total interets payes  : "
               WS-DISP-AMOUNT " MGA"
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Frais preleves        : "
               WS-CTR-FEES
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE WS-TOT-FEES-COLLECTED TO WS-DISP-AMOUNT
           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Total frais collectes : "
               WS-DISP-AMOUNT " MGA"
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Decouverts traites    : "
               WS-CTR-OVERDRAFT
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE WS-TOT-OVERDRAFT-INT TO WS-DISP-AMOUNT
           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Interets decouverts   : "
               WS-DISP-AMOUNT " MGA"
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Comptes dormants      : "
               WS-CTR-DORMANT
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           MOVE SPACES TO WS-RPT-BUFFER
           STRING "  Erreurs               : "
               WS-CTR-ERRORS
               DELIMITED SIZE INTO WS-RPT-BUFFER
           WRITE RPT-LINE FROM WS-RPT-BUFFER

           WRITE RPT-LINE FROM WS-SEP.

      *================================================================
      * MODULE 2 : CALCUL DES INTERETS
      *================================================================
       200-INTEREST-BATCH.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  CALCUL DES INTERETS NOCTURNES"
           DISPLAY WS-SEP
           MOVE 0 TO WS-CTR-ACCOUNTS
           MOVE 0 TO WS-CTR-INTEREST
           MOVE 0 TO WS-CTR-ERRORS
           MOVE 0 TO WS-TOT-INTEREST-PAID
           PERFORM 200-INTEREST-BATCH-CORE
           MOVE WS-TOT-INTEREST-PAID TO WS-DISP-AMOUNT
           DISPLAY "  Comptes traites : " WS-CTR-ACCOUNTS
           DISPLAY "  Interets verses : " WS-CTR-INTEREST
           DISPLAY "  Total interets  : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Erreurs         : " WS-CTR-ERRORS.

       200-INTEREST-BATCH-CORE.
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO AC-ID
           START ACCOUNT-FILE KEY >= AC-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ ACCOUNT-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-CTR-ACCOUNTS
                       PERFORM 210-CALC-ACCOUNT-INTEREST
               END-READ
           END-PERFORM.

       210-CALC-ACCOUNT-INTEREST.
           IF NOT AC-ACTIVE
               ADD 1 TO WS-CTR-SKIPPED
               GO TO 210-EXIT
           END-IF

           EVALUATE TRUE
               WHEN AC-IS-EPARGNE
                   COMPUTE WS-DAILY-RATE =
                       WS-PARAM-INT-RATE-EPG / 100 / WS-DAYS-IN-YEAR
               WHEN AC-IS-PROFES
                   COMPUTE WS-DAILY-RATE =
                       WS-PARAM-INT-RATE-PRO / 100 / WS-DAYS-IN-YEAR
               WHEN OTHER
                   COMPUTE WS-DAILY-RATE =
                       WS-PARAM-INT-RATE-CRT / 100 / WS-DAYS-IN-YEAR
           END-EVALUATE

           IF WS-DAILY-RATE = 0 OR AC-BALANCE <= 0
               GO TO 210-EXIT
           END-IF

           COMPUTE WS-CALC-INTEREST =
               AC-BALANCE * WS-DAILY-RATE

           IF WS-CALC-INTEREST <= 0
               GO TO 210-EXIT
           END-IF

           MOVE WS-CALC-INTEREST TO WS-INTEREST-AMOUNT
           ADD WS-INTEREST-AMOUNT TO AC-BALANCE
           MOVE WS-INTEREST-AMOUNT TO AC-LAST-INTEREST
           MOVE WS-BATCH-DATE      TO AC-LAST-BATCH-DATE
           REWRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS NOT = '00'
               ADD 1 TO WS-CTR-ERRORS
               GO TO 210-EXIT
           END-IF

           PERFORM 999-WRITE-TRANSACTION-INT
           ADD 1 TO WS-CTR-INTEREST
           ADD WS-INTEREST-AMOUNT TO WS-TOT-INTEREST-PAID.
       210-EXIT. CONTINUE.

      *================================================================
      * MODULE 3 : PRELEVEMENT DES FRAIS
      *================================================================
       300-FEES-BATCH.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  PRELEVEMENT DES FRAIS MENSUELS"
           DISPLAY WS-SEP
           MOVE 0 TO WS-CTR-FEES
           MOVE 0 TO WS-CTR-ERRORS
           MOVE 0 TO WS-TOT-FEES-COLLECTED
           PERFORM 300-FEES-BATCH-CORE
           MOVE WS-TOT-FEES-COLLECTED TO WS-DISP-AMOUNT
           DISPLAY "  Frais preleves : " WS-CTR-FEES
           DISPLAY "  Total collecte : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Erreurs        : " WS-CTR-ERRORS.

       300-FEES-BATCH-CORE.
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO AC-ID
           START ACCOUNT-FILE KEY >= AC-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ ACCOUNT-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM 310-APPLY-MONTHLY-FEE
               END-READ
           END-PERFORM.

       310-APPLY-MONTHLY-FEE.
           IF NOT AC-ACTIVE
               GO TO 310-EXIT
           END-IF

           MOVE AC-MONTHLY-FEES TO WS-CALC-FEE
           IF WS-CALC-FEE = 0
               MOVE WS-PARAM-FEE-MONTHLY TO WS-CALC-FEE
           END-IF

           IF WS-CALC-FEE <= 0
               GO TO 310-EXIT
           END-IF

           COMPUTE AC-BALANCE = AC-BALANCE - WS-CALC-FEE
           MOVE WS-CALC-FEE    TO AC-LAST-FEE
           MOVE WS-BATCH-DATE  TO AC-LAST-BATCH-DATE

           REWRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS NOT = '00'
               ADD 1 TO WS-CTR-ERRORS
               GO TO 310-EXIT
           END-IF

           PERFORM 999-WRITE-TRANSACTION-FEE
           ADD 1 TO WS-CTR-FEES
           ADD WS-CALC-FEE TO WS-TOT-FEES-COLLECTED.
       310-EXIT. CONTINUE.

      *================================================================
      * MODULE 4 : TRAITEMENT DECOUVERTS
      *================================================================
       400-OVERDRAFT-BATCH.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  TRAITEMENT DES DECOUVERTS"
           DISPLAY WS-SEP
           MOVE 0 TO WS-CTR-OVERDRAFT
           MOVE 0 TO WS-CTR-ERRORS
           MOVE 0 TO WS-TOT-OVERDRAFT-INT
           PERFORM 400-OVERDRAFT-BATCH-CORE
           MOVE WS-TOT-OVERDRAFT-INT TO WS-DISP-AMOUNT
           DISPLAY "  Decouverts     : " WS-CTR-OVERDRAFT
           DISPLAY "  Interets debit : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Erreurs        : " WS-CTR-ERRORS.

       400-OVERDRAFT-BATCH-CORE.
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO AC-ID
           START ACCOUNT-FILE KEY >= AC-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ ACCOUNT-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF AC-ACTIVE AND AC-BALANCE < 0
                           PERFORM 410-APPLY-OVERDRAFT-INT
                       END-IF
               END-READ
           END-PERFORM.

       410-APPLY-OVERDRAFT-INT.
           COMPUTE WS-DAILY-RATE =
               WS-PARAM-OVERDRAFT-RATE / 100 / WS-DAYS-IN-YEAR

           COMPUTE WS-CALC-INTEREST =
               AC-BALANCE * WS-DAILY-RATE * (-1)

           IF WS-CALC-INTEREST <= 0
               GO TO 410-EXIT
           END-IF

           MOVE WS-CALC-INTEREST TO WS-OVERDRAFT-INT
           COMPUTE AC-BALANCE = AC-BALANCE - WS-OVERDRAFT-INT
           MOVE WS-BATCH-DATE TO AC-LAST-BATCH-DATE

           REWRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS NOT = '00'
               ADD 1 TO WS-CTR-ERRORS
               GO TO 410-EXIT
           END-IF

           PERFORM 999-WRITE-TRANSACTION-OVD
           ADD 1 TO WS-CTR-OVERDRAFT
           ADD WS-OVERDRAFT-INT TO WS-TOT-OVERDRAFT-INT.
       410-EXIT. CONTINUE.

      *================================================================
      * MODULE 5 : DETECTION COMPTES DORMANTS
      *================================================================
       500-DORMANT-BATCH.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  DETECTION COMPTES DORMANTS"
           DISPLAY WS-SEP
           MOVE 0 TO WS-CTR-DORMANT
           PERFORM 500-DORMANT-BATCH-CORE
           DISPLAY "  Comptes passes dormants: " WS-CTR-DORMANT.

       500-DORMANT-BATCH-CORE.
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO AC-ID
           START ACCOUNT-FILE KEY >= AC-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ ACCOUNT-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM 510-CHECK-DORMANT
               END-READ
           END-PERFORM.

       510-CHECK-DORMANT.
           IF NOT AC-ACTIVE
               GO TO 510-EXIT
           END-IF
           IF AC-LAST-BATCH-DATE = SPACES
               GO TO 510-EXIT
           END-IF

           MOVE 'D' TO AC-STATUS
           REWRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS = '00'
               ADD 1 TO WS-CTR-DORMANT
               MOVE WS-PARAM-FEE-DORMANT TO WS-CALC-FEE
               STRING "Compte dormant - frais "
                   WS-BATCH-DATE
                   DELIMITED SIZE INTO WS-LOG-BUFFER
               WRITE LOG-LINE FROM WS-LOG-BUFFER
           END-IF.
       510-EXIT. CONTINUE.

      *================================================================
      * MODULE 6 : CREATION COMPTE
      *================================================================
       600-CREATE-ACCOUNT.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  CREATION D'UN COMPTE"
           DISPLAY WS-SEP

           DISPLAY "  ID compte (12 car.)  : " WITH NO ADVANCING
           ACCEPT AC-ID
           DISPLAY "  ID client (10 car.)  : " WITH NO ADVANCING
           ACCEPT AC-CLIENT-ID
           DISPLAY "  Nom complet client   : " WITH NO ADVANCING
           ACCEPT AC-CLIENT-NAME
           DISPLAY "  Type (CRT/EPG/PRO)   : " WITH NO ADVANCING
           ACCEPT AC-TYPE
           DISPLAY "  Solde initial (MGA)  : " WITH NO ADVANCING
           ACCEPT AC-BALANCE
           DISPLAY "  Limite decouvert MGA : " WITH NO ADVANCING
           ACCEPT AC-OVERDRAFT-LIMIT
           DISPLAY "  Frais mensuels MGA   : " WITH NO ADVANCING
           ACCEPT AC-MONTHLY-FEES

           EVALUATE AC-TYPE
               WHEN 'EPG' WHEN 'epg'
                   MOVE 'EPG'  TO AC-TYPE
                   MOVE WS-PARAM-INT-RATE-EPG TO AC-INTEREST-RATE
               WHEN 'PRO' WHEN 'pro'
                   MOVE 'PRO'  TO AC-TYPE
                   MOVE WS-PARAM-INT-RATE-PRO TO AC-INTEREST-RATE
               WHEN OTHER
                   MOVE 'CRT'  TO AC-TYPE
                   MOVE WS-PARAM-INT-RATE-CRT TO AC-INTEREST-RATE
           END-EVALUATE

           MOVE 'A'            TO AC-STATUS
           MOVE WS-BATCH-DATE  TO AC-OPEN-DATE
           MOVE SPACES         TO AC-LAST-BATCH-DATE
           MOVE 0              TO AC-LAST-INTEREST
           MOVE 0              TO AC-LAST-FEE

           WRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS = '00'
               DISPLAY "  Compte cree : " AC-ID
           ELSE IF WS-ACC-STATUS = '22'
               DISPLAY "  Erreur: ID compte deja existant."
           ELSE
               DISPLAY "  Erreur ecriture: " WS-ACC-STATUS
           END-IF.

      *================================================================
      * MODULE 7 : CONSULTATION COMPTE
      *================================================================
       700-CONSULT-ACCOUNT.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  CONSULTATION COMPTE"
           DISPLAY WS-SEP
           DISPLAY "  ID compte : " WITH NO ADVANCING
           ACCEPT AC-ID

           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "  Compte non trouve: " AC-ID
                   GO TO 700-EXIT
           END-READ

           MOVE AC-BALANCE TO WS-DISP-BALANCE
           MOVE AC-OVERDRAFT-LIMIT TO WS-DISP-AMOUNT
           MOVE AC-INTEREST-RATE TO WS-DISP-RATE
           DISPLAY WS-DASH
           DISPLAY "  ID Compte       : " AC-ID
           DISPLAY "  ID Client       : " AC-CLIENT-ID
           DISPLAY "  Nom Client      : " AC-CLIENT-NAME
           DISPLAY "  Type            : " AC-TYPE
           DISPLAY "  Solde           : " WS-DISP-BALANCE " MGA"
           DISPLAY "  Taux interet    : " WS-DISP-RATE " %"
           DISPLAY "  Lim. decouverte : " WS-DISP-AMOUNT " MGA"
           DISPLAY "  Ouvert le       : " AC-OPEN-DATE
           DISPLAY "  Dernier batch   : " AC-LAST-BATCH-DATE
           DISPLAY "  Statut          : "
           EVALUATE AC-STATUS
               WHEN 'A' DISPLAY "  Actif"
               WHEN 'D' DISPLAY "  Dormant"
               WHEN 'B' DISPLAY "  Bloque"
               WHEN 'C' DISPLAY "  Cloture"
           END-EVALUATE
           DISPLAY WS-DASH.
       700-EXIT. CONTINUE.

      *================================================================
      * MODULE 8 : LISTE COMPTES
      *================================================================
       800-LIST-ACCOUNTS.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  LISTE DES COMPTES"
           DISPLAY WS-SEP
           DISPLAY "  Filtre: 1=Tous  2=Actifs  3=Dormants"
               "  4=Decouverts"
           DISPLAY "  Choix : " WITH NO ADVANCING
           ACCEPT WS-MENU-CHOICE
           DISPLAY WS-DASH
           DISPLAY "  ID Compte   | Type | Solde"
               "          | Statut | Client"
           DISPLAY WS-DASH

           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO AC-ID
           START ACCOUNT-FILE KEY >= AC-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ ACCOUNT-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM 810-DISPLAY-ACCOUNT-LINE
               END-READ
           END-PERFORM
           DISPLAY WS-SEP.

       810-DISPLAY-ACCOUNT-LINE.
           EVALUATE WS-MENU-CHOICE
               WHEN 2 IF NOT AC-ACTIVE GO TO 810-EXIT END-IF
               WHEN 3 IF NOT AC-DORMANT GO TO 810-EXIT END-IF
               WHEN 4 IF AC-BALANCE >= 0 GO TO 810-EXIT END-IF
               WHEN OTHER CONTINUE
           END-EVALUATE
           MOVE AC-BALANCE TO WS-DISP-BALANCE
           DISPLAY "  " AC-ID
               " | " AC-TYPE
               " | " WS-DISP-BALANCE
               " | " AC-STATUS
               " | " AC-CLIENT-NAME(1:20).
       810-EXIT. CONTINUE.

      *================================================================
      * MODULE 9 : RAPPORT
      *================================================================
       900-SHOW-REPORT.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  RAPPORT BATCH - logs/BATCH_REPORT.txt"
           DISPLAY WS-SEP
           CALL "SYSTEM" USING
               "cat logs/BATCH_REPORT.txt"
           END-CALL.

      *================================================================
      * UTILITAIRE : ECRITURE TRANSACTIONS
      *================================================================
       999-WRITE-TRANSACTION-INT.
           ADD 1 TO WS-TRN-SEQ
           MOVE AC-ID          TO TR-ACCOUNT-ID
           MOVE WS-BATCH-DATE  TO TR-DATE
           MOVE WS-TRN-SEQ     TO TR-SEQ
           MOVE 'INT'          TO TR-TYPE
           MOVE WS-INTEREST-AMOUNT TO TR-AMOUNT
           MOVE AC-BALANCE     TO TR-BALANCE-AFTER
           STRING "Interets credites "
               WS-BATCH-DATE
               DELIMITED SIZE INTO TR-DESCRIPTION
           MOVE WS-BATCH-ID    TO TR-BATCH-ID
           WRITE TRANS-RECORD
               INVALID KEY REWRITE TRANS-RECORD.

       999-WRITE-TRANSACTION-FEE.
           ADD 1 TO WS-TRN-SEQ
           MOVE AC-ID          TO TR-ACCOUNT-ID
           MOVE WS-BATCH-DATE  TO TR-DATE
           MOVE WS-TRN-SEQ     TO TR-SEQ
           MOVE 'FRA'          TO TR-TYPE
           COMPUTE TR-AMOUNT = WS-CALC-FEE * (-1)
           MOVE AC-BALANCE     TO TR-BALANCE-AFTER
           STRING "Frais mensuels "
               WS-BATCH-DATE
               DELIMITED SIZE INTO TR-DESCRIPTION
           MOVE WS-BATCH-ID    TO TR-BATCH-ID
           WRITE TRANS-RECORD
               INVALID KEY REWRITE TRANS-RECORD.

       999-WRITE-TRANSACTION-OVD.
           ADD 1 TO WS-TRN-SEQ
           MOVE AC-ID          TO TR-ACCOUNT-ID
           MOVE WS-BATCH-DATE  TO TR-DATE
           MOVE WS-TRN-SEQ     TO TR-SEQ
           MOVE 'DEC'          TO TR-TYPE
           COMPUTE TR-AMOUNT = WS-OVERDRAFT-INT * (-1)
           MOVE AC-BALANCE     TO TR-BALANCE-AFTER
           STRING "Interets decouvert "
               WS-BATCH-DATE
               DELIMITED SIZE INTO TR-DESCRIPTION
           MOVE WS-BATCH-ID    TO TR-BATCH-ID
           WRITE TRANS-RECORD
               INVALID KEY REWRITE TRANS-RECORD.

      *================================================================
       099-FINALIZE.
           CLOSE ACCOUNT-FILE
           CLOSE TRANS-FILE
           CLOSE BATCH-LOG
           DISPLAY "  Au revoir - Bank Batch Processing System"
           DISPLAY WS-SEP.
