       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHPAY.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENTS ASSIGN TO 'CLIENT.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT RAPPORT  ASSIGN TO 'RAPPORT.TXT'.
           SELECT SYSIN    ASSIGN TO 'CONTROLCARD.TXT'.

       DATA DIVISION.
       FILE SECTION.
       FD CLIENTS.
       01 CLIENT-REC.
          05 CLIENT-ID     PIC 9(4).
          05 FILLER        PIC X(2).
          05 CLIENT-NOM    PIC X(10).
          05 FILLER        PIC X(2).
          05 CLIENT-DU     PIC 9(5)V99.

       FD RAPPORT.
       01 RAPPORT-LINE     PIC X(80).

       FD SYSIN.
       01 CARD-REC.
          05 BATCH-DATE    PIC X(10).
          05 FILLER        PIC X.
          05 BATCH-SEUIL   PIC 9(5)V99.

       WORKING-STORAGE SECTION.
       01 WS-FINISHED      PIC X VALUE 'N'.
          88 WS-EOF               VALUE 'Y'.
       01 WS-TOTAL-PAYE    PIC 9(9)V99 VALUE 0.
       
       01 WS-LINE-OUT.
          05 FILLER        PIC X(5)  VALUE SPACES.
          05 OUT-ID        PIC 9(4).
          05 FILLER        PIC X(5)  VALUE SPACES.
          05 OUT-NOM       PIC X(10).
          05 FILLER        PIC X(5)  VALUE SPACES.
          05 OUT-MONTANT   PIC Z(6)9.99.
          05 FILLER        PIC X(30) VALUE SPACES.
       
       01 WS-TOTAL-LINE.
          05 FILLER        PIC X(5)  VALUE SPACES.
          05 FILLER        PIC X(11) VALUE 'TOTAL PAYE :'.
          05 FILLER        PIC X(5)  VALUE SPACES.
          05 TOT-MONTANT   PIC Z(8)9.99.
          05 FILLER        PIC X(30) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN.
           OPEN INPUT CLIENTS
           OPEN OUTPUT RAPPORT
           OPEN INPUT SYSIN
           
           READ SYSIN INTO CARD-REC
           CLOSE SYSIN
           
           PERFORM UNTIL WS-EOF
               READ CLIENTS INTO CLIENT-REC
               AT END MOVE 'Y' TO WS-FINISHED
               NOT AT END
                   IF CLIENT-DU >= BATCH-SEUIL
                       ADD CLIENT-DU TO WS-TOTAL-PAYE
                       MOVE CLIENT-ID  TO OUT-ID
                       MOVE CLIENT-NOM TO OUT-NOM
                       MOVE CLIENT-DU  TO OUT-MONTANT
                       WRITE RAPPORT-LINE FROM WS-LINE-OUT
                   END-IF
               END-READ
           END-PERFORM
           
           MOVE WS-TOTAL-PAYE TO TOT-MONTANT
           WRITE RAPPORT-LINE FROM WS-TOTAL-LINE
           
           CLOSE CLIENTS
           CLOSE RAPPORT
           STOP RUN.