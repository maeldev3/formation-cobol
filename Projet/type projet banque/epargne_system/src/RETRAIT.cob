       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETRAIT.
       AUTHOR. SENIOR-COBOL-DEV.
      *> Retrait d'argent du compte épargne

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "/tmp/SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "/tmp/TEMP.DAT"
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
       COPY 'epargne_copy.cpy'.
       01  WS-CLIENT-IDX          PIC 9(9).
       01  WS-MONTANT-R           PIC S9(13)V99.
       01  WS-SOLDE-ACT           PIC S9(13)V99.
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
           DISPLAY "║                    RETRAIT                       ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant à retirer : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-R
           IF WS-MONTANT-R <= 0
               DISPLAY "Montant invalide."
               STOP RUN
           END-IF.

      *> Vérifier solde
           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT solde FROM comptes_epargne WHERE client_id = "
               WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /tmp/TEMP.DAT 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END MOVE 0 TO WS-SOLDE-ACT
               NOT AT END MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-SOLDE-ACT
           END-READ.
           CLOSE TEMP-FILE.

           IF WS-MONTANT-R > WS-SOLDE-ACT
               DISPLAY "Fonds insuffisants. Solde : " WS-SOLDE-ACT " EUR"
               STOP RUN
           END-IF.

      *> Mise à jour du solde
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes_epargne SET solde = solde - "
               WS-MONTANT-R " WHERE client_id = " WS-CLIENT-IDX ";"
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
               "VALUES (" WS-CLIENT-IDX ", 'RETRAIT', " WS-MONTANT-R ");"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /dev/null 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY " "
           DISPLAY "✓ Retrait de " WS-MONTANT-R " EUR effectué."
           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT - WS-MONTANT-R
           DISPLAY "  Nouveau solde : " WS-SOLDE-ACT " EUR"
           STOP RUN.
