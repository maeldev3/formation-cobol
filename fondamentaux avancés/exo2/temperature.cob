       IDENTIFICATION DIVISION.
       PROGRAM-ID. TEMP.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX         PIC 9.
       01 WS-TEMP-ENTREE   PIC 9(4)V99.
       01 WS-TEMP-SORTIE   PIC 9(4)V99.
       01 WS-FIN           PIC X(1) VALUE 'N'.
           88 CONTINUER    VALUE 'N'.
           88 ARRETER      VALUE 'O'.
       
       PROCEDURE DIVISION.
           PERFORM UNTIL ARRETER
               PERFORM 1000-MENU
               PERFORM 2000-TRAITER
           END-PERFORM
           DISPLAY "MERCI ET A BIENTOT!"
           STOP RUN.
       
       1000-MENU.
           DISPLAY " "
           DISPLAY "=== CONVERTISSEUR TEMPERATURE ==="
           DISPLAY "1. Celsius -> Fahrenheit"
           DISPLAY "2. Fahrenheit -> Celsius"
           DISPLAY "3. Quitter"
           DISPLAY "Votre choix: "
           ACCEPT WS-CHOIX
           .
       
       2000-TRAITER.
           EVALUATE WS-CHOIX
               WHEN 1
                   PERFORM 2100-CELSIUS-VERS-FAHRENHEIT
               WHEN 2
                   PERFORM 2200-FAHRENHEIT-VERS-CELSIUS
               WHEN 3
                   MOVE 'O' TO WS-FIN
               WHEN OTHER
                   DISPLAY "Choix invalide!"
           END-EVALUATE
           .
       
       2100-CELSIUS-VERS-FAHRENHEIT.
           DISPLAY "Temperature en Celsius: "
           ACCEPT WS-TEMP-ENTREE
           COMPUTE WS-TEMP-SORTIE = (WS-TEMP-ENTREE * 9 / 5) + 32
           DISPLAY WS-TEMP-ENTREE "°C = " WS-TEMP-SORTIE "°F"
           .
       
       2200-FAHRENHEIT-VERS-CELSIUS.
           DISPLAY "Temperature en Fahrenheit: "
           ACCEPT WS-TEMP-ENTREE
           COMPUTE WS-TEMP-SORTIE = (WS-TEMP-ENTREE - 32) * 5 / 9
           DISPLAY WS-TEMP-ENTREE "°F = " WS-TEMP-SORTIE "°C"
           .
