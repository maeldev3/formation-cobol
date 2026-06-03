       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPOT.
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
       01  WS-MONTANT-D           PIC S9(13)V99.
       01  WS-COMMANDE            PIC X(500).
       01  WS-TYPE-OP             PIC X(10) VALUE 'DEPOT'.

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
           DISPLAY "║                     DEPOT                       ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant a deposer : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-D.

           IF WS-MONTANT-D <= 0
               DISPLAY "Montant invalide"
               STOP RUN
           END-IF.

      *> Mise à jour du solde
           STRING
               "sqlite3 data/atm.db 'UPDATE comptes SET solde = solde + "
               WS-MONTANT-D " WHERE carte_id = " WS-CARTE-IDX ";'"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> Insertion de la transaction
           STRING
               "sqlite3 data/atm.db 'INSERT INTO transactions "
               "(carte_id, type_trans, montant) VALUES ("
               WS-CARTE-IDX ", '" WS-TYPE-OP "', " WS-MONTANT-D ");'"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY " "
           DISPLAY "✓ Depot de " WS-MONTANT-D " EUR effectue."
           STOP RUN.