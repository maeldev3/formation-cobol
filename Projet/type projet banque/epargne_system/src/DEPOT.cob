       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPOT.
       AUTHOR. SENIOR-COBOL-DEV.
      *> Dépôt d'argent sur le compte épargne

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "/tmp/SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       FD  SQL-FILE.
       01  SQL-RECORD             PIC X(300).

       WORKING-STORAGE SECTION.
       COPY 'epargne_copy.cpy'.
       01  WS-CLIENT-IDX          PIC 9(9).
       01  WS-MONTANT-D           PIC S9(13)V99.
       01  WS-COMMANDE            PIC X(500).

       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT SESSION-FILE.
           READ SESSION-FILE INTO SESSION-RECORD
               AT END 
                   DISPLAY "Session invalide. Authentifiez-vous."
                   STOP RUN
           END-READ.
           CLOSE SESSION-FILE.
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CLIENT-IDX.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║                     DEPOT                       ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant à déposer : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-D
           IF WS-MONTANT-D <= 0
               DISPLAY "Montant invalide."
               STOP RUN
           END-IF.

      *> Mise à jour du solde
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes_epargne SET solde = solde + "
               WS-MONTANT-D " WHERE client_id = " WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /dev/null 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> Enregistrement de la transaction
           OPEN OUTPUT SQL-FILE.
           STRING
               "INSERT INTO transactions (client_id, type_trans, montant) "
               "VALUES (" WS-CLIENT-IDX ", 'DEPOT', " WS-MONTANT-D ");"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /dev/null 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY " "
           DISPLAY "✓ Dépôt de " WS-MONTANT-D " EUR effectué."
           STOP RUN.
