       IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDER-CONGE.
       AUTHOR. DEV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD           PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-ID-CONGE          PIC 9(9).
       01 WS-STATUT            PIC X(10).

       01 WS-COMMANDE          PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        VALIDATION CONGE".
           DISPLAY "====================================".

           DISPLAY "ID conge : " WITH NO ADVANCING.
           ACCEPT WS-ID-CONGE.

           DISPLAY "Statut (APPROVED / REJECTED) : " WITH NO ADVANCING.
           ACCEPT WS-STATUT.

      *> ==============================
      *> SQL UPDATE
      *> ==============================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "UPDATE leaves SET status='"
               FUNCTION TRIM(WS-STATUT)
               "' WHERE leave_id="
               WS-ID-CONGE
               ";"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==============================
      *> EXECUTION SQLITE
      *> ==============================

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY SPACE.
           DISPLAY "[OK] CONGE MIS A JOUR".

           STOP RUN.