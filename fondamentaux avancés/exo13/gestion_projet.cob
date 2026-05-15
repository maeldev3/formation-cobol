       IDENTIFICATION DIVISION.
       PROGRAM-ID. GESTION-PROJET.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-PROJETS
               ASSIGN TO "projets.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ID-PROJET
               FILE STATUS IS WS-FS-PROJ.
           
           SELECT FICHIER-TACHES
               ASSIGN TO "taches.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-PROJET-ID, WS-TACHE-ID
               FILE STATUS IS WS-FS-TACHE.
           
           SELECT FICHIER-RESSOURCES
               ASSIGN TO "ressources.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-ID-RESSOURCE
               FILE STATUS IS WS-FS-RESS.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-PROJETS.
       01 WS-PROJET.
           05 WS-ID-PROJET        PIC 9(6).
           05 WS-NOM-PROJET       PIC X(50).
           05 WS-DATE-DEBUT       PIC 9(8).
           05 WS-DATE-FIN-PREVUE  PIC 9(8).
           05 WS-DATE-FIN-REELLE  PIC 9(8).
           05 WS-BUDGET-PREVU     PIC 9(12)V99.
           05 WS-BUDGET-REELLE    PIC 9(12)V99.
           05 WS-CHEF-PROJET      PIC X(30).
           05 WS-STATUT-PROJET    PIC X(15).
              88 EN_COURS         VALUE 'EN COURS'.
              88 TERMINE          VALUE 'TERMINE'.
              88 EN_RETARD        VALUE 'EN RETARD'.
              88 ANNULE           VALUE 'ANNULE'.
           05 WS-PRIORITE         PIC X(1) VALUE 'M'.
              88 HAUTE_PRIO       VALUE 'H'.
              88 MOYENNE_PRIO     VALUE 'M'.
              88 BASSE_PRIO       VALUE 'B'.
       
       FD FICHIER-TACHES.
       01 WS-TACHE.
           05 WS-PROJET-ID        PIC 9(6).
           05 WS-TACHE-ID         PIC 9(6).
           05 WS-TACHE-NOM        PIC X(50).
           05 WS-TACHE-DEBUT      PIC 9(8).
           05 WS-TACHE-FIN        PIC 9(8).
           05 WS-TACHE-DUREE      PIC 9(4).
           05 WS-TACHE-STATUT     PIC X(15).
              88 A_FAIRE          VALUE 'A FAIRE'.
              88 EN_COURS_TACHE   VALUE 'EN COURS'.
              88 TERMINE_TACHE    VALUE 'TERMINE'.
           05 WS-RESSOURCE-ID     PIC 9(6).
           05 WS-COUT-TACHE       PIC 9(10)V99.
           05 WS-AVANCEMENT       PIC 9(3).
       
       FD FICHIER-RESSOURCES.
       01 WS-RESSOURCE.
           05 WS-ID-RESSOURCE     PIC 9(6).
           05 WS-NOM-RESSOURCE    PIC X(30).
           05 WS-TYPE-RESSOURCE   PIC X(20).
              88 HUMAINE          VALUE 'HUMAINE'.
              88 MATERIELLE       VALUE 'MATERIELLE'.
              88 FINANCIERE       VALUE 'FINANCIERE'.
           05 WS-COUT-HORAIRE     PIC 9(7)V99.
           05 WS-DISPONIBILITE    PIC 9(3).
           05 WS-COMPETENCES      PIC X(50).
       
       WORKING-STORAGE SECTION.
       01 WS-FS-PROJ              PIC XX.
       01 WS-FS-TACHE             PIC XX.
       01 WS-FS-RESS              PIC XX.
       01 WS-CHOIX                PIC 9.
       01 WS-QUITTER-PROJ         PIC X(1) VALUE 'N'.
       01 WS-I                    PIC 9(4).
       01 WS-DATE-COURANTE-PROJ.
           05 WS-PROJ-JOUR        PIC 9(2).
           05 WS-PROJ-MOIS        PIC 9(2).
           05 WS-PROJ-ANNEE       PIC 9(4).
       
       *> ZONES SUIVI PROJET
       01 WS-INDICATEURS.
           05 WS-AVANCEMENT-GLOBAL PIC 9(3).
           05 WS-RETARD-GLOBAL     PIC 9(4).
           05 WS-ECART-BUDGET      PIC 9(12)V99.
           05 WS-TAUX-RETARD       PIC 9(4)V99.
           05 WS-NB-TACHES-TOTAL   PIC 9(4).
           05 WS-NB-TACHES-FAITES  PIC 9(4).
       
       PROCEDURE DIVISION.
           PERFORM 1000-INIT-PROJET
           PERFORM UNTIL WS-QUITTER-PROJ = 'O'
               PERFORM 2000-MENU-PROJET
               PERFORM 3000-TRAITER-PROJET
           END-PERFORM
           PERFORM 9000-FERMER-PROJET
           STOP RUN.
       
       1000-INIT-PROJET.
           DISPLAY "======================================"
           DISPLAY "        GESTION DE PROJET"
           DISPLAY "    PLANNING - RESSOURCES - BUDGET"
           DISPLAY "======================================"
           
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-COURANTE-PROJ
           
           OPEN I-O FICHIER-PROJETS
           IF WS-FS-PROJ NOT = '00'
               OPEN OUTPUT FICHIER-PROJETS
               CLOSE FICHIER-PROJETS
               OPEN I-O FICHIER-PROJETS
               PERFORM 1100-CHARGER-PROJETS-TEST
           END-IF
           
           OPEN I-O FICHIER-TACHES
           IF WS-FS-TACHE NOT = '00'
               OPEN OUTPUT FICHIER-TACHES
               CLOSE FICHIER-TACHES
               OPEN I-O FICHIER-TACHES
           END-IF
           
           OPEN I-O FICHIER-RESSOURCES
           IF WS-FS-RESS NOT = '00'
               OPEN OUTPUT FICHIER-RESSOURCES
               CLOSE FICHIER-RESSOURCES
               OPEN I-O FICHIER-RESSOURCES
               PERFORM 1200-CHARGER-RESSOURCES
           END-IF
           .
       
       1100-CHARGER-PROJETS-TEST.
           MOVE 1001 TO WS-ID-PROJET
           MOVE "REFONTE SITE WEB" TO WS-NOM-PROJET
           MOVE 01012024 TO WS-DATE-DEBUT
           MOVE 30062024 TO WS-DATE-FIN-PREVUE
           MOVE 0 TO WS-DATE-FIN-REELLE
           MOVE 50000.00 TO WS-BUDGET-PREVU
           MOVE 0 TO WS-BUDGET-REELLE
           MOVE "JEAN DUPONT" TO WS-CHEF-PROJET
           MOVE "EN COURS" TO WS-STATUT-PROJET
           MOVE "H" TO WS-PRIORITE
           WRITE WS-PROJET
           
           MOVE 1002 TO WS-ID-PROJET
           MOVE "APPLICATION MOBILE" TO WS-NOM-PROJET
           MOVE 01032024 TO WS-DATE-DEBUT
           MOVE 31122024 TO WS-DATE-FIN-PREVUE
           MOVE 0 TO WS-DATE-FIN-REELLE
           MOVE 75000.00 TO WS-BUDGET-PREVU
           MOVE 0 TO WS-BUDGET-REELLE
           MOVE "SOPHIE MARTIN" TO WS-CHEF-PROJET
           MOVE "EN COURS" TO WS-STATUT-PROJET
           MOVE "M" TO WS-PRIORITE
           WRITE WS-PROJET
           .
       
       1200-CHARGER-RESSOURCES.
           MOVE 2001 TO WS-ID-RESSOURCE
           MOVE "JEAN DUPONT" TO WS-NOM-RESSOURCE
           MOVE "HUMAINE" TO WS-TYPE-RESSOURCE
           MOVE 50.00 TO WS-COUT-HORAIRE
           MOVE 100 TO WS-DISPONIBILITE
           MOVE "COBOL,JAVA,SQL" TO WS-COMPETENCES
           WRITE WS-RESSOURCE
           
           MOVE 2002 TO WS-ID-RESSOURCE
           MOVE "SERVEUR PROD" TO WS-NOM-RESSOURCE
           MOVE "MATERIELLE" TO WS-TYPE-RESSOURCE
           MOVE 0.00 TO WS-COUT-HORAIRE
           MOVE 100 TO WS-DISPONIBILITE
           MOVE "HEBERGEMENT" TO WS-COMPETENCES
           WRITE WS-RESSOURCE
           .
       
       2000-MENU-PROJET.
           DISPLAY " "
           DISPLAY "=== MENU GESTION DE PROJET ==="
           DISPLAY "1.  CREER PROJET"
           DISPLAY "2.  AJOUTER TACHE"
           DISPLAY "3.  SUIVI PROJET"
           DISPLAY "4.  TABLEAU DE BORD"
           DISPLAY "5.  DIAGRAMME DE GANTT"
           DISPLAY "6.  GESTION RESSOURCES"
           DISPLAY "7.  RAPPORT D'AVANCEMENT"
           DISPLAY "8.  ANALYSE DES RISQUES"
           DISPLAY "9.  QUITTER"
           DISPLAY "CHOIX: "
           ACCEPT WS-CHOIX
           .
       
       3000-TRAITER-PROJET.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-CREER-PROJET
               WHEN 2 PERFORM 5000-AJOUTER-TACHE
               WHEN 3 PERFORM 6000-SUIVI-PROJET
               WHEN 4 PERFORM 7000-TABLEAU-BORD-PROJET
               WHEN 5 PERFORM 7100-DIAGRAMME-GANTT
               WHEN 6 PERFORM 8000-GESTION-RESSOURCES
               WHEN 7 PERFORM 8100-RAPPORT-AVANCEMENT
               WHEN 8 PERFORM 8200-ANALYSE-RISQUES
               WHEN 9 MOVE 'O' TO WS-QUITTER-PROJ
               WHEN OTHER DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       
       4000-CREER-PROJET.
           DISPLAY "--- CREATION PROJET ---"
           DISPLAY "ID PROJET: "
           ACCEPT WS-ID-PROJET
           
           READ FICHIER-PROJETS
               INVALID KEY
                   DISPLAY "NOM PROJET: "
                   ACCEPT WS-NOM-PROJET
                   DISPLAY "DATE DEBUT (JJMMAAAA): "
                   ACCEPT WS-DATE-DEBUT
                   DISPLAY "DATE FIN PREVUE (JJMMAAAA): "
                   ACCEPT WS-DATE-FIN-PREVUE
                   DISPLAY "BUDGET PREVU: "
                   ACCEPT WS-BUDGET-PREVU
                   DISPLAY "CHEF DE PROJET: "
                   ACCEPT WS-CHEF-PROJET
                   DISPLAY "PRIORITE (H/M/B): "
                   ACCEPT WS-PRIORITE
                   
                   MOVE 0 TO WS-BUDGET-REELLE
                   MOVE "EN COURS" TO WS-STATUT-PROJET
                   WRITE WS-PROJET
                   DISPLAY "PROJET CREE"
               NOT INVALID KEY
                   DISPLAY "ID PROJET EXISTANT"
           END-READ
           .
       
       5000-AJOUTER-TACHE.
           DISPLAY "--- AJOUTER TACHE ---"
           DISPLAY "ID PROJET: "
           ACCEPT WS-PROJET-ID
           
           READ FICHIER-PROJETS
               INVALID KEY
                   DISPLAY "PROJET NON TROUVE"
               NOT INVALID KEY
                   DISPLAY "ID TACHE: "
                   ACCEPT WS-TACHE-ID
                   
                   READ FICHIER-TACHES
                       INVALID KEY
                           DISPLAY "NOM TACHE: "
                           ACCEPT WS-TACHE-NOM
                           DISPLAY "DATE DEBUT (JJMMAAAA): "
                           ACCEPT WS-TACHE-DEBUT
                           DISPLAY "DUREE (JOURS): "
                           ACCEPT WS-TACHE-DUREE
                           DISPLAY "RESSOURCE ID: "
                           ACCEPT WS-RESSOURCE-ID
                           DISPLAY "COUT: "
                           ACCEPT WS-COUT-TACHE
                           
                           COMPUTE WS-TACHE-FIN = 
                               WS-TACHE-DEBUT + WS-TACHE-DUREE
                           MOVE "A FAIRE" TO WS-TACHE-STATUT
                           MOVE 0 TO WS-AVANCEMENT
                           
                           WRITE WS-TACHE
                           DISPLAY "TACHE AJOUTEE"
                       NOT INVALID KEY
                           DISPLAY "ID TACHE EXISTANT"
                   END-READ
           END-READ
           .
       
       6000-SUIVI-PROJET.
           DISPLAY "--- SUIVI PROJET ---"
           DISPLAY "ID PROJET: "
           ACCEPT WS-PROJET-RECH
           MOVE WS-PROJET-RECH TO WS-ID-PROJET
           
           READ FICHIER-PROJETS
               INVALID KEY
                   DISPLAY "PROJET NON TROUVE"
               NOT INVALID KEY
                   PERFORM 6100-CALCULER-AVANCEMENT
                   
                   DISPLAY " "
                   DISPLAY "=== SUIVI PROJET: " 
                           FUNCTION TRIM(WS-NOM-PROJET) " ==="
                   DISPLAY "CHEF DE PROJET: " WS-CHEF-PROJET
                   DISPLAY "PRIORITE: " WS-PRIORITE
                   DISPLAY "DATE DEBUT: " WS-DATE-DEBUT
                   DISPLAY "DATE FIN PREVUE: " WS-DATE-FIN-PREVUE
                   DISPLAY "-----------------------------------"
                   DISPLAY "AVANCEMENT GLOBAL: " 
                           WS-AVANCEMENT-GLOBAL "%"
                   DISPLAY "TACHES REALISEES: " 
                           WS-NB-TACHES-FAITES "/" 
                           WS-NB-TACHES-TOTAL
                   DISPLAY "RETARD: " WS-RETARD-GLOBAL " JOURS"
                   DISPLAY "ECART BUDGET: " WS-ECART-BUDGET " EUR"
                   
                   IF EN_RETARD
                       DISPLAY "*** PROJET EN RETARD ***"
                   END-IF
                   
                   PERFORM 6200-LISTER-TACHES
           END-READ
           .
       
       6100-CALCULER-AVANCEMENT.
           MOVE 0 TO WS-AVANCEMENT-GLOBAL
           MOVE 0 TO WS-NB-TACHES-TOTAL WS-NB-TACHES-FAITES
           MOVE 0 TO WS-RETARD-GLOBAL
           
           MOVE WS-PROJET-RECH TO WS-PROJET-ID
           MOVE 0 TO WS-TACHE-ID
           START FICHIER-TACHES 
               KEY IS NOT < WS-PROJET-ID
           
           PERFORM UNTIL WS-FS-TACHE = '10'
               READ FICHIER-TACHES NEXT
                   AT END
                       MOVE '10' TO WS-FS-TACHE
                   NOT AT END
                       IF WS-PROJET-ID = WS-PROJET-RECH
                           ADD 1 TO WS-NB-TACHES-TOTAL
                           IF TERMINE_TACHE
                               ADD 1 TO WS-NB-TACHES-FAITES
                           END-IF
                           ADD WS-AVANCEMENT 
                             TO WS-AVANCEMENT-GLOBAL
                           
                           IF WS-TACHE-FIN > WS-DATE-FIN-PREVUE
                               COMPUTE WS-RETARD = 
                                   WS-TACHE-FIN - 
                                   WS-DATE-FIN-PREVUE
                               IF WS-RETARD > WS-RETARD-GLOBAL
                                   MOVE WS-RETARD 
                                     TO WS-RETARD-GLOBAL
                               END-IF
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           
           IF WS-NB-TACHES-TOTAL > 0
               COMPUTE WS-AVANCEMENT-GLOBAL = 
                   WS-AVANCEMENT-GLOBAL / 
                   WS-NB-TACHES-TOTAL
           END-IF
           
           COMPUTE WS-ECART-BUDGET = 
               WS-BUDGET-REELLE - WS-BUDGET-PREVU
           
           IF WS-DATE-FIN-PREVUE < WS-DATE-COURANTE-PROJ
               MOVE "EN RETARD" TO WS-STATUT-PROJET
               REWRITE WS-PROJET
           END-IF
           .
       
       6200-LISTER-TACHES.
           DISPLAY " "
           DISPLAY "--- LISTE DES TACHES ---"
           DISPLAY "ID | TACHE                    | STATUT    | AVANCEMENT"
           DISPLAY "---+--------------------------+-----------+-----------"
           
           MOVE WS-PROJET-RECH TO WS-PROJET-ID
           MOVE 0 TO WS-TACHE-ID
           START FICHIER-TACHES 
               KEY IS NOT < WS-PROJET-ID
           
           PERFORM UNTIL WS-FS-TACHE = '10'
               READ FICHIER-TACHES NEXT
                   AT END
                       MOVE '10' TO WS-FS-TACHE
                   NOT AT END
                       IF WS-PROJET-ID = WS-PROJET-RECH
                           DISPLAY WS-TACHE-ID " | "
                                   FUNCTION TRIM(WS-TACHE-NOM)
                                   SPACE(25 - FUNCTION LENGTH(
                                   FUNCTION TRIM(WS-TACHE-NOM)))
                                   " | " 
                                   FUNCTION TRIM(WS-TACHE-STATUT)
                                   " | " 
                                   WS-AVANCEMENT "%"
                       END-IF
               END-READ
           END-PERFORM
           .
       
       7000-TABLEAU-BORD-PROJET.
           DISPLAY "=== TABLEAU DE BORD PROJETS ==="
           DISPLAY "PROJET ACTIF: "
           DISPLAY "ID | NOM                     | AVANCEMENT | STATUT"
           DISPLAY "---+-------------------------+------------+--------"
           
           MOVE 0 TO WS-ID-PROJET
           START FICHIER-PROJETS KEY IS NOT < WS-ID-PROJET
           
           PERFORM UNTIL WS-FS-PROJ = '10'
               READ FICHIER-PROJETS NEXT
                   AT END
                       MOVE '10' TO WS-FS-PROJ
                   NOT AT END
                       IF EN_COURS OR EN_RETARD
                           PERFORM 6100-CALCULER-AVANCEMENT
                           DISPLAY WS-ID-PROJET " | "
                                   FUNCTION TRIM(WS-NOM-PROJET)
                                   SPACE(24 - FUNCTION LENGTH(
                                   FUNCTION TRIM(WS-NOM-PROJET)))
                                   " | " 
                                   WS-AVANCEMENT-GLOBAL "% | "
                                   WS-STATUT-PROJET
                       END-IF
               END-READ
           END-PERFORM
           .
       
       7100-DIAGRAMME-GANTT.
           DISPLAY "--- DIAGRAMME DE GANTT ---"
           DISPLAY "PROJET ID: "
           ACCEPT WS-PROJET-GANTT
           
           DISPLAY " "
           DISPLAY "DIAGRAMME DE GANTT - PROJET: " 
                   WS-PROJET-GANTT
           DISPLAY "LEGENDE: [===] TACHE EN COURS"
           DISPLAY "         [---] TACHE TERMINEE"
           DISPLAY "         [   ] TACHE A FAIRE"
           DISPLAY " "
           
           MOVE WS-PROJET-GANTT TO WS-PROJET-ID
           MOVE 0 TO WS-TACHE-ID
           START FICHIER-TACHES 
               KEY IS NOT < WS-PROJET-ID
           
           PERFORM UNTIL WS-FS-TACHE = '10'
               READ FICHIER-TACHES NEXT
                   AT END
                       MOVE '10' TO WS-FS-TACHE
                   NOT AT END
                       IF WS-PROJET-ID = WS-PROJET-GANTT
                           DISPLAY FUNCTION TRIM(WS-TACHE-NOM)
                                   " ["
                                   WITH NO ADVANCING
                           PERFORM VARYING WS-I FROM 1 BY 1
                                     UNTIL WS-I > 20
                               IF WS-I <= WS-AVANCEMENT / 5
                                   IF TERMINE_TACHE
                                       DISPLAY "-" 
                                         WITH NO ADVANCING
                                   ELSE
                                       DISPLAY "=" 
                                         WITH NO ADVANCING
                                   END-IF
                               ELSE
                                   DISPLAY " " 
                                     WITH NO ADVANCING
                               END-IF
                           END-PERFORM
                           DISPLAY "] " WS-AVANCEMENT "%"
                       END-IF
               END-READ
           END-PERFORM
           .
       
       8000-GESTION-RESSOURCES.
           DISPLAY "--- GESTION RESSOURCES ---"
           DISPLAY "1. AJOUTER RESSOURCE"
           DISPLAY "2. LISTE RESSOURCES"
           DISPLAY "3. AFFECTER RESSOURCE"
           DISPLAY "4. DISPONIBILITE"
           ACCEPT WS-CHOIX
           
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 8010-AJOUTER-RESSOURCE
               WHEN 2 PERFORM 8020-LISTER-RESSOURCES
               WHEN 3 PERFORM 8030-AFFECTER-RESSOURCE
               WHEN 4 PERFORM 8040-VERIFIER-DISPONIBILITE
           END-EVALUATE
           .
       
       8010-AJOUTER-RESSOURCE.
           DISPLAY "--- AJOUTER RESSOURCE ---"
           DISPLAY "ID RESSOURCE: "
           ACCEPT WS-ID-RESSOURCE
           
           READ FICHIER-RESSOURCES
               INVALID KEY
                   DISPLAY "NOM: "
                   ACCEPT WS-NOM-RESSOURCE
                   DISPLAY "TYPE (HUMAINE/MATERIELLE/FINANCIERE): "
                   ACCEPT WS-TYPE-RESSOURCE
                   DISPLAY "COUT HORAIRE: "
                   ACCEPT WS-COUT-HORAIRE
                   DISPLAY "DISPONIBILITE (%): "
                   ACCEPT WS-DISPONIBILITE
                   DISPLAY "COMPETENCES: "
                   ACCEPT WS-COMPETENCES
                   WRITE WS-RESSOURCE
                   DISPLAY "RESSOURCE AJOUTEE"
               NOT INVALID KEY
                   DISPLAY "ID EXISTANT"
           END-READ
           .
       
       8020-LISTER-RESSOURCES.
           DISPLAY "--- LISTE RESSOURCES ---"
           DISPLAY "ID | NOM                     | TYPE      | DISPO"
           DISPLAY "---+-------------------------+-----------+------"
           
           MOVE 0 TO WS-ID-RESSOURCE
           START FICHIER-RESSOURCES 
               KEY IS NOT < WS-ID-RESSOURCE
           
           PERFORM UNTIL WS-FS-RESS = '10'
               READ FICHIER-RESSOURCES NEXT
                   AT END
                       MOVE '10' TO WS-FS-RESS
                   NOT AT END
                       DISPLAY WS-ID-RESSOURCE " | "
                               FUNCTION TRIM(WS-NOM-RESSOURCE)
                               SPACE(24 - FUNCTION LENGTH(
                               FUNCTION TRIM(WS-NOM-RESSOURCE)))
                               " | " 
                               FUNCTION TRIM(WS-TYPE-RESSOURCE)
                               " | " 
                               WS-DISPONIBILITE "%"
               END-READ
           END-PERFORM
           .
       
       8030-AFFECTER-RESSOURCE.
           DISPLAY "--- AFFECTER RESSOURCE ---"
           DISPLAY "ID TACHE: "
           ACCEPT WS-TACHE-ID-AFFECT
           DISPLAY "ID RESSOURCE: "
           ACCEPT WS-RESSOURCE-ID-AFFECT
           
           DISPLAY "RESSOURCE AFFECTEE A LA TACHE"
           .
       
       8040-VERIFIER-DISPONIBILITE.
           DISPLAY "--- VERIFICATION DISPONIBILITE ---"
           DISPLAY "ID RESSOURCE: "
           ACCEPT WS-RESSOURCE-RECH
           
           MOVE WS-RESSOURCE-RECH TO WS-ID-RESSOURCE
           READ FICHIER-RESSOURCES
               INVALID KEY
                   DISPLAY "RESSOURCE NON TROUVEE"
               NOT INVALID KEY
                   DISPLAY "RESSOURCE: " 
                           FUNCTION TRIM(WS-NOM-RESSOURCE)
                   DISPLAY "DISPONIBILITE: " 
                           WS-DISPONIBILITE "%"
                   
                   IF WS-DISPONIBILITE >= 70
                       DISPLAY "STATUT: DISPONIBLE"
                   ELSE
                       IF WS-DISPONIBILITE >= 30
                           DISPLAY "STATUT: PARTIELLEMENT DISPONIBLE"
                       ELSE
                           DISPLAY "STATUT: NON DISPONIBLE"
                       END-IF
                   END-IF
           END-READ
           .
       
       8100-RAPPORT-AVANCEMENT.
           DISPLAY "--- RAPPORT D'AVANCEMENT ---"
           DISPLAY "ID PROJET: "
           ACCEPT WS-PROJET-RAPPORT
           
           MOVE WS-PROJET-RAPPORT TO WS-ID-PROJET
           READ FICHIER-PROJETS
               INVALID KEY
                   DISPLAY "PROJET NON TROUVE"
               NOT INVALID KEY
                   PERFORM 6100-CALCULER-AVANCEMENT
                   
                   DISPLAY "========================================"
                   DISPLAY "RAPPORT D'AVANCEMENT - " 
                           FUNCTION TRIM(WS-NOM-PROJET)
                   DISPLAY "========================================"
                   DISPLAY "DATE RAPPORT: " WS-DATE-COURANTE-PROJ
                   DISPLAY "AVANCEMENT GLOBAL: " 
                           WS-AVANCEMENT-GLOBAL "%"
                   DISPLAY "TACHES REALISEES: " 
                           WS-NB-TACHES-FAITES "/" 
                           WS-NB-TACHES-TOTAL
                   DISPLAY "RETARD: " WS-RETARD-GLOBAL " JOURS"
                   DISPLAY "ECART BUDGET: " WS-ECART-BUDGET " EUR"
                   DISPLAY " "
                   DISPLAY "RECOMMANDATIONS:"
                   IF WS-RETARD-GLOBAL > 10
                       DISPLAY "  - ACCELERER LE RYTHME DES TACHES"
                       DISPLAY "  - REALLOCATION DES RESSOURCES"
                   END-IF
                   IF WS-ECART-BUDGET > 0
                       DISPLAY "  - REVOIR LE BUDGET PREVISIONNEL"
                   END-IF
                   IF WS-AVANCEMENT-GLOBAL < 25
                       DISPLAY "  - REDEFINIR LE PLANNING INITIAL"
                   END-IF
                   DISPLAY "========================================"
           END-READ
           .
       
       8200-ANALYSE-RISQUES.
           DISPLAY "--- ANALYSE DES RISQUES ---"
           DISPLAY "PROJET ID: "
           ACCEPT WS-PROJET-RISQUE
           
           MOVE WS-PROJET-RISQUE TO WS-ID-PROJET
           READ FICHIER-PROJETS
               INVALID KEY
                   DISPLAY "PROJET NON TROUVE"
               NOT INVALID KEY
                   PERFORM 6100-CALCULER-AVANCEMENT
                   
                   DISPLAY " "
                   DISPLAY "=== ANALYSE DES RISQUES ==="
                   DISPLAY "PROJET: " FUNCTION TRIM(WS-NOM-PROJET)
                   DISPLAY " "
                   
                   IF WS-RETARD-GLOBAL > 15
                       DISPLAY "⚠ RISQUE ELEVE: RETARD SIGNIFICATIF"
                   ELSE
                       IF WS-RETARD-GLOBAL > 5
                           DISPLAY "⚠ RISQUE MOYEN: RETARD MODERE"
                       ELSE
                           DISPLAY "✓ RISQUE FAIBLE: PLANNING OK"
                       END-END-IF
                   END-IF
                   
                   IF WS-ECART-BUDGET > WS-BUDGET-PREVU * 0.10
                       DISPLAY "⚠ RISQUE ELEVE: DEPASSEMENT BUDGET"
                   ELSE
                       IF WS-ECART-BUDGET > 0
                           DISPLAY "⚠ RISQUE FAIBLE: LEGER DEPASSEMENT"
                       ELSE
                           DISPLAY "✓ BUDGET MAITRISE"
                       END-IF
                   END-IF
                   
                   IF WS-NB-TACHES-FAITES = 0
                       DISPLAY "⚠ RISQUE ELEVE: AUCUNE TACHE REALISEE"
                   END-IF
                   
                   DISPLAY " "
                   DISPLAY "ACTIONS PREVENTIVES:"
                   DISPLAY "- PLANIFIER DES REUNIONS HEBDOMADAIRES"
                   DISPLAY "- METTRE EN PLACE DES INDICATEURS DE SUIVI"
                   DISPLAY "- PREVOIR DES MARGES DE SECURITE"
           END-READ
           .
       
       9000-FERMER-PROJET.
           CLOSE FICHIER-PROJETS
           CLOSE FICHIER-TACHES
           CLOSE FICHIER-RESSOURCES
           DISPLAY "SYSTEME DE GESTION DE PROJET ARRETE"
           .
