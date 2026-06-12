       IDENTIFICATION DIVISION.
       PROGRAM-ID. SDSF.

       PROCEDURE DIVISION.

           DISPLAY "=== SYSTEM LOGS (SDSF SIM) ==="
           CALL "SYSTEM" USING "ls -l logs"

           STOP RUN.