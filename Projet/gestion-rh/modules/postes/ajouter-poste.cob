       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUTER-POSTE.
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
       01 SQL-RECORD           PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-NOM-POSTE         PIC X(50).

       01 WS-SALAIRE           PIC 9(9).

       01 WS-COMMANDE          PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY
           "====================================".

           DISPLAY
           "         AJOUTER POSTE".

           DISPLAY
           "====================================".

           DISPLAY
           "Nom du poste : "
           WITH NO ADVANCING.

           ACCEPT WS-NOM-POSTE.

           DISPLAY
           "Salaire de base : "
           WITH NO ADVANCING.

           ACCEPT WS-SALAIRE.

           OPEN OUTPUT SQL-FILE.

           STRING
               "INSERT INTO positions "
               "(position_name, base_salary) "
               "VALUES ('"
               FUNCTION TRIM(WS-NOM-POSTE)
               "', "
               WS-SALAIRE
               ");"
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

           DISPLAY SPACE.
           DISPLAY "[OK] POSTE AJOUTE.".

           STOP RUN.