       IDENTIFICATION DIVISION.
       PROGRAM-ID. CRM.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-CLIENTS-CRM
               ASSIGN TO "clients_crm.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ID-CLIENT-CRM
               FILE STATUS IS WS-FS-CLI-CRM.
           
           SELECT FICHIER-INTERACTIONS
               ASSIGN TO "interactions.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-INTERACTION-ID
               FILE STATUS IS WS-FS-INT.
           
           SELECT FICHIER-TICKETS
               ASSIGN TO "tickets.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-TICKET-ID
               FILE STATUS IS WS-FS-TKT.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-CLIENTS-CRM.
       01 WS-CLIENT-CRM.
           05 WS-ID-CLIENT-CRM     PIC 9(8).
           05 WS-NOM-CLIENT-CRM    PIC X(50).
           05 WS-PRENOM-CLIENT-CRM PIC X(30).
           05 WS-EMAIL-CLIENT-CRM  PIC X(60).
           05 WS-TELEPHONE-CRM     PIC X(15).
           05 WS-ADRESSE-CRM       PIC X(100).
           05 WS-CODE-POSTAL-CRM   PIC X(10).
           05 WS-VILLE-CRM         PIC X(30).
           05 WS-DATE-ADHESION     PIC 9(8).
           05 WS-CATEGORIE-CRM     PIC X(15).
              88 VIP               VALUE 'VIP'.
              88 PREMIUM           VALUE 'PREMIUM'.
              88 STANDARD          VALUE 'STANDARD'.
           05 WS-SOLDE-POINTS      PIC 9(6).
           05 WS-DERNIER-ACHAT     PIC 9(8).
           05 WS-ACTIF-CRM         PIC X(1) VALUE 'O'.
       
       FD FICHIER-INTERACTIONS.
       01 WS-INTERACTION.
           05 WS-INTERACTION-ID    PIC 9(10).
           05 WS-CLIENT-ID-INT     PIC 9(8).
           05 WS-DATE-INTERACTION  PIC 9(8).
           05 WS-TYPE-INTERACTION  PIC X(20).
              88 APPEL             VALUE 'APPEL'.
              88 EMAIL             VALUE 'EMAIL'.
              88 RENCONTRE         VALUE 'RENCONTRE'.
              88 FORMULAIRE        VALUE 'FORMULAIRE'.
           05 WS-SUJET             PIC X(50).
           05 WS-DESCRIPTION       PIC X(200).
           05 WS-COMMERCIAL        PIC X(30).
           05 WS-NOTATION          PIC 9(1).
       
       FD FICHIER-TICKETS.
       01 WS-TICKET.
           05 WS-TICKET-ID         PIC 9(10).
           05 WS-TICKET-CLIENT-ID  PIC 9(8).
           05 WS-TICKET-DATE       PIC 9(8).
           05 WS-TICKET-PRIORITE   PIC X(1).
              88 PRIORITE-HAUTE    VALUE 'H'.
              88 PRIORITE-MOYENNE  VALUE 'M'.
              88 PRIORITE-BASSE    VALUE 'B'.
           05 WS-TICKET-STATUT     PIC X(15).
              88 OUVERT            VALUE 'OUVERT'.
              88 EN_COURS_TKT      VALUE 'EN COURS'.
              88 RESOLU            VALUE 'RESOLU'.
              88 FERME             VALUE 'FERME'.
           05 WS-TICKET-SUJET      PIC X(60).
           05 WS-TICKET-DESCRIPTION PIC X(200).
           05 WS-TICKET-SOLUTION   PIC X(200).
           05 WS-ASSIGNEE          PIC X(30).
       
       WORKING-STORAGE SECTION.
       01 WS-FS-CLI-CRM            PIC XX.
       01 WS-FS-INT                PIC XX.
       01 WS-FS-TKT                PIC XX.
       01 WS-CHOIX                PIC 9.
       01 WS-QUITTER-CRM          PIC X(1) VALUE 'N'.
       01 WS-I                    PIC 9(4).
       01 WS-DATE-COURANTE-CRM.
           05 WS-CRM-JOUR          PIC 9(2).
           05 WS-CRM-MOIS          PIC 9(2).
           05 WS-CRM-ANNEE         PIC 9(4).
       
       01 WS-ZONES-CRM.
           05 WS-CLIENT-RECH       PIC 9(8).
           05 WS-TROUVE-CLIENT     PIC X(1).
           05 WS-NOTE-MOYENNE      PIC 9(2)V99.
           05 WS-SATISFACTION      PIC 9(3).
           05 WS-DUREE-MOYENNE     PIC 9(4).
       
       PROCEDURE DIVISION.
           PERFORM 1000-INIT-CRM
           PERFORM UNTIL WS-QUITTER-CRM = 'O'
               PERFORM 2000-MENU-CRM
               PERFORM 3000-TRAITER-CRM
           END-PERFORM
           PERFORM 9000-FERMER-CRM
           STOP RUN.
       
       1000-INIT-CRM.
           DISPLAY "======================================"
           DISPLAY "         SYSTÈME CRM"
           DISPLAY "    CLIENTS - SUPPORT - MARKETING"
           DISPLAY "======================================"
           
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-COURANTE-CRM
           
           OPEN I-O FICHIER-CLIENTS-CRM
           IF WS-FS-CLI-CRM NOT = '00'
               OPEN OUTPUT FICHIER-CLIENTS-CRM
               CLOSE FICHIER-CLIENTS-CRM
               OPEN I-O FICHIER-CLIENTS-CRM
               PERFORM 1100-CHARGER-CLIENTS-CRM
           END-IF
           
           OPEN I-O FICHIER-INTERACTIONS
           IF WS-FS-INT NOT = '00'
               OPEN OUTPUT FICHIER-INTERACTIONS
               CLOSE FICHIER-INTERACTIONS
               OPEN I-O FICHIER-INTERACTIONS
           END-IF
           
           OPEN I-O FICHIER-TICKETS
           IF WS-FS-TKT NOT = '00'
               OPEN OUTPUT FICHIER-TICKETS
               CLOSE FICHIER-TICKETS
               OPEN I-O FICHIER-TICKETS
           END-IF
           .
       
       1100-CHARGER-CLIENTS-CRM.
           MOVE 10000001 TO WS-ID-CLIENT-CRM
           MOVE "DUPONT" TO WS-NOM-CLIENT-CRM
           MOVE "JEAN" TO WS-PRENOM-CLIENT-CRM
           MOVE "jean.dupont@email.com" TO WS-EMAIL-CLIENT-CRM
           MOVE "0612345678" TO WS-TELEPHONE-CRM
           MOVE "12 RUE DE PARIS" TO WS-ADRESSE-CRM
           MOVE "75001" TO WS-CODE-POSTAL-CRM
           MOVE "PARIS" TO WS-VILLE-CRM
           MOVE 01012023 TO WS-DATE-ADHESION
           MOVE "VIP" TO WS-CATEGORIE-CRM
           MOVE 1500 TO WS-SOLDE-POINTS
           MOVE 15052024 TO WS-DERNIER-ACHAT
           WRITE WS-CLIENT-CRM
           
           MOVE 10000002 TO WS-ID-CLIENT-CRM
           MOVE "MARTIN" TO WS-NOM-CLIENT-CRM
           MOVE "SOPHIE" TO WS-PRENOM-CLIENT-CRM
           MOVE "sophie.martin@email.com" TO WS-EMAIL-CLIENT-CRM
           MOVE "0698765432" TO WS-TELEPHONE-CRM
           MOVE "45 AVENUE DE LYON" TO WS-ADRESSE-CRM
           MOVE "69002" TO WS-CODE-POSTAL-CRM
           MOVE "LYON" TO WS-VILLE-CRM
           MOVE 15062023 TO WS-DATE-ADHESION
           MOVE "PREMIUM" TO WS-CATEGORIE-CRM
           MOVE 800 TO WS-SOLDE-POINTS
           MOVE 10052024 TO WS-DERNIER-ACHAT
           WRITE WS-CLIENT-CRM
           .
       
       2000-MENU-CRM.
           DISPLAY " "
           DISPLAY "=== MENU CRM ==="
           DISPLAY "1.  GESTION CLIENTS"
           DISPLAY "2.  FICHE CLIENT"
           DISPLAY "3.  INTERACTIONS"
           DISPLAY "4.  TICKETS SUPPORT"
           DISPLAY "5.  CAMPAGNES MARKETING"
           DISPLAY "6.  PROGRAMME FIDÉLITÉ"
           DISPLAY "7.  ANALYSE SATISFACTION"
           DISPLAY "8.  TABLEAU DE BORD"
           DISPLAY "9.  QUITTER"
           DISPLAY "CHOIX: "
           ACCEPT WS-CHOIX
           .
       
       3000-TRAITER-CRM.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-GESTION-CLIENTS-CRM
               WHEN 2 PERFORM 5000-FICHE-CLIENT
               WHEN 3 PERFORM 6000-INTERACTIONS
               WHEN 4 PERFORM 7000-TICKETS-SUPPORT
               WHEN 5 PERFORM 8000-CAMPAGNES
               WHEN 6 PERFORM 8100-FIDELITE
               WHEN 7 PERFORM 8200-ANALYSE-SATISFACTION
               WHEN 8 PERFORM 8300-TABLEAU-BORD-CRM
               WHEN 9 MOVE 'O' TO WS-QUITTER-CRM
               WHEN OTHER DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       
       4000-GESTION-CLIENTS-CRM.
           DISPLAY "--- GESTION CLIENTS ---"
           DISPLAY "1. AJOUTER CLIENT"
           DISPLAY "2. MODIFIER CLIENT"
           DISPLAY "3. LISTE CLIENTS"
           DISPLAY "4. RECHERCHER CLIENT"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4100-AJOUTER-CLIENT-CRM
               WHEN 2 PERFORM 4200-MODIFIER-CLIENT-CRM
               WHEN 3 PERFORM 4300-LISTER-CLIENTS-CRM
               WHEN 4 PERFORM 4400-RECHERCHER-CLIENT-CRM
           END-EVALUATE
           .
       
       4100-AJOUTER-CLIENT-CRM.
           DISPLAY "--- AJOUTER CLIENT ---"
           DISPLAY "ID CLIENT (8 chiffres): "
           ACCEPT WS-ID-CLIENT-CRM
           
           READ FICHIER-CLIENTS-CRM
               INVALID KEY
                   DISPLAY "NOM: "
                   ACCEPT WS-NOM-CLIENT-CRM
                   DISPLAY "PRENOM: "
                   ACCEPT WS-PRENOM-CLIENT-CRM
                   DISPLAY "EMAIL: "
                   ACCEPT WS-EMAIL-CLIENT-CRM
                   DISPLAY "TÉLÉPHONE: "
                   ACCEPT WS-TELEPHONE-CRM
                   DISPLAY "ADRESSE: "
                   ACCEPT WS-ADRESSE-CRM
                   DISPLAY "CODE POSTAL: "
                   ACCEPT WS-CODE-POSTAL-CRM
                   DISPLAY "VILLE: "
                   ACCEPT WS-VILLE-CRM
                   DISPLAY "CATÉGORIE (VIP/PREMIUM/STANDARD): "
                   ACCEPT WS-CATEGORIE-CRM
                   
                   MOVE WS-DATE-COURANTE-CRM 
                     TO WS-DATE-ADHESION
                   MOVE 0 TO WS-SOLDE-POINTS
                   MOVE 0 TO WS-DERNIER-ACHAT
                   MOVE 'O' TO WS-ACTIF-CRM
                   WRITE WS-CLIENT-CRM
                   DISPLAY "CLIENT AJOUTÉ"
               NOT INVALID KEY
                   DISPLAY "ID CLIENT EXISTANT"
           END-READ
           .
       
       4200-MODIFIER-CLIENT-CRM.
           DISPLAY "ID CLIENT: "
           ACCEPT WS-CLIENT-RECH
           MOVE WS-CLIENT-RECH TO WS-ID-CLIENT-CRM
           
           READ FICHIER-CLIENTS-CRM
               INVALID KEY
                   DISPLAY "CLIENT NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY "NOUVEL EMAIL (" 
                           WS-EMAIL-CLIENT-CRM "): "
                   ACCEPT WS-NEW-EMAIL
                   IF WS-NEW-EMAIL NOT = SPACES
                       MOVE WS-NEW-EMAIL TO WS-EMAIL-CLIENT-CRM
                   END-IF
                   
                   DISPLAY "NOUVEAU TÉLÉPHONE (" 
                           WS-TELEPHONE-CRM "): "
                   ACCEPT WS-NEW-TEL
                   IF WS-NEW-TEL NOT = SPACES
                       MOVE WS-NEW-TEL TO WS-TELEPHONE-CRM
                   END-IF
                   
                   DISPLAY "NOUVELLE CATÉGORIE (" 
                           WS-CATEGORIE-CRM "): "
                   ACCEPT WS-NEW-CAT
                   IF WS-NEW-CAT NOT = SPACES
                       MOVE WS-NEW-CAT TO WS-CATEGORIE-CRM
                   END-IF
                   
                   REWRITE WS-CLIENT-CRM
                   DISPLAY "CLIENT MODIFIÉ"
           END-READ
           .
       
       4300-LISTER-CLIENTS-CRM.
           DISPLAY "=== LISTE CLIENTS ==="
           DISPLAY "ID       | NOM COMPLET                | CATÉGORIE | POINTS"
           DISPLAY "---------+----------------------------+-----------+--------"
           
           MOVE 0 TO WS-ID-CLIENT-CRM
           START FICHIER-CLIENTS-CRM 
               KEY IS NOT < WS-ID-CLIENT-CRM
           
           PERFORM UNTIL WS-FS-CLI-CRM = '10'
               READ FICHIER-CLIENTS-CRM NEXT
                   AT END
                       MOVE '10' TO WS-FS-CLI-CRM
                   NOT AT END
                       DISPLAY WS-ID-CLIENT-CRM " | "
                               FUNCTION TRIM(WS-PRENOM-CLIENT-CRM)
                               " " 
                               FUNCTION TRIM(WS-NOM-CLIENT-CRM)
                               SPACE(27 - FUNCTION LENGTH(
                               FUNCTION TRIM(WS-PRENOM-CLIENT-CRM)
                               " " 
                               FUNCTION TRIM(WS-NOM-CLIENT-CRM)))
                               " | " 
                               WS-CATEGORIE-CRM " | "
                               WS-SOLDE-POINTS
               END-READ
           END-PERFORM
           .
       
       4400-RECHERCHER-CLIENT-CRM.
           DISPLAY "--- RECHERCHE CLIENT ---"
           DISPLAY "NOM OU EMAIL: "
           ACCEPT WS-RECHERCHE
           
           DISPLAY " "
           DISPLAY "RÉSULTATS DE RECHERCHE:"
           MOVE 0 TO WS-ID-CLIENT-CRM
           START FICHIER-CLIENTS-CRM 
               KEY IS NOT < WS-ID-CLIENT-CRM
           
           PERFORM UNTIL WS-FS-CLI-CRM = '10'
               READ FICHIER-CLIENTS-CRM NEXT
                   AT END
                       MOVE '10' TO WS-FS-CLI-CRM
                   NOT AT END
                       IF WS-NOM-CLIENT-CRM 
                          CONTAINS WS-RECHERCHE
                          OR WS-EMAIL-CLIENT-CRM 
                          CONTAINS WS-RECHERCHE
                           DISPLAY WS-ID-CLIENT-CRM " - "
                                   FUNCTION TRIM(WS-PRENOM-CLIENT-CRM)
                                   " " 
                                   FUNCTION TRIM(WS-NOM-CLIENT-CRM)
                                   " (" WS-EMAIL-CLIENT-CRM ")"
                       END-IF
               END-READ
           END-PERFORM
           .
       
       5000-FICHE-CLIENT.
           DISPLAY "--- FICHE CLIENT ---"
           DISPLAY "ID CLIENT: "
           ACCEPT WS-CLIENT-RECH
           MOVE WS-CLIENT-RECH TO WS-ID-CLIENT-CRM
           
           READ FICHIER-CLIENTS-CRM
               INVALID KEY
                   DISPLAY "CLIENT NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY " "
                   DISPLAY "=== FICHE CLIENT ==="
                   DISPLAY "ID: " WS-ID-CLIENT-CRM
                   DISPLAY "NOM COMPLET: " 
                           FUNCTION TRIM(WS-PRENOM-CLIENT-CRM) " "
                           FUNCTION TRIM(WS-NOM-CLIENT-CRM)
                   DISPLAY "EMAIL: " WS-EMAIL-CLIENT-CRM
                   DISPLAY "TÉLÉPHONE: " WS-TELEPHONE-CRM
                   DISPLAY "ADRESSE: " 
                           FUNCTION TRIM(WS-ADRESSE-CRM)
                   DISPLAY "CODE POSTAL: " WS-CODE-POSTAL-CRM
                   DISPLAY "VILLE: " FUNCTION TRIM(WS-VILLE-CRM)
                   DISPLAY "DATE ADHÉSION: " WS-DATE-ADHESION
                   DISPLAY "CATÉGORIE: " WS-CATEGORIE-CRM
                   DISPLAY "POINTS FIDÉLITÉ: " WS-SOLDE-POINTS
                   DISPLAY "DERNIER ACHAT: " WS-DERNIER-ACHAT
                   DISPLAY "STATUT: " 
                           IF WS-ACTIF-CRM = 'O' 
                               "ACTIF" ELSE "INACTIF"
                   PERFORM 5100-LISTER-INTERACTIONS-CLIENT
                   PERFORM 5200-LISTER-TICKETS-CLIENT
           END-READ
           .
       
       5100-LISTER-INTERACTIONS-CLIENT.
           DISPLAY " "
           DISPLAY "--- DERNIÈRES INTERACTIONS ---"
           MOVE 0 TO WS-INTERACTION-ID
           START FICHIER-INTERACTIONS 
               KEY IS NOT < WS-INTERACTION-ID
           
           PERFORM VARYING WS-I FROM 1 BY 1 
                     UNTIL WS-I > 5 OR WS-FS-INT = '10'
               READ FICHIER-INTERACTIONS NEXT
                   AT END
                       MOVE '10' TO WS-FS-INT
                   NOT AT END
                       IF WS-CLIENT-ID-INT = WS-CLIENT-RECH
                           DISPLAY WS-DATE-INTERACTION " - "
                                   WS-TYPE-INTERACTION " - "
                                   FUNCTION TRIM(WS-SUJET)
                       END-IF
               END-READ
           END-PERFORM
           .
       
       5200-LISTER-TICKETS-CLIENT.
           DISPLAY " "
           DISPLAY "--- TICKETS SUPPORT ---"
           MOVE 0 TO WS-TICKET-ID
           START FICHIER-TICKETS 
               KEY IS NOT < WS-TICKET-ID
           
           PERFORM UNTIL WS-FS-TKT = '10'
               READ FICHIER-TICKETS NEXT
                   AT END
                       MOVE '10' TO WS-FS-TKT
                   NOT AT END
                       IF WS-TICKET-CLIENT-ID = WS-CLIENT-RECH
                           DISPLAY "N°" WS-TICKET-ID " - "
                                   WS-TICKET-STATUT " - "
                                   FUNCTION TRIM(WS-TICKET-SUJET)
                       END-IF
               END-READ
           END-PERFORM
           .
       
       6000-INTERACTIONS.
           DISPLAY "--- INTERACTIONS ---"
           DISPLAY "1. AJOUTER INTERACTION"
           DISPLAY "2. LISTE INTERACTIONS"
           DISPLAY "3. STATISTIQUES INTERACTIONS"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 6100-AJOUTER-INTERACTION
               WHEN 2 PERFORM 6200-LISTER-INTERACTIONS
               WHEN 3 PERFORM 6300-STATS-INTERACTIONS
           END-EVALUATE
           .
       
       6100-AJOUTER-INTERACTION.
           DISPLAY "--- AJOUTER INTERACTION ---"
           DISPLAY "ID CLIENT: "
           ACCEPT WS-CLIENT-RECH
           
           MOVE WS-CLIENT-RECH TO WS-ID-CLIENT-CRM
           READ FICHIER-CLIENTS-CRM
               INVALID KEY
                   DISPLAY "CLIENT NON TROUVÉ"
               NOT INVALID KEY
                   ADD 1 TO WS-INTERACTION-ID
                   MOVE WS-INTERACTION-ID TO WS-INTERACTION-ID
                   MOVE WS-CLIENT-RECH TO WS-CLIENT-ID-INT
                   MOVE WS-DATE-COURANTE-CRM 
                     TO WS-DATE-INTERACTION
                   
                   DISPLAY "TYPE (APPEL/EMAIL/RENCONTRE/FORMULAIRE): "
                   ACCEPT WS-TYPE-INTERACTION
                   DISPLAY "SUJET: "
                   ACCEPT WS-SUJET
                   DISPLAY "DESCRIPTION: "
                   ACCEPT WS-DESCRIPTION
                   DISPLAY "COMMERCIAL: "
                   ACCEPT WS-COMMERCIAL
                   DISPLAY "NOTATION (1-5): "
                   ACCEPT WS-NOTATION
                   
                   WRITE WS-INTERACTION
                   DISPLAY "INTERACTION ENREGISTRÉE"
           END-READ
           .
       
       6200-LISTER-INTERACTIONS.
           DISPLAY "--- LISTE INTERACTIONS ---"
           DISPLAY "ID CLIENT: "
           ACCEPT WS-CLIENT-RECH
           
           DISPLAY " "
           DISPLAY "DATE       | TYPE      | SUJET"
           DISPLAY "-----------+-----------+----------------------------"
           
           MOVE 0 TO WS-INTERACTION-ID
           START FICHIER-INTERACTIONS 
               KEY IS NOT < WS-INTERACTION-ID
           
           PERFORM UNTIL WS-FS-INT = '10'
               READ FICHIER-INTERACTIONS NEXT
                   AT END
                       MOVE '10' TO WS-FS-INT
                   NOT AT END
                       IF WS-CLIENT-ID-INT = WS-CLIENT-RECH
                           DISPLAY WS-DATE-INTERACTION " | "
                                   WS-TYPE-INTERACTION " | "
                                   FUNCTION TRIM(WS-SUJET)
                       END-IF
               END-READ
           END-PERFORM
           .
       
       6300-STATS-INTERACTIONS.
           DISPLAY "--- STATISTIQUES INTERACTIONS ---"
           DISPLAY "PÉRIODE DU (JJMMAAAA): "
           ACCEPT WS-DATE-DEBUT
           DISPLAY "AU (JJMMAAAA): "
           ACCEPT WS-DATE-FIN
           
           MOVE 0 TO WS-NB-INTERACTIONS
           MOVE 0 TO WS-SOMME-NOTES
           
           MOVE 0 TO WS-INTERACTION-ID
           START FICHIER-INTERACTIONS 
               KEY IS NOT < WS-INTERACTION-ID
           
           PERFORM UNTIL WS-FS-INT = '10'
               READ FICHIER-INTERACTIONS NEXT
                   AT END
                       MOVE '10' TO WS-FS-INT
                   NOT AT END
                       IF WS-DATE-INTERACTION >= WS-DATE-DEBUT
                          AND WS-DATE-INTERACTION <= WS-DATE-FIN
                           ADD 1 TO WS-NB-INTERACTIONS
                           ADD WS-NOTATION TO WS-SOMME-NOTES
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY " "
           DISPLAY "INTERACTIONS SUR LA PÉRIODE: " 
                   WS-NB-INTERACTIONS
           IF WS-NB-INTERACTIONS > 0
               COMPUTE WS-NOTE-MOYENNE = 
                   WS-SOMME-NOTES / WS-NB-INTERACTIONS
               DISPLAY "NOTE MOYENNE: " WS-NOTE-MOYENNE "/5"
               COMPUTE WS-SATISFACTION = 
                   (WS-NOTE-MOYENNE * 100) / 5
               DISPLAY "TAUX SATISFACTION: " 
                       WS-SATISFACTION "%"
           END-IF
           .
       
       7000-TICKETS-SUPPORT.
           DISPLAY "--- TICKETS SUPPORT ---"
           DISPLAY "1. CRÉER TICKET"
           DISPLAY "2. TRAITER TICKET"
           DISPLAY "3. LISTE TICKETS"
           DISPLAY "4. STATISTIQUES SUPPORT"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 7100-CREER-TICKET
               WHEN 2 PERFORM 7200-TRAITER-TICKET
               WHEN 3 PERFORM 7300-LISTER-TICKETS
               WHEN 4 PERFORM 7400-STATS-SUPPORT
           END-EVALUATE
           .
       
       7100-CREER-TICKET.
           DISPLAY "--- CRÉER TICKET ---"
           DISPLAY "ID CLIENT: "
           ACCEPT WS-CLIENT-RECH
           
           MOVE WS-CLIENT-RECH TO WS-ID-CLIENT-CRM
           READ FICHIER-CLIENTS-CRM
               INVALID KEY
                   DISPLAY "CLIENT NON TROUVÉ"
               NOT INVALID KEY
                   ADD 1 TO WS-TICKET-ID
                   MOVE WS-TICKET-ID TO WS-TICKET-ID
                   MOVE WS-CLIENT-RECH TO WS-TICKET-CLIENT-ID
                   MOVE WS-DATE-COURANTE-CRM 
                     TO WS-TICKET-DATE
                   
                   DISPLAY "PRIORITÉ (H/M/B): "
                   ACCEPT WS-TICKET-PRIORITE
                   DISPLAY "SUJET: "
                   ACCEPT WS-TICKET-SUJET
                   DISPLAY "DESCRIPTION: "
                   ACCEPT WS-TICKET-DESCRIPTION
                   
                   MOVE "OUVERT" TO WS-TICKET-STATUT
                   MOVE "NON ASSIGNÉ" TO WS-ASSIGNEE
                   WRITE WS-TICKET
                   DISPLAY "TICKET N°" WS-TICKET-ID " CRÉÉ"
           END-READ
           .
       
       7200-TRAITER-TICKET.
           DISPLAY "--- TRAITER TICKET ---"
           DISPLAY "NUMÉRO TICKET: "
           ACCEPT WS-TICKET-NUM
           
           MOVE WS-TICKET-NUM TO WS-TICKET-ID
           READ FICHIER-TICKETS
               INVALID KEY
                   DISPLAY "TICKET NON TROUVÉ"
               NOT INVALID KEY
                   DISPLAY "TICKET: " WS-TICKET-SUJET
                   DISPLAY "STATUT ACTUEL: " WS-TICKET-STATUT
                   DISPLAY "1. PRENDRE EN CHARGE"
                   DISPLAY "2. RÉSOUDRE"
                   DISPLAY "3. FERMER"
                   ACCEPT WS-CHOIX
