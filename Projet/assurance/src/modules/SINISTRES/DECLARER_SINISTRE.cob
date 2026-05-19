       IDENTIFICATION DIVISION.
       PROGRAM-ID. DECLARER-SINISTRE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-SINISTRE ASSIGN TO 'data/input/SINISTRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-SINISTRE.
       01 ENR-SINISTRE.
          05 ID-SIN          PIC X(10).
          05 FILLER          PIC X(1).
          05 NUM-CONTRAT     PIC X(10).
          05 FILLER          PIC X(1).
          05 DATE-SIN        PIC X(10).
          05 FILLER          PIC X(1).
          05 MONTANT-SIN     PIC 9(8)V99.
          05 FILLER          PIC X(1).
          05 STATUS-SIN      PIC X(1).
       
       WORKING-STORAGE SECTION.
       01 WS-ID             PIC X(10).
       01 WS-NUM-CONTRAT    PIC X(10).
       01 WS-MONTANT        PIC 9(8)V99.
       01 WS-DATE           PIC X(10).
       01 WS-FIN            PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== DECLARER UN SINISTRE ==="
           DISPLAY " "
           DISPLAY "NUMERO CONTRAT : "
           ACCEPT WS-NUM-CONTRAT
           DISPLAY "MONTANT DEMANDE : "
           ACCEPT WS-MONTANT
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Générer ID sinistre
           ACCEPT WS-ID FROM TIME
           MOVE 'SIN' TO WS-ID(1:3)
           
      *> Enregistrer sinistre
           OPEN EXTEND FICHIER-SINISTRE
           
           MOVE WS-ID TO ID-SIN
           MOVE WS-NUM-CONTRAT TO NUM-CONTRAT
           MOVE WS-DATE TO DATE-SIN
           MOVE WS-MONTANT TO MONTANT-SIN
           MOVE 'O' TO STATUS-SIN
           
           WRITE ENR-SINISTRE
           CLOSE FICHIER-SINISTRE
           
           DISPLAY " "
           DISPLAY "--- SINISTRE DECLARE ---"
           DISPLAY "ID SINISTRE : " WS-ID
           DISPLAY "CONTRAT     : " WS-NUM-CONTRAT
           DISPLAY "MONTANT     : " WS-MONTANT " €"
           DISPLAY "STATUS      : OUVERT"
           DISPLAY "DATE        : " WS-DATE
           
           STOP RUN.
