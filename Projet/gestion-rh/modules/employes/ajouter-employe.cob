       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUTER-EMPLOYE.
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
       01 SQL-RECORD           PIC X(1000).  *> Augmenté car la requête est plus longue

       WORKING-STORAGE SECTION.

       01 WS-PRENOM            PIC X(30).
       01 WS-NOM               PIC X(30).
       *> Remplacement des IDs par des noms textuels
       01 WS-DEPT-NOM          PIC X(50).
       01 WS-POSTE-NOM         PIC X(50).

       01 WS-COMMANDE          PIC X(500).

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        AJOUT EMPLOYE".
           DISPLAY "====================================".

           DISPLAY "Prenom : " WITH NO ADVANCING.
           ACCEPT WS-PRENOM.

           DISPLAY "Nom : " WITH NO ADVANCING.
           ACCEPT WS-NOM.

           DISPLAY "Nom du Departement : " WITH NO ADVANCING.
           ACCEPT WS-DEPT-NOM.

           DISPLAY "Nom du Poste : " WITH NO ADVANCING.
           ACCEPT WS-POSTE-NOM.

      *> Création SQL avec sous-requêtes

           OPEN OUTPUT SQL-FILE.

           STRING
               "INSERT INTO employees "
               "(first_name, last_name, department_id, position_id) "
               "VALUES ('"
               FUNCTION TRIM(WS-PRENOM)
               "','"
               FUNCTION TRIM(WS-NOM)
               "', (SELECT department_id FROM departments WHERE "
               "department_name = '" FUNCTION TRIM(WS-DEPT-NOM) "'), "
               "(SELECT position_id FROM positions WHERE "
               "position_name = '" FUNCTION TRIM(WS-POSTE-NOM) "'));"
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
           DISPLAY "[OK] EMPLOYE AJOUTE".

           STOP RUN.




      *IDENTIFICATION DIVISION.
      *PROGRAM-ID. AJOUTER-EMPLOYE.
      *AUTHOR. DEV.
      *
      *ENVIRONMENT DIVISION.
      *INPUT-OUTPUT SECTION.
      *FILE-CONTROL.
      *
      *    SELECT SQL-FILE
      *        ASSIGN TO "temp/sql.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      *DATA DIVISION.
      *
      *FILE SECTION.
      *
      *FD SQL-FILE.
      *01 SQL-RECORD           PIC X(500).
      *
      *WORKING-STORAGE SECTION.
      *
      *01 WS-PRENOM            PIC X(30).
      *01 WS-NOM               PIC X(30).
      *01 WS-DEPT-ID           PIC 9(9).
      *01 WS-POSTE-ID          PIC 9(9).
      *
      *01 WS-COMMANDE          PIC X(500).
      *
      *PROCEDURE DIVISION.
      *
      *DEBUT.
      *
      *    DISPLAY SPACE.
      *    DISPLAY "====================================".
      *    DISPLAY "        AJOUT EMPLOYE".
      *    DISPLAY "====================================".
      *
      *    DISPLAY "Prenom : " WITH NO ADVANCING.
      *    ACCEPT WS-PRENOM.
      *
      *    DISPLAY "Nom : " WITH NO ADVANCING.
      *    ACCEPT WS-NOM.
      *
      *    DISPLAY "ID Departement : " WITH NO ADVANCING.
      *    ACCEPT WS-DEPT-ID.
      *
      *    DISPLAY "ID Poste : " WITH NO ADVANCING.
      *    ACCEPT WS-POSTE-ID.
      *
      **> Création SQL
      *
      *    OPEN OUTPUT SQL-FILE.
      *
      *    STRING
      *        "INSERT INTO employees "
      *        "(first_name,last_name,department_id,position_id) "
      *        "VALUES ('"
      *        FUNCTION TRIM(WS-PRENOM)
      *        "','"
      *        FUNCTION TRIM(WS-NOM)
      *        "',"
      *        WS-DEPT-ID
      *        ","
      *        WS-POSTE-ID
      *        ");"
      *        DELIMITED BY SIZE
      *        INTO SQL-RECORD
      *    END-STRING.
      *
      *    WRITE SQL-RECORD.
      *
      *    CLOSE SQL-FILE.
      *
      **> Exécution SQLite
      *
      *    STRING
      *        "sqlite3 data/rh.db < temp/sql.tmp"
      *        DELIMITED BY SIZE
      *        INTO WS-COMMANDE
      *    END-STRING.
      *
      *    CALL "SYSTEM" USING WS-COMMANDE.
      *
      *    DISPLAY SPACE.
      *    DISPLAY "[OK] EMPLOYE AJOUTE".
      *
      *    STOP RUN.
      