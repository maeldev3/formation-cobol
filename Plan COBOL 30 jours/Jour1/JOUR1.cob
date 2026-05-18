       IDENTIFICATION DIVISION.
       PROGRAM-ID. JOUR1.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-NOM        PIC X(20).
       01 WS-AGE        PIC 99.
       01 WS-SALAIRE    PIC 9(5)V99.

       PROCEDURE DIVISION.

           DISPLAY "NOM : "
           ACCEPT WS-NOM

           DISPLAY "AGE : "
           ACCEPT WS-AGE

           DISPLAY "SALAIRE : "
           ACCEPT WS-SALAIRE

           DISPLAY "-------------"
           DISPLAY "NOM = " WS-NOM
           DISPLAY "AGE = " WS-AGE
           DISPLAY "SALAIRE = " WS-SALAIRE

           STOP RUN.
