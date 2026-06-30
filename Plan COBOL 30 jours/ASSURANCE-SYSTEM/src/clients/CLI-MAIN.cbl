       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLI-MAIN.
       
       ENVIRONMENT DIVISION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
       01 WS-MESSAGE PIC X(50).
       
       PROCEDURE DIVISION.
       
           MOVE "CLI-MAIN EXECUTION" TO WS-MESSAGE
           DISPLAY WS-MESSAGE
       
           STOP RUN.
       