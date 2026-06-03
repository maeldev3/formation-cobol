       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEMANDE-CONGE.
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

       01 WS-EMP-ID            PIC 9(9).
       01 WS-DEBUT             PIC X(10).
       01 WS-FIN               PIC X(10).
       01 WS-RAISON            PIC X(50).

       01 WS-COMMANDE          PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        DEMANDE DE CONGE".
           DISPLAY "====================================".

           DISPLAY "ID employe : " WITH NO ADVANCING.
           ACCEPT WS-EMP-ID.

           DISPLAY "Date debut (YYYY-MM-DD) : " WITH NO ADVANCING.
           ACCEPT WS-DEBUT.

           DISPLAY "Date fin (YYYY-MM-DD) : " WITH NO ADVANCING.
           ACCEPT WS-FIN.

           DISPLAY "Raison : " WITH NO ADVANCING.
           ACCEPT WS-RAISON.

      *> ==============================
      *> INSERT SQL CONGE
      *> ==============================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "INSERT INTO leaves "
               "(employee_id, start_date, end_date, reason) "
               "VALUES ("
               WS-EMP-ID
               ", '"
               FUNCTION TRIM(WS-DEBUT)
               "', '"
               FUNCTION TRIM(WS-FIN)
               "', '"
               FUNCTION TRIM(WS-RAISON)
               "');"
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
           DISPLAY "[OK] DEMANDE DE CONGE ENREGISTREE".

           STOP RUN.