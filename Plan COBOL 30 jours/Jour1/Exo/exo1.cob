
       IDENTIFICATION DIVISION.
       PROGRAM-ID. JOUR1.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-NOM        PIC X(20).
       01 WS-PRENOM     PIC X(20).
       01 WS-POST       PIC X(20).
       01 WS-AGE        PIC 99.
       01 WS-SALAIRE    PIC 9(5)V99.

       PROCEDURE DIVISION.

           DISPLAY "NOM : "
           ACCEPT WS-NOM

           DISPLAY "PRENOM : "
           ACCEPT WS-PRENOM

           DISPLAY "AGE : "
           ACCEPT WS-AGE

           DISPLAY "POSTE : "
           ACCEPT WS-POST

           DISPLAY "SALAIRE : "
           ACCEPT WS-SALAIRE

           DISPLAY "-------------"
           DISPLAY "NOM = " WS-NOM
           DISPLAY "PRENOM = " WS-PRENOM
           DISPLAY "AGE = " WS-AGE
           DISPLAY "PRENOM = " WS-POST
           DISPLAY "SALAIRE = " WS-SALAIRE

           STOP RUN.
