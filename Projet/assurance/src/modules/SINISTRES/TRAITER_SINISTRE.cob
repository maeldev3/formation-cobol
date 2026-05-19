       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRAITER-SINISTRE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-SINISTRE ASSIGN TO 'data/input/SINISTRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/input/SINISTRES.TMP'
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
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-SIN         PIC X(10).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-STATUS         PIC X(1).
       
       PROCEDURE DIVISION.
           DISPLAY "=== TRAITER UN SINISTRE ==="
           DISPLAY " "
           DISPLAY "ID SINISTRE : "
           ACCEPT WS-ID-SIN
           DISPLAY "NOUVEAU STATUS (T=Traite,R=Rejete) : "
           ACCEPT WS-STATUS
           
           OPEN INPUT FICHIER-SINISTRE
           OPEN OUTPUT FICHIER-TEMP
           
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-SINISTRE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-SIN = WS-ID-SIN
                           MOVE 'Y' TO WS-TROUVE
                           MOVE WS-STATUS TO STATUS-SIN
                       END-IF
                       MOVE ENR-SINISTRE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-SINISTRE, FICHIER-TEMP
           
           IF WS-TROUVE = 'Y'
               CALL 'SYSTEM' USING 'mv data/input/SINISTRES.TMP data/input/SINISTRES.DAT'
               DISPLAY "Sinistre " WS-ID-SIN " mis a jour (Status: " WS-STATUS ")"
           ELSE
               DISPLAY "Sinistre non trouve"
               CALL 'SYSTEM' USING 'rm data/input/SINISTRES.TMP'
           END-IF
           
           STOP RUN.
