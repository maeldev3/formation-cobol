       IDENTIFICATION DIVISION.
       PROGRAM-ID. BIBLIOTHEQUE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT FICHIER-LIVRES
               ASSIGN TO "livres.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT FICHIER-ABONNES
               ASSIGN TO "abonnes.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD FICHIER-LIVRES.
       01 FS-LIVRE.
           05 FS-ID        PIC 9(4).
           05 FS-TITRE     PIC X(40).
           05 FS-AUTEUR    PIC X(30).
           05 FS-STATUT    PIC X(1).
           05 FS-EMPRUNTE  PIC X(30).

       FD FICHIER-ABONNES.
       01 FS-ABONNE.
           05 FS-AID       PIC 9(4).
           05 FS-NOM       PIC X(30).

       WORKING-STORAGE SECTION.

       01 WS-CHOIX        PIC 9.
       01 WS-FIN          PIC X VALUE 'N'.

       01 WS-ID           PIC 9(4).
       01 WS-NOM          PIC X(40).
       01 WS-AUTEUR       PIC X(30).
       01 WS-ABONNE-ID    PIC 9(4).

       01 WS-TROUVE       PIC X VALUE 'N'.

       PROCEDURE DIVISION.

       MAIN.
           PERFORM 1000-INIT
           PERFORM UNTIL WS-FIN = 'O'
               PERFORM 2000-MENU
               PERFORM 3000-TRAITEMENT
           END-PERFORM
           PERFORM 9000-FIN
           STOP RUN.

       *---------------- INIT ----------------
       1000-INIT.
           OPEN I-O FICHIER-LIVRES
           OPEN I-O FICHIER-ABONNES
           DISPLAY "=== BIBLIOTHEQUE PROFESSIONNELLE ==="
           .

       *---------------- MENU ----------------
       2000-MENU.
           DISPLAY " "
           DISPLAY "1. Ajouter livre"
           DISPLAY "2. Lister livres"
           DISPLAY "3. Modifier livre"
           DISPLAY "4. Supprimer livre"
           DISPLAY "5. Emprunter livre"
           DISPLAY "6. Retour livre"
           DISPLAY "7. Quitter"
           ACCEPT WS-CHOIX
           .

       *---------------- CONTROLE ----------------
       3000-TRAITEMENT.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-AJOUTER
               WHEN 2 PERFORM 4100-LISTER
               WHEN 3 PERFORM 4200-MODIFIER
               WHEN 4 PERFORM 4300-SUPPRIMER
               WHEN 5 PERFORM 4400-EMPRUNTER
               WHEN 6 PERFORM 4500-RETOUR
               WHEN 7 MOVE 'O' TO WS-FIN
               WHEN OTHER DISPLAY "Choix invalide"
           END-EVALUATE
           .

       *---------------- CREATE ----------------
       4000-AJOUTER.
           DISPLAY "ID livre: "
           ACCEPT FS-ID

           READ FICHIER-LIVRES
               INVALID KEY

                   DISPLAY "Titre: "
                   ACCEPT FS-TITRE
                   DISPLAY "Auteur: "
                   ACCEPT FS-AUTEUR

                   MOVE 'D' TO FS-STATUT
                   MOVE SPACES TO FS-EMPRUNTE

                   WRITE FS-LIVRE
                   DISPLAY "Livre ajoute!"
               NOT INVALID KEY
                   DISPLAY "ID deja existant!"
           END-READ
           .

       *---------------- READ ----------------
       4100-LISTER.
           DISPLAY "--- LISTE DES LIVRES ---"

           MOVE 0 TO FS-ID

           START FICHIER-LIVRES KEY IS NOT < FS-ID

           PERFORM UNTIL WS-TROUVE = 'E'
               READ FICHIER-LIVRES NEXT
                   AT END
                       MOVE 'E' TO WS-TROUVE
                   NOT AT END
                       DISPLAY FS-ID " | " FS-TITRE
                       IF FS-STATUT = 'D'
                           DISPLAY "   DISPONIBLE"
                       ELSE
                           DISPLAY "   EMPRUNTE par " FS-EMPRUNTE
                       END-IF
               END-READ
           END-PERFORM

           MOVE 'N' TO WS-TROUVE
           .

       *---------------- UPDATE ----------------
       4200-MODIFIER.
           DISPLAY "ID livre: "
           ACCEPT FS-ID

           READ FICHIER-LIVRES
               INVALID KEY
                   DISPLAY "Introuvable"
               NOT INVALID KEY
                   DISPLAY "Nouveau titre: "
                   ACCEPT FS-TITRE
                   DISPLAY "Nouvel auteur: "
                   ACCEPT FS-AUTEUR
                   REWRITE FS-LIVRE
                   DISPLAY "Modifie!"
           END-READ
           .

       *---------------- DELETE ----------------
       4300-SUPPRIMER.
           DISPLAY "ID livre: "
           ACCEPT FS-ID

           READ FICHIER-LIVRES
               INVALID KEY
                   DISPLAY "Introuvable"
               NOT INVALID KEY
                   DELETE FICHIER-LIVRES
                   DISPLAY "Supprime!"
           END-READ
           .

       *---------------- EMPRUNT ----------------
       4400-EMPRUNTER.
           DISPLAY "ID livre: "
           ACCEPT FS-ID

           READ FICHIER-LIVRES
               INVALID KEY
                   DISPLAY "Livre introuvable"
               NOT INVALID KEY
                   IF FS-STATUT = 'D'
                       DISPLAY "Nom abonne: "
                       ACCEPT FS-EMPRUNTE

                       MOVE 'E' TO FS-STATUT
                       REWRITE FS-LIVRE
                       DISPLAY "Emprunt OK"
                   ELSE
                       DISPLAY "Deja emprunte"
                   END-IF
           END-READ
           .

       *---------------- RETOUR ----------------
       4500-RETOUR.
           DISPLAY "ID livre: "
           ACCEPT FS-ID

           READ FICHIER-LIVRES
               INVALID KEY
                   DISPLAY "Introuvable"
               NOT INVALID KEY
                   MOVE 'D' TO FS-STATUT
                   MOVE SPACES TO FS-EMPRUNTE
                   REWRITE FS-LIVRE
                   DISPLAY "Retour OK"
           END-READ
           .

       *---------------- FIN ----------------
       9000-FIN.
           CLOSE FICHIER-LIVRES
           CLOSE FICHIER-ABONNES
           DISPLAY "Au revoir!"
           .
