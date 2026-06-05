       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-DEPARTEMENTS.
       AUTHOR. DEV.

      *> ==========================================
      *> LISTE DES DEPARTEMENTS
      *> Ce programme génère une requête SQL, l'exécute
      *> sur une base SQLite, puis affiche le résultat.
      *> ==========================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

      *> Déclaration du fichier contenant la requête SQL
           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

      *> Déclaration du fichier contenant le résultat de la requête
           SELECT RESULT-FILE
               ASSIGN TO "temp/result.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

      *> Fichier SQL : contient la requête à exécuter
       FD SQL-FILE.
       01 SQL-RECORD             PIC X(300).

      *> Fichier résultat : contient la sortie de SQLite
       FD RESULT-FILE.
       01 RESULT-RECORD          PIC X(300).

       WORKING-STORAGE SECTION.

      *> Variable pour construire la commande système
       01 WS-COMMANDE            PIC X(300).

      *> Indicateur de fin de fichier pour la lecture du résultat
       01 WS-FIN-FICHIER         PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> 1. Création de la requête SQL
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

      *> La requête sélectionne l'identifiant et le nom
      *> de chaque département dans la table 'departments'
           MOVE
               "SELECT department_id, department_name FROM departments;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================================
      *> 2. Exécution de la commande SQLite
      *> ==========================================

      *> Construction de la commande système :
      *>   - sqlite3 : exécutable
      *>   - -separator ' | ' : séparateur entre colonnes
      *>   - data/rh.db : chemin de la base de données
      *>   - < temp/sql.tmp : lit la requête depuis le fichier temporaire
      *>   - > temp/result.tmp : redirige la sortie vers un fichier
           STRING
               "sqlite3 -separator ' | ' data/rh.db "
               "< temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

      *> Appel au système d'exploitation pour exécuter la commande
           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================================
      *> 3. Affichage du résultat
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY
               "====================================".

           DISPLAY
               "      LISTE DES DEPARTEMENTS".

           DISPLAY
               "====================================".

      *> Ouverture du fichier résultat pour lecture
           OPEN INPUT RESULT-FILE.

           MOVE "N" TO WS-FIN-FICHIER.

      *> Boucle de lecture ligne par ligne jusqu'à la fin du fichier
           PERFORM UNTIL WS-FIN-FICHIER = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-FIN-FICHIER
                   NOT AT END
                       DISPLAY FUNCTION TRIM(RESULT-RECORD)
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.

           STOP RUN.