       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPPR-ADHERENT.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-ADHERENT ASSIGN TO 'data/input/ADHERENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/input/ADHERENTS.TMP'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-ADHERENT.
       01 ENR-ADHERENT.
          05 ID-ADH          PIC X(6).
          05 FILLER1         PIC X(1).
          05 NOM-ADH         PIC X(15).
          05 FILLER2         PIC X(1).
          05 PRENOM-ADH      PIC X(10).
          05 FILLER3         PIC X(1).
          05 ADRESSE-ADH     PIC X(35).
          05 FILLER4         PIC X(1).
          05 DATE-ADH        PIC X(10).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-SUPPR       PIC X(6).
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-CONFIRMATION   PIC X.
       
       PROCEDURE DIVISION.
           DISPLAY " "
           DISPLAY "================= SUPPRIMER ADHERENT ================="
           DISPLAY "ID a supprimer : "
           ACCEPT WS-ID-SUPPR
           
           OPEN INPUT FICHIER-ADHERENT
           OPEN OUTPUT FICHIER-TEMP
           
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ADH = WS-ID-SUPPR
                           MOVE 'Y' TO WS-TROUVE
                           DISPLAY " "
                           DISPLAY "Adherent a supprimer :"
                           DISPLAY "ID    : " ID-ADH
                           DISPLAY "NOM   : " FUNCTION TRIM(NOM-ADH)
                           DISPLAY "PRENOM: " FUNCTION TRIM(PRENOM-ADH)
                           DISPLAY " "
                           DISPLAY "Confirmer suppression (O/N) : "
                           ACCEPT WS-CONFIRMATION
                           IF WS-CONFIRMATION = 'O' OR 'o'
                               DISPLAY "*** ADHERENT SUPPRIME ***"
      *> Ne PAS écrire l'enregistrement dans le fichier temporaire
      *> Cela le supprime car on ne le recopie pas
                           ELSE
                               WRITE ENR-TEMP FROM ENR-ADHERENT
                               DISPLAY "*** SUPPRESSION ANNULEE ***"
                           END-IF
                       ELSE
                           WRITE ENR-TEMP FROM ENR-ADHERENT
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-ADHERENT
           CLOSE FICHIER-TEMP
           
           IF WS-TROUVE = 'N'
               DISPLAY "*** ID NON TROUVE ***"
               STOP RUN
           END-IF
           
      *> Remplacer l'ancien fichier par le nouveau (version LINUX)
           CALL "SYSTEM" USING 'rm -f data/input/ADHERENTS.DAT'
           CALL "SYSTEM" USING 'mv data/input/ADHERENTS.TMP data/input/ADHERENTS.DAT'
           
           DISPLAY "*** OPERATION TERMINEE ***"
           
           STOP RUN.