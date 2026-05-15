       IDENTIFICATION DIVISION.
       PROGRAM-ID. FICHIERS.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-SORTIE
               ASSIGN TO "sortie.txt"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-SORTIE.
       01 WS-LIGNE        PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-TEXTE        PIC X(50).
       01 WS-NOM          PIC X(20).
       01 WS-AGE          PIC 9(3).
       
       PROCEDURE DIVISION.
           OPEN OUTPUT FICHIER-SORTIE.
           
           DISPLAY "ENTREZ VOTRE NOM: ".
           ACCEPT WS-NOM.
           DISPLAY "ENTREZ VOTRE AGE: ".
           ACCEPT WS-AGE.
           
           STRING "NOM: " WS-NOM ", AGE: " WS-AGE
               INTO WS-LIGNE
           END-STRING.
           
           WRITE WS-LIGNE.
           CLOSE FICHIER-SORTIE.
           
           DISPLAY "DONNEES ENREGISTREES DANS sortie.txt".
           STOP RUN.


      *IDENTIFICATION DIVISION.
      *PROGRAM-ID. FICHIERS.
      *
      ** --------------------------------
      ** CONFIGURATION DU FICHIER
      ** --------------------------------
      *ENVIRONMENT DIVISION.
      *INPUT-OUTPUT SECTION.
      *FILE-CONTROL.
      *
      *    * Déclaration du fichier de sortie
      *    * "sortie.txt" sera créé dans le dossier courant
      *    SELECT FICHIER-SORTIE
      *        ASSIGN TO "sortie.txt"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      ** --------------------------------
      ** ZONE DE DONNÉES FICHIER
      ** --------------------------------
      *DATA DIVISION.
      *FILE SECTION.
      *
      ** FD = File Description
      *FD FICHIER-SORTIE.
      *
      ** Ligne à écrire dans le fichier
      *01 WS-LIGNE        PIC X(80).
      *
      ** --------------------------------
      ** VARIABLES MÉMOIRE
      ** --------------------------------
      *WORKING-STORAGE SECTION.
      *
      ** Texte temporaire (pas utilisé ici, optionnel)
      *01 WS-TEXTE        PIC X(50).
      *
      ** Nom saisi par utilisateur
      *01 WS-NOM          PIC X(20).
      *
      ** Age saisi (3 chiffres max)
      *01 WS-AGE          PIC 9(3).
      *
      ** --------------------------------
      ** LOGIQUE PRINCIPALE
      ** --------------------------------
      *PROCEDURE DIVISION.
      *
      *    * Ouvre le fichier en écriture
      *    * (crée le fichier ou remplace s'il existe)
      *    OPEN OUTPUT FICHIER-SORTIE
      *
      *    * Demande nom utilisateur
      *    DISPLAY "ENTREZ VOTRE NOM: "
      *    ACCEPT WS-NOM
      *
      *    * Demande âge
      *    DISPLAY "ENTREZ VOTRE AGE: "
      *    ACCEPT WS-AGE
      *
      *    * Concatène texte + nom + âge dans WS-LIGNE
      *    STRING "NOM: " WS-NOM ", AGE: " WS-AGE
      *        INTO WS-LIGNE
      *    END-STRING
      *
      *    * Écrit la ligne dans le fichier
      *    WRITE WS-LIGNE
      *
      *    * Ferme le fichier
      *    CLOSE FICHIER-SORTIE
      *
      *    * Message de confirmation
      *    DISPLAY "DONNEES ENREGISTREES DANS sortie.txt"
      *
      *    STOP RUN.