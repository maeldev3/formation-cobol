       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-UTILISATEUR.
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
       01 SQL-RECORD       PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-ID            PIC 9(9).
       01 WS-LOGIN         PIC X(30).
       01 WS-PIN           PIC X(10).
       01 WS-ROLE          PIC X(20).

       01 WS-COMMANDE      PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY "ID Utilisateur : "
               WITH NO ADVANCING.
           ACCEPT WS-ID.

           DISPLAY "Nouveau Login : "
               WITH NO ADVANCING.
           ACCEPT WS-LOGIN.

           DISPLAY "Nouveau PIN : "
               WITH NO ADVANCING.
           ACCEPT WS-PIN.

           DISPLAY "Nouveau Role : "
               WITH NO ADVANCING.
           ACCEPT WS-ROLE.

           OPEN OUTPUT SQL-FILE.

           STRING
               "UPDATE users SET login='"
               FUNCTION TRIM(WS-LOGIN)
               "', pin='"
               FUNCTION TRIM(WS-PIN)
               "', role='"
               FUNCTION TRIM(WS-ROLE)
               "' WHERE user_id="
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

           DISPLAY "[OK] Utilisateur modifie".

           STOP RUN.