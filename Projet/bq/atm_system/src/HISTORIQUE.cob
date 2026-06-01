       IDENTIFICATION DIVISION.
       PROGRAM-ID. HISTORIQUE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       WORKING-STORAGE SECTION.
       COPY 'atm_copy.cpy'.
       01  WS-CARTE-IDX           PIC 9(9).
       01  WS-COMMANDE            PIC X(500).

       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT SESSION-FILE.
           READ SESSION-FILE INTO SESSION-RECORD
               AT END 
                   DISPLAY "Session invalide."
                   STOP RUN
           END-READ.
           CLOSE SESSION-FILE.
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CARTE-IDX.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║               DERNIERES OPERATIONS              ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"

           STRING
               "sqlite3 data/atm.db 'SELECT date_trans, type_trans, montant "
               "FROM transactions WHERE carte_id = " WS-CARTE-IDX
               " ORDER BY date_trans DESC LIMIT 5;'"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY " "
           STOP RUN.