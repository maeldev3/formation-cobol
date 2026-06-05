      *================================================================*
      *  ATM-INIT.CBL - INITIALISATION BASE DE DONNÉES ATM            *
      *  Crée les fichiers indexés et charge les données de démo      *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-INIT.
       AUTHOR. SYSTEME-BANCAIRE.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENTS ASSIGN TO "data/CLIENTS.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS CLIENT-ID
               ALTERNATE RECORD KEY IS CLIENT-NOM
                   WITH DUPLICATES
               FILE STATUS IS WS-FS-CLIENTS.

           SELECT FICHIER-COMPTES ASSIGN TO "data/COMPTES.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS COMPTE-ID
               ALTERNATE RECORD KEY IS COMPTE-NUMERO
               FILE STATUS IS WS-FS-COMPTES.

           SELECT FICHIER-CARTES ASSIGN TO "data/CARTES.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS CARTE-ID
               ALTERNATE RECORD KEY IS CARTE-NUMERO
               FILE STATUS IS WS-FS-CARTES.

       DATA DIVISION.
       FILE SECTION.

       FD  FICHIER-CLIENTS.
       01  ENREG-CLIENT.
           05  CLIENT-ID           PIC 9(5).
           05  CLIENT-NOM          PIC X(50).
           05  CLIENT-PRENOM       PIC X(50).
           05  CLIENT-NAISSANCE    PIC X(10).
           05  CLIENT-ADRESSE      PIC X(100).
           05  CLIENT-TEL          PIC X(20).

       FD  FICHIER-COMPTES.
       01  ENREG-COMPTE.
           05  COMPTE-ID           PIC 9(5).
           05  COMPTE-CLIENT-ID    PIC 9(5).
           05  COMPTE-NUMERO       PIC X(24).
           05  COMPTE-TYPE         PIC X(10).
           05  COMPTE-SOLDE        PIC S9(13)V99.
           05  COMPTE-PLAFOND      PIC S9(8)V99.
           05  COMPTE-DATE-OUV     PIC X(10).
           05  COMPTE-ACTIF        PIC 9.

       FD  FICHIER-CARTES.
       01  ENREG-CARTE.
           05  CARTE-ID            PIC 9(5).
           05  CARTE-COMPTE-ID     PIC 9(5).
           05  CARTE-NUMERO        PIC X(19).
           05  CARTE-PIN           PIC X(4).
           05  CARTE-EXPIRATION    PIC X(10).
           05  CARTE-ACTIF         PIC 9.
           05  CARTE-TENTATIVES    PIC 9.
           05  CARTE-BLOQUE        PIC 9.

       WORKING-STORAGE SECTION.
       01  WS-FS-CLIENTS           PIC XX VALUE SPACES.
       01  WS-FS-COMPTES           PIC XX VALUE SPACES.
       01  WS-FS-CARTES            PIC XX VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-INIT.
           DISPLAY "================================================="
           DISPLAY "  ATM - Initialisation des données"
           DISPLAY "================================================="
           DISPLAY " "

           OPEN OUTPUT FICHIER-CLIENTS
           OPEN OUTPUT FICHIER-COMPTES
           OPEN OUTPUT FICHIER-CARTES

           PERFORM INIT-CLIENTS
           PERFORM INIT-COMPTES
           PERFORM INIT-CARTES

           CLOSE FICHIER-CLIENTS
           CLOSE FICHIER-COMPTES
           CLOSE FICHIER-CARTES

           DISPLAY " "
           DISPLAY "  [OK] Initialisation terminée avec succès."
           DISPLAY "  Fichiers créés dans le répertoire data/"
           DISPLAY " "
           STOP RUN.

       INIT-CLIENTS.
           DISPLAY "  Création des clients..."

           MOVE 1            TO CLIENT-ID
           MOVE "DUPONT"     TO CLIENT-NOM
           MOVE "Jean"       TO CLIENT-PRENOM
           MOVE "1980-05-12" TO CLIENT-NAISSANCE
           MOVE "12 rue de Paris, 75001 Paris" TO CLIENT-ADRESSE
           MOVE "0612345678" TO CLIENT-TEL
           WRITE ENREG-CLIENT

           MOVE 2            TO CLIENT-ID
           MOVE "MARTIN"     TO CLIENT-NOM
           MOVE "Sophie"     TO CLIENT-PRENOM
           MOVE "1992-09-23" TO CLIENT-NAISSANCE
           MOVE "45 avenue des Champs, 69000 Lyon" TO CLIENT-ADRESSE
           MOVE "0698765432" TO CLIENT-TEL
           WRITE ENREG-CLIENT

           MOVE 3            TO CLIENT-ID
           MOVE "RAKOTO"     TO CLIENT-NOM
           MOVE "Hery"       TO CLIENT-PRENOM
           MOVE "1988-11-03" TO CLIENT-NAISSANCE
           MOVE "Lot IVA 32 Antananarivo" TO CLIENT-ADRESSE
           MOVE "+261341234567" TO CLIENT-TEL
           WRITE ENREG-CLIENT

           DISPLAY "  [OK] 3 clients créés.".

       INIT-COMPTES.
           DISPLAY "  Création des comptes..."

           MOVE 1                         TO COMPTE-ID
           MOVE 1                         TO COMPTE-CLIENT-ID
           MOVE "FR7612345000012345678901" TO COMPTE-NUMERO
           MOVE "COURANT"                 TO COMPTE-TYPE
           MOVE 1250,75                   TO COMPTE-SOLDE
           MOVE 300,00                    TO COMPTE-PLAFOND
           MOVE "2020-01-15"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE

           MOVE 2                         TO COMPTE-ID
           MOVE 1                         TO COMPTE-CLIENT-ID
           MOVE "FR7612345000012345678902" TO COMPTE-NUMERO
           MOVE "EPARGNE"                 TO COMPTE-TYPE
           MOVE 5000,00                   TO COMPTE-SOLDE
           MOVE 500,00                    TO COMPTE-PLAFOND
           MOVE "2020-01-15"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE

           MOVE 3                         TO COMPTE-ID
           MOVE 2                         TO COMPTE-CLIENT-ID
           MOVE "FR7698765000012345678903" TO COMPTE-NUMERO
           MOVE "COURANT"                 TO COMPTE-TYPE
           MOVE 850,30                    TO COMPTE-SOLDE
           MOVE 200,00                    TO COMPTE-PLAFOND
           MOVE "2021-03-20"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE

           MOVE 4                         TO COMPTE-ID
           MOVE 3                         TO COMPTE-CLIENT-ID
           MOVE "MG0000001234567890123456" TO COMPTE-NUMERO
           MOVE "COURANT"                 TO COMPTE-TYPE
           MOVE 2500,00                   TO COMPTE-SOLDE
           MOVE 400,00                    TO COMPTE-PLAFOND
           MOVE "2022-06-10"              TO COMPTE-DATE-OUV
           MOVE 1                         TO COMPTE-ACTIF
           WRITE ENREG-COMPTE

           DISPLAY "  [OK] 4 comptes créés.".

       INIT-CARTES.
           DISPLAY "  Création des cartes..."

           MOVE 1                    TO CARTE-ID
           MOVE 1                    TO CARTE-COMPTE-ID
           MOVE "4978 1234 5678 9012" TO CARTE-NUMERO
           MOVE "1234"               TO CARTE-PIN
           MOVE "2028-12-31"         TO CARTE-EXPIRATION
           MOVE 1 TO CARTE-ACTIF
           MOVE 0 TO CARTE-TENTATIVES
           MOVE 0 TO CARTE-BLOQUE
           WRITE ENREG-CARTE

           MOVE 2                    TO CARTE-ID
           MOVE 2                    TO CARTE-COMPTE-ID
           MOVE "4978 2345 6789 0123" TO CARTE-NUMERO
           MOVE "1111"               TO CARTE-PIN
           MOVE "2027-10-31"         TO CARTE-EXPIRATION
           MOVE 1 TO CARTE-ACTIF
           MOVE 0 TO CARTE-TENTATIVES
           MOVE 0 TO CARTE-BLOQUE
           WRITE ENREG-CARTE

           MOVE 3                    TO CARTE-ID
           MOVE 3                    TO CARTE-COMPTE-ID
           MOVE "4978 3456 7890 1234" TO CARTE-NUMERO
           MOVE "4321"               TO CARTE-PIN
           MOVE "2026-05-31"         TO CARTE-EXPIRATION
           MOVE 1 TO CARTE-ACTIF
           MOVE 0 TO CARTE-TENTATIVES
           MOVE 0 TO CARTE-BLOQUE
           WRITE ENREG-CARTE

           MOVE 4                    TO CARTE-ID
           MOVE 4                    TO CARTE-COMPTE-ID
           MOVE "5368 9876 5432 1098" TO CARTE-NUMERO
           MOVE "0000"               TO CARTE-PIN
           MOVE "2029-03-31"         TO CARTE-EXPIRATION
           MOVE 1 TO CARTE-ACTIF
           MOVE 0 TO CARTE-TENTATIVES
           MOVE 0 TO CARTE-BLOQUE
           WRITE ENREG-CARTE

           DISPLAY "  [OK] 4 cartes créées.".
