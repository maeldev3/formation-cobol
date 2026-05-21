       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIF-ADHERENT.
       
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
          05 FILLER          PIC X(1).
          05 NOM-ADH         PIC X(15).
          05 FILLER          PIC X(1).
          05 PRENOM-ADH      PIC X(10).
          05 FILLER          PIC X(1).
          05 ADRESSE-ADH     PIC X(35).
          05 FILLER          PIC X(1).
          05 DATE-ADH        PIC X(10).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP          PIC X(80).
       
       WORKING-STORAGE SECTION.
       01 WS-ID-MODIF       PIC X(6).
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-CONFIRMATION   PIC X.
       01 WS-NEW-NOM        PIC X(15).
       01 WS-NEW-PRENOM     PIC X(10).
       01 WS-NEW-ADRESSE    PIC X(35).
       01 WS-NEW-DATE       PIC X(10).
       01 WS-COMMANDE       PIC X(200).
       
       PROCEDURE DIVISION.
           DISPLAY " "
           DISPLAY "================= MODIFIER ADHERENT ================="
           DISPLAY "ID a modifier : "
           ACCEPT WS-ID-MODIF
           
           OPEN INPUT FICHIER-ADHERENT
           OPEN OUTPUT FICHIER-TEMP
           
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-ADHERENT
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-ADH = WS-ID-MODIF
                           MOVE 'Y' TO WS-TROUVE
                           PERFORM SAISIR-NOUVELLES-VALEURS
                           MOVE WS-NEW-NOM TO NOM-ADH
                           MOVE WS-NEW-PRENOM TO PRENOM-ADH
                           MOVE WS-NEW-ADRESSE TO ADRESSE-ADH
                           MOVE WS-NEW-DATE TO DATE-ADH
                           DISPLAY "Adherent modifie"
                       END-IF
                       WRITE ENR-TEMP FROM ENR-ADHERENT
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-ADHERENT
           CLOSE FICHIER-TEMP
           
           IF WS-TROUVE = 'N'
               DISPLAY "*** ID NON TROUVE ***"
               STOP RUN
           END-IF
           
      *> Remplacer l'ancien fichier par le nouveau (version LINUX)
           
      *> Méthode 1 : Utilisation des commandes Linux
           CALL "SYSTEM" USING 'rm -f data/input/ADHERENTS.DAT'
           CALL "SYSTEM" USING 'mv data/input/ADHERENTS.TMP data/input/ADHERENTS.DAT'
           
      *> OU Méthode 2 : Avec une seule commande (pour éviter l'erreur si rm échoue)
      *> STRING 'mv data/input/ADHERENTS.TMP data/input/ADHERENTS.DAT'
      *>    INTO WS-COMMANDE
      *> END-STRING
      *> CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY "*** MODIFICATION EFFECTUEE AVEC SUCCES ***"
           
           STOP RUN.
       
       SAISIR-NOUVELLES-VALEURS.
           DISPLAY " "
           DISPLAY "Anciennes valeurs :"
           DISPLAY "NOM    : " NOM-ADH
           DISPLAY "PRENOM : " PRENOM-ADH
           DISPLAY "ADRESSE: " ADRESSE-ADH
           DISPLAY "DATE   : " DATE-ADH
           DISPLAY " "
           DISPLAY "Nouveau NOM (Entrer=conserver) : "
           ACCEPT WS-NEW-NOM
           IF WS-NEW-NOM = SPACES
               MOVE NOM-ADH TO WS-NEW-NOM
           END-IF
           
           DISPLAY "Nouveau PRENOM (Entrer=conserver) : "
           ACCEPT WS-NEW-PRENOM
           IF WS-NEW-PRENOM = SPACES
               MOVE PRENOM-ADH TO WS-NEW-PRENOM
           END-IF
           
           DISPLAY "Nouvelle ADRESSE (Entrer=conserver) : "
           ACCEPT WS-NEW-ADRESSE
           IF WS-NEW-ADRESSE = SPACES
               MOVE ADRESSE-ADH TO WS-NEW-ADRESSE
           END-IF
           
           DISPLAY "Nouvelle DATE (Entrer=conserver) : "
           ACCEPT WS-NEW-DATE
           IF WS-NEW-DATE = SPACES
               MOVE DATE-ADH TO WS-NEW-DATE
           END-IF.