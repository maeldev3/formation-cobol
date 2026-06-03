       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUTER-DEPARTEMENT.
       AUTHOR. DEV.

      *> ==========================================
      *> AJOUT D'UN DEPARTEMENT DANS SQLITE
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
       01 SQL-RECORD              PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-NOM-DEPARTEMENT      PIC X(50).

       01 WS-COMMANDE             PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "      AJOUT DE DEPARTEMENT".
           DISPLAY "====================================".

           DISPLAY "Nom du departement : "
               WITH NO ADVANCING.

           ACCEPT WS-NOM-DEPARTEMENT.

      *> Création de la requête SQL

           OPEN OUTPUT SQL-FILE.

           STRING
               "INSERT INTO departments "
               "(department_name) "
               "VALUES('"
               FUNCTION TRIM(WS-NOM-DEPARTEMENT)
               "');"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> Exécution SQLite

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           DISPLAY SPACE.
           DISPLAY "[OK] DEPARTEMENT AJOUTE.".

           STOP RUN.