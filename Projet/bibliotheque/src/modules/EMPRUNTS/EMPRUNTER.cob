       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPRUNTER.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID-ADH         PIC X(6).
       01 WS-ISBN           PIC X(17).
       01 WS-DATE           PIC X(10).
       01 WS-EMP-ID         PIC X(6) VALUE 'E00099'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== ENREGISTRER UN EMPRUNT ==="
           DISPLAY " "
           DISPLAY "ID ADHERENT : "
           ACCEPT WS-ID-ADH
           DISPLAY "ISBN LIVRE : "
           ACCEPT WS-ISBN
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
           DISPLAY " "
           DISPLAY "--- EMPRUNT ENREGISTRE ---"
           DISPLAY "ID EMPRUNT : " WS-EMP-ID
           DISPLAY "ADHERENT   : " WS-ID-ADH
           DISPLAY "LIVRE      : " WS-ISBN
           DISPLAY "DATE       : " WS-DATE
           
           STOP RUN.
