      *================================================================
      * LOAN-REPORT.CBL - Module de rapport PDF/TXT
      * Gestion Prets Bancaires - Generation rapports
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOAN-REPORT.
       AUTHOR. GnuCOBOL-Banking-System.

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

           SELECT RPT-FILE
               ASSIGN TO "data/LOAN_REPORT.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-STATUS.

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

       FD  RPT-FILE.
       01  RPT-LINE                PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX.
       01  WS-AMORT-STATUS         PIC XX.
       01  WS-RPT-STATUS           PIC XX.
       01  WS-EOF                  PIC X VALUE 'N'.

       01  WS-DATE-TODAY           PIC X(21).
       01  WS-RPT-DATE             PIC X(10).

       01  WS-COUNT-TOTAL          PIC 9(5) VALUE 0.
       01  WS-COUNT-PENDING        PIC 9(5) VALUE 0.
       01  WS-COUNT-APPROVED       PIC 9(5) VALUE 0.
       01  WS-COUNT-ACTIVE         PIC 9(5) VALUE 0.
       01  WS-COUNT-CLOSED         PIC 9(5) VALUE 0.
       01  WS-COUNT-REJECTED       PIC 9(5) VALUE 0.
       01  WS-SUM-AMOUNT           PIC 9(14)V99 VALUE 0.
       01  WS-SUM-INTEREST         PIC 9(14)V99 VALUE 0.

       01  WS-DISP-AMOUNT          PIC ZZZ,ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-PMT             PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-DISP-RATE            PIC ZZ9.9999.

       01  WS-SEPARATOR.
           05 FILLER               PIC X(80) VALUE ALL '='.
       01  WS-DASH.
           05 FILLER               PIC X(80) VALUE ALL '-'.

       PROCEDURE DIVISION.

       000-MAIN.
           OPEN INPUT LOAN-FILE
           IF WS-FILE-STATUS NOT = '00'
               DISPLAY "Erreur ouverture LOANS.dat: " WS-FILE-STATUS
               STOP RUN
           END-IF
           OPEN INPUT AMORT-FILE
           OPEN OUTPUT RPT-FILE

           MOVE FUNCTION CURRENT-DATE TO WS-DATE-TODAY
           MOVE WS-DATE-TODAY(1:10)   TO WS-RPT-DATE

           PERFORM 100-WRITE-HEADER
           PERFORM 200-LOANS-SUMMARY
           PERFORM 300-WRITE-FOOTER

           CLOSE LOAN-FILE
           CLOSE AMORT-FILE
           CLOSE RPT-FILE
           DISPLAY "Rapport genere: data/LOAN_REPORT.txt"
           STOP RUN.

       100-WRITE-HEADER.
           WRITE RPT-LINE FROM WS-SEPARATOR
           MOVE SPACES TO RPT-LINE
           STRING
               "  LOAN MANAGEMENT SYSTEM - RAPPORT DU "
               WS-RPT-DATE
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-SEPARATOR.

       200-LOANS-SUMMARY.
           MOVE 'N'    TO WS-EOF
           MOVE SPACES TO LN-ID
           START LOAN-FILE KEY >= LN-ID
               INVALID KEY MOVE 'Y' TO WS-EOF
           END-START

           PERFORM UNTIL WS-EOF = 'Y'
               READ LOAN-FILE NEXT
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END
                       PERFORM 210-PROCESS-LOAN
               END-READ
           END-PERFORM

           WRITE RPT-LINE FROM WS-DASH
           MOVE SPACES TO RPT-LINE
           STRING "  TOTAL PRETS         : " WS-COUNT-TOTAL
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE SPACES TO RPT-LINE
           STRING "  En attente          : " WS-COUNT-PENDING
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE SPACES TO RPT-LINE
           STRING "  Approuves           : " WS-COUNT-APPROVED
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE SPACES TO RPT-LINE
           STRING "  Actifs              : " WS-COUNT-ACTIVE
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE SPACES TO RPT-LINE
           STRING "  Clotures            : " WS-COUNT-CLOSED
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE SPACES TO RPT-LINE
           STRING "  Rejetes             : " WS-COUNT-REJECTED
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE WS-SUM-AMOUNT   TO WS-DISP-AMOUNT
           MOVE SPACES TO RPT-LINE
           STRING "  Volume total MGA    : " WS-DISP-AMOUNT
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE

           MOVE WS-SUM-INTEREST TO WS-DISP-AMOUNT
           MOVE SPACES TO RPT-LINE
           STRING "  Total interets MGA  : " WS-DISP-AMOUNT
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE.

       210-PROCESS-LOAN.
           ADD 1 TO WS-COUNT-TOTAL
           ADD LN-AMOUNT TO WS-SUM-AMOUNT
           ADD LN-TOTAL-INTEREST TO WS-SUM-INTEREST

           EVALUATE LN-STATUS
               WHEN 'D' ADD 1 TO WS-COUNT-PENDING
               WHEN 'A' ADD 1 TO WS-COUNT-APPROVED
               WHEN 'E' ADD 1 TO WS-COUNT-ACTIVE
               WHEN 'C' ADD 1 TO WS-COUNT-CLOSED
               WHEN 'R' ADD 1 TO WS-COUNT-REJECTED
           END-EVALUATE

           MOVE LN-AMOUNT         TO WS-DISP-AMOUNT
           MOVE LN-MONTHLY-PAYMENT TO WS-DISP-PMT
           MOVE LN-RATE-ANNUAL    TO WS-DISP-RATE
           WRITE RPT-LINE FROM WS-DASH
           MOVE SPACES TO RPT-LINE
           STRING "  ID: " LN-ID
               "  Client: " LN-CLIENT-NAME(1:30)
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE
           MOVE SPACES TO RPT-LINE
           STRING "  Montant: " WS-DISP-AMOUNT
               "  Taux: " WS-DISP-RATE "%"
               "  Mensualite: " WS-DISP-PMT
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE.

       300-WRITE-FOOTER.
           WRITE RPT-LINE FROM WS-SEPARATOR
           MOVE SPACES TO RPT-LINE
           STRING "  Rapport genere le " WS-RPT-DATE
               " - Loan Management System"
               DELIMITED SIZE INTO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-SEPARATOR.
