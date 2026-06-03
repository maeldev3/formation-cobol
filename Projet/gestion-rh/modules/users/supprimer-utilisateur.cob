       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPPRIMER-UTILISATEUR.
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
       01 SQL-RECORD       PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-ID            PIC X(10).
       01 WS-COMMANDE      PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY "ID Utilisateur a supprimer : "
               WITH NO ADVANCING.
           ACCEPT WS-ID.

           OPEN OUTPUT SQL-FILE.

           STRING
               "DELETE FROM users WHERE user_id="
               FUNCTION TRIM(WS-ID)
               ";"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY "[OK] Utilisateur supprime".

           STOP RUN.