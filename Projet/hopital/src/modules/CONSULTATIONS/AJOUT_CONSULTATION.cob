       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-CONSULTATION.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CONSULT ASSIGN TO 'data/input/CONSULTATIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-PATIENT ASSIGN TO 'data/input/PATIENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-MEDECIN ASSIGN TO 'data/input/MEDECINS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CONSULT.
       01 ENR-CONSULT.
          05 ID-CONSULT      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-PATIENT      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-MEDECIN      PIC X(6).
          05 FILLER          PIC X(1).
          05 DATE-CONSULT    PIC X(10).
          05 FILLER          PIC X(1).
          05 DIAGNOSTIC      PIC X(30).
       
       FD FICHIER-PATIENT.
       01 ENR-PATIENT.
          05 ID-PAT          PIC X(6).
       FD FICHIER-MEDECIN.
       01 ENR-MEDECIN.
          05 ID-MED          PIC X(6).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-PATIENT      PIC X(6).
       01 WS-ID-MEDECIN      PIC X(6).
       01 WS-DIAGNOSTIC      PIC X(30).
       01 WS-DATE            PIC X(10).
       01 WS-NEW-ID          PIC X(6).
       01 WS-COMPTEUR        PIC 99.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-PATIENT-OK      PIC X VALUE 'N'.
       01 WS-MEDECIN-OK      PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UNE CONSULTATION ==="
           DISPLAY " "
           
           DISPLAY "ID PATIENT: "
           ACCEPT WS-ID-PATIENT
           DISPLAY "ID MEDECIN: "
           ACCEPT WS-ID-MEDECIN
           DISPLAY "DIAGNOSTIC: "
           ACCEPT WS-DIAGNOSTIC
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Vérifier patient
           OPEN INPUT FICHIER-PATIENT
           MOVE 'N' TO WS-PATIENT-OK
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-PATIENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-PAT = WS-ID-PATIENT
                           MOVE 'Y' TO WS-PATIENT-OK
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-PATIENT
           
           IF WS-PATIENT-OK = 'N'
               DISPLAY "ERREUR: Patient inexistant"
               STOP RUN
           END-IF
           
      *> Vérifier médecin
           OPEN INPUT FICHIER-MEDECIN
           MOVE 'N' TO WS-MEDECIN-OK
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-MEDECIN
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-MED = WS-ID-MEDECIN
                           MOVE 'Y' TO WS-MEDECIN-OK
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-MEDECIN
           
           IF WS-MEDECIN-OK = 'N'
               DISPLAY "ERREUR: Medecin inexistant"
               STOP RUN
           END-IF
           
      *> Générer ID consultation
           OPEN INPUT FICHIER-CONSULT
           MOVE 1 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               MOVE WS-COMPTEUR TO WS-NEW-ID(5:2)
               MOVE 'C' TO WS-NEW-ID(1:1)
               MOVE '0' TO WS-NEW-ID(2:1)
               MOVE '0' TO WS-NEW-ID(3:1)
               MOVE '0' TO WS-NEW-ID(4:1)
               
               READ FICHIER-CONSULT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CONSULT = WS-NEW-ID
                           ADD 1 TO WS-COMPTEUR
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CONSULT
           
      *> Enregistrer consultation
           OPEN EXTEND FICHIER-CONSULT
           
           MOVE WS-NEW-ID TO ID-CONSULT
           MOVE WS-ID-PATIENT TO ID-PATIENT
           MOVE WS-ID-MEDECIN TO ID-MEDECIN
           MOVE WS-DATE TO DATE-CONSULT
           MOVE WS-DIAGNOSTIC TO DIAGNOSTIC
           
           WRITE ENR-CONSULT
           CLOSE FICHIER-CONSULT
           
           DISPLAY " "
           DISPLAY "--- CONSULTATION AJOUTEE ---"
           DISPLAY "ID CONSULTATION: " WS-NEW-ID
           DISPLAY "PATIENT        : " WS-ID-PATIENT
           DISPLAY "MEDECIN        : " WS-ID-MEDECIN
           DISPLAY "DATE           : " WS-DATE
           DISPLAY "DIAGNOSTIC     : " WS-DIAGNOSTIC
           
           STOP RUN.
