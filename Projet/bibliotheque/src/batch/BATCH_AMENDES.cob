       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCH-AMENDES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-EMPRUNT ASSIGN TO 'data/input/EMPRUNTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-SORTIE ASSIGN TO 'data/output/reports/AMENDES.rpt'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-EMPRUNT.
       01 ENR-EMPRUNT.
          05 EMP-ID          PIC X(6).
          05 FILLER          PIC X(1).
          05 EMP-ID-ADH      PIC X(6).
          05 FILLER          PIC X(1).
          05 EMP-ISBN        PIC X(17).
          05 FILLER          PIC X(1).
          05 EMP-DATE        PIC X(10).
       
       FD FICHIER-SORTIE.
       01 ENR-SORTIE         PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-DATE-COURANTE   PIC X(10).
       01 WS-DATE-RETOUR     PIC X(10).
       01 WS-RETARD          PIC 99.
       01 WS-AMENDE          PIC 9(4)V99.
       01 WS-TOTAL           PIC 9(7)V99 VALUE 0.
       01 WS-COMPTEUR        PIC 99 VALUE 0.
       01 WS-ANNEE           PIC 9(4).
       01 WS-MOIS            PIC 9(2).
       01 WS-JOUR            PIC 9(2).
       
       PROCEDURE DIVISION.
      *> Date courante (format YYYYMMDD)
           ACCEPT WS-DATE-COURANTE FROM DATE YYYYMMDD
           
           OPEN INPUT FICHIER-EMPRUNT
           OPEN OUTPUT FICHIER-SORTIE
           
      *> En-tête du rapport
           MOVE SPACES TO ENR-SORTIE
           STRING "RAPPORT DES AMENDES - " WS-DATE-COURANTE
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "ID EMPRUNT  ID ADHERENT  RETARD (j)  AMENDE (€)"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "----------------------------------------------"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
      *> Traiter chaque emprunt
           MOVE 'N' TO WS-FIN
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-EMPRUNT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
      *> Calculer le retard (exemple: 5 jours par défaut)
      *> Dans la réalité, il faudrait comparer avec date retour
                       COMPUTE WS-RETARD = 5
                       ADD 1 TO WS-COMPTEUR
                       
                       IF WS-RETARD > 0
                           COMPUTE WS-AMENDE = WS-RETARD * 0.50
                           ADD WS-AMENDE TO WS-TOTAL
                           
                           MOVE SPACES TO ENR-SORTIE
                           STRING EMP-ID "       "
                                   EMP-ID-ADH "          "
                                   WS-RETARD "         "
                                   WS-AMENDE " €"
                               INTO ENR-SORTIE
                           WRITE ENR-SORTIE
                       END-IF
               END-READ
           END-PERFORM
           
      *> Pied du rapport
           MOVE SPACES TO ENR-SORTIE
           STRING "----------------------------------------------"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "TOTAL EMPRUNTS TRAITES: " WS-COMPTEUR
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "TOTAL AMENDES: " WS-TOTAL " €"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           CLOSE FICHIER-EMPRUNT, FICHIER-SORTIE
           
           DISPLAY " "
           DISPLAY "=== BATCH AMENDES TERMINE ==="
           DISPLAY "Emprunts traités: " WS-COMPTEUR
           DISPLAY "Total amendes: " WS-TOTAL " €"
           DISPLAY "Rapport généré: data/output/reports/AMENDES.rpt"
           
           STOP RUN.
