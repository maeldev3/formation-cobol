       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLO.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-MESSAGE PIC X(20) VALUE "Hello World!".
       
       PROCEDURE DIVISION.
           DISPLAY WS-MESSAGE.
           DISPLAY "GnuCOBOL fonctionne parfaitement!".
           STOP RUN.
