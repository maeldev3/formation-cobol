       IDENTIFICATION DIVISION.
       PROGRAM-ID. JCLSIM.

       PROCEDURE DIVISION.

           DISPLAY "JOB SUBMITTED"
           DISPLAY "STEP 1: COMPILATION"
           CALL "SYSTEM" USING "./scripts/compile.sh"

           DISPLAY "STEP 2: EXECUTION"
           CALL "SYSTEM" USING "./scripts/run.sh"

           STOP RUN.