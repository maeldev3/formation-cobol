       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIENTBANK.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-ID          PIC 9(5).
       01 WS-NOM         PIC X(20).
       01 WS-VILLE       PIC X(20).
       01 WS-SOLDE       PIC 9(7)V99.

       PROCEDURE DIVISION.

           DISPLAY "ID CLIENT : "
           ACCEPT WS-ID

           DISPLAY "NOM : "
           ACCEPT WS-NOM

           DISPLAY "VILLE : "
           ACCEPT WS-VILLE

           DISPLAY "SOLDE : "
           ACCEPT WS-SOLDE

           DISPLAY "===================="
           DISPLAY "CLIENT"
           DISPLAY "ID : " WS-ID
           DISPLAY "NOM : " WS-NOM
           DISPLAY "VILLE : " WS-VILLE
           DISPLAY "SOLDE : " WS-SOLDE

           STOP RUN.