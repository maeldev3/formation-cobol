IDENTIFICATION DIVISION.
       PROGRAM-ID. GESTION-PAIE.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-EMPLOYES
               ASSIGN TO "employes.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-MATRICULE
               FILE STATUS IS WS-FS.
           
           SELECT FICHIER-PAIES
               ASSIGN TO "paies.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FS-PAIE.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-EMPLOYES.
       01 WS-EMPLOYE.
           05 WS-MATRICULE        PIC 9(6).
           05 WS-NOM              PIC X(30).
           05 WS-PRENOM           PIC X(30).
           05 WS-DATE-NAISSANCE   PIC 9(8).
           05 WS-DATE-EMBAUCHE    PIC 9(8).
           05 WS-CATEGORIE        PIC X(15).
              88 CADRE            VALUE 'CADRE'.
              88 NON-CADRE        VALUE 'NON-CADRE'.
           05 WS-SALAIRE-BASE     PIC 9(7)V99.
           05 WS-TAUX-HORAIRE     PIC 9(4)V99.
           05 WS-HEURES-MOIS      PIC 9(3).
           05 WS-PRIME-ANCIENNETE PIC 9(5)V99.
           05 WS-NB-ENFANTS       PIC 9(2).
           05 WS-SITUATION        PIC X(10).
              88 MARIE            VALUE 'MARIE'.
              88 CELIBATAIRE      VALUE 'CELIBATAIRE'.
           05 WS-TAUX-IMPOT       PIC 9(2)V99.

       FD FICHIER-PAIES.
       01 WS-LIGNE-PAIE.
           05 WS-P-MATRICULE      PIC 9(6).
           05 WS-P-MOIS           PIC 9(2).
           05 WS-P-ANNEE          PIC 9(4).
           05 WS-P-SALAIRE-BRUT   PIC 9(7)V99.
           05 WS-P-COTISATIONS    PIC 9(7)V99.
           05 WS-P-IMPOT          PIC 9(7)V99.
           05 WS-P-SALAIRE-NET    PIC 9(7)V99.
           05 WS-P-DATE-CALCUL    PIC 9(8).

       WORKING-STORAGE SECTION.
       01 WS-FS                   PIC XX.
       01 WS-FS-PAIE              PIC XX.
       01 WS-CHOIX                PIC 9.
       01 WS-QUITTER              PIC X(1) VALUE 'N'.
       01 WS-MATR-RECH            PIC 9(6).
       01 WS-CONFIRM              PIC X(1).
       01 WS-NEW-SALAIRE          PIC 9(7)V99.
       
       *> VARIABLES DE TEMPS
       01 WS-ANNEE-ACTUELLE       PIC 9(4) VALUE 2026.
       01 WS-MOIS                 PIC 9(2) VALUE 05.
       01 WS-ANNEE                PIC 9(4) VALUE 2026.

       *> ZONES DE CALCUL (Toutes les variables manquantes sont ici)
       01 WS-CALCULS.
           05 WS-SAL-BRUT         PIC 9(7)V99.
           05 WS-COTISATION-SECU  PIC 9(7)V99.
           05 WS-COTISATION-RETRAITE PIC 9(7)V99.
           05 WS-COTISATION-CHOMAGE PIC 9(7)V99.
           05 WS-IMPOT-REVENU     PIC 9(7)V99.
           05 WS-SAL-NET          PIC 9(7)V99.
           05 WS-PRIME            PIC 9(7)V99.
           05 WS-HEURES-SUP       PIC 9(3).
           05 WS-MAJORATION       PIC 9(5)V99.
           05 WS-ANNEE-EMBAUCHE   PIC 9(4).
           05 WS-ANCIENNETE       PIC 9(4).
           05 WS-POURCENT         PIC 9(3)V99.
           05 WS-NOUVEAU-SALAIRE  PIC 9(7)V99.
           05 WS-AUGMENTATION     PIC 9(7)V99.
           05 WS-CONGES-RESTANTS  PIC S9(3) VALUE 25.
           05 WS-CONGES-PRIS      PIC 9(2)  VALUE 0.
           05 WS-DEDUCTION        PIC 9(7)V99.

       *> BILAN SOCIAL ET RAPPORTS
       01 WS-STATS.
           05 WS-MASSE-TOTALE     PIC 9(9)V99.
           05 WS-NB-EMPLOYES      PIC 9(4).
           05 WS-NB-HOMMES        PIC 9(4).
           05 WS-NB-FEMMES        PIC 9(4).
           05 WS-NB-CADRES        PIC 9(4).
           05 WS-NB-NON-CADRES    PIC 9(4).
           05 WS-SOMME-ANCIENNETE PIC 9(6).
           05 WS-ANCIENNETE-MOY   PIC 9(3)V99.
           05 WS-CHARGES-PATRONALES PIC 9(9)V99.
           05 WS-COTISATIONS-TOTALES PIC 9(12)V99.
           05 WS-CHARGES-PATRONALES-TOTALES PIC 9(12)V99.
           05 WS-BUDGET-FORMATION PIC 9(12)V99.

       01 WS-CONSTANTES.
           05 SECU-TAUX           PIC 9(2)V99 VALUE 12.50.
           05 RETRAITE-TAUX       PIC 9(2)V99 VALUE 8.45.
           05 CHOMAGE-TAUX        PIC 9(2)V99 VALUE 4.05.
           05 HEURES-LEGALES      PIC 9(3) VALUE 151.

       PROCEDURE DIVISION.
           PERFORM 1000-INIT
           PERFORM UNTIL WS-QUITTER = 'O'
               PERFORM 2000-MENU-PRINCIPAL
               PERFORM 3000-TRAITER-MENU
           END-PERFORM
           PERFORM 9000-FERMETURE
           STOP RUN.

       1000-INIT.
           *> Initialisation sécurisée Employés (Status 35 = Fichier manquant)
           OPEN I-O FICHIER-EMPLOYES
           IF WS-FS = '35'
               OPEN OUTPUT FICHIER-EMPLOYES
               CLOSE FICHIER-EMPLOYES
               OPEN I-O FICHIER-EMPLOYES
               PERFORM 1100-CHARGER-EMPLOYES-TEST
           END-IF.

           *> Initialisation sécurisée Paies
           OPEN EXTEND FICHIER-PAIES
           IF WS-FS-PAIE = '35'
               OPEN OUTPUT FICHIER-PAIES
               CLOSE FICHIER-PAIES
               OPEN EXTEND FICHIER-PAIES
           END-IF.

       1100-CHARGER-EMPLOYES-TEST.
           MOVE 1001 TO WS-MATRICULE
           MOVE "DUPONT" TO WS-NOM
           MOVE "JEAN" TO WS-PRENOM
           MOVE 01012020 TO WS-DATE-EMBAUCHE
           MOVE "CADRE" TO WS-CATEGORIE
           MOVE 3500.00 TO WS-SALAIRE-BASE
           MOVE 23.00 TO WS-TAUX-HORAIRE
           MOVE 151 TO WS-HEURES-MOIS
           MOVE 2 TO WS-NB-ENFANTS
           MOVE 15.00 TO WS-TAUX-IMPOT
           WRITE WS-EMPLOYE.

       2000-MENU-PRINCIPAL.
           DISPLAY " "
           DISPLAY "=== GESTION DE LA PAIE ==="
           DISPLAY "1. GESTION EMPLOYES"
           DISPLAY "2. CALCULER PAIE"
           DISPLAY "3. BILAN SOCIAL"
           DISPLAY "4. SIMULATION AUGMENTATION"
           DISPLAY "9. QUITTER"
           DISPLAY "CHOIX : " WITH NO ADVANCING
           ACCEPT WS-CHOIX.

       3000-TRAITER-MENU.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-GESTION-EMPLOYES
               WHEN 2 PERFORM 5000-CALCULER-PAIE
               WHEN 3 PERFORM 7000-BILAN-SOCIAL
               WHEN 4 PERFORM 7100-SIMULATION
               WHEN 9 MOVE 'O' TO WS-QUITTER
           END-EVALUATE.

       4000-GESTION-EMPLOYES.
           DISPLAY "1. AJOUTER | 2. LISTER"
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4100-AJOUTER-EMPLOYE
               WHEN 2 PERFORM 4400-LISTER-EMPLOYES
           END-EVALUATE.

       4100-AJOUTER-EMPLOYE.
           DISPLAY "MATRICULE: " ACCEPT WS-MATRICULE
           DISPLAY "NOM: " ACCEPT WS-NOM
           DISPLAY "SALAIRE BASE: " ACCEPT WS-SALAIRE-BASE
           WRITE WS-EMPLOYE
           DISPLAY "EMPLOYE ENREGISTRE.".

       4400-LISTER-EMPLOYES.
           DISPLAY "LISTE DES EMPLOYES :"
           MOVE 0 TO WS-MATRICULE
           START FICHIER-EMPLOYES KEY IS NOT < WS-MATRICULE
           MOVE '00' TO WS-FS
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-EMPLOYES NEXT AT END MOVE '10' TO WS-FS
               NOT AT END
                   DISPLAY WS-MATRICULE " - " WS-NOM " - " WS-SALAIRE-BASE " EUR"
               END-READ
           END-PERFORM.

       5000-CALCULER-PAIE.
           DISPLAY "MATRICULE POUR PAIE: " ACCEPT WS-MATR-RECH
           MOVE WS-MATR-RECH TO WS-MATRICULE
           READ FICHIER-EMPLOYES INVALID KEY DISPLAY "INCONNU"
           NOT INVALID KEY
               COMPUTE WS-SAL-BRUT = WS-SALAIRE-BASE
               COMPUTE WS-COTISATION-SECU = WS-SAL-BRUT * 0.22
               COMPUTE WS-SAL-NET = WS-SAL-BRUT - WS-COTISATION-SECU
               PERFORM 5500-AFFICHER-PAIE
           END-READ.

       5500-AFFICHER-PAIE.
           DISPLAY "BULLETIN DE : " WS-NOM
           DISPLAY "SALAIRE BRUT : " WS-SAL-BRUT
           DISPLAY "SALAIRE NET  : " WS-SAL-NET.

       7000-BILAN-SOCIAL.
           MOVE 0 TO WS-MASSE-TOTALE
           MOVE 0 TO WS-NB-EMPLOYES
           MOVE 0 TO WS-MATRICULE
           MOVE '00' TO WS-FS
           START FICHIER-EMPLOYES KEY IS NOT < WS-MATRICULE
           PERFORM UNTIL WS-FS = '10'
               READ FICHIER-EMPLOYES NEXT AT END MOVE '10' TO WS-FS
               NOT AT END
                   ADD WS-SALAIRE-BASE TO WS-MASSE-TOTALE
                   ADD 1 TO WS-NB-EMPLOYES
               END-READ
           END-PERFORM
           DISPLAY "NB EMPLOYES     : " WS-NB-EMPLOYES
           DISPLAY "MASSE SALARIALE : " WS-MASSE-TOTALE " EUR".

       7100-SIMULATION.
           DISPLAY "MATRICULE: " ACCEPT WS-MATRICULE
           READ FICHIER-EMPLOYES NOT INVALID KEY
               DISPLAY "% AUGMENTATION (ex: 05.00): " ACCEPT WS-POURCENT
               COMPUTE WS-NOUVEAU-SALAIRE = WS-SALAIRE-BASE * (1 + (WS-POURCENT / 100))
               DISPLAY "NOUVEAU SALAIRE : " WS-NOUVEAU-SALAIRE
           END-READ.

       9000-FERMETURE.
           CLOSE FICHIER-EMPLOYES FICHIER-PAIES.
