       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CARTE ASSIGN TO 'data/input/CARTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-COMPTE ASSIGN TO 'data/input/COMPTES.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TRANSACTION ASSIGN TO 'data/input/TRANSACTIONS.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FICHIER-TEMP ASSIGN TO 'data/temp/TEMP.dat'
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CARTE.
       01 ENR-CARTE.
          05 ID-CARTE       PIC X(6).
          05 FILLER         PIC X(1).
          05 NUM-COMPTE     PIC X(6).
          05 FILLER         PIC X(1).
          05 NUMERO-CARTE   PIC X(16).
          05 FILLER         PIC X(1).
          05 DATE-EXP       PIC X(4).
          05 FILLER         PIC X(1).
          05 PIN-CARTE      PIC X(4).
          05 FILLER         PIC X(1).
          05 STATUT-CARTE   PIC X(6).
          05 FILLER         PIC X(1).
          05 TENTATIVES     PIC 9.
          05 FILLER         PIC X(1).
          05 PLAFOND-JOUR   PIC 9(8)V99.
       
       FD FICHIER-COMPTE.
       01 ENR-COMPTE.
          05 ID-COMPTE      PIC X(6).
          05 FILLER         PIC X(1).
          05 ID-CLIENT      PIC X(4).
          05 FILLER         PIC X(1).
          05 NOM-CLIENT     PIC X(15).
          05 FILLER         PIC X(1).
          05 PRENOM-CLIENT  PIC X(10).
          05 FILLER         PIC X(1).
          05 PIN-COMPTE     PIC X(4).
          05 FILLER         PIC X(1).
          05 SOLDE-COMPTE   PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-OUV       PIC X(10).
          05 FILLER         PIC X(1).
          05 STATUT-COMPTE  PIC X(6).
       
       FD FICHIER-TRANSACTION.
       01 ENR-TRANS.
          05 ID-TRANS       PIC X(15).
          05 FILLER         PIC X(1).
          05 ID-COMPTE-T    PIC X(6).
          05 FILLER         PIC X(1).
          05 TYPE-TRANS     PIC X(10).
          05 FILLER         PIC X(1).
          05 MONTANT-TRANS  PIC 9(10)V99.
          05 FILLER         PIC X(1).
          05 DATE-TRANS     PIC X(10).
          05 FILLER         PIC X(1).
          05 HEURE-TRANS    PIC X(8).
          05 FILLER         PIC X(1).
          05 STATUT-TRANS   PIC X(7).
       
       FD FICHIER-TEMP.
       01 ENR-TEMP         PIC X(200).
       
       WORKING-STORAGE SECTION.
      *> Variables de session
       01 WS-CARTE-INSEREE  PIC X VALUE 'N'.
       01 WS-AUTHENTIFIE    PIC X VALUE 'N'.
       01 WS-NUMERO-CARTE   PIC X(16).
       01 WS-ID-CARTE       PIC X(6).
       01 WS-ID-COMPTE      PIC X(6).
       01 WS-PIN-SAISI      PIC X(4).
       01 WS-PIN-VALIDE     PIC X(4).
       01 WS-NOM-CLIENT     PIC X(25).
       01 WS-SOLDE-ACTUEL   PIC 9(10)V99.
       01 WS-PLAFOND        PIC 9(8)V99.
       01 WS-TENTATIVES     PIC 9.
       01 WS-MONTANT        PIC 9(10)V99.
       01 WS-MONTANT-AFF    PIC Z(9)9.99.
       01 WS-SOLDE-AFF      PIC Z(9)9.99.
       01 WS-NOUVEAU-SOLDE  PIC 9(10)V99.
       01 WS-DATE           PIC X(10).
       01 WS-HEURE          PIC X(8).
       01 WS-TRANS-COUNT    PIC 9(6) VALUE 0.
       01 WS-FIN            PIC X VALUE 'N'.
       01 WS-TROUVE         PIC X VALUE 'N'.
       01 WS-CHOIX          PIC 9.
       01 WS-COMMANDE       PIC X(200).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════════════════╗"
           DISPLAY "║                                                              ║"
           DISPLAY "║            BIENVENUE AU DISTRIBUTEUR AUTOMATIQUE             ║"
           DISPLAY "║                       ATM BANKING SYSTEM                     ║"
           DISPLAY "║                                                              ║"
           DISPLAY "╚══════════════════════════════════════════════════════════════╝"
           DISPLAY " "
           
      *> ÉTAPE 1: Insertion de la carte
           PERFORM INSERTION-CARTE
           
           IF WS-CARTE-INSEREE = 'Y'
               PERFORM AUTHENTIFICATION
               IF WS-AUTHENTIFIE = 'Y'
                   PERFORM MENU-PRINCIPAL
               END-IF
           END-IF.
           
           DISPLAY " "
           DISPLAY "Merci d'avoir utilisé notre service ATM."
           DISPLAY "A bientôt !"
           DISPLAY " "
           STOP RUN.
       
       INSERTION-CARTE.
           DISPLAY "Veuillez insérer votre carte bancaire"
           DISPLAY "Numéro de carte (16 chiffres): "
           ACCEPT WS-NUMERO-CARTE
           
      *> Vérifier la carte
           MOVE 'N' TO WS-TROUVE
           MOVE 'N' TO WS-FIN
           
           OPEN INPUT FICHIER-CARTE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF NUMERO-CARTE = WS-NUMERO-CARTE
                           MOVE 'Y' TO WS-TROUVE
                           MOVE ID-CARTE TO WS-ID-CARTE
                           MOVE NUM-COMPTE TO WS-ID-COMPTE
                           MOVE STATUT-CARTE TO WS-STATUT
                           MOVE TENTATIVES TO WS-TENTATIVES
                           MOVE PLAFOND-JOUR TO WS-PLAFOND
                           IF STATUT-CARTE = 'ACTIF'
                               MOVE 'Y' TO WS-CARTE-INSEREE
                               DISPLAY " "
                               DISPLAY "✓ Carte valide"
                               DISPLAY " "
                           ELSE
                               DISPLAY "ERREUR: Carte bloquee"
                               DISPLAY "Contactez votre banque"
                               CLOSE FICHIER-CARTE
                               STOP RUN
                           END-IF
                       END-IF
               END-READ
           END-PERFORM.
           
           CLOSE FICHIER-CARTE
           
           IF WS-TROUVE = 'N'
               DISPLAY "ERREUR: Carte non reconnue"
               STOP RUN
           END-IF.
       
       AUTHENTIFICATION.
           DISPLAY "========================================="
           DISPLAY "         AUTHENTIFICATION               "
           DISPLAY "========================================="
           DISPLAY " "
           
           MOVE 0 TO WS-TENTATIVES
           
           PERFORM VARYING WS-TENTATIVES FROM 1 BY 1 
                   UNTIL WS-TENTATIVES > 3 OR WS-AUTHENTIFIE = 'Y'
               
               DISPLAY "Veuillez saisir votre code PIN (4 chiffres): "
               ACCEPT WS-PIN-SAISI
               
      *> Vérifier le PIN
               OPEN INPUT FICHIER-COMPTE
               MOVE 'N' TO WS-TROUVE
               MOVE 'N' TO WS-FIN
               
               PERFORM UNTIL WS-FIN = 'Y'
                   READ FICHIER-COMPTE
                       AT END MOVE 'Y' TO WS-FIN
                       NOT AT END
                           IF ID-COMPTE = WS-ID-COMPTE
                               MOVE 'Y' TO WS-TROUVE
                               MOVE PIN-COMPTE TO WS-PIN-VALIDE
                               MOVE SOLDE-COMPTE TO WS-SOLDE-ACTUEL
                               MOVE NOM-CLIENT TO WS-NOM-CLIENT
                               MOVE PRENOM-CLIENT TO WS-PRENOM
                           END-IF
                   END-READ
               END-PERFORM
               CLOSE FICHIER-COMPTE
               
               IF WS-PIN-SAISI = WS-PIN-VALIDE
                   MOVE 'Y' TO WS-AUTHENTIFIE
                   DISPLAY " "
                   DISPLAY "✓ Authentification reussie"
                   DISPLAY "Bienvenue " WS-PRENOM " " WS-NOM-CLIENT
                   DISPLAY " "
               ELSE
                   DISPLAY "✗ PIN incorrect. Tentative " WS-TENTATIVES "/3"
                   IF WS-TENTATIVES = 3
                       DISPLAY " "
                       DISPLAY "ERREUR: Trop de tentatives"
                       DISPLAY "Carte bloquee. Contactez votre banque"
                       PERFORM BLOQUER-CARTE
                       STOP RUN
                   END-IF
               END-IF
           END-PERFORM.
       
       MENU-PRINCIPAL.
           PERFORM UNTIL WS-CHOIX = 0
               DISPLAY " "
               DISPLAY "========================================="
               DISPLAY "              MENU PRINCIPAL            "
               DISPLAY "========================================="
               DISPLAY "1. RETRAIT D'ARGENT"
               DISPLAY "2. DEPOT D'ARGENT"
               DISPLAY "3. CONSULTATION SOLDE"
               DISPLAY "4. MINI RELEVE (5 dernieres operations)"
               DISPLAY "5. CHANGER CODE PIN"
               DISPLAY "0. QUITTER"
               DISPLAY "========================================="
               DISPLAY "Votre choix: "
               ACCEPT WS-CHOIX
               
               EVALUATE WS-CHOIX
                   WHEN 1
                       PERFORM RETRAIT
                   WHEN 2
                       PERFORM DEPOT
                   WHEN 3
                       PERFORM CONSULTATION-SOLDE
                   WHEN 4
                       PERFORM MINI-RELEVE
                   WHEN 5
                       PERFORM CHANGER-PIN
                   WHEN 0
                       DISPLAY " "
                       DISPLAY "Merci de votre visite"
                   WHEN OTHER
                       DISPLAY "Option invalide"
               END-EVALUATE
           END-PERFORM.
       
       RETRAIT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "              RETRAIT D'ARGENT           "
           DISPLAY "========================================="
           DISPLAY " "
           
           DISPLAY "Montant a retirer: "
           ACCEPT WS-MONTANT
           
           MOVE WS-MONTANT TO WS-MONTANT-AFF
           
      *> Vérifier le montant
           IF WS-MONTANT <= 0
               DISPLAY "ERREUR: Montant invalide"
               EXIT PARAGRAPH
           END-IF.
           
           IF FUNCTION MOD(WS-MONTANT, 10) NOT = 0
               DISPLAY "ERREUR: Montant multiple de 10 requis"
               EXIT PARAGRAPH
           END-IF.
           
           IF WS-MONTANT > 500
               DISPLAY "ERREUR: Retrait maximum 500€ par operation"
               EXIT PARAGRAPH
           END-IF.
           
      *> Vérifier solde
           IF WS-MONTANT > WS-SOLDE-ACTUEL
               DISPLAY "ERREUR: Solde insuffisant"
               MOVE WS-SOLDE-ACTUEL TO WS-SOLDE-AFF
               DISPLAY "Solde disponible: " WS-SOLDE-AFF " €"
               EXIT PARAGRAPH
           END-IF.
           
      *> Vérifier plafond journalier
           PERFORM VERIFIER-PLAFOND-JOUR
           IF WS-PLAFOND-JOUR-UTILISE + WS-MONTANT > WS-PLAFOND
               DISPLAY "ERREUR: Plafond journalier depasse"
               DISPLAY "Plafond restant: " 
                       WS-PLAFOND - WS-PLAFOND-JOUR-UTILISE " €"
               EXIT PARAGRAPH
           END-IF.
           
      *> Mettre à jour le solde
           COMPUTE WS-NOUVEAU-SOLDE = WS-SOLDE-ACTUEL - WS-MONTANT
           
           PERFORM METTRE-A-JOUR-COMPTE
           
           IF WS-UPDATE-OK = 'Y'
               PERFORM ENREGISTRER-TRANSACTION
               PERFORM DISTRIBUER-BILLETS
               
               MOVE WS-MONTANT TO WS-MONTANT-AFF
               MOVE WS-NOUVEAU-SOLDE TO WS-SOLDE-AFF
               
               DISPLAY " "
               DISPLAY "✓ Retrait effectue avec succes"
               DISPLAY "Montant: " WS-MONTANT-AFF " €"
               DISPLAY "Nouveau solde: " WS-SOLDE-AFF " €"
               DISPLAY " "
               DISPLAY "N'oubliez pas de prendre vos billets !"
           ELSE
               DISPLAY "ERREUR: Operation echouee"
           END-IF.
       
       DEPOT.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "              DEPOT D'ARGENT             "
           DISPLAY "========================================="
           DISPLAY " "
           
           DISPLAY "Inserez votre enveloppe dans le lecteur"
           DISPLAY "Montant a deposer: "
           ACCEPT WS-MONTANT
           
           MOVE WS-MONTANT TO WS-MONTANT-AFF
           
           IF WS-MONTANT <= 0
               DISPLAY "ERREUR: Montant invalide"
               EXIT PARAGRAPH
           END-IF.
           
      *> Mettre à jour le solde
           COMPUTE WS-NOUVEAU-SOLDE = WS-SOLDE-ACTUEL + WS-MONTANT
           
           PERFORM METTRE-A-JOUR-COMPTE
           
           IF WS-UPDATE-OK = 'Y'
               PERFORM ENREGISTRER-TRANSACTION
               
               MOVE WS-MONTANT TO WS-MONTANT-AFF
               MOVE WS-NOUVEAU-SOLDE TO WS-SOLDE-AFF
               
               DISPLAY " "
               DISPLAY "✓ Depot effectue avec succes"
               DISPLAY "Montant: " WS-MONTANT-AFF " €"
               DISPLAY "Nouveau solde: " WS-SOLDE-AFF " €"
               DISPLAY " "
               DISPLAY "Votre enveloppe a ete acceptee"
           ELSE
               DISPLAY "ERREUR: Operation echouee"
           END-IF.
       
       CONSULTATION-SOLDE.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "          CONSULTATION SOLDE             "
           DISPLAY "========================================="
           DISPLAY " "
           
           MOVE WS-SOLDE-ACTUEL TO WS-SOLDE-AFF
           
           DISPLAY "Client: " WS-PRENOM " " WS-NOM-CLIENT
           DISPLAY "Compte: " WS-ID-COMPTE
           DISPLAY "Solde actuel: " WS-SOLDE-AFF " €"
           DISPLAY " "
           DISPLAY "Plafond journalier restant: "
           
           PERFORM VERIFIER-PLAFOND-JOUR
           COMPUTE WS-PLAFOND-RESTANT = WS-PLAFOND - WS-PLAFOND-JOUR-UTILISE
           MOVE WS-PLAFOND-RESTANT TO WS-MONTANT-AFF
           DISPLAY WS-MONTANT-AFF " €"
           
           PERFORM ENREGISTRER-CONSULTATION.
       
       MINI-RELEVE.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "            MINI RELEVE DE COMPTE        "
           DISPLAY "========================================="
           DISPLAY " "
           
           DISPLAY "5 dernieres operations:"
           DISPLAY " "
           DISPLAY "DATE       HEURE     TYPE       MONTANT     STATUT"
           DISPLAY "---------- -------- ---------- ----------- -------"
           
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 'N' TO WS-FIN
           MOVE 0 TO WS-COUNT
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-COMPTE-T = WS-ID-COMPTE
                           ADD 1 TO WS-COUNT
                           MOVE MONTANT-TRANS TO WS-MONTANT-AFF
                           DISPLAY DATE-TRANS " " 
                                   HEURE-TRANS " "
                                   TYPE-TRANS "   "
                                   WS-MONTANT-AFF "  "
                                   STATUT-TRANS
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION.
           
           IF WS-COUNT = 0
               DISPLAY "Aucune transaction trouvee"
           END-IF.
           
           DISPLAY " "
           MOVE WS-SOLDE-ACTUEL TO WS-SOLDE-AFF
           DISPLAY "Solde actuel: " WS-SOLDE-AFF " €"
           
           PERFORM ENREGISTRER-CONSULTATION.
       
       CHANGER-PIN.
           DISPLAY " "
           DISPLAY "========================================="
           DISPLAY "            CHANGER CODE PIN             "
           DISPLAY "========================================="
           DISPLAY " "
           
           DISPLAY "Ancien code PIN: "
           ACCEPT WS-PIN-SAISI
           
           IF WS-PIN-SAISI NOT = WS-PIN-VALIDE
               DISPLAY "ERREUR: Ancien PIN incorrect"
               EXIT PARAGRAPH
           END-IF.
           
           DISPLAY "Nouveau code PIN (4 chiffres): "
           ACCEPT WS-PIN-SAISI
           
           IF WS-PIN-SAISI = WS-PIN-VALIDE
               DISPLAY "ERREUR: Le nouveau PIN doit etre different"
               EXIT PARAGRAPH
           END-IF.
           
           IF WS-PIN-SAISI < 1000 OR WS-PIN-SAISI > 9999
               DISPLAY "ERREUR: PIN invalide (4 chiffres requis)"
               EXIT PARAGRAPH
           END-IF.
           
      *> Mettre à jour le PIN
           PERFORM METTRE-A-JOUR-PIN
           
           IF WS-UPDATE-OK = 'Y'
               DISPLAY "✓ Code PIN change avec succes"
               MOVE WS-PIN-SAISI TO WS-PIN-VALIDE
           ELSE
               DISPLAY "ERREUR: Changement PIN echoue"
           END-IF.
       
      *> Sous-programmes
       METTRE-A-JOUR-COMPTE.
           MOVE 'N' TO WS-UPDATE-OK
           
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-COMPTE = WS-ID-COMPTE
                           MOVE 'Y' TO WS-TROUVE
                           MOVE WS-NOUVEAU-SOLDE TO SOLDE-COMPTE
                           MOVE WS-SOLDE-ACTUEL TO WS-SOLDE-AFF
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           IF WS-TROUVE = 'Y'
               MOVE 'mv data/temp/TEMP.dat data/input/COMPTES.dat' 
                   TO WS-COMMANDE
               CALL 'SYSTEM' USING WS-COMMANDE
               MOVE 'Y' TO WS-UPDATE-OK
               MOVE WS-NOUVEAU-SOLDE TO WS-SOLDE-ACTUEL
           END-IF.
       
       METTRE-A-JOUR-PIN.
           MOVE 'N' TO WS-UPDATE-OK
           
           OPEN INPUT FICHIER-COMPTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN
           MOVE 'N' TO WS-TROUVE
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-COMPTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-COMPTE = WS-ID-COMPTE
                           MOVE 'Y' TO WS-TROUVE
                           MOVE WS-PIN-SAISI TO PIN-COMPTE
                       END-IF
                       MOVE ENR-COMPTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-COMPTE, FICHIER-TEMP
           
           IF WS-TROUVE = 'Y'
               MOVE 'mv data/temp/TEMP.dat data/input/COMPTES.dat' 
                   TO WS-COMMANDE
               CALL 'SYSTEM' USING WS-COMMANDE
               MOVE 'Y' TO WS-UPDATE-OK
           END-IF.
       
       ENREGISTRER-TRANSACTION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           ACCEPT WS-HEURE FROM TIME
           
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 0 TO WS-TRANS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-TRANS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
           ADD 1 TO WS-TRANS-COUNT
           
           IF WS-CHOIX = 1
               STRING 'TR' WS-TRANS-COUNT INTO WS-ID-TRANS
               OPEN EXTEND FICHIER-TRANSACTION
               MOVE WS-ID-TRANS TO ID-TRANS
               MOVE WS-ID-COMPTE TO ID-COMPTE-T
               MOVE 'RETRAIT' TO TYPE-TRANS
               MOVE WS-MONTANT TO MONTANT-TRANS
               MOVE WS-DATE TO DATE-TRANS
               MOVE WS-HEURE TO HEURE-TRANS
               MOVE 'VALIDEE' TO STATUT-TRANS
               WRITE ENR-TRANS
               CLOSE FICHIER-TRANSACTION
           ELSE
               IF WS-CHOIX = 2
                   STRING 'TD' WS-TRANS-COUNT INTO WS-ID-TRANS
                   OPEN EXTEND FICHIER-TRANSACTION
                   MOVE WS-ID-TRANS TO ID-TRANS
                   MOVE WS-ID-COMPTE TO ID-COMPTE-T
                   MOVE 'DEPOT' TO TYPE-TRANS
                   MOVE WS-MONTANT TO MONTANT-TRANS
                   MOVE WS-DATE TO DATE-TRANS
                   MOVE WS-HEURE TO HEURE-TRANS
                   MOVE 'VALIDEE' TO STATUT-TRANS
                   WRITE ENR-TRANS
                   CLOSE FICHIER-TRANSACTION
               END-IF
           END-IF.
       
       ENREGISTRER-CONSULTATION.
           ACCEPT WS-DATE FROM DATE YYYYMMDD
           ACCEPT WS-HEURE FROM TIME
           
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 0 TO WS-TRANS-COUNT
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       ADD 1 TO WS-TRANS-COUNT
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION
           
           ADD 1 TO WS-TRANS-COUNT
           STRING 'TC' WS-TRANS-COUNT INTO WS-ID-TRANS
           
           OPEN EXTEND FICHIER-TRANSACTION
           MOVE WS-ID-TRANS TO ID-TRANS
           MOVE WS-ID-COMPTE TO ID-COMPTE-T
           MOVE 'CONSULT' TO TYPE-TRANS
           MOVE 0 TO MONTANT-TRANS
           MOVE WS-DATE TO DATE-TRANS
           MOVE WS-HEURE TO HEURE-TRANS
           MOVE 'VALIDEE' TO STATUT-TRANS
           WRITE ENR-TRANS
           CLOSE FICHIER-TRANSACTION.
       
       VERIFIER-PLAFOND-JOUR.
           MOVE 0 TO WS-PLAFOND-JOUR-UTILISE
           OPEN INPUT FICHIER-TRANSACTION
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-TRANSACTION
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-COMPTE-T = WS-ID-COMPTE 
                          AND TYPE-TRANS = 'RETRAIT'
                          AND DATE-TRANS = WS-DATE
                           ADD MONTANT-TRANS TO WS-PLAFOND-JOUR-UTILISE
                       END-IF
               END-READ
           END-PERFORM
           CLOSE FICHIER-TRANSACTION.
       
       DISTRIBUER-BILLETS.
           DISPLAY " "
           DISPLAY "Distribution des billets..."
           DISPLAY "Veuillez patienter..."
           
      *> Simulation distribution billets
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
               DISPLAY "." WITH NO ADVANCING
               CALL 'C$SLEEP' USING 1
           END-PERFORM
           DISPLAY " "
       
       BLOQUER-CARTE.
           OPEN INPUT FICHIER-CARTE
           OPEN OUTPUT FICHIER-TEMP
           MOVE 'N' TO WS-FIN
           
           PERFORM UNTIL WS-FIN = 'Y'
               READ FICHIER-CARTE
                   AT END MOVE 'Y' TO WS-FIN
                   NOT AT END
                       IF ID-CARTE = WS-ID-CARTE
                           MOVE 'BLOQUE' TO STATUT-CARTE
                           MOVE 3 TO TENTATIVES
                       END-IF
                       MOVE ENR-CARTE TO ENR-TEMP
                       WRITE ENR-TEMP
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-CARTE, FICHIER-TEMP
           
           MOVE 'mv data/temp/TEMP.dat data/input/CARTES.dat' 
               TO WS-COMMANDE
           CALL 'SYSTEM' USING WS-COMMANDE.
       
       WORKING-STORAGE SECTION.
       01 WS-PRENOM        PIC X(10).
       01 WS-STATUT        PIC X(6).
       01 WS-UPDATE-OK     PIC X.
       01 WS-I             PIC 99.
       01 WS-COUNT         PIC 99.
       01 WS-PLAFOND-JOUR-UTILISE PIC 9(8)V99.
       01 WS-PLAFOND-RESTANT PIC 9(8)V99.
       
       END PROGRAM ATM.
