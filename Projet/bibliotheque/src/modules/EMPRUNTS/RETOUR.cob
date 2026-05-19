       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETOUR.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-EMP-ID         PIC X(6).
       01 WS-DATE           PIC X(10).
       01 WS-RETARD         PIC 99 VALUE 3.
       01 WS-AMENDE         PIC 9(4)V99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== RETOURNER UN LIVRE ==="
           DISPLAY " "
           DISPLAY "ID EMPRUNT : "
           ACCEPT WS-EMP-ID
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           COMPUTE WS-AMENDE = WS-RETARD * 0.50
           
           DISPLAY " "
           DISPLAY "--- RETOUR ENREGISTRE ---"
           DISPLAY "ID EMPRUNT : " WS-EMP-ID
           DISPLAY "DATE RETOUR: " WS-DATE
           DISPLAY "RETARD     : " WS-RETARD " jours"
           DISPLAY "AMENDE     : " WS-AMENDE " €"
           
           STOP RUN.
