       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETRAIT.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "SQL_TMP.DAT"
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
       COPY 'atm_copy.cpy'.
       01  WS-CARTE-IDX           PIC 9(9).
       01  WS-MONTANT-R           PIC S9(13)V99.
       01  WS-SOLDE-ACT           PIC S9(13)V99.
       01  WS-COMMANDE            PIC X(500).
       01  WS-SQL-QUERY           PIC X(300).
       01  WS-RETOUR              PIC 9(3).

       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT SESSION-FILE.
           READ SESSION-FILE INTO SESSION-RECORD
               AT END 
                   DISPLAY "Session invalide. Authentifiez-vous d'abord."
                   STOP RUN
           END-READ.
           CLOSE SESSION-FILE.
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CARTE-IDX.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║                    RETRAIT                       ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Montant (max 1000€) : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-R.

           IF WS-MONTANT-R <= 0 OR WS-MONTANT-R > 1000
               DISPLAY "Montant invalide (min 1, max 1000)"
               STOP RUN
           END-IF.

      *> Récupérer le solde actuel
           STRING
               "sqlite3 data/atm.db 'SELECT solde FROM comptes "
               "WHERE carte_id = " WS-CARTE-IDX ";' > TEMP.DAT"
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
           STRING
               "sqlite3 data/atm.db 'UPDATE comptes SET solde = solde - "
               WS-MONTANT-R " WHERE carte_id = " WS-CARTE-IDX ";'"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> Insertion de la transaction (en utilisant un fichier SQL)
           OPEN OUTPUT SQL-FILE.
           STRING
               "INSERT INTO transactions (carte_id, type_trans, montant) "
               "VALUES (" WS-CARTE-IDX ", 'RETRAIT', " WS-MONTANT-R ");"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING "sqlite3 data/atm.db < SQL_TMP.DAT" 
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> Nettoyer fichier temporaire
           CALL "SYSTEM" USING "rm -f SQL_TMP.DAT".

           DISPLAY " "
           DISPLAY "✓ Retrait de " WS-MONTANT-R " EUR effectue."
           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT - WS-MONTANT-R
           DISPLAY "  Nouveau solde : " WS-SOLDE-ACT " EUR"
           STOP RUN.