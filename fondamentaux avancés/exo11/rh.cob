       IDENTIFICATION DIVISION.
       PROGRAM-ID. RH.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-EMPLOYES
               ASSIGN TO "employes_rh.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-MATRICULE-RH
               FILE STATUS IS WS-FS-RH.
           
           SELECT FICHIER-CONGES
               ASSIGN TO "conges.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-MATRICULE-CON, WS-DEBUT-CON
               FILE STATUS IS WS-FS-CON.
           
           SELECT FICHIER-FORMATION
               ASSIGN TO "formation.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-MATRICULE-FORM, WS-ID-FORM
               FILE STATUS IS WS-FS-FORM.
           
           SELECT FICHIER-CANDIDATS
               ASSIGN TO "candidats.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-EMPLOYES.
       01 WS-EMPLOYE-RH.
           05 WS-MATRICULE-RH      PIC 9(6).
           05 WS-NOM-RH            PIC X(30).
           05 WS-PRENOM-RH         PIC X(30).
           05 WS-DATE-NAISS-RH     PIC 9(8).
           05 WS-DATE-EMBAUCHE-RH  PIC 9(8).
           05 WS-SERVICE           PIC X(20).
           05 WS-POSTE             PIC X(30).
           05 WS-CONGES-ANNUELS    PIC 9(3) VALUE 25.
           05 WS-CONGES-PRIS       PIC 9(3) VALUE 0.
           05 WS-CONGES-RESTANTS   PIC 9(3).
           05 WS-HEURES-FORMATION  PIC 9(4) VALUE 0.
           05 WS-SALAIRE-RH        PIC 9(7)V99.
           05 WS-STATUT-EMPLOYE    PIC X(10).
              88 ACTIF             VALUE 'ACTIF'.
              88 CONGE             VALUE 'CONGE'.
              88 ARRET             VALUE 'ARRET'.
              88 QUITTE            VALUE 'QUITTE'.
       
       FD FICHIER-CONGES.
       01 WS-DEMANDE-CONGE.
           05 WS-MATRICULE-CON     PIC 9(6).
           05 WS-DEBUT-CON         PIC 9(8).
           05 WS-FIN-CON           PIC 9(8).
           05 WS-NB-JOURS          PIC 9(3).
           05 WS-TYPE-CONGE        PIC X(15).
              88 CONGES-PAYES      VALUE 'PAYES'.
              88 CONGES-SANS-SOLDE VALUE 'SANS-SOLDE'.
              88 RTT               VALUE 'RTT'.
           05 WS-STATUT-CONGE      PIC X(10).
              88 EN-ATTENTE        VALUE 'ATTENTE'.
              88 VALIDE            VALUE 'VALIDE'.
              88 REFUSE            VALUE 'REFUSE'.
           05 WS-MOTIF             PIC X(100).
       
       FD FICHIER-FORMATION.
       01 WS-FORMATION.
           05 WS-MATRICULE-FORM    PIC 9(6).
           05 WS-ID-FORM           PIC 9(4).
           05 WS-INTITULE          PIC X(50).
           05 WS-DATE-FORM         PIC 9(8).
           05 WS-DUREE             PIC 9(3).
           05 WS-ORGANISME         PIC X(50).
           05 WS-COUT              PIC 9(7)V99.
           05 WS-VALIDEE           PIC X(1) VALUE 'N'.
       
       FD FICHIER-CANDIDATS.
       01 WS-CANDIDAT.
           05 WS-ID-CANDIDAT       PIC 9(6).
           05 WS-NOM-CAND          PIC X(30).
           05 WS-PRENOM-CAND       PIC X(30).
           05 WS-EMAIL-CAND        PIC X(50).
           05 WS-TEL-CAND          PIC X(15).
           05 WS-DIPLOME           PIC X(50).
           05 WS-EXPERIENCE        PIC 9(2).
           05 WS-POSTE-VISE        PIC X(30).
           05 WS-STATUT-CAND       PIC X(10).
              88 A_TRAITER         VALUE 'TRAITER'.
              88 ENTRETIEN         VALUE 'ENTRETIEN'.
              88 REFUSE            VALUE 'REFUSE'.
              88 E       PROCEDURE DIVISION.
           PERFORM 1000-INIT-RH
           PERFORM UNTIL WS-QUITTER-RH = 'O'
               PERFORM 2000-MENU-RH
               PERFORM 3000-TRAITER-RH
           END-PERFORM
           PERFORM 9000-FERMER-RH
           STOP RUN.
       
       1000-INIT-RH.
           DISPLAY "======================================"
           DISPLAY "         SYSTEME RH INTEGRE"
           DISPLAY "    CONGES - FORMATION - RECRUTEMENT"
           DISPLAY "======================================"
           
           OPEN I-O FICHIER-EMPLOYES
           IF WS-FS-RH NOT = '00'
               OPEN OUTPUT FICHIER-EMPLOYES
               CLOSE FICHIER-EMPLOYES
               OPEN I-O FICHIER-EMPLOYES
               PERFORM 1100-CHARGER-EMPLOYES-RH
           END-IF
           
           OPEN I-O FICHIER-CONGES
           IF WS-FS-CON NOT = '00'
               OPEN OUTPUT FICHIER-CONGES
               CLOSE FICHIER-CONGES
               OPEN I-O FICHIER-CONGES
           END-IF
           
           OPEN I-O FICHIER-FORMATION
           IF WS-FS-FORM NOT = '00'
               OPEN OUTPUT FICHIER-FORMATION
               CLOSE FICHIER-FORMATION
               OPEN I-O FICHIER-FORMATION
           END-IF
           
           OPEN EXTEND FICHIER-CANDIDATS
           .
       
       1100-CHARGER-EMPLOYES-RH.
           MOVE 1001 TO WS-MATRICULE-RH
           MOVE "DUPONT" TO WS-NOM-RH
           MOVE "JEAN" TO WS-PRENOM-RH
           MOVE "15031980" TO WS-DATE-NAISS-RH
           MOVE "01012020" TO WS-DATE-EMBAUCHE-RH
           MOVE "INFORMATIQUE" TO WS-SERVICE
           MOVE "DEVELOPPEUR" TO WS-POSTE
           MOVE 0 TO WS-CONGES-PRIS
           MOVE 25 TO WS-CONGES-ANNUELS
           MOVE 25 TO WS-CONGES-RESTANTS
           MOVE 0 TO WS-HEURES-FORMATION
           MOVE 3500.00 TO WS-SALAIRE-RH
           MOVE "ACTIF" TO WS-STATUT-EMPLOYE
           WRITE WS-EMPLOYE-RH
           
           MOVE 1002 TO WS-MATRICULE-RH
           MOVE "MARTIN" TO WS-NOM-RH
           MOVE "SOPHIE" TO WS-PRENOM-RH
           MOVE "20051985" TO WS-DATE-NAISS-RH
           MOVE "15032021" TO WS-DATE-EMBAUCHE-RH
           MOVE "COMMERCIAL" TO WS-SERVICE
           MOVE "COMMERCIAL" TO WS-POSTE
           MOVE 0 TO WS-CONGES-PRIS
           MOVE 25 TO WS-CONGES-ANNUELS
           MOVE 25 TO WS-CONGES-RESTANTS
           MOVE 0 TO WS-HEURES-FORMATION
           MOVE 2800.00 TO WS-SALAIRE-RH
           MOVE "ACTIF" TO WS-STATUT-EMPLOYE
           WRITE WS-EMPLOYE-RH
           
           DISPLAY "EMPLOYES DE TEST CHARGES"
           .
       
       2000-MENU-RH.
           DISPLAY " "
           DISPLAY "=== MENU PRINCIPAL RH ==="
           DISPLAY "1.  GESTION CONGES"
           DISPLAY "2.  GESTION FORMATION"
           DISPLAY "3.  RECRUTEMENT"
           DISPLAY "4.  BILAN SOCIAL"
           DISPLAY "5.  TABLEAU DE BORD RH"
           DISPLAY "6.  PLANNING PRESENCE"
           DISPLAY "7.  ENTREVUES"
           DISPLAY "8.  QUITTER"
           DISPLAY "CHOIX: "
           ACCEPT WS-CHOIX
           .
       
       3000-TRAITER-RH.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-GESTION-CONGES
               WHEN 2 PERFORM 5000-GESTION-FORMATION
               WHEN 3 PERFORM 6000-RECRUTEMENT
               WHEN 4 PERFORM 7000-BILAN-SOCIAL-RH
               WHEN 5 PERFORM 8000-TABLEAU-BORD-RH
               WHEN 6 PERFORM 8100-PLANNING-PRESENCE
               WHEN 7 PERFORM 8200-ENTREVUES
               WHEN 8 MOVE 'O' TO WS-QUITTER-RH
               WHEN OTHER DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       
       4000-GESTION-CONGES.
           DISPLAY "--- GESTION CONGES ---"
           DISPLAY "1. DEMANDER CONGE"
           DISPLAY "2. VALIDER CONGE"
           DISPLAY "3. LISTE DEMANDES"
           DISPLAY "4. SOLDE CONGES"
           DISPLAY "5. PLANNING CONGES"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4100-DEMANDER-CONGE
               WHEN 2 PERFORM 4200-VALIDER-CONGE
               WHEN 3 PERFORM 4300-LISTE-DEMANDES
               WHEN 4 PERFORM 4400-SOLDE-CONGES
               WHEN 5 PERFORM 4500-PLANNING-CONGES
           END-EVALUATE
           .
       
       4100-DEMANDER-CONGE.
           DISPLAY "--- DEMANDE CONGE ---"
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-RECH
           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-RH
           
           READ FICHIER-EMPLOYES
               INVALID KEY
                   DISPLAY "EMPLOYE NON TROUVE"
               NOT INVALID KEY
                   DISPLAY "DATE DEBUT (JJMMAAAA): "
                   ACCEPT WS-DEBUT-CON
                   DISPLAY "DATE FIN (JJMMAAAA): "
                   ACCEPT WS-FIN-CON
                   DISPLAY "TYPE CONGE (PAYES/SANS-SOLDE/RTT): "
                   ACCEPT WS-TYPE-CONGE
                   DISPLAY "MOTIF: "
                   ACCEPT WS-MOTIF
                   
                   COMPUTE WS-NB-JOURS = WS-FIN-CON - WS-DEBUT-CON
                   COMPUTE WS-NB-JOURS = WS-NB-JOURS + 1
                   
                   IF WS-CONGES-RESTANTS >= WS-NB-JOURS
                       MOVE WS-MATRICULE-RECH TO WS-MATRICULE-CON
                       MOVE "ATTENTE" TO WS-STATUT-CONGE
                       WRITE WS-DEMANDE-CONGE
                       DISPLAY "DEMANDE ENREGISTREE"
                   ELSE
                       DISPLAY "SOLDE CONGES INSUFFISANT"
                       DISPLAY "RESTANT: " WS-CONGES-RESTANTS
                       DISPLAY "DEMANDE: " WS-NB-JOURS
                   END-IF
           END-READ
           .
       
       4200-VALIDER-CONGE.
           DISPLAY "--- VALIDATION CONGE ---"
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-RECH
           DISPLAY "DATE DEBUT: "
           ACCEPT WS-DEBUT-RECH
           
           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-CON
           MOVE WS-DEBUT-RECH TO WS-DEBUT-CON
           
           READ FICHIER-CONGES
               INVALID KEY
                   DISPLAY "DEMANDE NON TROUVEE"
               NOT INVALID KEY
                   IF EN-ATTENTE
                       DISPLAY "1. VALIDER"
                       DISPLAY "2. REFUSER"
                       ACCEPT WS-CHOIX
                       
                       IF WS-CHOIX = 1
                           MOVE "VALIDE" TO WS-STATUT-CONGE
                           REWRITE WS-DEMANDE-CONGE
                           
                           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-RH
                           READ FICHIER-EMPLOYES
                               NOT INVALID KEY
                                   ADD WS-NB-JOURS 
                                     TO WS-CONGES-PRIS
                                   SUBTRACT WS-NB-JOURS 
                                     FROM WS-CONGES-RESTANTS
                                   REWRITE WS-EMPLOYE-RH
                           END-READ
                           DISPLAY "CONGE VALIDE"
                       ELSE
                           MOVE "REFUSE" TO WS-STATUT-CONGE
                           REWRITE WS-DEMANDE-CONGE
                           DISPLAY "CONGE REFUSE"
                       END-IF
                   ELSE
                       DISPLAY "DEMANDE DEJA TRAITEE"
                   END-IF
           END-READ
           .
       
       4300-LISTE-DEMANDES.
           DISPLAY "--- LISTE DEMANDES CONGES ---"
           DISPLAY "MATRIC | DEBUT     | FIN       | NB JOURS | STATUT"
           DISPLAY "-------+-----------+-----------+----------+--------"
           
           MOVE 0 TO WS-MATRICULE-CON
           START FICHIER-CONGES KEY IS NOT < WS-MATRICULE-CON
           
           PERFORM UNTIL WS-FS-CON = '10'
               READ FICHIER-CONGES NEXT
                   AT END
                       MOVE '10' TO WS-FS-CON
                   NOT AT END
                       DISPLAY WS-MATRICULE-CON " | "
                               WS-DEBUT-CON " | "
                               WS-FIN-CON " | "
                               WS-NB-JOURS " | "
                               WS-STATUT-CONGE
               END-READ
           END-PERFORM
           .
       
       4400-SOLDE-CONGES.
           DISPLAY "--- SOLDE CONGES ---"
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-RECH
           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-RH
           
           READ FICHIER-EMPLOYES
               INVALID KEY
                   DISPLAY "EMPLOYE NON TROUVE"
               NOT INVALID KEY
                   DISPLAY " "
                   DISPLAY "SOLDE CONGES POUR: " 
                           FUNCTION TRIM(WS-PRENOM-RH) " "
                           FUNCTION TRIM(WS-NOM-RH)
                   DISPLAY "CONGES ANNUELS: " WS-CONGES-ANNUELS
                   DISPLAY "CONGES PRIS: " WS-CONGES-PRIS
                   DISPLAY "CONGES RESTANTS: " WS-CONGES-RESTANTS
           END-READ
           .
       
       4500-PLANNING-CONGES.
           DISPLAY "--- PLANNING CONGES ---"
           DISPLAY "MOIS (MM): "
           ACCEPT WS-MOIS-CON
           DISPLAY "ANNEE (AAAA): "
           ACCEPT WS-ANNEE-CON
           
           DISPLAY " "
           DISPLAY "PLANNING DES CONGES - " 
                   WS-MOIS-CON "/" WS-ANNEE-CON
           DISPLAY "MATRIC | NOM PRENOM           | DEBUT     | FIN"
           DISPLAY "-------+----------------------+-----------+--------"
           
           MOVE 0 TO WS-MATRICULE-CON
           START FICHIER-CONGES KEY IS NOT < WS-MATRICULE-CON
           
           PERFORM UNTIL WS-FS-CON = '10'
               READ FICHIER-CONGES NEXT
                   AT END
                       MOVE '10' TO WS-FS-CON
                   NOT AT END
                       IF VALIDE
                           IF FUNCTION INTEGER(
                              WS-DEBUT-CON(5:4)) = WS-ANNEE-CON
                              AND FUNCTION INTEGER(
                              WS-DEBUT-CON(3:2)) = WS-MOIS-CON
                               MOVE WS-MATRICULE-CON 
                                 TO WS-MATRICULE-RH
                               READ FICHIER-EMPLOYES
                                   NOT INVALID KEY
                                       DISPLAY WS-MATRICULE-CON 
                                               " | "
                                               FUNCTION TRIM(
                                               WS-PRENOM-RH) " "
                                               FUNCTION TRIM(
                                               WS-NOM-RH)
                                               SPACE(22 - 
                                               FUNCTION LENGTH(
                                               FUNCTION TRIM(
                                               WS-PRENOM-RH) " "
                                               FUNCTION TRIM(
                                               WS-NOM-RH)))
                                               " | " 
                                               WS-DEBUT-CON " | "
                                               WS-FIN-CON
                               END-READ
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           .
       
       5000-GESTION-FORMATION.
           DISPLAY "--- GESTION FORMATION ---"
           DISPLAY "1. INSCRIRE FORMATION"
           DISPLAY "2. VALIDER FORMATION"
           DISPLAY "3. LISTE FORMATIONS"
           DISPLAY "4. BILAN FORMATION"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 5100-INSCRIRE-FORMATION
               WHEN 2 PERFORM 5200-VALIDER-FORMATION
               WHEN 3 PERFORM 5300-LISTE-FORMATIONS
               WHEN 4 PERFORM 5400-BILAN-FORMATION-RH
           END-EVALUATE
           .
       
       5100-INSCRIRE-FORMATION.
           DISPLAY "--- INSCRIPTION FORMATION ---"
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-RECH
           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-RH
           
           READ FICHIER-EMPLOYES
               INVALID KEY
                   DISPLAY "EMPLOYE NON TROUVE"
               NOT INVALID KEY
                   DISPLAY "ID FORMATION: "
                   ACCEPT WS-ID-FORM
                   DISPLAY "INTITULE: "
                   ACCEPT WS-INTITULE
                   DISPLAY "DATE (JJMMAAAA): "
                   ACCEPT WS-DATE-FORM
                   DISPLAY "DUREE (HEURES): "
                   ACCEPT WS-DUREE
                   DISPLAY "ORGANISME: "
                   ACCEPT WS-ORGANISME
                   DISPLAY "COUT: "
                   ACCEPT WS-COUT
                   
                   MOVE WS-MATRICULE-RECH TO WS-MATRICULE-FORM
                   MOVE 'N' TO WS-VALIDEE
                   WRITE WS-FORMATION
                   DISPLAY "INSCRIPTION ENREGISTREE"
           END-READ
           .
       
       5200-VALIDER-FORMATION.
           DISPLAY "--- VALIDATION FORMATION ---"
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-RECH
           DISPLAY "ID FORMATION: "
           ACCEPT WS-ID-FORM-RECH
           
           MOVE WS-MATRICULE-RECH TO WS-MATRICULE-FORM
           MOVE WS-ID-FORM-RECH TO WS-ID-FORM
           
           READ FICHIER-FORMATION
               INVALID KEY
                   DISPLAY "FORMATION NON TROUVEE"
               NOT INVALID KEY
                   MOVE 'O' TO WS-VALIDEE
                   REWRITE WS-FORMATION
                   
                   MOVE WS-MATRICULE-RECH TO WS-MATRICULE-RH
                   READ FICHIER-EMPLOYES
                       NOT INVALID KEY
                           ADD WS-DUREE 
                             TO WS-HEURES-FORMATION
                           REWRITE WS-EMPLOYE-RH
                   END-READ
                   DISPLAY "FORMATION VALIDEE"
           END-READ
           .
       
       5300-LISTE-FORMATIONS.
           DISPLAY "--- LISTE FORMATIONS ---"
           DISPLAY "MATRIC | DATE       | INTITULE"
           DISPLAY "-------+------------+--------------------------------"
           
           MOVE 0 TO WS-MATRICULE-FORM
           START FICHIER-FORMATION 
               KEY IS NOT < WS-MATRICULE-FORM
           
           PERFORM UNTIL WS-FS-FORM = '10'
               READ FICHIER-FORMATION NEXT
                   AT END
                       MOVE '10' TO WS-FS-FORM
                   NOT AT END
                       DISPLAY WS-MATRICULE-FORM " | "
                               WS-DATE-FORM " | "
                               FUNCTION TRIM(WS-INTITULE)
               END-READ
           END-PERFORM
           .
       
       5400-BILAN-FORMATION-RH.
           DISPLAY "--- BILAN FORMATION ---"
           MOVE 0 TO WS-TOTAL-HEURES WS-TOTAL-COUT
           
           MOVE 0 TO WS-MATRICULE-FORM
           START FICHIER-FORMATION 
               KEY IS NOT < WS-MATRICULE-FORM
           
           PERFORM UNTIL WS-FS-FORM = '10'
               READ FICHIER-FORMATION NEXT
                   AT END
                       MOVE '10' TO WS-FS-FORM
                   NOT AT END
                       ADD WS-DUREE TO WS-TOTAL-HEURES
                       ADD WS-COUT TO WS-TOTAL-COUT
               END-READ
           END-PERFORM
           
           DISPLAY "TOTAL HEURES FORMATION: " WS-TOTAL-HEURES
           DISPLAY "TOTAL COUT FORMATION: " WS-TOTAL-COUT " EUR"
           .
       
       6000-RECRUTEMENT.
           DISPLAY "--- RECRUTEMENT ---"
           DISPLAY "1. DEPOSER CANDIDATURE"
           DISPLAY "2. LISTE CANDIDATS"
           DISPLAY "3. TRAITER CANDIDATURE"
           DISPLAY "4. PLANIFIER ENTRETIEN"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 6100-DEPOSER-CANDIDATURE
               WHEN 2 PERFORM 6200-LISTE-CANDIDATS
               WHEN 3 PERFORM 6300-TRAITER-CANDIDATURE
               WHEN 4 PERFORM 6400-PLANIFIER-ENTRETIEN
           END-EVALUATE
           .
       
       6100-DEPOSER-CANDIDATURE.
           DISPLAY "--- DEPOT CANDIDATURE ---"
           ADD 1 TO WS-ID-CANDIDAT
           DISPLAY "NOM: "
           ACCEPT WS-NOM-CAND
           DISPLAY "PRENOM: "
           ACCEPT WS-PRENOM-CAND
           DISPLAY "EMAIL: "
           ACCEPT WS-EMAIL-CAND
           DISPLAY "TELEPHONE: "
           ACCEPT WS-TEL-CAND
           DISPLAY "DIPLOME: "
           ACCEPT WS-DIPLOME
           DISPLAY "EXPERIENCE (ANNES): "
           ACCEPT WS-EXPERIENCE
           DISPLAY "POSTE VISE: "
           ACCEPT WS-POSTE-VISE
           MOVE "TRAITER" TO WS-STATUT-CAND
           WRITE WS-CANDIDAT
           DISPLAY "CANDIDATURE ENREGISTREE"
           .
       
       6200-LISTE-CANDIDATS.
           DISPLAY "--- LISTE CANDIDATS ---"
           DISPLAY "ID | NOM PRENOM            | POSTE VISE"
           DISPLAY "---+-----------------------+----------------"
           
           CLOSE FICHIER-CANDIDATS
           OPEN INPUT FICHIER-CANDIDATS
           
           PERFORM UNTIL WS-FS-CAND = '10'
               READ FICHIER-CANDIDATS
                   AT END
                       MOVE '10' TO WS-FS-CAND
                   NOT AT END
                       DISPLAY WS-ID-CANDIDAT " | "
                               FUNCTION TRIM(WS-PRENOM-CAND) " "
                               FUNCTION TRIM(WS-NOM-CAND)
                               SPACE(22 - FUNCTION LENGTH(
                               FUNCTION TRIM(WS-PRENOM-CAND) " "
                               FUNCTION TRIM(WS-NOM-CAND)))
                               " | " 
                               FUNCTION TRIM(WS-POSTE-VISE)
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-CANDIDATS
           OPEN EXTEND FICHIER-CANDIDATS
           .
       
       6300-TRAITER-CANDIDATURE.
           DISPLAY "--- TRAITEMENT CANDIDATURE ---"
           DISPLAY "ID CANDIDAT: "
           ACCEPT WS-ID-RECH
           
           CLOSE FICHIER-CANDIDATS
           OPEN I-O FICHIER-CANDIDATS
           
           PERFORM UNTIL WS-FS-CAND = '10'
               READ FICHIER-CANDIDATS
                   AT END
                       MOVE '10' TO WS-FS-CAND
                   NOT AT END
                       IF WS-ID-CANDIDAT = WS-ID-RECH
                           DISPLAY "CANDIDAT: " 
                                   FUNCTION TRIM(WS-PRENOM-CAND)
                                   " " FUNCTION TRIM(WS-NOM-CAND)
                           DISPLAY "POSTE: " WS-POSTE-VISE
                           DISPLAY "EXPERIENCE: " 
                                   WS-EXPERIENCE " ANS"
                           DISPLAY "1. ENTRETIEN"
                           DISPLAY "2. REFUS"
                           DISPLAY "3. EMBARCHE"
                           ACCEPT WS-CHOIX
                           
                           EVALUATE WS-CHOIX
                               WHEN 1 MOVE "ENTRETIEN" 
                                 TO WS-STATUT-CAND
                               WHEN 2 MOVE "REFUSE" 
                                 TO WS-STATUT-CAND
                               WHEN 3 MOVE "EMBARCHE" 
                                 TO WS-STATUT-CAND
                           END-EVALUATE
                           REWRITE WS-CANDIDAT
                           DISPLAY "CANDIDATURE MISE A JOUR"
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-CANDIDATS
           OPEN EXTEND FICHIER-CANDIDATS
           .
       
       6400-PLANIFIER-ENTRETIEN.
           DISPLAY "--- PLANIFICATION ENTRETIEN ---"
           DISPLAY "ID CANDIDAT: "
           ACCEPT WS-ID-RECH
           DISPLAY "DATE ENTRETIEN (JJMMAAAA): "
           ACCEPT WS-DATE-ENTRETIEN
           DISPLAY "HEURE: "
           ACCEPT WS-HEURE-ENTRETIEN
           DISPLAY "LIEU: "
           ACCEPT WS-LIEU-ENTRETIEN
           
           DISPLAY "ENTRETIEN PLANIFIE LE " 
                   WS-DATE-ENTRETIEN " A " 
                   WS-HEURE-ENTRETIEN
           .
       
       7000-BILAN-SOCIAL-RH.
           DISPLAY "=== BILAN SOCIAL ==="
           MOVE 0 TO WS-NB-TOTAL WS-NB-ACTIF WS-NB-CONGE
           MOVE 0 TO WS-MASSE-SALARIALE
           
           MOVE 0 TO WS-MATRICULE-RH
           START FICHIER-EMPLOYES KEY IS NOT < WS-MATRICULE-RH
           
           PERFORM UNTIL WS-FS-RH = '10'
               READ FICHIER-EMPLOYES NEXT
                   AT END
                       MOVE '10' TO WS-FS-RH
                   NOT AT END
                       ADD 1 TO WS-NB-TOTAL
                       ADD WS-SALAIRE-RH TO WS-MASSE-SALARIALE
                       
                       IF ACTIF
                           ADD 1 TO WS-NB-ACTIF
                       END-IF
                       IF CONGE
                           ADD 1 TO WS-NB-CONGE
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY "EFFECTIF TOTAL: " WS-NB-TOTAL
           DISPLAY "ACTIFS: " WS-NB-ACTIF
           DISPLAY "EN CONGE: " WS-NB-CONGE
           DISPLAY "MASSE SALARIALE: " WS-MASSE-SALARIALE " EUR"
           .
       
       8000-TABLEAU-BORD-RH.
           DISPLAY "=== TABLEAU DE BORD RH ==="
           PERFORM 7000-BILAN-SOCIAL-RH
           PERFORM 5400-BILAN-FORMATION-RH
           PERFORM 8010-CALCULER-ABSENTEISME
           .
       
       8010-CALCULER-ABSENTEISME.
           MOVE 0 TO WS-NB-JOURS-CONGES
           MOVE 0 TO WS-MATRICULE-CON
           START FICHIER-CONGES KEY IS NOT < WS-MATRICULE-CON
           
           PERFORM UNTIL WS-FS-CON = '10'
               READ FICHIER-CONGES NEXT
                   AT END
                       MOVE '10' TO WS-FS-CON
                   NOT AT END
                       IF VALIDE
                           ADD WS-NB-JOURS TO WS-NB-JOURS-CONGES
                       END-IF
               END-READ
           END-PERFORM
           
           DISPLAY "TOTAL JOURS CONGES PRIS: " WS-NB-JOURS-CONGES
           IF WS-NB-TOTAL > 0
               COMPUTE WS-TAUX-ABS = WS-NB-JOURS-CONGES / 
                                     (WS-NB-TOTAL * 20) * 100
               DISPLAY "TAUX D'ABSENTEISME: " WS-TAUX-ABS "%"
           END-IF
           .
       
       8100-PLANNING-PRESENCE.
           DISPLAY "--- PLANNING PRESENCE ---"
           DISPLAY "DATE (JJMMAAAA): "
           ACCEPT WS-DATE-PRES
           DISPLAY "MATRICULE: "
           ACCEPT WS-MATRICULE-PRES
           DISPLAY "STATUT (PRESENT/ABSENT/CONGE): "
           ACCEPT WS-STATUT-PRES
           DISPLAY "PRESENCE ENREGISTREE"
           .
       
       8200-ENTREVUES.
           DISPLAY "--- ENTREVUES PLANIFIEES ---"
           DISPLAY "DATE | CANDIDAT | POSTE"
           DISPLAY "-----+----------+----------------"
           
           CLOSE FICHIER-CANDIDATS
           OPEN INPUT FICHIER-CANDIDATS
           
           PERFORM UNTIL WS-FS-CAND = '10'
               READ FICHIER-CANDIDATS
                   AT END
                       MOVE '10' TO WS-FS-CAND
                   NOT AT END
                       IF ENTRETIEN
                           DISPLAY WS-DATE-ENTRETIEN " | "
                                   FUNCTION TRIM(WS-PRENOM-CAND)
                                   " " 
                                   FUNCTION TRIM(WS-NOM-CAND)
                                   " | " 
                                   FUNCTION TRIM(WS-POSTE-VISE)
                       END-IF
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-CANDIDATS
           OPEN EXTEND FICHIER-CANDIDATS
           .
       
       9000-FERMER-RH.
           CLOSE FICHIER-EMPLOYES
           CLOSE FICHIER-CONGES
           CLOSE FICHIER-FORMATION
           CLOSE FICHIER-CANDIDATS
           DISPLAY "SYSTEME RH ARRETE"
           .
