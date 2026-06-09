      *================================================================
      * BATCH-INIT.CBL - Initialisation donnees de test
      * Cree 20 comptes de demonstration pour le batch
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-INIT.
       AUTHOR. GnuCOBOL-Banking-System.

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

       DATA DIVISION.
       FILE SECTION.

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
       01  WS-ACC-STATUS           PIC XX VALUE SPACES.
       01  WS-TODAY                PIC X(21).
       01  WS-DATE                 PIC X(10).
       01  WS-IDX                  PIC 9(02) VALUE 1.

      *--- Table des comptes de test ---
       01  WS-TEST-ACCOUNTS.
           05 WS-ACCT OCCURS 20 TIMES.
               10 TA-ID     PIC X(12).
               10 TA-CLI    PIC X(10).
               10 TA-NAME   PIC X(40).
               10 TA-TYPE   PIC X(03).
               10 TA-BAL    PIC S9(10)V99.
               10 TA-OVD    PIC S9(08)V99.
               10 TA-FEES   PIC 9(06)V99.
               10 TA-STATUS PIC X(01).

       PROCEDURE DIVISION.

       000-MAIN.
           MOVE FUNCTION CURRENT-DATE TO WS-TODAY
           STRING WS-TODAY(1:4) "-" WS-TODAY(5:2)
               "-" WS-TODAY(7:2)
               DELIMITED SIZE INTO WS-DATE

           OPEN OUTPUT ACCOUNT-FILE
           CLOSE ACCOUNT-FILE
           OPEN I-O ACCOUNT-FILE

           PERFORM 100-POPULATE-TABLE
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > 20
               PERFORM 200-WRITE-ACCOUNT
           END-PERFORM

           CLOSE ACCOUNT-FILE
           DISPLAY "20 comptes de test crees avec succes."
           STOP RUN.

       100-POPULATE-TABLE.
      *--- Comptes courants (CRT) ---
           MOVE "ACC001" TO TA-ID(1)
           MOVE "CLI001" TO TA-CLI(1)
           MOVE "RAKOTO Andry" TO TA-NAME(1)
           MOVE "CRT" TO TA-TYPE(1)
           MOVE 5000000.00 TO TA-BAL(1)
           MOVE 2000000.00 TO TA-OVD(1)
           MOVE 5000.00 TO TA-FEES(1)
           MOVE "A" TO TA-STATUS(1)

           MOVE "ACC002" TO TA-ID(2)
           MOVE "CLI002" TO TA-CLI(2)
           MOVE "RAZAFY Noro" TO TA-NAME(2)
           MOVE "CRT" TO TA-TYPE(2)
           MOVE -250000.00 TO TA-BAL(2)
           MOVE 500000.00 TO TA-OVD(2)
           MOVE 5000.00 TO TA-FEES(2)
           MOVE "A" TO TA-STATUS(2)

           MOVE "ACC003" TO TA-ID(3)
           MOVE "CLI003" TO TA-CLI(3)
           MOVE "RAMAROLAHY Haja" TO TA-NAME(3)
           MOVE "CRT" TO TA-TYPE(3)
           MOVE 850000.00 TO TA-BAL(3)
           MOVE 300000.00 TO TA-OVD(3)
           MOVE 5000.00 TO TA-FEES(3)
           MOVE "A" TO TA-STATUS(3)

           MOVE "ACC004" TO TA-ID(4)
           MOVE "CLI004" TO TA-CLI(4)
           MOVE "RANDRIA Fara" TO TA-NAME(4)
           MOVE "CRT" TO TA-TYPE(4)
           MOVE 125000.00 TO TA-BAL(4)
           MOVE 200000.00 TO TA-OVD(4)
           MOVE 5000.00 TO TA-FEES(4)
           MOVE "A" TO TA-STATUS(4)

           MOVE "ACC005" TO TA-ID(5)
           MOVE "CLI005" TO TA-CLI(5)
           MOVE "RASOLOFONIRINA Jean" TO TA-NAME(5)
           MOVE "CRT" TO TA-TYPE(5)
           MOVE -1200000.00 TO TA-BAL(5)
           MOVE 1500000.00 TO TA-OVD(5)
           MOVE 5000.00 TO TA-FEES(5)
           MOVE "A" TO TA-STATUS(5)

      *--- Comptes epargne (EPG) ---
           MOVE "ACC006" TO TA-ID(6)
           MOVE "CLI006" TO TA-CLI(6)
           MOVE "ANDRIAMANA Marie" TO TA-NAME(6)
           MOVE "EPG" TO TA-TYPE(6)
           MOVE 12000000.00 TO TA-BAL(6)
           MOVE 0.00 TO TA-OVD(6)
           MOVE 0.00 TO TA-FEES(6)
           MOVE "A" TO TA-STATUS(6)

           MOVE "ACC007" TO TA-ID(7)
           MOVE "CLI007" TO TA-CLI(7)
           MOVE "RATSIMBAZAFY Lova" TO TA-NAME(7)
           MOVE "EPG" TO TA-TYPE(7)
           MOVE 3500000.00 TO TA-BAL(7)
           MOVE 0.00 TO TA-OVD(7)
           MOVE 0.00 TO TA-FEES(7)
           MOVE "A" TO TA-STATUS(7)

           MOVE "ACC008" TO TA-ID(8)
           MOVE "CLI008" TO TA-CLI(8)
           MOVE "RAZANADRAKOTO Paul" TO TA-NAME(8)
           MOVE "EPG" TO TA-TYPE(8)
           MOVE 7800000.00 TO TA-BAL(8)
           MOVE 0.00 TO TA-OVD(8)
           MOVE 0.00 TO TA-FEES(8)
           MOVE "A" TO TA-STATUS(8)

           MOVE "ACC009" TO TA-ID(9)
           MOVE "CLI009" TO TA-CLI(9)
           MOVE "ANDRIATSARA Zo" TO TA-NAME(9)
           MOVE "EPG" TO TA-TYPE(9)
           MOVE 450000.00 TO TA-BAL(9)
           MOVE 0.00 TO TA-OVD(9)
           MOVE 0.00 TO TA-FEES(9)
           MOVE "A" TO TA-STATUS(9)

           MOVE "ACC010" TO TA-ID(10)
           MOVE "CLI010" TO TA-CLI(10)
           MOVE "RAKOTONDRABE Soa" TO TA-NAME(10)
           MOVE "EPG" TO TA-TYPE(10)
           MOVE 22000000.00 TO TA-BAL(10)
           MOVE 0.00 TO TA-OVD(10)
           MOVE 0.00 TO TA-FEES(10)
           MOVE "A" TO TA-STATUS(10)

      *--- Comptes professionnels (PRO) ---
           MOVE "ACC011" TO TA-ID(11)
           MOVE "CLI011" TO TA-CLI(11)
           MOVE "MADAGASCAR SARL" TO TA-NAME(11)
           MOVE "PRO" TO TA-TYPE(11)
           MOVE 45000000.00 TO TA-BAL(11)
           MOVE 10000000.00 TO TA-OVD(11)
           MOVE 15000.00 TO TA-FEES(11)
           MOVE "A" TO TA-STATUS(11)

           MOVE "ACC012" TO TA-ID(12)
           MOVE "CLI012" TO TA-CLI(12)
           MOVE "IMPORT EXPORT MADA" TO TA-NAME(12)
           MOVE "PRO" TO TA-TYPE(12)
           MOVE 8500000.00 TO TA-BAL(12)
           MOVE 5000000.00 TO TA-OVD(12)
           MOVE 15000.00 TO TA-FEES(12)
           MOVE "A" TO TA-STATUS(12)

           MOVE "ACC013" TO TA-ID(13)
           MOVE "CLI013" TO TA-CLI(13)
           MOVE "HOTELI NY ANTSIKA" TO TA-NAME(13)
           MOVE "PRO" TO TA-TYPE(13)
           MOVE -3200000.00 TO TA-BAL(13)
           MOVE 5000000.00 TO TA-OVD(13)
           MOVE 15000.00 TO TA-FEES(13)
           MOVE "A" TO TA-STATUS(13)

           MOVE "ACC014" TO TA-ID(14)
           MOVE "CLI014" TO TA-CLI(14)
           MOVE "TAXI-BROUSSE EXPRESS" TO TA-NAME(14)
           MOVE "PRO" TO TA-TYPE(14)
           MOVE 2100000.00 TO TA-BAL(14)
           MOVE 1000000.00 TO TA-OVD(14)
           MOVE 15000.00 TO TA-FEES(14)
           MOVE "A" TO TA-STATUS(14)

           MOVE "ACC015" TO TA-ID(15)
           MOVE "CLI015" TO TA-CLI(15)
           MOVE "ARTISANAT MALGACHE" TO TA-NAME(15)
           MOVE "PRO" TO TA-TYPE(15)
           MOVE 980000.00 TO TA-BAL(15)
           MOVE 500000.00 TO TA-OVD(15)
           MOVE 15000.00 TO TA-FEES(15)
           MOVE "A" TO TA-STATUS(15)

      *--- Comptes speciaux / edge cases ---
           MOVE "ACC016" TO TA-ID(16)
           MOVE "CLI016" TO TA-CLI(16)
           MOVE "RANAIVO Seheno" TO TA-NAME(16)
           MOVE "CRT" TO TA-TYPE(16)
           MOVE 0.00 TO TA-BAL(16)
           MOVE 100000.00 TO TA-OVD(16)
           MOVE 5000.00 TO TA-FEES(16)
           MOVE "A" TO TA-STATUS(16)

           MOVE "ACC017" TO TA-ID(17)
           MOVE "CLI017" TO TA-CLI(17)
           MOVE "COMPTE BLOQUE TEST" TO TA-NAME(17)
           MOVE "CRT" TO TA-TYPE(17)
           MOVE 500000.00 TO TA-BAL(17)
           MOVE 0.00 TO TA-OVD(17)
           MOVE 5000.00 TO TA-FEES(17)
           MOVE "B" TO TA-STATUS(17)

           MOVE "ACC018" TO TA-ID(18)
           MOVE "CLI018" TO TA-CLI(18)
           MOVE "RASAMIMANANA Bodo" TO TA-NAME(18)
           MOVE "EPG" TO TA-TYPE(18)
           MOVE 600000.00 TO TA-BAL(18)
           MOVE 0.00 TO TA-OVD(18)
           MOVE 0.00 TO TA-FEES(18)
           MOVE "A" TO TA-STATUS(18)

           MOVE "ACC019" TO TA-ID(19)
           MOVE "CLI019" TO TA-CLI(19)
           MOVE "TECH DIGITAL MADA" TO TA-NAME(19)
           MOVE "PRO" TO TA-TYPE(19)
           MOVE 15600000.00 TO TA-BAL(19)
           MOVE 3000000.00 TO TA-OVD(19)
           MOVE 15000.00 TO TA-FEES(19)
           MOVE "A" TO TA-STATUS(19)

           MOVE "ACC020" TO TA-ID(20)
           MOVE "CLI020" TO TA-CLI(20)
           MOVE "RAZAFY Tiana" TO TA-NAME(20)
           MOVE "EPG" TO TA-TYPE(20)
           MOVE 100000.00 TO TA-BAL(20)
           MOVE 0.00 TO TA-OVD(20)
           MOVE 0.00 TO TA-FEES(20)
           MOVE "A" TO TA-STATUS(20).

       200-WRITE-ACCOUNT.
           MOVE TA-ID(WS-IDX)     TO AC-ID
           MOVE TA-CLI(WS-IDX)    TO AC-CLIENT-ID
           MOVE TA-NAME(WS-IDX)   TO AC-CLIENT-NAME
           MOVE TA-TYPE(WS-IDX)   TO AC-TYPE
           MOVE TA-BAL(WS-IDX)    TO AC-BALANCE
           MOVE TA-OVD(WS-IDX)    TO AC-OVERDRAFT-LIMIT
           MOVE TA-FEES(WS-IDX)   TO AC-MONTHLY-FEES
           MOVE TA-STATUS(WS-IDX) TO AC-STATUS
           MOVE SPACES            TO AC-LAST-BATCH-DATE
           MOVE 0                 TO AC-LAST-INTEREST
           MOVE 0                 TO AC-LAST-FEE
           MOVE WS-DATE           TO AC-OPEN-DATE
           EVALUATE TA-TYPE(WS-IDX)
               WHEN "EPG"
                   MOVE 3.50 TO AC-INTEREST-RATE
               WHEN OTHER
                   MOVE 0.00 TO AC-INTEREST-RATE
           END-EVALUATE
           WRITE ACCOUNT-RECORD
           IF WS-ACC-STATUS NOT = '00'
               DISPLAY "Erreur compte " TA-ID(WS-IDX)
                   ": " WS-ACC-STATUS
           END-IF.
