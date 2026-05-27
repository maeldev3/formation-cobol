       IDENTIFICATION DIVISION.
       PROGRAM-ID. BLOQUER-CARTE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CARTE ASSIGN TO 'data/input/CARTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/temp/CARTES.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CARTE.
       01 ENR-CARTE.
          05 ID-CARTE       PIC X(6).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE-C   PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-CLIENT-CARTE PIC X(6).
          05 FILLER         PIC X(1).
          05 NUMERO-CARTE   PIC X(16).
          05 FILLER         PIC X(1).
          05 DATE-EXP       PIC X(4).
          05 FILLER         PIC X(1).
          05 CVV            PIC X(3).
          05 FILLER         PIC X(1).
          05 DATE-EMISSION  PIC X(10).
          05 FILLER         PIC X(1).
          05 DATE-VALIDITE  PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CARTE   PIC X(6).
          05 FILLER         PIC X(1).
          05 PLAFOND        PIC 9(8)V99.
          05 FILLER         PIC X(1).
          05 TYPE-CARTE     PIC X(15).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP         PIC X(100).
       
       WORKING-STORAGE SECTION.
       01 WS-ID            PIC X(6).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-TROUVE        PIC X VALUE 'N'.
       01 WS-OLD-STATUT    PIC X(6).
       
       PROCEDURE DIVISION.
           DISPLAY "=== BLOQUER/DEBLOQUER UNE CARTE ==="
           DISPLAY " "
           DISPLAY "ID CARTE: "
           ACCEPT WS-ID
           
           OPEN INPUT FICHIER-CARTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CARTE = WS-ID
                           MOVE 'Y' TO WS-TROUVE
                           MOVE STATUT-CARTE TO WS-OLD-STATUT
                           IF STATUT-CARTE = "ACTIF"
                               MOVE "BLOQUE" TO STATUT-CARTE
                               DISPLAY "Carte bloquee avec succes"
                           ELSE
                               MOVE "ACTIF" TO STATUT-CARTE
                               DISPLAY "Carte debloquee avec succes"
                           END-IF
                       END-IF
                       MOVE ENR-CARTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-CARTE, FICHIER-TEMP
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Carte non trouvee"
               STOP RUN
           END-IF
           
           CALL 'SYSTEM' USING 
               'mv data/temp/CARTES.TMP data/input/CARTES.dat'
           
           DISPLAY "Nouveau statut: " STATUT-CARTE
           
           STOP RUN.
