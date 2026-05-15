       IDENTIFICATION DIVISION.
       PROGRAM-ID. TABLEAU.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ETUDIANTS.
           05 WS-ETUDIANT OCCURS 3 TIMES.
               10 WS-NOM      PIC X(20).
               10 WS-NOTE     PIC 9(2).
       
       01 WS-I               PIC 9(2).
       
       PROCEDURE DIVISION.
           DISPLAY "SAISIE DES ETUDIANTS:".
           
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
               DISPLAY "ETUDIANT " WS-I ":"
               DISPLAY "NOM: "
               ACCEPT WS-NOM(WS-I)
               DISPLAY "NOTE: "
               ACCEPT WS-NOTE(WS-I)
           END-PERFORM.
           
           DISPLAY " ".
           DISPLAY "LISTE DES ETUDIANTS:".
           
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
               DISPLAY WS-NOM(WS-I) " : " WS-NOTE(WS-I)
           END-PERFORM.
           
           STOP RUN.