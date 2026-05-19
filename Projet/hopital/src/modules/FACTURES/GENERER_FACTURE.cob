       IDENTIFICATION DIVISION.
       PROGRAM-ID. GENERER-FACTURE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CONSULT ASSIGN TO 'data/input/CONSULTATIONS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-MEDECIN ASSIGN TO 'data/input/MEDECINS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-FACTURE ASSIGN TO 'data/input/FACTURES.DAT'
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
       
       FD FICHIER-MEDECIN.
       01 ENR-MEDECIN.
          05 ID-MED          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-MED         PIC X(15).
          05 FILLER          PIC X(1).
          05 SPECIALITE      PIC X(15).
          05 FILLER          PIC X(1).
          05 TARIF-MED       PIC 9(4)V99.
          05 FILLER          PIC X(1).
          05 DATE-EMBAUCHE   PIC X(10).
       
       FD FICHIER-FACTURE.
       01 ENR-FACTURE.
          05 ID-FACTURE      PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-CONSULT-F    PIC X(6).
          05 FILLER          PIC X(1).
          05 ID-PATIENT-F    PIC X(6).
          05 FILLER          PIC X(1).
          05 MONTANT-F       PIC 9(6)V99.
          05 FILLER          PIC X(1).
          05 DATE-FACTURE    PIC X(10).
          05 FILLER          PIC X(1).
          05 STATUT-F        PIC X(1).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-CONSULT      PIC X(6).
       01 WS-TARIF           PIC 9(4)V99.
       01 WS-MONTANT         PIC 9(6)V99.
       01 WS-DATE            PIC X(10).
       01 WS-NEW-ID          PIC X(6).
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-TROUVE          PIC X VALUE 'N'.
       01 WS-COMPTEUR        PIC 99.
       
       PROCEDURE DIVISION.
           DISPLAY "=== GENERER UNE FACTURE ==="
           DISPLAY " "
           DISPLAY "ID CONSULTATION: "
           ACCEPT WS-ID-CONSULT
           
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           
      *> Trouver la consultation et le tarif
           OPEN INPUT FICHIER-CONSULT
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CONSULT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CONSULT = WS-ID-CONSULT
                           MOVE 'Y' TO WS-TROUVE
                           OPEN INPUT FICHIER-MEDECIN
                           MOVE 'N' TO WS-FIN
                           PERFORM UNTIL WS-FIN = 'Y'
                               READ FICHIER-MEDECIN
                                   AT END MOVE 'Y' TO WS-FIN
                                   NOT AT END
                                       IF ID-MED = ID-MEDECIN
                                           MOVE TARIF-MED TO WS-TARIF
                                       END-IF
                               END-READ
                           END-PERFORM
                           CLOSE FICHIER-MEDECIN
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-CONSULT
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Consultation inexistante"
               STOP RUN
           END-IF
           
           COMPUTE WS-MONTANT = WS-TARIF
           
      *> Générer ID facture
           OPEN INPUT FICHIER-FACTURE
           MOVE 1 TO WS-COMPTEUR
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               MOVE WS-COMPTEUR TO WS-NEW-ID(5:2)
               MOVE 'F' TO WS-NEW-ID(1:1)
               MOVE '0' TO WS-NEW-ID(2:1)
               MOVE '0' TO WS-NEW-ID(3:1)
               MOVE '0' TO WS-NEW-ID(4:1)
               
               READ FICHIER-FACTURE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-FACTURE = WS-NEW-ID
                           ADD 1 TO WS-COMPTEUR
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-FACTURE
           
      *> Enregistrer facture
           OPEN EXTEND FICHIER-FACTURE
           
           MOVE WS-NEW-ID TO ID-FACTURE
           MOVE WS-ID-CONSULT TO ID-CONSULT-F
           MOVE ID-PATIENT TO ID-PATIENT-F
           MOVE WS-MONTANT TO MONTANT-F
           MOVE WS-DATE TO DATE-FACTURE
           MOVE 'I' TO STATUT-F
           
           WRITE ENR-FACTURE
           CLOSE FICHIER-FACTURE
           
           DISPLAY " "
           DISPLAY "--- FACTURE GENERE ---"
           DISPLAY "ID FACTURE    : " WS-NEW-ID
           DISPLAY "CONSULTATION  : " WS-ID-CONSULT
           DISPLAY "MONTANT       : " WS-MONTANT " €"
           DISPLAY "DATE          : " WS-DATE
           DISPLAY "STATUT        : IMPAYEE"
           
           STOP RUN.
