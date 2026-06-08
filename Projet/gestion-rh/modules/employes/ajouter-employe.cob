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
       01 SQL-RECORD           PIC X(500).
       
       WORKING-STORAGE SECTION.
       
       01 WS-PRENOM            PIC X(30).
       01 WS-NOM               PIC X(30).
       01 WS-DEPT-ID           PIC 9(9).
       01 WS-POSTE-ID          PIC 9(9).
       01 WS-COMMANDE          PIC X(500).
       01 WS-MKDIR             PIC X(100).
       
       PROCEDURE DIVISION.
       
       DEBUT.
       
      *> Créer le répertoire temp (si inexistant)
           MOVE "mkdir -p temp" TO WS-MKDIR
           CALL "SYSTEM" USING WS-MKDIR.
       
           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        AJOUT EMPLOYE".
           DISPLAY "====================================".
       
           DISPLAY "Prenom : " WITH NO ADVANCING.
           ACCEPT WS-PRENOM.
       
           DISPLAY "Nom : " WITH NO ADVANCING.
           ACCEPT WS-NOM.
       
           DISPLAY "ID Departement : " WITH NO ADVANCING.
           ACCEPT WS-DEPT-ID.
       
           DISPLAY "ID Poste : " WITH NO ADVANCING.
           ACCEPT WS-POSTE-ID.
       
      *> Création du fichier SQL
           OPEN OUTPUT SQL-FILE.
       
           STRING
               "INSERT INTO employees "
               "(first_name,last_name,department_id,position_id) "
               "VALUES ('"
               FUNCTION TRIM(WS-PRENOM)
               "','"
               FUNCTION TRIM(WS-NOM)
               "',"
               WS-DEPT-ID
               ","
               WS-POSTE-ID
               ");"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.
       
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
       
      *> Exécution de la commande SQLite
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
      *    SELECT DEPT-FILE
      *        ASSIGN TO "temp/dept.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *        
      *    SELECT POSTE-FILE
      *        ASSIGN TO "temp/poste.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      *DATA DIVISION.
      *
      *FILE SECTION.
      *
      *FD SQL-FILE.
      *01 SQL-RECORD           PIC X(500).
      *
      *FD DEPT-FILE.
      *01 DEPT-RECORD          PIC X(100).
      *
      *FD POSTE-FILE.
      *01 POSTE-RECORD         PIC X(100).
      *
      *WORKING-STORAGE SECTION.
      *
      *01 WS-PRENOM            PIC X(30).
      *01 WS-NOM               PIC X(30).
      *01 WS-DEPT-ID           PIC 9(9).
      *01 WS-POSTE-ID          PIC 9(9).
      *01 WS-CHOIX             PIC 9(2).
      *
      *01 WS-COMMANDE          PIC X(500).
      *01 WS-COUNT             PIC 9(9).
      *01 WS-MKDIR             PIC X(100).
      *01 WS-AFFICHAGE         PIC X(100).
      *
      *PROCEDURE DIVISION.
      *
      *DEBUT.
      *
      **> Créer le répertoire temp
      *    STRING "mkdir -p temp" 
      *        DELIMITED BY SIZE
      *        INTO WS-MKDIR
      *    END-STRING.
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
      **> 1. Liste des départements
      *    DISPLAY SPACE.
      *    DISPLAY "--- LISTE DES DEPARTEMENTS ---".
      *    
      **> Commande simplifiée - utilisation de guillemets doubles
      *    STRING 
      *        "sqlite3 data/rh.db " 
      *        '"SELECT id FROM departments ORDER BY id;"' 
      *        " > temp/dept.tmp"
      *        DELIMITED BY SIZE
      *        INTO WS-COMMANDE
      *    END-STRING.
      *    
      *    CALL "SYSTEM" USING WS-COMMANDE.
      *    
      *    OPEN INPUT DEPT-FILE.
      *    MOVE 1 TO WS-COUNT.
      *    
      *    PERFORM UNTIL WS-COUNT > 50
      *        READ DEPT-FILE INTO DEPT-RECORD
      *            AT END EXIT PERFORM
      *        NOT AT END
      *            STRING 
      *                FUNCTION TRIM(DEPT-RECORD) 
      *                " - Departement"
      *                DELIMITED BY SIZE
      *                INTO WS-AFFICHAGE
      *            END-STRING
      *            DISPLAY WS-COUNT ". " WS-AFFICHAGE
      *            ADD 1 TO WS-COUNT
      *        END-READ
      *    END-PERFORM.
      *    
      *    CLOSE DEPT-FILE.
      *    SUBTRACT 1 FROM WS-COUNT.
      *    
      *    IF WS-COUNT = 0
      *        DISPLAY "ERREUR: Aucun departement trouve"
      *        STOP RUN
      *    END-IF.
      *    
      *    DISPLAY "Choisissez le departement (1-" 
      *            WS-COUNT "): " 
      *            WITH NO ADVANCING.
      *    ACCEPT WS-CHOIX.
      *    MOVE WS-CHOIX TO WS-DEPT-ID.
      *
      **> 2. Liste des postes
      *    DISPLAY SPACE.
      *    DISPLAY "--- LISTE DES POSTES ---".
      *    
      *    STRING 
      *        "sqlite3 data/rh.db " 
      *        '"SELECT id FROM postes ORDER BY id;"' 
      *        " > temp/poste.tmp"
      *        DELIMITED BY SIZE
      *        INTO WS-COMMANDE
      *    END-STRING.
      *    
      *    CALL "SYSTEM" USING WS-COMMANDE.
      *    
      *    OPEN INPUT POSTE-FILE.
      *    MOVE 1 TO WS-COUNT.
      *    
      *    PERFORM UNTIL WS-COUNT > 50
      *        READ POSTE-FILE INTO POSTE-RECORD
      *            AT END EXIT PERFORM
      *        NOT AT END
      *            STRING 
      *                FUNCTION TRIM(POSTE-RECORD) 
      *                " - Poste"
      *                DELIMITED BY SIZE
      *                INTO WS-AFFICHAGE
      *            END-STRING
      *            DISPLAY WS-COUNT ". " WS-AFFICHAGE
      *            ADD 1 TO WS-COUNT
      *        END-READ
      *    END-PERFORM.
      *    
      *    CLOSE POSTE-FILE.
      *    SUBTRACT 1 FROM WS-COUNT.
      *    
      *    IF WS-COUNT = 0
      *        DISPLAY "ERREUR: Aucun poste trouve"
      *        STOP RUN
      *    END-IF.
      *    
      *    DISPLAY "Choisissez le poste (1-" 
      *            WS-COUNT "): " 
      *            WITH NO ADVANCING.
      *    ACCEPT WS-CHOIX.
      *    MOVE WS-CHOIX TO WS-POSTE-ID.
      *
      **> 3. Insertion SQL
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
      **> 4. Exécution
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
      *01 SQL-RECORD           PIC X(1000).  *> Augmenté car la requête est plus longue
      *
      *WORKING-STORAGE SECTION.
      *
      *01 WS-PRENOM            PIC X(30).
      *01 WS-NOM               PIC X(30).
      * *> Remplacement des IDs par des noms textuels
      *01 WS-DEPT-NOM          PIC X(50).
      *01 WS-POSTE-NOM         PIC X(50).
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
      *    DISPLAY "Nom du Departement : " WITH NO ADVANCING.
      *    ACCEPT WS-DEPT-NOM.
      *
      *    DISPLAY "Nom du Poste : " WITH NO ADVANCING.
      *    ACCEPT WS-POSTE-NOM.
      *
      **> Création SQL avec sous-requêtes
      *
      *    OPEN OUTPUT SQL-FILE.
      *
      *    STRING
      *        "INSERT INTO employees "
      *        "(first_name, last_name, department_id, position_id) "
      *        "VALUES ('"
      *        FUNCTION TRIM(WS-PRENOM)
      *        "','"
      *        FUNCTION TRIM(WS-NOM)
      *        "', (SELECT department_id FROM departments WHERE "
      *        "department_name = '" FUNCTION TRIM(WS-DEPT-NOM) "'), "
      *        "(SELECT position_id FROM positions WHERE "
      *        "position_name = '" FUNCTION TRIM(WS-POSTE-NOM) "'));"
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
      