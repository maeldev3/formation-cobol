       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUTER-EMPLOYE.
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
       01 RESULT-RECORD        PIC X(200).

       WORKING-STORAGE SECTION.

       01 WS-PRENOM            PIC X(30).
       01 WS-NOM               PIC X(30).
       01 WS-DEPT-ID           PIC 9(9).
       01 WS-POSTE-ID          PIC 9(9).
       01 WS-COMMANDE          PIC X(500).
       01 WS-MKDIR             PIC X(100).
       01 WS-EOF               PIC X VALUE 'N'.

       PROCEDURE DIVISION.

       DEBUT.

      *> Créer répertoires nécessaires
           MOVE "mkdir -p temp data" TO WS-MKDIR
           CALL "SYSTEM" USING WS-MKDIR.

           PERFORM AFFICHER-ENTETE.
           PERFORM SAISIR-EMPLOYE.
           PERFORM AFFICHER-DEPARTEMENTS.
           PERFORM SAISIR-DEPARTEMENT.
           PERFORM AFFICHER-POSTES.
           PERFORM SAISIR-POSTE.
           PERFORM INSERER-EMPLOYE.
           PERFORM AFFICHER-CONFIRMATION.

           STOP RUN.

      *> ============================================
       AFFICHER-ENTETE.
           DISPLAY SPACE.
           DISPLAY "============================================".
           DISPLAY "           AJOUT D UN EMPLOYE              ".
           DISPLAY "============================================".
           DISPLAY SPACE.

      *> ============================================
       SAISIR-EMPLOYE.
           DISPLAY "  Prenom     : " WITH NO ADVANCING.
           ACCEPT WS-PRENOM.

           DISPLAY "  Nom        : " WITH NO ADVANCING.
           ACCEPT WS-NOM.

      *> ============================================
       AFFICHER-DEPARTEMENTS.
           DISPLAY SPACE.
           DISPLAY "--------------------------------------------".
           DISPLAY "         DEPARTEMENTS DISPONIBLES           ".
           DISPLAY "--------------------------------------------".

      *>  Commande : sqlite3 sans .headers, juste SELECT
           STRING
               "sqlite3 data/rh.db "
               """SELECT department_id || '. ' || department_name"
               " FROM departments ORDER BY department_id;"
               """"
               " > temp/result.tmp 2>&1"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           PERFORM LIRE-ET-AFFICHER-RESULT.

           DISPLAY "--------------------------------------------".

      *> ============================================
       SAISIR-DEPARTEMENT.
           DISPLAY SPACE.
           DISPLAY "  >> Entrer l ID du departement : "
               WITH NO ADVANCING.
           ACCEPT WS-DEPT-ID.

      *> ============================================
       AFFICHER-POSTES.
           DISPLAY SPACE.
           DISPLAY "--------------------------------------------".
           DISPLAY "           POSTES DISPONIBLES               ".
           DISPLAY "--------------------------------------------".

           STRING
               "sqlite3 data/rh.db "
               """SELECT position_id || '. ' || position_name"
               " || '   Salaire: ' || base_salary || ' Ar'"
               " FROM positions ORDER BY position_id;"
               """"
               " > temp/result.tmp 2>&1"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           PERFORM LIRE-ET-AFFICHER-RESULT.

           DISPLAY "--------------------------------------------".

      *> ============================================
       SAISIR-POSTE.
           DISPLAY SPACE.
           DISPLAY "  >> Entrer l ID du poste      : "
               WITH NO ADVANCING.
           ACCEPT WS-POSTE-ID.

      *> ============================================
       INSERER-EMPLOYE.
           OPEN OUTPUT SQL-FILE.

           STRING
               "INSERT INTO employees "
               "(first_name, last_name, department_id, position_id)"
               " VALUES ('"
               FUNCTION TRIM(WS-PRENOM)
               "', '"
               FUNCTION TRIM(WS-NOM)
               "', "
               WS-DEPT-ID
               ", "
               WS-POSTE-ID
               ");"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           MOVE "sqlite3 data/rh.db < temp/sql.tmp" TO WS-COMMANDE.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> ============================================
       AFFICHER-CONFIRMATION.
           DISPLAY SPACE.
           DISPLAY "============================================".
           DISPLAY "   [OK]  EMPLOYE AJOUTE AVEC SUCCES        ".
           DISPLAY "============================================".
           DISPLAY SPACE.

      *> ============================================
      *>  Paragraphe réutilisable : lit temp/result.tmp
      *>  et affiche chaque ligne
      *> ============================================
       LIRE-ET-AFFICHER-RESULT.
           MOVE 'N' TO WS-EOF.
           OPEN INPUT RESULT-FILE.
           PERFORM UNTIL WS-EOF = 'Y'
               READ RESULT-FILE INTO RESULT-RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       DISPLAY "  " FUNCTION TRIM(RESULT-RECORD)
               END-READ
           END-PERFORM.
           CLOSE RESULT-FILE.














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
      *01 WS-COMMANDE          PIC X(500).
      *01 WS-MKDIR             PIC X(100).
      *
      *PROCEDURE DIVISION.
      *
      *DEBUT.
      *
      **> Créer le répertoire temp (si inexistant)
      *    MOVE "mkdir -p temp" TO WS-MKDIR
      *    CALL "SYSTEM" USING WS-MKDIR.
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
      **> Création du fichier SQL
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
      *    CLOSE SQL-FILE.
      *
      **> Exécution de la commande SQLite
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
      