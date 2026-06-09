       IDENTIFICATION DIVISION.
       PROGRAM-ID. VIREMENT-INTERNE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       FD  SQL-FILE.
       01  SQL-RECORD             PIC X(300).
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).
       WORKING-STORAGE SECTION.
       COPY 'virement_copy.cpy'.
       01  WS-CLIENT-IDX          PIC 9(9).
       01  WS-MONTANT-V           PIC S9(13)V99.
       01  WS-SOLDE-ACT           PIC S9(13)V99.
       01  WS-IBAN-DEST-INTERNE   PIC X(34).
       01  WS-DEST-CLIENT-ID      PIC 9(9).
       01  WS-COMMANDE            PIC X(500).
       01  WS-IBAN-TRIM           PIC X(34).

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
           DISPLAY "║              VIREMENT INTERNE                    ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant à transférer : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-V
           IF WS-MONTANT-V <= 0
               DISPLAY "Montant invalide."
               STOP RUN
           END-IF.
           DISPLAY "IBAN du bénéficiaire (interne) : " WITH NO ADVANCING
           ACCEPT WS-IBAN-DEST-INTERNE
           MOVE FUNCTION TRIM(WS-IBAN-DEST-INTERNE) TO WS-IBAN-TRIM

      *> Vérifier que l'IBAN existe (construction fichier SQL)
           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT client_id FROM clients WHERE iban = '"
               WS-IBAN-TRIM "';"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING "sqlite3 data/banque.db < SQL_TMP.SQL > TEMP.DAT"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           MOVE 0 TO WS-DEST-CLIENT-ID.
           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END CONTINUE
               NOT AT END
                   IF TEMP-RECORD NOT = SPACES
                       MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-DEST-CLIENT-ID
                   END-IF
           END-READ.
           CLOSE TEMP-FILE.

           IF WS-DEST-CLIENT-ID = 0
               DISPLAY "IBAN interne non trouvé."
               STOP RUN
           END-IF.

      *> Vérifier solde (même méthode)
           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT solde FROM comptes WHERE client_id = "
               WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING "sqlite3 data/banque.db < SQL_TMP.SQL > TEMP.DAT"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END MOVE 0 TO WS-SOLDE-ACT
               NOT AT END MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-SOLDE-ACT
           END-READ.
           CLOSE TEMP-FILE.

           IF WS-MONTANT-V > WS-SOLDE-ACT
               DISPLAY "Fonds insuffisants. Solde : " WS-SOLDE-ACT " EUR"
               STOP RUN
           END-IF.

      *> Débiter
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes SET solde = solde - " WS-MONTANT-V
               " WHERE client_id = " WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           CALL "SYSTEM" USING "sqlite3 data/banque.db < SQL_TMP.SQL > /dev/null 2>&1".

      *> Créditer
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes SET solde = solde + " WS-MONTANT-V
               " WHERE client_id = " WS-DEST-CLIENT-ID ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           CALL "SYSTEM" USING "sqlite3 data/banque.db < SQL_TMP.SQL > /dev/null 2>&1".

      *> Enregistrer la transaction
           OPEN OUTPUT SQL-FILE.
           STRING
               "INSERT INTO transactions (client_id, type_trans, montant, iban_dest) "
               "VALUES (" WS-CLIENT-IDX ", 'VIREMENT_INTERNE', " WS-MONTANT-V
               ", '" WS-IBAN-TRIM "');"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           CALL "SYSTEM" USING "sqlite3 data/banque.db < SQL_TMP.SQL > /dev/null 2>&1".

           DISPLAY " "
           DISPLAY "✓ Virement interne de " WS-MONTANT-V " EUR effectué."
           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT - WS-MONTANT-V
           DISPLAY "  Nouveau solde : " WS-SOLDE-ACT " EUR"
           STOP RUN.