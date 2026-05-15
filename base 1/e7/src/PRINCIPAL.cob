       IDENTIFICATION DIVISION.
       PROGRAM-ID. PRINCIPAL.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-UTILISATEURS
               ASSIGN TO "data/utilisateurs.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-UTILISATEURS.
       01 WS-ENREGISTREMENT PIC X(100).
       
       WORKING-STORAGE SECTION.
       01 WS-QUITTER       PIC X(1) VALUE 'N'.
           88 FIN-PROGRAMME VALUE 'O'.
       
       01 WS-MENU-CHOIX    PIC 9.
       
       01 WS-UTILISATEUR.
           05 WS-NOM       PIC X(30).
           05 WS-AGE       PIC 9(3).
           05 WS-VILLE     PIC X(30).
       
       01 WS-VALIDE        PIC 9.
       
       01 WS-LIGNE-OUT     PIC X(100).

       01 WS-STATUT PIC X(20).
       
       
       PROCEDURE DIVISION.
       MAIN.
           PERFORM 1000-INIT
           PERFORM UNTIL FIN-PROGRAMME
               PERFORM 2000-AFFICHER-MENU
               PERFORM 3000-TRAITER-MENU
           END-PERFORM
           PERFORM 9000-FERMER
           .
       
       1000-INIT.
           DISPLAY "INITIALISATION..."
           CALL "SYSTEM" USING "mkdir -p data"
           .
       
       2000-AFFICHER-MENU.
           DISPLAY " "
           DISPLAY "1. AJOUTER UN UTILISATEUR"
           DISPLAY "2. LISTER LES UTILISATEURS"
           DISPLAY "3. QUITTER"
           DISPLAY "VOTRE CHOIX: "
           ACCEPT WS-MENU-CHOIX
           .
       
       3000-TRAITER-MENU.
           EVALUATE WS-MENU-CHOIX
               WHEN 1
                   PERFORM 3100-AJOUTER
               WHEN 2
                   PERFORM 3200-LISTER
               WHEN 3
                   MOVE 'O' TO WS-QUITTER
               WHEN OTHER
                   DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       3100-AJOUTER.

           OPEN EXTEND FICHIER-UTILISATEURS
       
           DISPLAY "--- AJOUT UTILISATEUR ---"
           DISPLAY "NOM: "
           ACCEPT WS-NOM
           DISPLAY "AGE: "
           ACCEPT WS-AGE
       
           CALL "VALIDATION" USING WS-AGE, WS-VALIDE
       
           IF WS-VALIDE = 1
               DISPLAY "VILLE: "
               ACCEPT WS-VILLE
       
               STRING WS-NOM ";" WS-AGE ";" WS-VILLE
                    INTO WS-LIGNE-OUT
               END-STRING
       
               WRITE WS-ENREGISTREMENT FROM WS-LIGNE-OUT
               DISPLAY "UTILISATEUR AJOUTE AVEC SUCCES!"
       ELSE
               DISPLAY "AGE INVALIDE"
           END-IF
       
           CLOSE FICHIER-UTILISATEURS
           .
       3200-LISTER.
       
           DISPLAY "--- LISTE DES UTILISATEURS ---"
           DISPLAY "NOM | AGE | VILLE"
           DISPLAY "------------------------"
       
           OPEN INPUT FICHIER-UTILISATEURS
       
           PERFORM UNTIL EOF
               READ FICHIER-UTILISATEURS
                    AT END
                        MOVE 'Y' TO WS-STATUT
                    NOT AT END
                        DISPLAY WS-ENREGISTREMENT
               END-READ
           END-PERFORM
       
           CLOSE FICHIER-UTILISATEURS
           .
       
       9000-FERMER.
           CLOSE FICHIER-UTILISATEURS
           DISPLAY "MERCI, AU REVOIR!"
           STOP RUN.