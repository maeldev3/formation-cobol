       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-DEPARTEMENT.
       AUTHOR. DEV.

      *> ==========================================
      *> MODIFICATION D'UN DÉPARTEMENT
      *> Ce programme permet de modifier le nom d'un
      *> département dans la base SQLite 'rh.db'.
      *> ==========================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

      *> Fichier temporaire contenant la requête SQL UPDATE
           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

      *> Fichier SQL : une seule ligne contenant la requête
       FD SQL-FILE.
       01 SQL-RECORD              PIC X(300).

       WORKING-STORAGE SECTION.

      *> Variables saisies par l'utilisateur
       01 WS-DEPARTMENT-ID        PIC 9(9).
       01 WS-NOUVEAU-NOM          PIC X(50).

      *> Variable pour la commande système (appel à sqlite3)
       01 WS-COMMANDE             PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> 1. Saisie des informations
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "      MODIFIER DEPARTEMENT".
           DISPLAY "====================================".

           DISPLAY "ID du departement : "
               WITH NO ADVANCING.
           ACCEPT WS-DEPARTMENT-ID.

           DISPLAY "Nouveau nom : "
               WITH NO ADVANCING.
           ACCEPT WS-NOUVEAU-NOM.

      *> ==========================================
      *> 2. Génération de la requête SQL UPDATE
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

      *> Construction de la chaîne SQL :
      *>   UPDATE departments SET department_name='nouveau nom'
      *>   WHERE department_id=ID;
           STRING
               "UPDATE departments SET "
               "department_name='"
               FUNCTION TRIM(WS-NOUVEAU-NOM)
               "' WHERE department_id="
               WS-DEPARTMENT-ID
               ";"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

      *> Écriture de la requête dans le fichier temporaire
           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================================
      *> 3. Exécution de la commande SQLite
      *> ==========================================

      *> Commande : sqlite3 data/rh.db < temp/sql.tmp
      *>   - lit la requête depuis le fichier temporaire
      *>   - l'exécute sur la base de données 'rh.db'
           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

      *> Appel au système d'exploitation pour exécuter la commande
           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================================
      *> 4. Confirmation de la modification
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "[OK] DEPARTEMENT MODIFIE.".

           STOP RUN.