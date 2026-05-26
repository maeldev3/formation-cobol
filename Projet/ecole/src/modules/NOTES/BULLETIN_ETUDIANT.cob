       IDENTIFICATION DIVISION.
       PROGRAM-ID. BULLETIN-ETUDIANT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-NOTE ASSIGN TO 'data/input/NOTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-ETUDIANT ASSIGN TO 'data/input/ETUDIANTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COURS ASSIGN TO 'data/input/COURS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-BULLETIN ASSIGN TO 'data/output/reports/BULLETIN.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-ETUDIANT.
       01 ENR-ETUDIANT.
          05 ID-ETU          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-ETU         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-ETU      PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-NAISS      PIC X(10).
          05 FILLER          PIC X(1).
          05 CLASSE-ETU      PIC X(3).
       
       FD FICHIER-COURS.
       01 ENR-COURS.
          05 ID-COURS        PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-COURS       PIC X(30).
          05 FILLER          PIC X(1).
          05 COEFFICIENT     PIC 9.
       
       FD FICHIER-NOTE.
       01 ENR-NOTE.
          05 ID-NOTE         PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-ETU-NOTE     PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-COURS-NOTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 VALEUR-NOTE     PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DATE-NOTE       PIC X(10).
       
       FD FICHIER-BULLETIN.
       01 ENR-BULLETIN       PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-RECH         PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-FIN-COURS       PIC X VALUE 'N'.
       01 WS-FIN-NOTE        PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-NOM-ETUDIANT    PIC X(25).
       01 WS-CLASSE          PIC X(3).
       01 WS-TOTAL-POND      PIC 9(6)V99 VALUE 0.
       01 WS-TOTAL-COEFF     PIC 9(3) VALUE 0.
       01 WS-MOYENNE         PIC 9(4)V99 VALUE 0.
       01 WS-MENTION         PIC X(10).
       01 WS-NOTE-TROUVEE    PIC X VALUE 'N'.
       01 WS-TEMP-POND       PIC 9(6)V99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== BULLETIN SCOLAIRE ==="
           DISPLAY " "
           DISPLAY "ID ETUDIANT: "
           ACCEPT WS-ID-RECH
           
      *> Trouver l'étudiant
           OPEN INPUT FICHIER-ETUDIANT
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ETU = WS-ID-RECH
                           MOVE 'Y' TO WS-TROUVE
                           STRING NOM-ETU DELIMITED BY SPACE
                                  ' ' DELIMITED BY SIZE
                                  PRENOM-ETU DELIMITED BY SPACE
                                  INTO WS-NOM-ETUDIANT
                           MOVE CLASSE-ETU TO WS-CLASSE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-ETUDIANT
           
           IF WS-TROUVE = 'N'
               DISPLAY "Etudiant non trouve"
               STOP RUN
           END-IF
           
           OPEN OUTPUT FICHIER-BULLETIN
           
      *> En-tête bulletin
           MOVE SPACES TO ENR-BULLETIN
           STRING "========================================="
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "BULLETIN SCOLAIRE - " 
                  WS-NOM-ETUDIANT(1:25)
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "CLASSE: " WS-CLASSE
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "========================================="
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "MATIERE                       NOTE   COEFF"
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "-----------------------------------------"
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
      *> Calcul des notes - Parcours des cours
           OPEN INPUT FICHIER-COURS
           MOVE 0 TO WS-TOTAL-POND
           MOVE 0 TO WS-TOTAL-COEFF
           MOVE 'N' TO WS-FIN-COURS
           
           PERFORM UNTIL WS-FIN-COURS = 'Y'
               READ FICHIER-COURS
                   AT END MOVE 'Y' TO WS-FIN-COURS
                   NOT AT END
      *> Chercher la note pour ce cours
                       MOVE 'N' TO WS-NOTE-TROUVEE
                       MOVE 'N' TO WS-FIN-NOTE
                       OPEN INPUT FICHIER-NOTE
                       PERFORM UNTIL WS-FIN-NOTE = 'Y'
                           READ FICHIER-NOTE
                               AT END MOVE 'Y' TO WS-FIN-NOTE
                               NOT AT END
                                   IF ID-ETU-NOTE = WS-ID-RECH AND
                                      ID-COURS-NOTE = ID-COURS
                                       MOVE 'Y' TO WS-NOTE-TROUVEE
                                       COMPUTE WS-TEMP-POND = 
                                           VALEUR-NOTE * COEFFICIENT
                                       ADD WS-TEMP-POND TO WS-TOTAL-POND
                                       ADD COEFFICIENT TO WS-TOTAL-COEFF
      *> Afficher la ligne dans le bulletin
                                       MOVE SPACES TO ENR-BULLETIN
                                       STRING 
                                           NOM-COURS(1:25) 
                                           SPACE
                                           VALEUR-NOTE(1:4)
                                           "    "
                                           COEFFICIENT
                                           INTO ENR-BULLETIN
                                       WRITE ENR-BULLETIN
                                       DISPLAY NOM-COURS(1:25) 
                                               " - Note: " VALEUR-NOTE
                                               " Coeff: " COEFFICIENT
                                   END-IF
                               END-READ
                       END-PERFORM
                       CLOSE FICHIER-NOTE
                       IF WS-NOTE-TROUVEE = 'N'
                           MOVE SPACES TO ENR-BULLETIN
                           STRING 
                               NOM-COURS(1:25)
                               "    -      "
                               COEFFICIENT
                               INTO ENR-BULLETIN
                           WRITE ENR-BULLETIN
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COURS
           
      *> Calcul moyenne et mention
           IF WS-TOTAL-COEFF > 0 THEN
               COMPUTE WS-MOYENNE = WS-TOTAL-POND / WS-TOTAL-COEFF
           ELSE
               MOVE 0 TO WS-MOYENNE
           END-IF
           
           EVALUATE WS-MOYENNE
               WHEN >= 16
                   MOVE 'TRES BIEN' TO WS-MENTION
               WHEN >= 14
                   MOVE 'BIEN' TO WS-MENTION
               WHEN >= 12
                   MOVE 'ASSEZ BIEN' TO WS-MENTION
               WHEN >= 10
                   MOVE 'PASSABLE' TO WS-MENTION
               WHEN OTHER
                   MOVE 'INSUFFISANT' TO WS-MENTION
           END-EVALUATE
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "========================================="
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "MOYENNE GENERALE: " 
                  WS-MOYENNE "/20"
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "MENTION: " WS-MENTION
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           MOVE SPACES TO ENR-BULLETIN
           STRING "========================================="
               INTO ENR-BULLETIN
           WRITE ENR-BULLETIN
           
           CLOSE FICHIER-BULLETIN
           
           DISPLAY " "
           DISPLAY "--- BULLETIN GENERE ---"
           DISPLAY "MOYENNE: " WS-MOYENNE "/20"
           DISPLAY "MENTION: " WS-MENTION
           DISPLAY "FICHIER: data/output/reports/BULLETIN.rpt"
           
           STOP RUN.