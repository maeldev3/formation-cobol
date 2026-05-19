       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOUT-ADHERENT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-ADHERENT ASSIGN TO 'data/input/ADHERENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-ADHERENT.
       01 ENR-ADHERENT.
          05 ID-ADH          PIC X(6).
          05 FILLER          PIC X(1).
          05 NOM-ADH         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-ADH      PIC X(10).
          05 FILLER          PIC X(1).
          05 ADRESSE-ADH     PIC X(35).
          05 FILLER          PIC X(1).
          05 DATE-ADH        PIC X(10).
       
       WORKING-STORAGE SECTION.
       01 WS-NEW-ID          PIC X(6).
       01 WS-NEW-NOM         PIC X(15).
       01 WS-NEW-PRENOM      PIC X(10).
       01 WS-NEW-ADRESSE     PIC X(35).
       01 WS-NEW-DATE        PIC X(10).
       01 WS-AGE             PIC 99.
       01 WS-PRIME           PIC 9(5)V99.
       01 WS-FIN             PIC X VALUE 'N'.
       01 WS-EXISTE          PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
           DISPLAY "=== AJOUTER UN ADHERENT ==="
           DISPLAY " "
           
           DISPLAY "ID (ex: A00006) : "
           ACCEPT WS-NEW-ID
           
           DISPLAY "NOM : "
           ACCEPT WS-NEW-NOM
           
           DISPLAY "PRENOM : "
           ACCEPT WS-NEW-PRENOM
           
           DISPLAY "ADRESSE : "
           ACCEPT WS-NEW-ADRESSE
           
           DISPLAY "DATE D'ADHESION (YYYY-MM-DD) : "
           ACCEPT WS-NEW-DATE
           
           DISPLAY "AGE DE L'ADHERENT : "
           ACCEPT WS-AGE
           
      *> Vérification âge
           IF WS-AGE < 18
               DISPLAY "ERREUR: Age minimum 18 ans"
               STOP RUN
           END-IF
           
      *> Calcul prime annuelle
           IF WS-AGE < 25
               COMPUTE WS-PRIME = 50.00
           ELSE
               IF WS-AGE < 60
                   COMPUTE WS-PRIME = 80.00
               ELSE
                   COMPUTE WS-PRIME = 100.00
               END-IF
           END-IF
           
      *> Vérifier si l'ID existe déjà
           OPEN INPUT FICHIER-ADHERENT
           MOVE 'N' TO WS-EXISTE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ADH = WS-NEW-ID
                           MOVE 'Y' TO WS-EXISTE
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-ADHERENT
           
           IF WS-EXISTE = 'Y'
               DISPLAY "ERREUR: ID existe deja"
               STOP RUN
           END-IF
           
      *> Ajouter le nouvel adhérent (écriture dans le fichier)
           OPEN EXTEND FICHIER-ADHERENT
           
           MOVE WS-NEW-ID TO ID-ADH
           MOVE WS-NEW-NOM TO NOM-ADH
           MOVE WS-NEW-PRENOM TO PRENOM-ADH
           MOVE WS-NEW-ADRESSE TO ADRESSE-ADH
           MOVE WS-NEW-DATE TO DATE-ADH
           
           WRITE ENR-ADHERENT
           
           CLOSE FICHIER-ADHERENT
           
           DISPLAY " "
           DISPLAY "--- NOUVEL ADHERENT AJOUTE ---"
           DISPLAY "ID     : " WS-NEW-ID
           DISPLAY "NOM    : " WS-NEW-NOM
           DISPLAY "PRENOM : " WS-NEW-PRENOM
           DISPLAY "ADRESSE: " WS-NEW-ADRESSE
           DISPLAY "DATE   : " WS-NEW-DATE
           DISPLAY "PRIME  : " WS-PRIME " €"
           DISPLAY " "
           DISPLAY "Adherent enregistre dans ADHERENTS.DAT"
           
           STOP RUN.
