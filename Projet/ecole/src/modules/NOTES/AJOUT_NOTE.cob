       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-NOTE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-NOTE ASSIGN TO 'data/input/NOTES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-ETUDIANT ASSIGN TO 'data/input/ETUDIANTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COURS ASSIGN TO 'data/input/COURS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-NOTE.
       01 ENR-NOTE.
          05 ID-NOTE         PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-ETU-NOTE     PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-COURS-NOTE   PIC X(6).
          05 FILLER          PIC X(1).
          05 VALEUR-NOTE     PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DATE-NOTE       PIC X(10).
       
       FD FICHIER-ETUDIANT.
       01 ENR-ETUDIANT.
          05 ID-ETU          PIC X(6).
       
       FD FICHIER-COURS.
       01 ENR-COURS.
          05 ID-COURS        PIC X(6).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-ETU          PIC X(6).
       01 WS-ID-COURS        PIC X(6).
       01 WS-VALEUR          PIC 9(4)V99.
       01 WS-DATE            PIC X(10).
       01 WS-NEW-ID          PIC X(6).
       01 WS-COMPTEUR        PIC 99.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-ETU-OK          PIC X VALUE 'N'.
       01 WS-COURS-OK        PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UNE NOTE ==="
           DISPLAY " "
           
           DISPLAY "ID ETUDIANT: "
           ACCEPT WS-ID-ETU
           DISPLAY "ID COURS: "
           ACCEPT WS-ID-COURS
           DISPLAY "NOTE (0-20): "
           ACCEPT WS-VALEUR
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Vérifier étudiant
           OPEN INPUT FICHIER-ETUDIANT
           MOVE 'N' TO WS-ETU-OK
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ETUDIANT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ETU = WS-ID-ETU
                           MOVE 'Y' TO WS-ETU-OK
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-ETUDIANT
           
           IF WS-ETU-OK = 'N'
               DISPLAY "ERREUR: Etudiant inexistant"
               STOP RUN
           END-IF
           
      *> Vérifier cours
           OPEN INPUT FICHIER-COURS
           MOVE 'N' TO WS-COURS-OK
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COURS
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-COURS = WS-ID-COURS
                           MOVE 'Y' TO WS-COURS-OK
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-COURS
           
           IF WS-COURS-OK = 'N'
               DISPLAY "ERREUR: Cours inexistant"
               STOP RUN
           END-IF
           
      *> Générer ID note
           OPEN INPUT FICHIER-NOTE
           MOVE 1 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               MOVE WS-COMPTEUR TO WS-NEW-ID(5:2)
               MOVE 'N' TO WS-NEW-ID(1:1)
               MOVE '0' TO WS-NEW-ID(2:1)
               MOVE '0' TO WS-NEW-ID(3:1)
               MOVE '0' TO WS-NEW-ID(4:1)
               
               READ FICHIER-NOTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-NOTE = WS-NEW-ID
                           ADD 1 TO WS-COMPTEUR
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-NOTE
           
      *> Ajouter note
           OPEN EXTEND FICHIER-NOTE
           
           MOVE WS-NEW-ID TO ID-NOTE
           MOVE WS-ID-ETU TO ID-ETU-NOTE
           MOVE WS-ID-COURS TO ID-COURS-NOTE
           MOVE WS-VALEUR TO VALEUR-NOTE
           MOVE WS-DATE TO DATE-NOTE
           
           WRITE ENR-NOTE
           CLOSE FICHIER-NOTE
           
           DISPLAY " "
           DISPLAY "--- NOTE AJOUTEE ---"
           DISPLAY "ID NOTE  : " WS-NEW-ID
           DISPLAY "ETUDIANT : " WS-ID-ETU
           DISPLAY "COURS    : " WS-ID-COURS
           DISPLAY "NOTE     : " WS-VALEUR "/20"
           DISPLAY "DATE     : " WS-DATE
           
           STOP RUN.
