       IDENTIFICATION DIVISION.
       PROGRAM-ID. TABLE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-NOMBRE       PIC 99.
       01 WS-I            PIC 99.
       01 WS-RESULTAT     PIC 9999.
       01 WS-QUITTER      PIC X VALUE 'N'.
       01 WS-CHOIX        PIC X.

       PROCEDURE DIVISION.

           PERFORM UNTIL WS-QUITTER = 'O'
               DISPLAY "1. AFFICHER TABLE"
               DISPLAY "2. QUITTER"
               ACCEPT WS-CHOIX

               IF WS-CHOIX = '1'
                   PERFORM CALCUL-TABLE
               ELSE
                   IF WS-CHOIX = '2'
                       MOVE 'O' TO WS-QUITTER
                   END-IF
               END-IF
           END-PERFORM

           STOP RUN.

       CALCUL-TABLE.
           DISPLAY "TABLE DE MULTIPLICATION"
           DISPLAY "ENTREZ UN NOMBRE (1-10): "
           ACCEPT WS-NOMBRE

           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 10
               COMPUTE WS-RESULTAT = WS-NOMBRE * WS-I
               DISPLAY WS-NOMBRE " x " WS-I " = " WS-RESULTAT
           END-PERFORM.