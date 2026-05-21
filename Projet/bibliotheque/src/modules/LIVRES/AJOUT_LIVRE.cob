       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-LIVRE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-LIVRES ASSIGN TO 'data/input/LIVRES.DAT'
           ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-LIVRES.
       01 ENREG-LIVRE.
           05 ENREG-ISBN       PIC X(17).
           05 ENREG-TITRE      PIC X(30).
           05 ENREG-AUTEUR     PIC X(20).
           05 ENREG-CATEGORIE  PIC X(15).
           05 ENREG-QUANTITE   PIC 9(3).
       
       WORKING-STORAGE SECTION.
       01 WS-ISBN           PIC X(17).
       01 WS-TITRE          PIC X(30).
       01 WS-AUTEUR         PIC X(20).
       01 WS-CATEGORIE      PIC X(15).
       01 WS-QUANTITE       PIC 9(3).
       01 WS-CONFIRMATION   PIC X(01).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY "=== AJOUTER UN LIVRE ==="
           DISPLAY " "
           
           DISPLAY "ISBN : "
           ACCEPT WS-ISBN
           
           DISPLAY "TITRE : "
           ACCEPT WS-TITRE
           
           DISPLAY "AUTEUR : "
           ACCEPT WS-AUTEUR
           
           DISPLAY "CATEGORIE : "
           ACCEPT WS-CATEGORIE
           
           DISPLAY "QUANTITE : "
           ACCEPT WS-QUANTITE
           
           DISPLAY " "
           DISPLAY "--- NOUVEAU LIVRE ---"
           DISPLAY "ISBN     : " WS-ISBN
           DISPLAY "TITRE    : " WS-TITRE
           DISPLAY "AUTEUR   : " WS-AUTEUR
           DISPLAY "CATEGORIE: " WS-CATEGORIE
           DISPLAY "QUANTITE : " WS-QUANTITE
           DISPLAY " "
           
           DISPLAY "Confirmer l'ajout ? (O/N) : "
           ACCEPT WS-CONFIRMATION
           
           IF WS-CONFIRMATION = 'O' OR 'o'
               PERFORM AJOUTER-FICHIER
               DISPLAY "*** LIVRE AJOUTE AVEC SUCCES ***"
           ELSE
               DISPLAY "*** AJOUT ANNULE ***"
           END-IF.
           
           STOP RUN.
       
       AJOUTER-FICHIER.
           OPEN EXTEND FICHIER-LIVRES
           
           MOVE WS-ISBN TO ENREG-ISBN
           MOVE WS-TITRE TO ENREG-TITRE
           MOVE WS-AUTEUR TO ENREG-AUTEUR
           MOVE WS-CATEGORIE TO ENREG-CATEGORIE
           MOVE WS-QUANTITE TO ENREG-QUANTITE
           
           WRITE ENREG-LIVRE
           
           CLOSE FICHIER-LIVRES.