       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-POSTE.
       AUTHOR. DEV.

      *> ==========================================
      *> MODIFICATION D'UN POSTE
      *> Ce programme permet de modifier le nom et le
      *> salaire d'un poste dans la table 'positions'
      *> de la base SQLite 'rh.db'.
      *> ==========================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

      *> Fichier temporaire qui contiendra la requête SQL UPDATE
           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

      *> Fichier SQL : une seule ligne contenant la requête à exécuter
       FD SQL-FILE.
       01 SQL-RECORD           PIC X(300).

       WORKING-STORAGE SECTION.

      *> Variables saisies par l'utilisateur
       01 WS-POSTE-ID          PIC 9(9).      *> Identifiant du poste
       01 WS-NOM-POSTE         PIC X(50).     *> Nouveau nom du poste
       01 WS-SALAIRE           PIC 9(9).      *> Nouveau salaire de base

      *> Variable pour stocker la commande système (appel à sqlite3)
       01 WS-COMMANDE          PIC X(300).

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> 1. Affichage de l'en-tête et saisie des informations
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "        MODIFIER POSTE".
           DISPLAY "====================================".

           DISPLAY "ID du poste : "
               WITH NO ADVANCING.
           ACCEPT WS-POSTE-ID.

           DISPLAY "Nouveau nom : "
               WITH NO ADVANCING.
           ACCEPT WS-NOM-POSTE.

           DISPLAY "Nouveau salaire : "
               WITH NO ADVANCING.
           ACCEPT WS-SALAIRE.

      *> ==========================================
      *> 2. Construction de la requête SQL UPDATE
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

      *> La requête va mettre à jour deux colonnes :
      *>   - position_name avec le nouveau nom (entre guillemets simples)
      *>   - base_salary avec le nouveau salaire (nombre)
      *>   - filtre sur position_id pour cibler le bon enregistrement
           STRING
               "UPDATE positions SET "
               "position_name='"
               FUNCTION TRIM(WS-NOM-POSTE)
               "', base_salary="
               WS-SALAIRE
               " WHERE position_id="
               WS-POSTE-ID
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
      *>   - sqlite3 : exécutable du gestionnaire de base de données
      *>   - data/rh.db : chemin vers la base SQLite
      *>   - < temp/sql.tmp : redirection d'entrée (lit la requête depuis le fichier)
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
           DISPLAY "[OK] POSTE MODIFIE".

           STOP RUN.