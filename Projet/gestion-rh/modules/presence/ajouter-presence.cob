       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUTER-PRESENCE.
       AUTHOR. DEV.

      *> ==========================================
      *> AJOUT D'UNE PRÉSENCE (ATTENDANCE)
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
       01 SQL-RECORD           PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-EMP-ID            PIC 9(9).
       01 WS-CHECK-IN          PIC X(10).
       01 WS-STATUS            PIC X(10).

       01 WS-COMMANDE          PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        AJOUT PRESENCE".
           DISPLAY "====================================".

           DISPLAY "ID employe : " WITH NO ADVANCING.
           ACCEPT WS-EMP-ID.

           DISPLAY "Heure entree (HH:MM) : " WITH NO ADVANCING.
           ACCEPT WS-CHECK-IN.

           DISPLAY "Statut (PRESENT/ABSENT) : " WITH NO ADVANCING.
           ACCEPT WS-STATUS.

      *> ==============================
      *> CRÉATION SQL INSERT
      *> ==============================

           OPEN OUTPUT SQL-FILE.

           STRING
               "INSERT INTO attendance "
               "(employee_id, check_in, status) "
               "VALUES ("
               WS-EMP-ID
               ", '"
               FUNCTION TRIM(WS-CHECK-IN)
               "', '"
               FUNCTION TRIM(WS-STATUS)
               "');"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==============================
      *> EXÉCUTION SQLITE
      *> ==============================

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY SPACE.
           DISPLAY "[OK] PRESENCE ENREGISTREE".

           STOP RUN.
