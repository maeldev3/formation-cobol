      *================================================================
      * BATCH-HISTORY.CBL - Historique des transactions batch
      * Affiche les transactions generees par le batch
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-HISTORY.
       AUTHOR. GnuCOBOL-Banking-System.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANS-FILE
               ASSIGN TO "data/TRANSACTIONS.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TR-KEY
               FILE STATUS IS WS-TRN-STATUS.

           SELECT ACCOUNT-FILE
               ASSIGN TO "data/ACCOUNTS.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AC-ID
               FILE STATUS IS WS-ACC-STATUS.

       DATA DIVISION.
       FILE SECTION.

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

       FD  ACCOUNT-FILE.
       01  ACCOUNT-RECORD.
           05  AC-ID               PIC X(12).
           05  AC-CLIENT-ID        PIC X(10).
           05  AC-CLIENT-NAME      PIC X(40).
           05  AC-TYPE             PIC X(03).
           05  AC-BALANCE          PIC S9(12)V99.
           05  AC-INTEREST-RATE    PIC 9(02)V9(04).
           05  AC-OVERDRAFT-LIMIT  PIC S9(10)V99.
           05  AC-STATUS           PIC X(01).
           05  AC-LAST-BATCH-DATE  PIC X(10).
           05  AC-LAST-INTEREST    PIC S9(12)V99.
           05  AC-LAST-FEE         PIC S9(10)V99.
           05  AC-MONTHLY-FEES     PIC 9(08)V99.
           05  AC-OPEN-DATE        PIC X(10).
           05  AC-FILLER           PIC X(20).

       WORKING-STORAGE SECTION.
       01  WS-TRN-STATUS           PIC XX VALUE SPACES.
       01  WS-ACC-STATUS           PIC XX VALUE SPACES.
       01  WS-EOF                  PIC X VALUE 'N'.
       01  WS-MENU-CHOICE          PIC 9 VALUE 0.
       01  WS-CONTINUE             PIC X VALUE 'Y'.
       01  WS-FILTER-ID            PIC X(12) VALUE SPACES.
       01  WS-CTR                  PIC 9(07) VALUE 0.

       01  WS-DISP-AMOUNT          PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.
       01  WS-DISP-BAL             PIC ZZZ,ZZZ,ZZZ,ZZ9.99-.

       01  WS-SEP.
           05  FILLER  PIC X(70) VALUE ALL '='.
       01  WS-DASH.
           05  FILLER  PIC X(70) VALUE ALL '-'.

       01  WS-TYPE-LABEL           PIC X(20).

       PROCEDURE DIVISION.

       000-MAIN.
           OPEN INPUT TRANS-FILE
           IF WS-TRN-STATUS = '35'
               DISPLAY "Aucune transaction - lancer le batch d'abord"
               STOP RUN
           END-IF
           OPEN INPUT ACCOUNT-FILE

           PERFORM 020-MENU UNTIL WS-CONTINUE = 'N'

           CLOSE TRANS-FILE
           CLOSE ACCOUNT-FILE
           STOP RUN.

       020-MENU.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  HISTORIQUE DES TRANSACTIONS BATCH"
           DISPLAY WS-SEP
           DISPLAY "  1. Toutes les transactions"
           DISPLAY "  2. Par compte (saisir ID)"
           DISPLAY "  3. Interets uniquement"
           DISPLAY "  4. Frais uniquement"
           DISPLAY "  5. Decouverts uniquement"
           DISPLAY "  0. Quitter"
           DISPLAY WS-DASH
           DISPLAY "  Choix : " WITH NO ADVANCING
           ACCEPT WS-MENU-CHOICE
           EVALUATE WS-MENU-CHOICE
               WHEN 0 MOVE 'N' TO WS-CONTINUE
               WHEN 1 PERFORM 100-ALL-TRANSACTIONS
               WHEN 2 PERFORM 200-BY-ACCOUNT
               WHEN 3 MOVE 'INT' TO WS-FILTER-ID
                      PERFORM 300-BY-TYPE
               WHEN 4 MOVE 'FRA' TO WS-FILTER-ID
                      PERFORM 300-BY-TYPE
               WHEN 5 MOVE 'DEC' TO WS-FILTER-ID
                      PERFORM 300-BY-TYPE
               WHEN OTHER DISPLAY "  Choix invalide."
           END-EVALUATE.

       100-ALL-TRANSACTIONS.
           MOVE 0 TO WS-CTR
           DISPLAY WS-DASH
           DISPLAY "  Compte      | Date       | Type"
               " | Montant          | Solde apres"
           DISPLAY WS-DASH
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO TR-KEY
           START TRANS-FILE KEY >= TR-KEY
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START
           PERFORM UNTIL WS-EOF = 'Y'
               READ TRANS-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-CTR
                       PERFORM 900-DISPLAY-TRANS
               END-READ
           END-PERFORM
           DISPLAY WS-DASH
           DISPLAY "  Total : " WS-CTR " transaction(s)".

       200-BY-ACCOUNT.
           DISPLAY "  ID compte : " WITH NO ADVANCING
           ACCEPT WS-FILTER-ID
           MOVE 0 TO WS-CTR
           DISPLAY WS-DASH
           DISPLAY "  Compte      | Date       | Type"
               " | Montant          | Solde apres"
           DISPLAY WS-DASH
           MOVE 'N' TO WS-EOF
           MOVE WS-FILTER-ID TO TR-ACCOUNT-ID
           MOVE SPACES TO TR-DATE
           MOVE 0 TO TR-SEQ
           START TRANS-FILE KEY >= TR-KEY
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START
           PERFORM UNTIL WS-EOF = 'Y'
               READ TRANS-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF TR-ACCOUNT-ID = WS-FILTER-ID
                           ADD 1 TO WS-CTR
                           PERFORM 900-DISPLAY-TRANS
                       ELSE
                           MOVE 'Y' TO WS-EOF
                       END-IF
               END-READ
           END-PERFORM
           DISPLAY WS-DASH
           DISPLAY "  Total : " WS-CTR " transaction(s)".

       300-BY-TYPE.
           MOVE 0 TO WS-CTR
           DISPLAY WS-DASH
           DISPLAY "  Compte      | Date       | Type"
               " | Montant          | Solde apres"
           DISPLAY WS-DASH
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO TR-KEY
           START TRANS-FILE KEY >= TR-KEY
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START
           PERFORM UNTIL WS-EOF = 'Y'
               READ TRANS-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       IF TR-TYPE = WS-FILTER-ID(1:3)
                           ADD 1 TO WS-CTR
                           PERFORM 900-DISPLAY-TRANS
                       END-IF
               END-READ
           END-PERFORM
           DISPLAY WS-DASH
           DISPLAY "  Total : " WS-CTR " transaction(s)".

       900-DISPLAY-TRANS.
           EVALUATE TR-TYPE
               WHEN 'INT' MOVE "INTERET    " TO WS-TYPE-LABEL
               WHEN 'FRA' MOVE "FRAIS      " TO WS-TYPE-LABEL
               WHEN 'DEC' MOVE "DECOUVERT  " TO WS-TYPE-LABEL
               WHEN OTHER MOVE TR-TYPE        TO WS-TYPE-LABEL
           END-EVALUATE
           MOVE TR-AMOUNT       TO WS-DISP-AMOUNT
           MOVE TR-BALANCE-AFTER TO WS-DISP-BAL
           DISPLAY "  " TR-ACCOUNT-ID
               " | " TR-DATE
               " | " WS-TYPE-LABEL
               " | " WS-DISP-AMOUNT
               " | " WS-DISP-BAL.
