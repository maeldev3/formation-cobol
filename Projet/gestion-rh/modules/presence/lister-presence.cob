       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-PRESENCE.
       AUTHOR. DEV.

      *> ==========================================
      *> LISTE DES PRÉSENCES
      *> ==========================================

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

      *> ==========================
      *> CONSTRUCTION DE LA REQUÊTE
      *> ==========================

           OPEN OUTPUT SQL-FILE.

           STRING
               "SELECT a.attendance_id || ' | ' || "
               "e.first_name || ' ' || e.last_name || ' | ' || "
               "a.check_in || ' | ' || "
               "a.status || ' | ' || "
               "a.date "
               "FROM attendance a, employees e "
               "WHERE a.employee_id = e.employee_id;"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================
      *> EXÉCUTION SQLITE
      *> ==========================

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================
      *> AFFICHAGE
      *> ==========================

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        LISTE DES PRESENCES".
           DISPLAY "====================================".

           OPEN INPUT RESULT-FILE.

           MOVE "N" TO WS-END.

           PERFORM UNTIL WS-END = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-END
                   NOT AT END
                       DISPLAY FUNCTION TRIM(RESULT-RECORD)
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.

           STOP RUN.
