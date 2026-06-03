       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHE-CREDIT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CREDIT ASSIGN TO 'data/input/CREDITS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CREDIT.
       01 ENR-CREDIT.
          05 ID-CREDIT       PIC X(6).
          05 FILLER          PIC X(1).
          05 NUM-COMPTE      PIC X(6).
          05 FILLER          PIC X(1).
          05 MONTANT         PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 TAUX            PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DUREE           PIC 9(5).
          05 FILLER          PIC X(1).
          05 MENSUALITE      PIC 9(9)V99.
          05 FILLER          PIC X(1).
          05 DATE-DEBUT      PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT          PIC X(3).
       
       WORKING-STORAGE SECTION.
       01 WS-NUM-COMPTE      PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-MONTANT-AFF     PIC Z(9)9.99.
       01 WS-MENSUALITE-AFF  PIC Z(9)9.99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RECHERCHE CREDIT ==="
           DISPLAY " "
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           DISPLAY " "
           
           OPEN INPUT FICHIER-CREDIT
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           DISPLAY "Credits pour le compte " WS-NUM-COMPTE ":"
           DISPLAY ""
           DISPLAY "ID      MONTANT    TAUX  DUREE MENSUALITE  DATE       STATUT"
           DISPLAY "------  ---------- ----  ----- ----------  ---------- -----"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CREDIT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-TROUVE
                           MOVE MONTANT TO WS-MONTANT-AFF
                           MOVE MENSUALITE TO WS-MENSUALITE-AFF
                           DISPLAY ID-CREDIT " "
                                   WS-MONTANT-AFF " "
                                   TAUX "   "
                                   DUREE "   "
                                   WS-MENSUALITE-AFF " "
                                   DATE-DEBUT " "
                                   STATUT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CREDIT
           
           IF WS-TROUVE = 'N'
               DISPLAY "Aucun credit trouve pour ce compte"
           END-IF
           
           STOP RUN.