       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPPRIMER-POSTE.
       AUTHOR. DEV.

      *> ==========================================
      *> SUPPRESSION D'UN POSTE
      *> ==========================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD           PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-POSTE-ID          PIC 9(9).
       01 WS-CONFIRMATION      PIC X.

       01 WS-COMMANDE          PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        SUPPRESSION POSTE".
           DISPLAY "====================================".

           DISPLAY "ID du poste : "
               WITH NO ADVANCING.
           ACCEPT WS-POSTE-ID.

           DISPLAY "Confirmer (O/N) : "
               WITH NO ADVANCING.
           ACCEPT WS-CONFIRMATION.

           IF WS-CONFIRMATION = "O"
           OR WS-CONFIRMATION = "o"

               OPEN OUTPUT SQL-FILE

               STRING
                   "DELETE FROM positions "
                   "WHERE position_id = "
                   WS-POSTE-ID
                   ";"
                   DELIMITED BY SIZE
                   INTO SQL-RECORD
               END-STRING

               WRITE SQL-RECORD

               CLOSE SQL-FILE

               STRING
                   "sqlite3 data/rh.db < temp/sql.tmp"
                   DELIMITED BY SIZE
                   INTO WS-COMMANDE
               END-STRING

               CALL "SYSTEM" USING WS-COMMANDE

               DISPLAY SPACE
               DISPLAY "[OK] POSTE SUPPRIME"

           ELSE

               DISPLAY SPACE
               DISPLAY "[INFO] OPERATION ANNULEE"

           END-IF.

           STOP RUN.