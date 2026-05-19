       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-SINISTRES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-SINISTRE ASSIGN TO 'data/input/SINISTRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-SINISTRE.
       01 ENR-SINISTRE.
          05 ID-SIN          PIC X(10).
          05 FILLER          PIC X(1).
          05 NUM-CONTRAT     PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-SIN        PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-SIN     PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 STATUS-SIN      PIC X(1).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-SINISTRE
           
           DISPLAY " "
           DISPLAY "=== LISTE DES SINISTRES ==="
           DISPLAY "ID           CONTRAT     DATE       MONTANT   STATUS"
           DISPLAY "-----------------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-SINISTRE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY ID-SIN " " NUM-CONTRAT " " 
                               DATE-SIN " " MONTANT-SIN "   " STATUS-SIN
               END-READ
           END-PERFORM
           
           DISPLAY "-----------------------------------------------------"
           DISPLAY "TOTAL SINISTRES: " WS-COMPTEUR
           
           CLOSE FICHIER-SINISTRE
           
           STOP RUN.
