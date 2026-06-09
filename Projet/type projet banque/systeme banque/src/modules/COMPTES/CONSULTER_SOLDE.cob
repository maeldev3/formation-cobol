       IDENTIFICATION DIVISION.
       PROGRAM-ID. CONSULTER-SOLDE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CLIENT-C     PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-COMPTE     PIC X(4).
          05 FILLER          PIC X(1).
          05 SOLDE-COMPTE    PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 DATE-OUV-COMP   PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-NUM-RECH        PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-SOLDE           PIC 9(9)V99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== CONSULTER SOLDE ==="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-RECH
           
           OPEN INPUT FICHIER-COMPTE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-RECH
                           MOVE 'Y' TO WS-TROUVE
                           MOVE SOLDE-COMPTE TO WS-SOLDE
                           DISPLAY " "
                           DISPLAY "--- SOLDE DU COMPTE ---"
                           DISPLAY "NUMERO  : " NUM-COMPTE
                           DISPLAY "TYPE    : " TYPE-COMPTE
                           DISPLAY "SOLDE   : " WS-SOLDE " €"
                           DISPLAY "DATE    : " DATE-OUV-COMP
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-TROUVE = 'N'
               DISPLAY "Compte non trouve"
           END-IF
           
           CLOSE FICHIER-COMPTE
           
           STOP RUN.
