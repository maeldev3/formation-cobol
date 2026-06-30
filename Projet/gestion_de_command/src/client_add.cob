       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIENTADD.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
       
           SELECT CLIENTFILE
               ASSIGN TO "clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       
       FILE SECTION.
       
       FD CLIENTFILE.
       
       01 CLIENT-RECORD.
          05 CR-ID         PIC 9(5).
          05 CR-NOM        PIC X(30).
          05 CR-TELEPHONE  PIC X(20).
          05 CR-EMAIL      PIC X(50).
       
       WORKING-STORAGE SECTION.
       
       01 WS-ID            PIC 9(5).
       01 WS-NOM           PIC X(30).
       01 WS-TELEPHONE     PIC X(20).
       01 WS-EMAIL         PIC X(50).
       
       PROCEDURE DIVISION.
       
       MAIN-PROGRAM.
       
           OPEN EXTEND CLIENTFILE
       
           DISPLAY "==============================="
           DISPLAY " AJOUT D'UN CLIENT"
           DISPLAY "==============================="
       
           DISPLAY "ID CLIENT : "
           ACCEPT WS-ID
       
           DISPLAY "NOM : "
           ACCEPT WS-NOM
       
           DISPLAY "TELEPHONE : "
           ACCEPT WS-TELEPHONE
       
           DISPLAY "EMAIL : "
           ACCEPT WS-EMAIL
       
           MOVE WS-ID        TO CR-ID
           MOVE WS-NOM       TO CR-NOM
           MOVE WS-TELEPHONE TO CR-TELEPHONE
           MOVE WS-EMAIL     TO CR-EMAIL
       
           WRITE CLIENT-RECORD
       
           DISPLAY "CLIENT ENREGISTRE"
       
           CLOSE CLIENTFILE
       
           STOP RUN.
