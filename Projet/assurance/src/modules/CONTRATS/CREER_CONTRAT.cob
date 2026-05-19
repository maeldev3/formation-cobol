       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CONTRAT.
       
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
       01 WS-NUM            PIC X(10).
       01 WS-ID-CLI         PIC X(6).
       01 WS-TYPE           PIC X(4).
       01 WS-PRIME          PIC 9(8)V99.
       01 WS-DATE           PIC X(10).
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-EXISTE         PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== CREER UN CONTRAT ==="
           DISPLAY " "
           DISPLAY "NUMERO (AUTO002) : "
           ACCEPT WS-NUM
           DISPLAY "ID CLIENT : "
           ACCEPT WS-ID-CLI
           DISPLAY "TYPE (AUTO/SANT/HABI) : "
           ACCEPT WS-TYPE
           DISPLAY "PRIME MENSUELLE : "
           ACCEPT WS-PRIME
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Vérifier existence
           OPEN INPUT FICHIER-CONTRAT
           MOVE 'N' TO WS-EXISTE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CONTRAT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUM-CONTRAT = WS-NUM
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CONTRAT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: Contrat existe deja"
               STOP RUN
           END-IF
           
      *> Ajouter contrat
           OPEN EXTEND FICHIER-CONTRAT
           
           MOVE WS-NUM TO NUM-CONTRAT
           MOVE WS-ID-CLI TO ID-CLIENT
           MOVE WS-TYPE TO TYPE-CONTRAT
           MOVE WS-PRIME TO PRIME-CONTRAT
           MOVE WS-DATE TO DATE-DEBUT
           
           WRITE ENR-CONTRAT
           CLOSE FICHIER-CONTRAT
           
           DISPLAY " "
           DISPLAY "--- CONTRAT CREE ---"
           DISPLAY "NUMERO  : " WS-NUM
           DISPLAY "CLIENT  : " WS-ID-CLI
           DISPLAY "TYPE    : " WS-TYPE
           DISPLAY "PRIME   : " WS-PRIME " €"
           DISPLAY "DATE    : " WS-DATE
           
           STOP RUN.
