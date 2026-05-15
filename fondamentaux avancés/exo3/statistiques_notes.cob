       IDENTIFICATION DIVISION.
       PROGRAM-ID. STATNOTES.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-NB-ETUDIANTS  PIC 9(2) VALUE 5.

       01 WS-ETUDIANTS.
           05 WS-ETU OCCURS 5 TIMES.
               10 WS-NOM    PIC X(20).
               10 WS-NOTE   PIC 9(2)V99.

       01 WS-I             PIC 9(2).
       01 WS-J             PIC 9(2).

       01 WS-SOMME         PIC 9(4)V99 VALUE 0.
       01 WS-MOYENNE       PIC 9(2)V99.
       01 WS-MAX           PIC 9(2)V99 VALUE 0.
       01 WS-MIN           PIC 9(2)V99 VALUE 20.
       01 WS-NB-ADMIS      PIC 9(2) VALUE 0.

       01 WS-NOM-MAXI      PIC X(20).

       * variables de swap (TRI)
       01 WS-TEMP-NOM      PIC X(20).
       01 WS-TEMP-NOTE     PIC 9(2)V99.

       PROCEDURE DIVISION.

           PERFORM 1000-SAISIR-NOTES
           PERFORM 2000-CALCULER-STATS
           PERFORM 3000-AFFICHER-STATS
           PERFORM 4000-AFFICHER-CLASSEMENT
           PERFORM 5000-AJOUTER-APPRECIATIONS

           STOP RUN.

       1000-SAISIR-NOTES.
           DISPLAY "=== SAISIE DES NOTES ==="

           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-NB-ETUDIANTS

               DISPLAY "Etudiant " WS-I
               DISPLAY "Nom: "
               ACCEPT WS-NOM(WS-I)

               PERFORM UNTIL WS-NOTE(WS-I) >= 0 AND WS-NOTE(WS-I) <= 20
                   DISPLAY "Note (0-20): "
                   ACCEPT WS-NOTE(WS-I)
               END-PERFORM

           END-PERFORM
           .

       2000-CALCULER-STATS.
           MOVE 0 TO WS-SOMME WS-NB-ADMIS
           MOVE 0 TO WS-MAX
           MOVE 20 TO WS-MIN

           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-NB-ETUDIANTS

               ADD WS-NOTE(WS-I) TO WS-SOMME

               IF WS-NOTE(WS-I) >= 10
                   ADD 1 TO WS-NB-ADMIS
               END-IF

               IF WS-NOTE(WS-I) > WS-MAX
                   MOVE WS-NOTE(WS-I) TO WS-MAX
                   MOVE WS-NOM(WS-I) TO WS-NOM-MAXI
               END-IF

               IF WS-NOTE(WS-I) < WS-MIN
                   MOVE WS-NOTE(WS-I) TO WS-MIN
               END-IF

           END-PERFORM

           COMPUTE WS-MOYENNE = WS-SOMME / WS-NB-ETUDIANTS
           .

       3000-AFFICHER-STATS.
           DISPLAY " "
           DISPLAY "=== STATISTIQUES ==="
           DISPLAY "Moyenne: " WS-MOYENNE
           DISPLAY "Max: " WS-MAX " (" WS-NOM-MAXI ")"
           DISPLAY "Min: " WS-MIN
           DISPLAY "Reussite: "
               (WS-NB-ADMIS * 100 / WS-NB-ETUDIANTS) " %"
           .

       4000-AFFICHER-CLASSEMENT.
           PERFORM 4100-TRIER-NOTES

           DISPLAY " "
           DISPLAY "=== CLASSEMENT ==="

           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-NB-ETUDIANTS

               DISPLAY WS-I " - "
                       WS-NOM(WS-I)
                       " : "
                       WS-NOTE(WS-I)

           END-PERFORM
           .

       4100-TRIER-NOTES.
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I >= WS-NB-ETUDIANTS

               PERFORM VARYING WS-J FROM WS-I + 1 BY 1
                   UNTIL WS-J > WS-NB-ETUDIANTS

                   IF WS-NOTE(WS-I) < WS-NOTE(WS-J)

                       MOVE WS-NOTE(WS-I) TO WS-TEMP-NOTE
                       MOVE WS-NOM(WS-I) TO WS-TEMP-NOM

                       MOVE WS-NOTE(WS-J) TO WS-NOTE(WS-I)
                       MOVE WS-NOM(WS-J) TO WS-NOM(WS-I)

                       MOVE WS-TEMP-NOTE TO WS-NOTE(WS-J)
                       MOVE WS-TEMP-NOM TO WS-NOM(WS-J)

                   END-IF
               END-PERFORM
           END-PERFORM
           .

       5000-AJOUTER-APPRECIATIONS.
           DISPLAY " "
           DISPLAY "=== APPRECIATIONS ==="

           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-NB-ETUDIANTS

               DISPLAY WS-NOM(WS-I) " : " WS-NOTE(WS-I)

               EVALUATE WS-NOTE(WS-I)
                   WHEN 16 THRU 20
                       DISPLAY "EXCELLENT"
                   WHEN 14 THRU 15
                       DISPLAY "TRES BIEN"
                   WHEN 12 THRU 13
                       DISPLAY "BIEN"
                   WHEN 10 THRU 11
                       DISPLAY "PASSABLE"
                   WHEN OTHER
                       DISPLAY "INSUFFISANT"
               END-EVALUATE

           END-PERFORM
           .
