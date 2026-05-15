       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMC.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-POIDS         PIC 9(3).
       01 WS-TAILLE        PIC 9V99.
       01 WS-IMC           PIC 99V99.
       01 WS-CATEGORIE     PIC X(15).
       01 WS-ERREUR        PIC X(1) VALUE 'N'.
           88 OK-VALIDE    VALUE 'N'.
       
       PROCEDURE DIVISION.
           PERFORM 1000-SAISIE
           PERFORM 2000-CALCUL
           PERFORM 3000-AFFICHAGE
           STOP RUN.
       
       1000-SAISIE.
           DISPLAY "=== CALCUL IMC ==="
           DISPLAY "POIDS (kg): " 
           ACCEPT WS-POIDS
           
           IF WS-POIDS < 20 OR WS-POIDS > 300
               DISPLAY "ERREUR: POIDS INVALIDE"
               MOVE 'O' TO WS-ERREUR
           END-IF
           
           DISPLAY "TAILLE (m): "
           ACCEPT WS-TAILLE
           
           IF WS-TAILLE < 0.50 OR WS-TAILLE > 2.50
               DISPLAY "ERREUR: TAILLE INVALIDE"
               MOVE 'O' TO WS-ERREUR
           END-IF
           .
       
       2000-CALCUL.
           IF NOT OK-VALIDE
               COMPUTE WS-IMC = WS-POIDS / (WS-TAILLE * WS-TAILLE)
               
               EVALUATE TRUE
                   WHEN WS-IMC < 18.5
                       MOVE "MAIGREUR" TO WS-CATEGORIE
                   WHEN WS-IMC >= 18.5 AND WS-IMC < 25
                       MOVE "NORMAL" TO WS-CATEGORIE
                   WHEN WS-IMC >= 25 AND WS-IMC < 30
                       MOVE "SURPOIDS" TO WS-CATEGORIE
                   WHEN WS-IMC >= 30 AND WS-IMC < 35
                       MOVE "OBESITE MODEREE" TO WS-CATEGORIE
                   WHEN WS-IMC >= 35
                       MOVE "OBESITE SEVERE" TO WS-CATEGORIE
               END-EVALUATE
           END-IF
           .
       
       3000-AFFICHAGE.
           IF NOT OK-VALIDE
               DISPLAY " "
               DISPLAY "--- RESULTAT ---"
               DISPLAY "IMC: " WS-IMC
               DISPLAY "CATEGORIE: " WS-CATEGORIE
               DISPLAY "INTERPRETATION: "
               EVALUATE WS-CATEGORIE
                   WHEN "MAIGREUR"
                       DISPLAY "Consultation nutritionniste recommandee"
                   WHEN "NORMAL"
                       DISPLAY "Poids sain - Continuez ainsi!"
                   WHEN "SURPOIDS"
                       DISPLAY "Regime equilibre et exercice physique"
                   WHEN "OBESITE MODEREE"
                       DISPLAY "Consultation medicale recommandee"
                   WHEN "OBESITE SEVERE"
                       DISPLAY "Suivi medical obligatoire"
               END-EVALUATE
           ELSE
               DISPLAY "Veuillez relancer le programme"
           END-IF
           .
