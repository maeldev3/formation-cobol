       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CHOIX PIC 9.

       PROCEDURE DIVISION.

       MAIN.

           DISPLAY "=========================="
           DISPLAY " MINI MAINFRAME ISPF"
           DISPLAY "=========================="
           DISPLAY "1 LOGIN"
           DISPLAY "2 JCL SIM"
           DISPLAY "3 DB2 SIM"
           DISPLAY "4 SDSF LOGS"
           DISPLAY "0 EXIT"

           ACCEPT WS-CHOIX

           EVALUATE WS-CHOIX
               WHEN 1
                   CALL "SYSTEM" USING "./cobol/LOGIN"
               WHEN 2
                   CALL "SYSTEM" USING "./cobol/JCLSIM"
               WHEN 3
                   CALL "SYSTEM" USING "./cobol/DB2SIM"
               WHEN 4
                   CALL "SYSTEM" USING "ls logs"
               WHEN 0
                   STOP RUN
           END-EVALUATE

           STOP RUN.