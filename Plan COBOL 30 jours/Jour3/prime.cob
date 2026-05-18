       IDENTIFICATION DIVISION.
       PROGRAM-ID. PRIME.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-SAL PIC 9(6).
       01 WS-ANC PIC 99.

       PROCEDURE DIVISION.

           DISPLAY "SALAIRE : "
           ACCEPT WS-SAL

           DISPLAY "ANCIENNETE : "
           ACCEPT WS-ANC

           IF WS-SAL > 500000
               IF WS-ANC > 2
                   DISPLAY "PRIME ACCORDEE"
               ELSE
                   DISPLAY "PAS PRIME"
               END-IF
           ELSE
               DISPLAY "PAS PRIME"
           END-IF

           STOP RUN.