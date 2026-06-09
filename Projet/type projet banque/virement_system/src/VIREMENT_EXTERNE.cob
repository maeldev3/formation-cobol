       IDENTIFICATION DIVISION.
       PROGRAM-ID. VIREMENT-EXTERNE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).
       FD  SQL-FILE.
       01  SQL-RECORD             PIC X(300).
       WORKING-STORAGE SECTION.
       COPY 'virement_copy.cpy'.
       01  WS-CLIENT-IDX          PIC 9(9).
       01  WS-MONTANT-V           PIC S9(13)V99.
       01  WS-SOLDE-ACT           PIC S9(13)V99.
       01  WS-IBAN-EXTERNE        PIC X(34).
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
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CLIENT-IDX.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║              VIREMENT EXTERNE                    ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant à transférer : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-V
           IF WS-MONTANT-V <= 0
               DISPLAY "Montant invalide."
               STOP RUN
           END-IF.
           DISPLAY "IBAN du bénéficiaire externe : " WITH NO ADVANCING
           ACCEPT WS-IBAN-EXTERNE

      *> Validation IBAN simple (longueur minimale 15)
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-IBAN-EXTERNE)) < 15
               DISPLAY "IBAN invalide (trop court)."
               STOP RUN
           END-IF.

      *> Vérifier solde
           STRING
               "sqlite3 data/banque.db 'SELECT solde FROM comptes "
               "WHERE client_id = " WS-CLIENT-IDX ";' > TEMP.DAT"
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

      *> Débiter l'émetteur
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes SET solde = solde - " WS-MONTANT-V
               " WHERE client_id = " WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           CALL "SYSTEM" USING "sqlite3 data/banque.db < SQL_TMP.SQL > /dev/null 2>&1".

      *> Enregistrer la transaction
           OPEN OUTPUT SQL-FILE.
           STRING
               "INSERT INTO transactions (client_id, type_trans, montant, iban_dest) "
               "VALUES (" WS-CLIENT-IDX ", 'VIREMENT_EXTERNE', " WS-MONTANT-V
               ", '" WS-IBAN-EXTERNE "');"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           CALL "SYSTEM" USING "sqlite3 data/banque.db < SQL_TMP.SQL > /dev/null 2>&1".

           DISPLAY " "
           DISPLAY "✓ Virement externe de " WS-MONTANT-V " EUR effectué vers "
                   FUNCTION TRIM(WS-IBAN-EXTERNE)
           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT - WS-MONTANT-V
           DISPLAY "  Nouveau solde : " WS-SOLDE-ACT " EUR"
           STOP RUN.
