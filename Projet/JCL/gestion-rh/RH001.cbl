       IDENTIFICATION DIVISION.
       PROGRAM-ID. RH001.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-MESSAGE PIC X(50).

       PROCEDURE DIVISION.

           MOVE 'RH SYSTEM OK - COBOL RUN SUCCESS' TO WS-MESSAGE

           DISPLAY '============================'
           DISPLAY '  RH001 MAINFRAME TEST'
           DISPLAY '============================'
           DISPLAY WS-MESSAGE
           DISPLAY '============================'

           STOP RUN.