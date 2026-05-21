       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-LIVRES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-LIVRES ASSIGN TO 'data/input/LIVRES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUT.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-LIVRES.
       01 ENREG-LIVRE.
           05 ENREG-ISBN       PIC X(17).
           05 FILLER           PIC X(1).
           05 ENREG-TITRE      PIC X(30).
           05 FILLER           PIC X(1).
           05 ENREG-AUTEUR     PIC X(20).
           05 FILLER           PIC X(1).
           05 ENREG-CATEGORIE  PIC X(15).
           05 FILLER           PIC X(1).
           05 ENREG-QUANTITE   PIC 9(3).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN-FICHIER      PIC X VALUE 'N'.
           88 FIN-FICHIER     VALUE 'O'.
       01 WS-COMPTEUR         PIC 9(3) VALUE 0.
       01 WS-STATUT           PIC XX.
           88 WS-OK           VALUE '00'.
           88 WS-FIN-FICHIER-OK VALUE '10'.
           88 WS-FICHIER-INTROUVABLE VALUE '35'.
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "=== LISTE DES LIVRES ==="
           DISPLAY "ISBN               TITRE                          AUTEUR               CATEGORIE     QTE"
           DISPLAY "---------------------------------------------------------------------------------------"
           
           OPEN INPUT FICHIER-LIVRES
           
           IF WS-FICHIER-INTROUVABLE
               DISPLAY "ERREUR: Fichier data/input/LIVRES.DAT non trouve"
               DISPLAY "Verifiez que le fichier existe."
               STOP RUN
           END-IF
           
           IF NOT WS-OK
               DISPLAY "ERREUR OUVERTURE FICHIER - STATUT: " WS-STATUT
               STOP RUN
           END-IF
           
           MOVE 0 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN-FICHIER
           
           PERFORM UNTIL FIN-FICHIER
               READ FICHIER-LIVRES
                   AT END 
                       SET FIN-FICHIER TO TRUE
                   NOT AT END
                       ADD 1 TO WS-COMPTEUR
                       DISPLAY 
                           ENREG-ISBN " " 
                           FUNCTION TRIM(ENREG-TITRE) " " 
                           FUNCTION TRIM(ENREG-AUTEUR) " " 
                           FUNCTION TRIM(ENREG-CATEGORIE) " " 
                           ENREG-QUANTITE
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-LIVRES
           
           DISPLAY "---------------------------------------------------------------------------------------"
           DISPLAY "TOTAL LIVRES: " WS-COMPTEUR
           
           STOP RUN.