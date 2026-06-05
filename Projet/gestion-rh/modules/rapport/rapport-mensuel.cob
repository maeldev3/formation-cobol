       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-MENSUEL.
       AUTHOR. DEV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT RESULT-FILE
               ASSIGN TO "temp/result.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD           PIC X(500).

       FD RESULT-FILE.
       01 RESULT-RECORD        PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-COMMANDE          PIC X(500).
       01 WS-END               PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        RAPPORT RH MENSUEL".
           DISPLAY "====================================".

      *> ==========================
      *> TOTAL EMPLOYES
      *> ==========================

           OPEN OUTPUT SQL-FILE.

           MOVE "SELECT COUNT(*) FROM employees;" TO SQL-RECORD.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY "Total employés : ".
           OPEN INPUT RESULT-FILE.
           READ RESULT-FILE AT END CONTINUE
               NOT AT END DISPLAY RESULT-RECORD
           END-READ.
           CLOSE RESULT-FILE.

            *> ==========================
      *> MASSE SALARIALE
      *> ==========================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "SELECT SUM(p.base_salary) "
               "FROM employees e, positions p "
               "WHERE e.position_id = p.position_id;"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY "Masse salariale : ".

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END
                   CONTINUE
               NOT AT END
                   DISPLAY FUNCTION TRIM(RESULT-RECORD)
           END-READ.

           CLOSE RESULT-FILE.