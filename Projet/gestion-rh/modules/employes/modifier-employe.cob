       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-EMPLOYE.
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

       01 WS-ID                PIC 9(9).
       01 WS-PRENOM            PIC X(30).
       01 WS-NOM               PIC X(30).
       01 WS-DEPT              PIC 9(9).
       01 WS-POSTE             PIC 9(9).

       01 WS-COMMANDE          PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        MODIFIER EMPLOYE".
           DISPLAY "====================================".

           DISPLAY "ID employe : " WITH NO ADVANCING.
           ACCEPT WS-ID.

           DISPLAY "Nouveau prenom : " WITH NO ADVANCING.
           ACCEPT WS-PRENOM.

           DISPLAY "Nouveau nom : " WITH NO ADVANCING.
           ACCEPT WS-NOM.

           DISPLAY "ID Departement : " WITH NO ADVANCING.
           ACCEPT WS-DEPT.

           DISPLAY "ID Poste : " WITH NO ADVANCING.
           ACCEPT WS-POSTE.

      *> ==========================
      *> CONSTRUCTION SQL UPDATE
      *> ==========================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "UPDATE employees SET "
               "first_name='"
               FUNCTION TRIM(WS-PRENOM)
               "', last_name='"
               FUNCTION TRIM(WS-NOM)
               "', department_id="
               WS-DEPT
               ", position_id="
               WS-POSTE
               " WHERE employee_id="
               WS-ID
               ";"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================
      *> EXECUTION SQLITE
      *> ==========================

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY SPACE.
           DISPLAY "[OK] EMPLOYE MODIFIE".

           STOP RUN.