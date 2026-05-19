       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHPAY.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-IN ASSIGN TO 'INPUT.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-OUT ASSIGN TO 'OUTPUT.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-IN.
       01 ENR-IN.
          05 CLIENT-IN     PIC X(10).
          05 MONTANT-IN    PIC 9(8).
       FD FICHIER-OUT.
       01 ENR-OUT.
          05 CLIENT-OUT    PIC X(10).
          05 MONTANT-OUT   PIC 9(8).
       WORKING-STORAGE SECTION.
       01 WS-FIN           PIC X(1) VALUE 'N'.
           88 FIN-VRAI     VALUE 'Y'.
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-IN
           OPEN OUTPUT FICHIER-OUT
           PERFORM UNTIL FIN-VRAI
               READ FICHIER-IN
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF MONTANT-IN > 1000
                           MOVE CLIENT-IN TO CLIENT-OUT
                           MOVE MONTANT-IN TO MONTANT-OUT
                           WRITE ENR-OUT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-IN, FICHIER-OUT
           STOP RUN.