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
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-DATE-COURANTE  PIC X(10).
       01 WS-DATE-RETOUR    PIC X(10).
       01 WS-RETARD         PIC 99.
       01 WS-AMENDE         PIC 9(4)V99.
       01 WS-TOTAL          PIC 9(7)V99 VALUE 0.
       01 WS-LIGNE          PIC X(80).
       
       PROCEDURE DIVISION.
           ACCEPT WS-DATE-COURANTE FROM DATE YYYYMMDD
           
           OPEN INPUT FICHIER-EMPRUNT
           OPEN OUTPUT FICHIER-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "RAPPORT DES RETARDS - " WS-DATE-COURANTE
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           MOVE SPACES TO ENR-SORTIE
           STRING "ID ADHERENT  DATE RETARD  AMENDE"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-EMPRUNT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
      *> Calcul retard (simplifié)
                       COMPUTE WS-RETARD = 5
                       IF WS-RETARD > 0
                           COMPUTE WS-AMENDE = WS-RETARD * 0.50
                           ADD WS-AMENDE TO WS-TOTAL
                           STRING EMP-ID-ADH "        "
                                   WS-DATE-COURANTE "     "
                                   WS-AMENDE " €"
                                   INTO ENR-SORTIE
                           WRITE ENR-SORTIE
                       END-IF
               END-READ
           END-PERFORM
           
           MOVE SPACES TO ENR-SORTIE
           STRING "TOTAL AMENDES: " WS-TOTAL " €"
               INTO ENR-SORTIE
           WRITE ENR-SORTIE
           
           CLOSE FICHIER-EMPRUNT, FICHIER-SORTIE
           
           DISPLAY "Batch amendes terminé"
           DISPLAY "Rapport généré dans data/output/reports/AMENDES.rpt"
           
           STOP RUN.
