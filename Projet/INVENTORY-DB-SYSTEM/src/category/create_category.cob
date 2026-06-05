       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREATE-CATEGORY.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CAT
               ASSIGN TO "data/categories.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUT.

       DATA DIVISION.
       FILE SECTION.
       FD  FICHIER-CAT.
       01  ENREG-CAT.
           05  FCAT-ID         PIC 9(5).
           05  FCAT-NOM        PIC X(50).
           05  FCAT-DESC       PIC X(100).

       WORKING-STORAGE SECTION.
       01 CATEGORY-REC.
           05 CATEGORY-ID      PIC 9(5).
           05 CATEGORY-NAME    PIC X(50).
           05 CATEGORY-DESC    PIC X(100).
       01 WS-CMD               PIC X(500).
       01 WS-STATUT            PIC XX.   *> 2 caractères pour le code statut

       PROCEDURE DIVISION.
       MAIN.
           DISPLAY "CATEGORY NAME: "
           ACCEPT CATEGORY-NAME

           DISPLAY "DESCRIPTION: "
           ACCEPT CATEGORY-DESC

      *> 1. Insertion SQLite
           STRING
               "sqlite3 data/inventory.db ""INSERT INTO categories (nom_categorie, description) VALUES ('"
               FUNCTION TRIM(CATEGORY-NAME)
               "', '"
               FUNCTION TRIM(CATEGORY-DESC)
               "')"""
               INTO WS-CMD
           END-STRING
           CALL "SYSTEM" USING WS-CMD

      *> 2. Sauvegarde fichier (avec gestion d'erreur)
           OPEN EXTEND FICHIER-CAT
           IF WS-STATUT NOT = "00"
               DISPLAY "ERREUR ouverture fichier backup, code " WS-STATUT
               DISPLAY "Le fichier n'a pas été sauvegardé"
           ELSE
               MOVE 0 TO CATEGORY-ID
               MOVE CATEGORY-NAME TO FCAT-NOM
               MOVE CATEGORY-DESC TO FCAT-DESC
               WRITE ENREG-CAT
               CLOSE FICHIER-CAT
               DISPLAY "Sauvegarde fichier OK"
           END-IF

           DISPLAY "CATEGORY ADDED SUCCESSFULLY"
           STOP RUN.