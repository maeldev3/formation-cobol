       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREDIT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-REVENU     PIC 9(7).
       01 WS-AGE        PIC 99.
       01 WS-PRET       PIC 9(8).
       01 WS-LIMITE     PIC 9(8).

       PROCEDURE DIVISION.

           DISPLAY "REVENU : "
           ACCEPT WS-REVENU

           DISPLAY "AGE : "
           ACCEPT WS-AGE

           DISPLAY "PRET : "
           ACCEPT WS-PRET

           COMPUTE WS-LIMITE = WS-REVENU * 5

           IF WS-REVENU > 700000
              AND WS-AGE >= 21
              AND WS-PRET <= WS-LIMITE
               DISPLAY "PRET ACCORDE"
           ELSE
               DISPLAY "PRET REFUSE"
           END-IF

           STOP RUN.