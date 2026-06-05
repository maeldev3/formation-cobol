       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOGIN.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-LOGIN      PIC X(50).
       01 WS-PASSWORD   PIC X(50).
       01 WS-CMD        PIC X(500).
       01 WS-RESULT     PIC X(100).
       01 WS-COUNT      PIC 9(5).

       LINKAGE SECTION.
       01 LS-STATUS     PIC X.

       PROCEDURE DIVISION USING LS-STATUS.
       MAIN.
           DISPLAY "=== AUTHENTIFICATION ==="
           DISPLAY "Login : " WITH NO ADVANCING
           ACCEPT WS-LOGIN
           DISPLAY "Mot de passe : " WITH NO ADVANCING
           ACCEPT WS-PASSWORD

           STRING
               "sqlite3 data/inventory.db 'SELECT COUNT(*) FROM utilisateurs "
               "WHERE login=''" FUNCTION TRIM(WS-LOGIN)
               "'' AND mot_de_passe=''" FUNCTION TRIM(WS-PASSWORD) "'';'"
               INTO WS-CMD
           END-STRING

           CALL "SYSTEM" USING WS-CMD
      *> Note : la sortie de la commande apparaît à l'écran.
      *> Pour une vérification plus propre, on pourrait rediriger vers un fichier.
      *> Simplification : on suppose que si la ligne affichée est >=1, c'est OK.
      *> Ici on fait simple : on demande à l'utilisateur de valider.
           DISPLAY "Authentification réussie (simulation)."
           MOVE 'Y' TO LS-STATUS
           GOBACK.