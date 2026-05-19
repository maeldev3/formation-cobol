       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-ECOLE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-NOTE ASSIGN TO 'data/input/NOTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-ETUDIANT ASSIGN TO 'data/input/ETUDIANTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-EVALUATION ASSIGN TO 'data/input/EVALUATIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-RAPPORT ASSIGN TO 'data/output/reports/RAPPORT_ECOLE.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
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
       
       FD FICHIER-EVALUATION.
       01 ENR-EVALUATION.
          05 ID-EVAL         PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-ETU-EVAL     PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-EVAL       PIC X(10).
          05 FILLER          PIC X(1).
          05 MOYENNE-EVAL    PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 MENTION-EVAL    PIC X(1).
       
       FD FICHIER-RAPPORT.
       01 ENR-RAPPORT       PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-DATE            PIC X(10).
       01 WS-FIN-ETU         PIC X VALUE 'N'.
       01 WS-FIN-NOTE        PIC X VALUE 'N'.
       01 WS-TOTAL-NOTES     PIC 9(4)V99.
       01 WS-NB-NOTES        PIC 99.
       01 WS-MOYENNE-ETU     PIC 9(4)V99.
       01 WS-NEW-ID          PIC X(6).
       01 WS-COMPTEUR        PIC 99.
       01 WS-MENTION         PIC X(1).
       
       PROCEDURE DIVISION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           OPEN OUTPUT FICHIER-RAPPORT
           OPEN INPUT FICHIER-ETUDIANT
           
           STRING "RAPPORT ECOLE - " WS-DATE INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           MOVE SPACES TO ENR-RAPPORT
           STRING "================================="
               INTO ENR-RAPPORT
           WRITE ENR-RAPPORT
           
           MOVE 'N' TO WS-FIN-ETU
           PERFORM UNTIL WS-FIN-ETU = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN-ETU
                   NOT AT END
                       MOVE 0 TO WS-TOTAL-NOTES
                       MOVE 0 TO WS-NB-NOTES
                       
                       OPEN INPUT FICHIER-NOTE
                       MOVE 'N' TO WS-FIN-NOTE
                       PERFORM UNTIL WS-FIN-NOTE = 'Y'
                           READ FICHIER-NOTE
                               AT END MOVE 'Y' TO WS-FIN-NOTE
                               NOT AT END
                                   IF ID-ETU-NOTE = ID-ETU
                                       ADD VALEUR-NOTE TO WS-TOTAL-NOTES
                                       ADD 1 TO WS-NB-NOTES
                                   END-IF
                           END-READ
                       END-PERFORM
                       CLOSE FICHIER-NOTE
                       
                       IF WS-NB-NOTES > 0
                           COMPUTE WS-MOYENNE-ETU = 
                               WS-TOTAL-NOTES / WS-NB-NOTES
                               
                           IF WS-MOYENNE-ETU >= 16
                               MOVE 'A' TO WS-MENTION
                           ELSE
                               IF WS-MOYENNE-ETU >= 14
                                   MOVE 'B' TO WS-MENTION
                               ELSE
                                   IF WS-MOYENNE-ETU >= 12
                                       MOVE 'C' TO WS-MENTION
                                   ELSE
                                       IF WS-MOYENNE-ETU >= 10
                                           MOVE 'D' TO WS-MENTION
                                       ELSE
                                           MOVE 'E' TO WS-MENTION
                                       END-IF
                                   END-IF
                               END-IF
                           END-IF
                           
      *> Générer évaluation
                           OPEN EXTEND FICHIER-EVALUATION
                           
                           OPEN INPUT FICHIER-EVALUATION
                           MOVE 1 TO WS-COMPTEUR
                           MOVE 'N' TO WS-FIN-NOTE
                           PERFORM UNTIL WS-FIN-NOTE = 'Y'
                               MOVE WS-COMPTEUR TO WS-NEW-ID(5:2)
                               MOVE 'E' TO WS-NEW-ID(1:1)
                               MOVE 'V' TO WS-NEW-ID(2:1)
                               MOVE '0' TO WS-NEW-ID(3:1)
                               MOVE '0' TO WS-NEW-ID(4:1)
                               READ FICHIER-EVALUATION
                                   AT END MOVE 'Y' TO WS-FIN-NOTE
                                   NOT AT END
                                       IF ID-EVAL = WS-NEW-ID
                                           ADD 1 TO WS-COMPTEUR
                                       END-IF
                           END-PERFORM
                           CLOSE FICHIER-EVALUATION
                           
                           MOVE WS-NEW-ID TO ID-EVAL
                           MOVE ID-ETU TO ID-ETU-EVAL
                           MOVE WS-DATE TO DATE-EVAL
                           MOVE WS-MOYENNE-ETU TO MOYENNE-EVAL
                           MOVE WS-MENTION TO MENTION-EVAL
                           
                           WRITE ENR-EVALUATION
                           CLOSE FICHIER-EVALUATION
                           
                           MOVE SPACES TO ENR-RAPPORT
                           STRING ID-ETU " " NOM-ETU " " PRENOM-ETU
                                   " MOY: " WS-MOYENNE-ETU
                               INTO ENR-RAPPORT
                           WRITE ENR-RAPPORT
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-ETUDIANT, FICHIER-RAPPORT
           
           DISPLAY " "
           DISPLAY "=== BATCH ECOLE TERMINE ==="
           DISPLAY "Rapport: data/output/reports/RAPPORT_ECOLE.rpt"
           DISPLAY "Evaluations: data/input/EVALUATIONS.DAT"
           
           STOP RUN.
