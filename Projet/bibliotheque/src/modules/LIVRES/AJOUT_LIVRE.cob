       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-LIVRE.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ISBN           PIC X(17).
       01 WS-TITRE          PIC X(30).
       01 WS-AUTEUR         PIC X(20).
       01 WS-CATEGORIE      PIC X(15).
       01 WS-QUANTITE       PIC 9(3).
       
       PROCEDURE DIVISION.
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
           
           STOP RUN.
