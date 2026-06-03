       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTHENTIFIER.
       AUTHOR. DEV.

      *> ---------------------------------------------------------
      *> AUTHENTIFICATION + ROLE + SESSION
      *> ---------------------------------------------------------

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
       01 SQL-RECORD              PIC X(300).

       FD RESULT-FILE.
       01 RESULT-RECORD           PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-LOGIN                PIC X(20).
       01 WS-PIN                  PIC X(10).

       01 WS-COMMANDE             PIC X(300).

       01 WS-USER-ID              PIC 9(9) VALUE 0.
       01 WS-ROLE                 PIC X(20) VALUE SPACES.
       01 WS-SESSION-OK          PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "========================================".
           DISPLAY "      SYSTEME RH - CONNEXION".
           DISPLAY "========================================".

           DISPLAY "Login : " WITH NO ADVANCING.
           ACCEPT WS-LOGIN.

           DISPLAY "PIN   : " WITH NO ADVANCING.
           ACCEPT WS-PIN.

      *> ---------------------------------------------------------
      *> SQL : récupérer ID + ROLE
      *> ---------------------------------------------------------

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "SELECT user_id || '|' || role "
               "FROM users "
               "WHERE login='"
               FUNCTION TRIM(WS-LOGIN)
               "' AND pin='"
               FUNCTION TRIM(WS-PIN)
               "';"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

      *> ---------------------------------------------------------
      *> EXECUTION SQLITE
      *> ---------------------------------------------------------

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

      *> ---------------------------------------------------------
      *> LECTURE RESULTAT
      *> ---------------------------------------------------------

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END
                   MOVE SPACES TO RESULT-RECORD
               NOT AT END
                   CONTINUE
           END-READ.

           CLOSE RESULT-FILE.

      *> ---------------------------------------------------------
      *> PARSING RESULTAT
      *> format attendu : user_id|role
      *> ---------------------------------------------------------

           IF RESULT-RECORD NOT = SPACES

               UNSTRING RESULT-RECORD
                   DELIMITED BY "|"
                   INTO WS-USER-ID WS-ROLE
               END-UNSTRING

               MOVE "O" TO WS-SESSION-OK

           END-IF.

      *> ---------------------------------------------------------
      *> VERIFICATION
      *> ---------------------------------------------------------

           IF WS-SESSION-OK = "O" AND WS-USER-ID > 0

               DISPLAY SPACE
               DISPLAY "[OK] CONNEXION REUSSIE"
               DISPLAY "USER ID : " WS-USER-ID
               DISPLAY "ROLE     : " WS-ROLE

           ELSE

               DISPLAY SPACE
               DISPLAY "[ERREUR] LOGIN OU PIN INCORRECT"
               STOP RUN

           END-IF.

           STOP RUN.







      *IDENTIFICATION DIVISION.
      *PROGRAM-ID. AUTHENTIFIER.
      *AUTHOR. DEV.
      **> ---------------------------------------------------------
      **> Programme : AUTHENTIFIER
      **> Objet     : Authentification utilisateur via SQLite
      **> Base      : data/rh.db
      **> Fonction  :
      **>   - Saisir login et PIN
      **>   - Générer une requête SQL
      **>   - Exécuter SQLite
      **>   - Vérifier si l'utilisateur existe
      **>   - Afficher le résultat de connexion
      **> ---------------------------------------------------------
      *
      *ENVIRONMENT DIVISION.
      *INPUT-OUTPUT SECTION.
      *FILE-CONTROL.
      *
      **> Fichier temporaire contenant la requête SQL
      *    SELECT SQL-FILE
      *        ASSIGN TO "temp/sql.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      **> Fichier temporaire contenant le résultat SQLite
      *    SELECT RESULT-FILE
      *        ASSIGN TO "temp/result.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      *DATA DIVISION.
      *
      *FILE SECTION.
      *
      **> ---------------------------------------------------------
      **> Fichier de requête SQL
      **> ---------------------------------------------------------
      *FD SQL-FILE.
      *01 SQL-RECORD              PIC X(200).
      *
      **> ---------------------------------------------------------
      **> Fichier résultat SQLite
      **> ---------------------------------------------------------
      *FD RESULT-FILE.
      *01 RESULT-RECORD           PIC X(200).
      *
      *WORKING-STORAGE SECTION.
      *
      **> ---------------------------------------------------------
      **> Données saisies par l'utilisateur
      **> ---------------------------------------------------------
      *01 WS-LOGIN                PIC X(20).
      *01 WS-PIN                  PIC X(4).
      *
      **> ---------------------------------------------------------
      **> Commande système SQLite
      **> ---------------------------------------------------------
      *01 WS-COMMANDE             PIC X(300).
      *
      **> ---------------------------------------------------------
      **> Identifiant utilisateur récupéré depuis la base
      **> Valeur 0 = utilisateur non trouvé
      **> ---------------------------------------------------------
      *01 WS-USER-ID              PIC 9(9) VALUE 0.
      *
      *PROCEDURE DIVISION.
      *
      **> =========================================================
      **> POINT D'ENTREE PRINCIPAL
      **> =========================================================
      *DEBUT.
      *
      **> Affichage de l'écran d'authentification
      *    DISPLAY SPACE.
      *    DISPLAY "========================================".
      *    DISPLAY "      SYSTEME RH - CONNEXION".
      *    DISPLAY "========================================".
      *
      **> Saisie du login
      *    DISPLAY "Login : " WITH NO ADVANCING.
      *    ACCEPT WS-LOGIN.
      *
      **> Saisie du PIN
      *    DISPLAY "PIN   : " WITH NO ADVANCING.
      *    ACCEPT WS-PIN.
      *
      **> ---------------------------------------------------------
      **> Construction de la requête SQL
      **> Exemple :
      **> SELECT user_id
      **> FROM users
      **> WHERE login='admin'
      **> AND pin='1234';
      **> ---------------------------------------------------------
      *    OPEN OUTPUT SQL-FILE.
      *
      *    STRING
      *        "SELECT user_id FROM users "
      *        "WHERE login='"
      *        FUNCTION TRIM(WS-LOGIN)
      *        "' AND pin='"
      *        WS-PIN
      *        "';"
      *        DELIMITED BY SIZE
      *        INTO SQL-RECORD
      *    END-STRING.
      *
      *    WRITE SQL-RECORD.
      *
      *    CLOSE SQL-FILE.
      *
      **> ---------------------------------------------------------
      **> Exécution de SQLite
      **> Le résultat est enregistré dans temp/result.tmp
      **> ---------------------------------------------------------
      *    STRING
      *        "sqlite3 data/rh.db < temp/sql.tmp "
      *        "> temp/result.tmp"
      *        DELIMITED BY SIZE
      *        INTO WS-COMMANDE
      *    END-STRING.
      *
      *    CALL "SYSTEM" USING WS-COMMANDE.
      *
      **> ---------------------------------------------------------
      **> Lecture du résultat retourné par SQLite
      **> ---------------------------------------------------------
      *    OPEN INPUT RESULT-FILE.
      *
      *    READ RESULT-FILE
      *        INTO RESULT-RECORD
      *        AT END
      *            CONTINUE
      *    END-READ.
      *
      *    CLOSE RESULT-FILE.
      *
      **> ---------------------------------------------------------
      **> Conversion du résultat texte vers numérique
      **> ---------------------------------------------------------
      *    IF RESULT-RECORD NOT = SPACES
      *        MOVE FUNCTION NUMVAL(RESULT-RECORD)
      *            TO WS-USER-ID
      *    END-IF.
      *
      **> ---------------------------------------------------------
      **> Vérification de l'authentification
      **> ---------------------------------------------------------
      *    IF WS-USER-ID > 0
      *        DISPLAY SPACE
      *        DISPLAY "[OK] AUTHENTIFICATION REUSSIE"
      *        DISPLAY "ID UTILISATEUR : " WS-USER-ID
      *    ELSE
      *        DISPLAY SPACE
      *        DISPLAY "[ERREUR] LOGIN OU PIN INCORRECT"
      *    END-IF.
      *
      **> Fin du programme
      *    STOP RUN.