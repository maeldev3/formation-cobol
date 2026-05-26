       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CARTE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CARTE ASSIGN TO 'data/input/CARTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-CLIENT ASSIGN TO 'data/input/CLIENTS.dat'
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
       
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 NUM-COMPTE     PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-CLI-COMPTE  PIC X(6).
          05 FILLER         PIC X(1).
          05 TYPE-COMPTE    PIC X(10).
          05 FILLER         PIC X(1).
          05 SOLDE-COMPTE   PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DECOUVERT      PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-OUV       PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-COMPTE  PIC X(6).
       
       FD FICHIER-CLIENT.
       01 ENR-CLIENT.
          05 ID-CLIENT      PIC X(6).
          05 FILLER         PIC X(1).
          05 NOM-CLIENT     PIC X(20).
          05 FILLER         PIC X(1).
          05 PRENOM-CLIENT  PIC X(15).
          05 FILLER         PIC X(1).
          05 ADRESSE-CLIENT PIC X(35).
          05 FILLER         PIC X(1).
          05 CP-CLIENT      PIC X(5).
          05 FILLER         PIC X(1).
          05 VILLE-CLIENT   PIC X(20).
          05 FILLER         PIC X(1).
          05 TEL-CLIENT     PIC X(10).
          05 FILLER         PIC X(1).
          05 EMAIL-CLIENT   PIC X(30).
          05 FILLER         PIC X(1).
          05 REVENU-CLIENT  PIC 9(8)V99.
          05 FILLER         PIC X(1).
          05 DATE-OUVERTURE PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-CLIENT  PIC X(7).
          05 FILLER         PIC X(1).
          05 CATEGORIE      PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-ID            PIC X(6).
       01 WS-NUM-COMPTE    PIC X(6).
       01 WS-ID-CLIENT     PIC X(6).
       01 WS-NUMERO        PIC X(16).
       01 WS-CVV           PIC X(3).
       01 WS-DATE-EMIS     PIC X(10).
       01 WS-DATE-VALID    PIC X(10).
       01 WS-PLAFOND       PIC 9(8)V99.
       01 WS-TYPE          PIC X(15).
       01 WS-FIN           PIC X VALUE 'N'.
       01 WS-EXISTE        PIC X VALUE 'N'.
       01 WS-COMPTE-EXISTE PIC X VALUE 'N'.
       01 WS-CLIENT-NOM    PIC X(35).
       01 WS-COUNT         PIC 9(6) VALUE 0.
       01 WS-PLAFOND-EDIT  PIC Z(8)9.99.
       01 WS-REVENU        PIC 9(8)V99.
       01 WS-CATEGORIE-CLIENT PIC X(10).
       
       PROCEDURE DIVISION.
           DISPLAY "=== EMISSION D'UNE NOUVELLE CARTE ==="
           DISPLAY " "
           
           DISPLAY "NUMERO DE COMPTE: "
           ACCEPT WS-NUM-COMPTE
           
      *> Verification compte existe et recuperation client
           OPEN INPUT FICHIER-COMPTE
           MOVE 'N' TO WS-COMPTE-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-COMPTE = WS-NUM-COMPTE
                           MOVE 'Y' TO WS-COMPTE-EXISTE
                           MOVE ID-CLI-COMPTE TO WS-ID-CLIENT
                           MOVE STATUT-COMPTE TO WS-STATUT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COMPTE
           
           IF WS-COMPTE-EXISTE = 'N'
               DISPLAY "ERREUR: Compte inexistant"
               STOP RUN
           END-IF
           
      *> Recuperer infos client pour determiner type carte
           OPEN INPUT FICHIER-CLIENT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CLIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CLIENT = WS-ID-CLIENT
                           MOVE REVENU-CLIENT TO WS-REVENU
                           MOVE CATEGORIE TO WS-CATEGORIE-CLIENT
                           STRING NOM-CLIENT DELIMITED BY SPACE
                                  ' ' DELIMITED BY SIZE
                                  PRENOM-CLIENT DELIMITED BY SPACE
                                  INTO WS-CLIENT-NOM
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CLIENT
           
           DISPLAY "Client: " WS-CLIENT-NOM
           DISPLAY "Categorie: " WS-CATEGORIE-CLIENT
           DISPLAY "Revenu annuel: " WS-REVENU " €"
           DISPLAY " "
           
      *> Proposition du type de carte selon revenu
           DISPLAY "Types de cartes disponibles:"
           DISPLAY "  1. CLASSIC  (Plafond: 1500€) - Revenu minimum: 20000€"
           DISPLAY "  2. GOLD     (Plafond: 3000€) - Revenu minimum: 40000€"
           DISPLAY "  3. PLATINUM (Plafond: 6000€) - Revenu minimum: 70000€"
           DISPLAY "  4. BLACK    (Plafond: 15000€)- Revenu minimum: 120000€"
           DISPLAY " "
           DISPLAY "Votre choix (1-4): "
           ACCEPT WS-TYPE
           
           EVALUATE WS-TYPE
               WHEN "1"
                   MOVE "CLASSIC" TO WS-TYPE
                   MOVE 1500.00 TO WS-PLAFOND
                   IF WS-REVENU < 20000
                       DISPLAY "ERREUR: Revenu insuffisant pour CLASSIC"
                       STOP RUN
                   END-IF
               WHEN "2"
                   MOVE "GOLD" TO WS-TYPE
                   MOVE 3000.00 TO WS-PLAFOND
                   IF WS-REVENU < 40000
                       DISPLAY "ERREUR: Revenu insuffisant pour GOLD"
                       STOP RUN
                   END-IF
               WHEN "3"
                   MOVE "PLATINUM" TO WS-TYPE
                   MOVE 6000.00 TO WS-PLAFOND
                   IF WS-REVENU < 70000
                       DISPLAY "ERREUR: Revenu insuffisant pour PLATINUM"
                       STOP RUN
                   END-IF
               WHEN "4"
                   MOVE "BLACK" TO WS-TYPE
                   MOVE 15000.00 TO WS-PLAFOND
                   IF WS-REVENU < 120000
                       DISPLAY "ERREUR: Revenu insuffisant pour BLACK"
                       STOP RUN
                   END-IF
               WHEN OTHER
                   DISPLAY "ERREUR: Choix invalide"
                   STOP RUN
           END-EVALUATE
           
      *> Generer numero carte (16 chiffres)
           MOVE FUNCTION RANDOM TO WS-NUMERO
           STRING "4975" 
                  FUNCTION NUMVAL(WS-NUMERO(1:12)) 
                  INTO WS-NUMERO
           
           ACCEPT WS-DATE-EMIS FROM DATE YYYYMMDD
           
      *> Date validite (5 ans)
           MOVE WS-DATE-EMIS TO WS-DATE-VALID
           COMPUTE WS-DATE-VALID(1:4) = 
               FUNCTION NUMVAL(WS-DATE-EMIS(1:4)) + 5
           
      *> Generer CVV
           MOVE FUNCTION RANDOM TO WS-CVV
           STRING FUNCTION NUMVAL(WS-CVV(1:3)) INTO WS-CVV
           
      *> Generer ID carte
           OPEN INPUT FICHIER-CARTE
           MOVE 0 TO WS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-CARTE
           
           ADD 1 TO WS-COUNT
           STRING 'CB' WS-COUNT(1:4) INTO WS-ID
           
      *> Ajout carte
           OPEN EXTEND FICHIER-CARTE
           
           MOVE WS-ID TO ID-CARTE
           MOVE WS-NUM-COMPTE TO NUM-COMPTE-C
           MOVE WS-ID-CLIENT TO ID-CLIENT-CARTE
           MOVE WS-NUMERO TO NUMERO-CARTE
           MOVE WS-DATE-VALID(3:4) TO DATE-EXP
           MOVE WS-CVV TO CVV
           MOVE WS-DATE-EMIS TO DATE-EMISSION
           MOVE WS-DATE-VALID TO DATE-VALIDITE
           MOVE "ACTIF" TO STATUT-CARTE
           MOVE WS-PLAFOND TO PLAFOND
           MOVE WS-TYPE TO TYPE-CARTE
           
           WRITE ENR-CARTE
           CLOSE FICHIER-CARTE
           
           MOVE WS-PLAFOND TO WS-PLAFOND-EDIT
           
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "=== CARTE EMISE AVEC SUCCES ==="
           DISPLAY "========================================="
           DISPLAY "ID CARTE    : " WS-ID
           DISPLAY "NUMERO      : " WS-NUMERO
           DISPLAY "TYPE        : " WS-TYPE
           DISPLAY "PLAFOND     : " WS-PLAFOND-EDIT " €"
           DISPLAY "DATE EXP    : " DATE-EXP
           DISPLAY "CVV         : " WS-CVV
           DISPLAY "COMPTE LIE  : " WS-NUM-COMPTE
           DISPLAY "CLIENT      : " WS-CLIENT-NOM
           DISPLAY "========================================="
           
           STOP RUN.
