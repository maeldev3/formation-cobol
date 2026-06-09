       IDENTIFICATION DIVISION.
       PROGRAM-ID. HISTORIQUE.
       AUTHOR. SENIOR-COBOL-DEV.
      *> Affiche l'historique des transactions du compte épargne

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
           DISPLAY "║               HISTORIQUE DES OPÉRATIONS          ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"

           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT date_trans, type_trans, montant FROM transactions "
               "WHERE client_id = " WS-CLIENT-IDX
               " ORDER BY date_trans DESC LIMIT 10;"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING
               "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY " "
           STOP RUN.
