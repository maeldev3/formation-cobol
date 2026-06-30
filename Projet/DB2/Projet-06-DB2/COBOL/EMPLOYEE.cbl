       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPLOYEE.

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL
            INCLUDE SQLCA
       END-EXEC.

       COPY EMPREC.

       PROCEDURE DIVISION.

       MAIN-PROGRAM.

           DISPLAY "=================================".
           DISPLAY "      EMPLOYEE DB2 SYSTEM        ".
           DISPLAY "=================================".

           DISPLAY "PROGRAM STARTED".

           GOBACK.