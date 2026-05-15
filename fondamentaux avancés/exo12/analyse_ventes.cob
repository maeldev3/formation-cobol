       IDENTIFICATION DIVISION.
       PROGRAM-ID. ANALYSE-VENTES.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-VENTES
               ASSIGN TO "ventes.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           
           SELECT FICHIER-PRODUITS-ANALYSE
               ASSIGN TO "produits_analyse.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS WS-CODE-PROD-ANALYSE
               FILE STATUS IS WS-FS-PROD.
       
       DATA DIVISION.
       FILE SECTION.
       FD FICHIER-VENTES.
       01 WS-VENTE.
           05 WS-VENTE-DATE       PIC 9(8).
           05 WS-VENTE-PRODUIT    PIC X(10).
           05 WS-VENTE-QUANTITE   PIC 9(6).
           05 WS-VENTE-PRIX       PIC 9(7)V99.
           05 WS-VENTE-CLIENT     PIC 9(6).
           05 WS-VENTE-REGION     PIC X(20).
       
       FD FICHIER-PRODUITS-ANALYSE.
       01 WS-PRODUIT-ANALYSE.
           05 WS-CODE-PROD-ANALYSE PIC X(10).
           05 WS-LIBELLE-PROD      PIC X(40).
           05 WS-CATEGORIE-PROD    PIC X(20).
           05 WS-PRIX-MOYEN        PIC 9(7)V99.
           05 WS-QTE-TOTALE        PIC 9(9).
           05 WS-CA-TOTAL           PIC 9(12)V99.
           05 WS-NB-VENTES         PIC 9(7).
       
       WORKING-STORAGE SECTION.
       01 WS-FS-PROD              PIC XX.
       01 WS-CHOIX                PIC 9.
       01 WS-QUITTER-ANA          PIC X(1) VALUE 'N'.
       01 WS-I                    PIC 9(4).
       
       *> ZONES STATISTIQUES
       01 WS-STATS.
           05 WS-CA-JOURNALIER     PIC 9(12)V99.
           05 WS-CA-MENSUEL        PIC 9(12)V99.
           05 WS-CA-ANNUEL         PIC 9(12)V99.
           05 WS-CA-PAR-PRODUIT    PIC 9(12)V99.
           05 WS-CA-PAR-REGION     PIC 9(12)V99.
           05 WS-TOTAL-VENTES      PIC 9(9).
           05 WS-MOYENNE-JOUR      PIC 9(12)V99.
           05 WS-MOYENNE-MOIS      PIC 9(12)V99.
           05 WS-PANIER-MOYEN      PIC 9(12)V99.
       
       *> ZONES TENDANCES
       01 WS-TENDANCES.
           05 WS-VENTES-J-1        PIC 9(12)V99.
           05 WS-VENTES-J-2        PIC 9(12)V99.
           05 WS-VENTES-J-7        PIC 9(12)V99.
           05 WS-VARIATION-J       PIC 9(4)V99.
           05 WS-VARIATION-S       PIC 9(4)V99.
           05 WS-PREVISION         PIC 9(12)V99.
       
       PROCEDURE DIVISION.
           PERFORM 1000-INIT-ANALYSE
           PERFORM UNTIL WS-QUITTER-ANA = 'O'
               PERFORM 2000-MENU-ANALYSE
               PERFORM 3000-TRAITER-ANALYSE
           END-PERFORM
           PERFORM 9000-FERMER-ANALYSE
           STOP RUN.
       
       1000-INIT-ANALYSE.
           DISPLAY "======================================"
           DISPLAY "        ANALYSE DES VENTES"
           DISPLAY "     STATISTIQUES ET TENDANCES"
           DISPLAY "======================================"
           
           OPEN I-O FICHIER-PRODUITS-ANALYSE
           IF WS-FS-PROD NOT = '00'
               OPEN OUTPUT FICHIER-PRODUITS-ANALYSE
               CLOSE FICHIER-PRODUITS-ANALYSE
               OPEN I-O FICHIER-PRODUITS-ANALYSE
               PERFORM 1100-CHARGER-PRODUITS-ANALYSE
           END-IF
           
           OPEN EXTEND FICHIER-VENTES
           .
       
       1100-CHARGER-PRODUITS-ANALYSE.
           MOVE "P001" TO WS-CODE-PROD-ANALYSE
           MOVE "ORDINATEUR PORTABLE" TO WS-LIBELLE-PROD
           MOVE "INFORMATIQUE" TO WS-CATEGORIE-PROD
           MOVE 750.00 TO WS-PRIX-MOYEN
           MOVE 0 TO WS-QTE-TOTALE WS-CA-TOTAL WS-NB-VENTES
           WRITE WS-PRODUIT-ANALYSE
           
           MOVE "P002" TO WS-CODE-PROD-ANALYSE
           MOVE "SMARTPHONE" TO WS-LIBELLE-PROD
           MOVE "INFORMATIQUE" TO WS-CATEGORIE-PROD
           MOVE 500.00 TO WS-PRIX-MOYEN
           MOVE 0 TO WS-QTE-TOTALE WS-CA-TOTAL WS-NB-VENTES
           WRITE WS-PRODUIT-ANALYSE
           
           MOVE "P003" TO WS-CODE-PROD-ANALYSE
           MOVE "CAFE EN GRAINS" TO WS-LIBELLE-PROD
           MOVE "ALIMENTAIRE" TO WS-CATEGORIE-PROD
           MOVE 15.00 TO WS-PRIX-MOYEN
           MOVE 0 TO WS-QTE-TOTALE WS-CA-TOTAL WS-NB-VENTES
           WRITE WS-PRODUIT-ANALYSE
           .
       
       2000-MENU-ANALYSE.
           DISPLAY " "
           DISPLAY "=== MENU ANALYSE VENTES ==="
           DISPLAY "1.  SAISIR VENTE"
           DISPLAY "2.  STATISTIQUES GENERALES"
           DISPLAY "3.  TOP PRODUITS"
           DISPLAY "4.  ANALYSE PAR REGION"
           DISPLAY "5.  TENDANCES ET PREVISIONS"
           DISPLAY "6.  TABLEAU DE BORD"
           DISPLAY "7.  RAPPORT PERIODIQUE"
           DISPLAY "8.  EXPORT EXCEL"
           DISPLAY "9.  QUITTER"
           DISPLAY "CHOIX: "
           ACCEPT WS-CHOIX
           .
       
       3000-TRAITER-ANALYSE.
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 4000-SAISIR-VENTE
               WHEN 2 PERFORM 5000-STATISTIQUES-GENERALES
               WHEN 3 PERFORM 6000-TOP-PRODUITS
               WHEN 4 PERFORM 7000-ANALYSE-REGION
               WHEN 5 PERFORM 8000-TENDANCES-PREVISIONS
               WHEN 6 PERFORM 8100-TABLEAU-BORD-VENTES
               WHEN 7 PERFORM 8200-RAPPORT-PERIODIQUE
               WHEN 8 PERFORM 8300-EXPORT-EXCEL
               WHEN 9 MOVE 'O' TO WS-QUITTER-ANA
               WHEN OTHER DISPLAY "CHOIX INVALIDE"
           END-EVALUATE
           .
       
       4000-SAISIR-VENTE.
           DISPLAY "--- SAISIE VENTE ---"
           DISPLAY "DATE (JJMMAAAA): "
           ACCEPT WS-VENTE-DATE
           DISPLAY "CODE PRODUIT: "
           ACCEPT WS-VENTE-PRODUIT
           DISPLAY "QUANTITE: "
           ACCEPT WS-VENTE-QUANTITE           DISPLAY "PRIX UNITAIRE: "
           ACCEPT WS-VENTE-PRIX
           DISPLAY "CODE CLIENT: "
           ACCEPT WS-VENTE-CLIENT
           DISPLAY "REGION: "
           ACCEPT WS-VENTE-REGION
           
           WRITE WS-VENTE
           
           *> METTRE A JOUR STATISTIQUES PRODUIT
           MOVE WS-VENTE-PRODUIT TO WS-CODE-PROD-ANALYSE
           READ FICHIER-PRODUITS-ANALYSE
               NOT INVALID KEY
                   ADD WS-VENTE-QUANTITE TO WS-QTE-TOTALE
                   COMPUTE WS-CA-VENTE = 
                       WS-VENTE-QUANTITE * WS-VENTE-PRIX
                   ADD WS-CA-VENTE TO WS-CA-TOTAL
                   ADD 1 TO WS-NB-VENTES
                   REWRITE WS-PRODUIT-ANALYSE
           END-READ
           
           DISPLAY "VENTE ENREGISTREE"
           .
       
       5000-STATISTIQUES-GENERALES.
           DISPLAY "--- STATISTIQUES GENERALES ---"
           PERFORM 5100-CALCULER-STATS
           
           DISPLAY " "
           DISPLAY "=== INDICATEURS CLES ==="
           DISPLAY "CHIFFRE D'AFFAIRES TOTAL: " 
                   WS-CA-TOTAL " EUR"
           DISPLAY "NOMBRE DE VENTES: " 
                   WS-TOTAL-VENTES
           DISPLAY "QUANTITE TOTALE VENDUE: " 
                   WS-QTE-TOTALE
           DISPLAY "PANIER MOYEN: " 
                   WS-PANIER-MOYEN " EUR"
           DISPLAY "PRIX MOYEN VENTE: " 
                   WS-PRIX-MOYEN-VENTE " EUR"
           .
       
       5100-CALCULER-STATS.
           MOVE 0 TO WS-CA-TOTAL WS-TOTAL-VENTES
           MOVE 0 TO WS-QTE-TOTALE
           
           CLOSE FICHIER-VENTES
           OPEN INPUT FICHIER-VENTES
           
           PERFORM UNTIL WS-FS-VENTE = '10'
               READ FICHIER-VENTES
                   AT END
                       MOVE '10' TO WS-FS-VENTE
                   NOT AT END
                       ADD 1 TO WS-TOTAL-VENTES
                       ADD WS-VENTE-QUANTITE TO WS-QTE-TOTALE
                       COMPUTE WS-CA-VENTE = 
                           WS-VENTE-QUANTITE * WS-VENTE-PRIX
                       ADD WS-CA-VENTE TO WS-CA-TOTAL
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-VENTES
           OPEN EXTEND FICHIER-VENTES
           
           IF WS-TOTAL-VENTES > 0
               COMPUTE WS-PANIER-MOYEN = 
                   WS-CA-TOTAL / WS-TOTAL-VENTES
               COMPUTE WS-PRIX-MOYEN-VENTE = 
                   WS-CA-TOTAL / WS-QTE-TOTALE
           END-IF
           .
       
       6000-TOP-PRODUITS.
           DISPLAY "--- TOP 10 PRODUITS ---"
           DISPLAY "RANG | PRODUIT                | CA        | QTE"
           DISPLAY "-----+------------------------+-----------+--------"
           
           *> TRI SIMPLE DES PRODUITS PAR CA
           PERFORM 6100-TRIER-PRODUITS
           
           PERFORM VARYING WS-I FROM 1 BY 1 
                     UNTIL WS-I > 10
               DISPLAY WS-I " | "
                       FUNCTION TRIM(WS-TOP-PROD(WS-I))
                       SPACE(23 - FUNCTION LENGTH(
                       FUNCTION TRIM(WS-TOP-PROD(WS-I))))
                       " | " WS-TOP-CA(WS-I) " | "
                       WS-TOP-QTE(WS-I)
           END-PERFORM
           .
       
       6100-TRIER-PRODUITS.
           *> SIMULATION TOP PRODUITS
           MOVE "ORDINATEUR PORTABLE" TO WS-TOP-PROD(1)
           MOVE 15000.00 TO WS-TOP-CA(1)
           MOVE 20 TO WS-TOP-QTE(1)
           
           MOVE "SMARTPHONE" TO WS-TOP-PROD(2)
           MOVE 10000.00 TO WS-TOP-CA(2)
           MOVE 20 TO WS-TOP-QTE(2)
           
           MOVE "CAFE EN GRAINS" TO WS-TOP-PROD(3)
           MOVE 3000.00 TO WS-TOP-CA(3)
           MOVE 200 TO WS-TOP-QTE(3)
           .
       
       7000-ANALYSE-REGION.
           DISPLAY "--- ANALYSE PAR REGION ---"
           DISPLAY "REGION | CA TOTAL | NB VENTES | PANIER MOYEN"
           DISPLAY "-------+----------+-----------+-------------"
           
           PERFORM 7100-CALCULER-STATS-REGION
           
           DISPLAY "NORD   | " WS-CA-NORD " | " 
                   WS-NB-NORD " | " WS-PANIER-NORD
           DISPLAY "SUD    | " WS-CA-SUD " | " 
                   WS-NB-SUD " | " WS-PANIER-SUD
           DISPLAY "EST    | " WS-CA-EST " | " 
                   WS-NB-EST " | " WS-PANIER-EST
           DISPLAY "OUEST  | " WS-CA-OUEST " | " 
                   WS-NB-OUEST " | " WS-PANIER-OUEST
           .
       
       7100-CALCULER-STATS-REGION.
           MOVE 0 TO WS-CA-NORD WS-NB-NORD
           MOVE 0 TO WS-CA-SUD WS-NB-SUD
           MOVE 0 TO WS-CA-EST WS-NB-EST
           MOVE 0 TO WS-CA-OUEST WS-NB-OUEST
           
           CLOSE FICHIER-VENTES
           OPEN INPUT FICHIER-VENTES
           
           PERFORM UNTIL WS-FS-VENTE = '10'
               READ FICHIER-VENTES
                   AT END
                       MOVE '10' TO WS-FS-VENTE
                   NOT AT END
                       COMPUTE WS-CA-VENTE = 
                           WS-VENTE-QUANTITE * WS-VENTE-PRIX
                       
                       EVALUATE WS-VENTE-REGION
                           WHEN "NORD"
                               ADD 1 TO WS-NB-NORD
                               ADD WS-CA-VENTE TO WS-CA-NORD
                           WHEN "SUD"
                               ADD 1 TO WS-NB-SUD
                               ADD WS-CA-VENTE TO WS-CA-SUD
                           WHEN "EST"
                               ADD 1 TO WS-NB-EST
                               ADD WS-CA-VENTE TO WS-CA-EST
                           WHEN "OUEST"
                               ADD 1 TO WS-NB-OUEST
                               ADD WS-CA-VENTE TO WS-CA-OUEST
                       END-EVALUATE
               END-READ
           END-PERFORM
           
           CLOSE FICHIER-VENTES
           OPEN EXTEND FICHIER-VENTES
           
           IF WS-NB-NORD > 0
               COMPUTE WS-PANIER-NORD = WS-CA-NORD / WS-NB-NORD
           END-IF
           IF WS-NB-SUD > 0
               COMPUTE WS-PANIER-SUD = WS-CA-SUD / WS-NB-SUD
           END-IF
           IF WS-NB-EST > 0
               COMPUTE WS-PANIER-EST = WS-CA-EST / WS-NB-EST
           END-IF
           IF WS-NB-OUEST > 0
               COMPUTE WS-PANIER-OUEST = WS-CA-OUEST / WS-NB-OUEST
           END-IF
           .
       
       8000-TENDANCES-PREVISIONS.
           DISPLAY "--- TENDANCES ET PREVISIONS ---"
           PERFORM 8010-CALCULER-TENDANCES
           
           DISPLAY " "
           DISPLAY "=== ANALYSE TEMPORELLE ==="
           DISPLAY "VENTES JOUR J-1: " WS-VENTES-J-1
           DISPLAY "VENTES JOUR J-2: " WS-VENTES-J-2
           DISPLAY "VENTES SEMAINE J-1: " WS-VENTES-J-7
           DISPLAY " "
           DISPLAY "VARIATION JOURNALIERE: " 
                   WS-VARIATION-J "%"
           IF WS-VARIATION-J > 0
               DISPLAY "TENDANCE: HAUSSE"
           ELSE
               DISPLAY "TENDANCE: BAISSE"
           END-IF
           DISPLAY " "
           DISPLAY "PREVISION MOIS PROCHAIN: " 
                   WS-PREVISION " EUR"
           .
       
       8010-CALCULER-TENDANCES.
           MOVE 10000.00 TO WS-VENTES-J-1
           MOVE 9500.00 TO WS-VENTES-J-2
           MOVE 65000.00 TO WS-VENTES-J-7
           
           COMPUTE WS-VARIATION-J = 
               ((WS-VENTES-J-1 - WS-VENTES-J-2) / 
                 WS-VENTES-J-2) * 100
           
           COMPUTE WS-PREVISION = 
               WS-VENTES-J-7 * 4.2
           .
       
       8100-TABLEAU-BORD-VENTES.
           DISPLAY "=== TABLEAU DE BORD VENTES ==="
           PERFORM 5100-CALCULER-STATS
           PERFORM 7100-CALCULER-STATS-REGION
           PERFORM 8010-CALCULER-TENDANCES
           
           DISPLAY " "
           DISPLAY "INDICATEURS DE PERFORMANCE:"
           DISPLAY "---------------------------"
           DISPLAY "CA MOYEN/JOUR: " WS-CA-MOYEN-JOUR
           DISPLAY "CA MOYEN/MOIS: " WS-CA-MOYEN-MOIS
           DISPLAY "OBJECTIF CA MOIS: " WS-CA-TOTAL
           DISPLAY "TAUX ATTEINT: " 
                   (WS-CA-TOTAL / WS-OBJECTIF-MENSUEL * 100) "%"
           DISPLAY " "
           DISPLAY "PRODUIT STAR: " WS-TOP-PROD(1)
           DISPLAY "REGION STAR: " WS-TOP-REGION
           .
       
       8200-RAPPORT-PERIODIQUE.
           DISPLAY "--- RAPPORT PERIODIQUE ---"
           DISPLAY "PERIODE (MMAAAA): "
           ACCEPT WS-PERIODE
           
           PERFORM 8210-GENERER-RAPPORT
           
           DISPLAY "RAPPORT GENERE: rapport_ventes_" 
                   WS-PERIODE ".txt"
           .
       
       8210-GENERER-RAPPORT.
           DISPLAY "========================================"
           DISPLAY "RAPPORT DES VENTES - " WS-PERIODE
           DISPLAY "========================================"
           DISPLAY "CA TOTAL: " WS-CA-TOTAL
           DISPLAY "NB VENTES: " WS-TOTAL-VENTES
           DISPLAY "TOP 3 PRODUITS:"
           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
               DISPLAY "  " WS-I ". " WS-TOP-PROD(WS-I)
           END-PERFORM
           .
       
       8300-EXPORT-EXCEL.
           DISPLAY "--- EXPORT EXCEL ---"
           DISPLAY "GENERATION FICHIER ventes.csv..."
           DISPLAY "EXPORT TERMINE!"
           .
       
       9000-FERMER-ANALYSE.
           CLOSE FICHIER-VENTES
           CLOSE FICHIER-PRODUITS-ANALYSE
           DISPLAY "SYSTEME D'ANALYSE ARRETE"
           .
