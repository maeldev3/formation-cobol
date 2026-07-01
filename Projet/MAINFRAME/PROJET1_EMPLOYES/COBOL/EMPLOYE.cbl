      ******************************************************************
      * PROGRAMME   : EMPLOYE                                         *
      * NIVEAU      : DEBUTANT                                        *
      * DESCRIPTION : LECTURE D'UN FICHIER SEQUENTIEL D'EMPLOYES ET   *
      *               AFFICHAGE DE CHAQUE ENREGISTREMENT, PUIS D'UN   *
      *               RECAPITULATIF (NOMBRE D'EMPLOYES, MASSE         *
      *               SALARIALE TOTALE)                               *
      * FICHIER ENTREE (DD EMPFILE) - UN ENREGISTREMENT PAR EMPLOYE : *
      *     POSITION  1- 5  : MATRICULE  (5 CARACTERES)               *
      *     POSITION  6-25  : NOM        (20 CARACTERES)              *
      *     POSITION 26-40  : PRENOM     (15 CARACTERES)               *
      *     POSITION 41-50  : SERVICE    (10 CARACTERES)               *
      *     POSITION 51-58  : SALAIRE    (8 CHIFFRES, 2 DECIMALES)    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPLOYE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-EMPLOYES ASSIGN TO EMPFILE
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FICHIER-EMPLOYES
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.
       01  EMP-ENREGISTREMENT.
           05  EMP-MATRICULE          PIC X(05).
           05  EMP-NOM                PIC X(20).
           05  EMP-PRENOM             PIC X(15).
           05  EMP-SERVICE            PIC X(10).
           05  EMP-SALAIRE            PIC 9(06)V99.
           05  FILLER                 PIC X(22).

       WORKING-STORAGE SECTION.
       01  WS-FIN-FICHIER             PIC X(01) VALUE 'N'.
           88  FIN-FICHIER-ATTEINTE          VALUE 'Y'.

       01  WS-COMPTEUR-EMPLOYES       PIC 9(05) VALUE ZEROES.
       01  WS-TOTAL-SALAIRES          PIC 9(09)V99 VALUE ZEROES.
       01  WS-MOYENNE-SALAIRE         PIC 9(07)V99 VALUE ZEROES.

       01  WS-SALAIRE-EDITE           PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-TOTAL-EDITE             PIC ZZZ,ZZZ,ZZ9.99.
       01  WS-MOYENNE-EDITEE          PIC ZZZ,ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       0000-DEBUT-PROGRAMME.
           DISPLAY ' '
           DISPLAY '=========================================='
           DISPLAY '   GESTION DES EMPLOYES - LISTE COMPLETE   '
           DISPLAY '=========================================='
           DISPLAY ' '

           OPEN INPUT FICHIER-EMPLOYES

           PERFORM 1000-LIRE-UN-EMPLOYE

           PERFORM 2000-TRAITER-UN-EMPLOYE
               UNTIL FIN-FICHIER-ATTEINTE

           CLOSE FICHIER-EMPLOYES

           PERFORM 3000-AFFICHER-RECAPITULATIF

           STOP RUN.

       1000-LIRE-UN-EMPLOYE.
           READ FICHIER-EMPLOYES
               AT END
                   MOVE 'Y' TO WS-FIN-FICHIER
           END-READ.

       2000-TRAITER-UN-EMPLOYE.
           ADD 1 TO WS-COMPTEUR-EMPLOYES
           ADD EMP-SALAIRE TO WS-TOTAL-SALAIRES
           MOVE EMP-SALAIRE TO WS-SALAIRE-EDITE

           DISPLAY 'MATRICULE : ' EMP-MATRICULE
           DISPLAY '   NOM     : ' EMP-NOM
           DISPLAY '   PRENOM  : ' EMP-PRENOM
           DISPLAY '   SERVICE : ' EMP-SERVICE
           DISPLAY '   SALAIRE : ' WS-SALAIRE-EDITE ' EUR'
           DISPLAY '------------------------------------------'

           PERFORM 1000-LIRE-UN-EMPLOYE.

       3000-AFFICHER-RECAPITULATIF.
           IF WS-COMPTEUR-EMPLOYES > 0
               COMPUTE WS-MOYENNE-SALAIRE ROUNDED =
                   WS-TOTAL-SALAIRES / WS-COMPTEUR-EMPLOYES
           END-IF

           MOVE WS-TOTAL-SALAIRES   TO WS-TOTAL-EDITE
           MOVE WS-MOYENNE-SALAIRE  TO WS-MOYENNE-EDITEE

           DISPLAY ' '
           DISPLAY '=========================================='
           DISPLAY '   RECAPITULATIF                           '
           DISPLAY '=========================================='
           DISPLAY 'NOMBRE TOTAL D EMPLOYES   : '
               WS-COMPTEUR-EMPLOYES
           DISPLAY 'MASSE SALARIALE TOTALE    : '
               WS-TOTAL-EDITE ' EUR'
           DISPLAY 'SALAIRE MOYEN             : '
               WS-MOYENNE-EDITEE ' EUR'
           DISPLAY '=========================================='.
