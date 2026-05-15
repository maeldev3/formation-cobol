       INITIALISATION.
           MOVE ZERO TO WS-CHOIX
           MOVE ZERO TO WS-TEMP-ENTREE
           MOVE ZERO TO WS-TEMP-SORTIE
           SET CONTINUER TO TRUE.
       
       AFFICHER-MENU.
           DISPLAY " "
           DISPLAY "=============================="
           DISPLAY " CONVERTISSEUR TEMPERATURE "
           DISPLAY "=============================="
           DISPLAY "1 - Celsius vers Fahrenheit"
           DISPLAY "2 - Fahrenheit vers Celsius"
           DISPLAY "3 - Quitter"
           DISPLAY "Choix : "
           ACCEPT WS-CHOIX.
       
       TRAITER-CHOIX.
           EVALUATE WS-CHOIX

               WHEN CHOIX-CELSIUS
                    PERFORM CONVERTIR-CELSIUS

               WHEN CHOIX-FAHRENHEIT
                    PERFORM CONVERTIR-FAHRENHEIT

               WHEN CHOIX-QUITTER
                    SET ARRETER TO TRUE

               WHEN OTHER
                    DISPLAY "Choix invalide"

           END-EVALUATE.
       
       CONVERTIR-CELSIUS.
           DISPLAY "Temperature Celsius : "
           ACCEPT WS-TEMP-ENTREE

           COMPUTE WS-TEMP-SORTIE ROUNDED =
               (WS-TEMP-ENTREE * FACTEUR-NEUF / FACTEUR-CINQ)
               + OFFSET-TRENTEDEUX

           PERFORM AFFICHER-RESULTAT-C.
       
       CONVERTIR-FAHRENHEIT.
           DISPLAY "Temperature Fahrenheit : "
           ACCEPT WS-TEMP-ENTREE

           COMPUTE WS-TEMP-SORTIE ROUNDED =
               (WS-TEMP-ENTREE - OFFSET-TRENTEDEUX)
               * FACTEUR-CINQ / FACTEUR-NEUF

           PERFORM AFFICHER-RESULTAT-F.
       
       AFFICHER-RESULTAT-C.
           DISPLAY WS-TEMP-ENTREE " C = "
                   WS-TEMP-SORTIE " F".
       
       AFFICHER-RESULTAT-F.
           DISPLAY WS-TEMP-ENTREE " F = "
                   WS-TEMP-SORTIE " C".