       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CONTRATS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CONTRAT ASSIGN TO 'data/input/CONTRATS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CONTRAT.
       01 ENR-CONTRAT.
          05 NUM-CONTRAT     PIC X(10).
          05 FILLER          PIC X(1).
          05 ID-CLIENT       PIC X(6).
          05 FILLER          PIC X(1).
          05 TYPE-CONTRAT    PIC X(4).
          05 FILLER          PIC X(1).
          05 PRIME-CONTRAT   PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 DATE-DEBUT      PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-COMPTEUR       PIC 99 VALUE 0.
       
       PROCEDURE DIVISION.
           OPEN INPUT FICHIER-CONTRAT
           
           DISPLAY " "
           DISPLAY "=== LISTE DES CONTRATS ==="
           DISPLAY "NUMERO     CLIENT  TYPE   PRIME     DATE DEBUT"
           DISPLAY "----------------------------------------------"
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CONTRAT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY NUM-CONTRAT " " ID-CLIENT " " 
                               TYPE-CONTRAT "   " PRIME-CONTRAT " " DATE-DEBUT
               END-READ
           END-PERFORM
           
           DISPLAY "----------------------------------------------"
           DISPLAY "TOTAL CONTRATS: " WS-COMPTEUR
           
           CLOSE FICHIER-CONTRAT
           
           STOP RUN.
