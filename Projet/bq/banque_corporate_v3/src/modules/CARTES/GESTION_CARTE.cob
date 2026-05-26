       IDENTIFICATION DIVISION.
       PROGRAM-ID. GESTION-CARTE.
       
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
       01 WS-ACTION        PIC X(1).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-TROUVE        PIC X VALUE 'N'.
       01 WS-OLD-STATUT    PIC X(6).
       01 WS-NUMERO-CARTE  PIC X(16).
       01 WS-TYPE-CARTE    PIC X(15).
       
       PROCEDURE DIVISION.
           DISPLAY "========================================="
           DISPLAY "=== GESTION DES CARTES ==="
           DISPLAY "========================================="
           DISPLAY " "
           DISPLAY "1. Blocker une carte"
           DISPLAY "2. Debloquer une carte"
           DISPLAY "3. Modifier plafond"
           DISPLAY " "
           DISPLAY "Votre choix: "
           ACCEPT WS-ACTION
           
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
                           MOVE NUMERO-CARTE TO WS-NUMERO-CARTE
                           MOVE TYPE-CARTE TO WS-TYPE-CARTE
                           
                           EVALUATE WS-ACTION
                               WHEN "1"
                                   IF STATUT-CARTE = "ACTIF"
                                       MOVE "BLOQUE" TO STATUT-CARTE
                                       DISPLAY " "
                                       DISPLAY "*** CARTE BLOQUEE AVEC SUCCES ***"
                                   ELSE
                                       DISPLAY " "
                                       DISPLAY "ERREUR: Carte deja bloquee"
                                   END-IF
                               WHEN "2"
                                   IF STATUT-CARTE = "BLOQUE"
                                       MOVE "ACTIF" TO STATUT-CARTE
                                       DISPLAY " "
                                       DISPLAY "*** CARTE DEBLOQUEE AVEC SUCCES ***"
                                   ELSE
                                       DISPLAY " "
                                       DISPLAY "ERREUR: Carte n'est pas bloquee"
                                   END-IF
                               WHEN "3"
                                   DISPLAY "NOUVEAU PLAFOND: "
                                   ACCEPT PLAFOND
                                   DISPLAY " "
                                   DISPLAY "*** PLAFOND MODIFIE AVEC SUCCES ***"
                               WHEN OTHER
                                   DISPLAY "ACTION INVALIDE"
                           END-EVALUATE
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
           
           IF WS-TROUVE = 'Y' AND WS-ACTION = "1" OR "2"
               DISPLAY " "
               DISPLAY "========================================="
               DISPLAY "NUMERO CARTE: " WS-NUMERO-CARTE
               DISPLAY "TYPE        : " WS-TYPE-CARTE
               DISPLAY "NOUVEAU STATUT: " STATUT-CARTE
               DISPLAY "========================================="
           END-IF
           
           STOP RUN.
