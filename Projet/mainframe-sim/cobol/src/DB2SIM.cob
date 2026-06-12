       IDENTIFICATION DIVISION.
       PROGRAM-ID. DB2SIM.

       PROCEDURE DIVISION.

           DISPLAY "=== DB2 SIMULATION ==="
           DISPLAY "SELECT * FROM EMPLOYEES"

           CALL "SYSTEM"
             USING "echo '1 | RAKOTO | DEV'"

           CALL "SYSTEM"
             USING "echo '2 | RAVO | ANALYSTE'"

           STOP RUN.