       INITIALISATION.
           MOVE SPACES TO WS-CATEGORIE
           MOVE ZERO TO WS-IMC
           MOVE 'N' TO WS-ERREUR.
       
       SAISIE-DONNEES.
           DISPLAY "=========================="
           DISPLAY " CALCULATEUR IMC "
           DISPLAY "=========================="

           PERFORM SAISIE-POIDS
           PERFORM SAISIE-TAILLE.
       
       SAISIE-POIDS.
           DISPLAY "POIDS (kg) : "
           ACCEPT WS-POIDS

           IF WS-POIDS < LIMITE-POIDS-MIN
              OR WS-POIDS > LIMITE-POIDS-MAX
               DISPLAY "ERREUR : POIDS INVALIDE"
               SET DONNEE-INVALIDE TO TRUE
           END-IF.
       
       SAISIE-TAILLE.
           DISPLAY "TAILLE (m) : "
           ACCEPT WS-TAILLE

           IF WS-TAILLE < LIMITE-TAILLE-MIN
              OR WS-TAILLE > LIMITE-TAILLE-MAX
               DISPLAY "ERREUR : TAILLE INVALIDE"
               SET DONNEE-INVALIDE TO TRUE
           END-IF.
       
       CALCUL-IMC.
           IF DONNEE-VALIDE
               COMPUTE WS-IMC ROUNDED =
                       WS-POIDS / (WS-TAILLE * WS-TAILLE)

               PERFORM DETERMINER-CATEGORIE
           END-IF.
       
       DETERMINER-CATEGORIE.
           EVALUATE TRUE

               WHEN WS-IMC < IMC-MAIGREUR
                    MOVE "MAIGREUR" TO WS-CATEGORIE

               WHEN WS-IMC < IMC-NORMAL
                    MOVE "NORMAL" TO WS-CATEGORIE

               WHEN WS-IMC < IMC-SURPOIDS
                    MOVE "SURPOIDS" TO WS-CATEGORIE

               WHEN WS-IMC < IMC-OBESITE
                    MOVE "OBESITE MODEREE" TO WS-CATEGORIE

               WHEN OTHER
                    MOVE "OBESITE SEVERE" TO WS-CATEGORIE

           END-EVALUATE.
       
       AFFICHAGE-RESULTAT.
           IF DONNEE-INVALIDE
               DISPLAY " "
               DISPLAY "PROGRAMME TERMINE AVEC ERREUR"
           ELSE
               PERFORM AFFICHER-DETAIL
           END-IF.
       
       AFFICHER-DETAIL.
           DISPLAY " "
           DISPLAY "===== RESULTAT ====="
           DISPLAY "IMC       : " WS-IMC
           DISPLAY "CATEGORIE : " WS-CATEGORIE

           PERFORM AFFICHER-CONSEIL.
       
       AFFICHER-CONSEIL.
           EVALUATE WS-CATEGORIE

               WHEN "MAIGREUR"
                    DISPLAY "Conseil : Nutritionniste"

               WHEN "NORMAL"
                    DISPLAY "Conseil : Bon equilibre"

               WHEN "SURPOIDS"
                    DISPLAY "Conseil : Sport conseille"

               WHEN "OBESITE MODEREE"
                    DISPLAY "Conseil : Suivi medical"

               WHEN "OBESITE SEVERE"
                    DISPLAY "Conseil : Consultation urgente"

           END-EVALUATE.