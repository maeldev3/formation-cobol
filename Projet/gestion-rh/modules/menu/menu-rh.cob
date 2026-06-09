       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-RH.
       AUTHOR. DEV.

      *> ==========================================
      *> SYSTEME DE GESTION RH — MENU PRINCIPAL
      *> Version 2.0 — Interface professionnelle
      *> ==========================================

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-CHOIX            PIC 9   VALUE 9.
       01 WS-SOUS-CHOIX       PIC 9   VALUE 9.

      *> Date et heure du systeme
       01 WS-DATE.
           05 WS-ANNEE        PIC 9(4).
           05 WS-MOIS         PIC 9(2).
           05 WS-JOUR         PIC 9(2).

       01 WS-HEURE.
           05 WS-H            PIC 9(2).
           05 WS-M            PIC 9(2).
           05 WS-S            PIC 9(2).
           05 FILLER          PIC 9(2).

      *> Ligne d'entete formatee
       01 WS-LIGNE-DATE       PIC X(42).

       PROCEDURE DIVISION.

       DEBUT.
           PERFORM UNTIL WS-CHOIX = 0
               PERFORM AFFICHER-MENU-PRINCIPAL
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX
               PERFORM TRAITER-CHOIX-PRINCIPAL
           END-PERFORM

           PERFORM AFFICHER-AUREVOIR
           STOP RUN.

      *> ==========================================
      *> AFFICHAGE MENU PRINCIPAL
      *> ==========================================

       AFFICHER-MENU-PRINCIPAL.
           MOVE FUNCTION CURRENT-DATE(1:8)  TO WS-DATE
           MOVE FUNCTION CURRENT-DATE(9:8)  TO WS-HEURE

           STRING
               WS-JOUR "/" WS-MOIS "/" WS-ANNEE
               "  " WS-H ":" WS-M ":" WS-S
               DELIMITED BY SIZE
               INTO WS-LIGNE-DATE
           END-STRING

           DISPLAY SPACE
           DISPLAY "+==========================================+"
           DISPLAY "|       SYSTEME DE GESTION RH — COBOL     |"
           DISPLAY "+==========================================+"
           DISPLAY "|  Date : " WS-LIGNE-DATE          "  |"
           DISPLAY "+------------------------------------------+"
           DISPLAY "|  [1]  Gestion des employes               |"
           DISPLAY "|  [2]  Gestion des departements           |"
           DISPLAY "|  [3]  Gestion des postes                 |"
           DISPLAY "|  [4]  Gestion des presences              |"
           DISPLAY "|  [5]  Gestion des conges                 |"
           DISPLAY "|  [6]  Gestion de la paie                 |"
           DISPLAY "+------------------------------------------+"
           DISPLAY "|  [7]  Rapport mensuel                    |"
           DISPLAY "|  [8]  Dashboard RH                       |"
           DISPLAY "|  [9]  Exports CSV                        |"
           DISPLAY "+------------------------------------------+"
           DISPLAY "|  [0]  Quitter                            |"
           DISPLAY "+==========================================+".

       TRAITER-CHOIX-PRINCIPAL.
           EVALUATE WS-CHOIX
               WHEN 1  PERFORM MENU-EMPLOYES
               WHEN 2  PERFORM MENU-DEPARTEMENTS
               WHEN 3  PERFORM MENU-POSTES
               WHEN 4  PERFORM MENU-PRESENCES
               WHEN 5  PERFORM MENU-CONGES
               WHEN 6  PERFORM MENU-PAIE
               WHEN 7  CALL "SYSTEM" USING "./bin/rapport-mensuel"
               WHEN 8  CALL "SYSTEM" USING "./bin/dashboard"
               WHEN 9  PERFORM MENU-EXPORTS
               WHEN 0  CONTINUE
               WHEN OTHER
                   DISPLAY SPACE
                   DISPLAY "  [!] Choix invalide. Entrez un"
                   DISPLAY "      chiffre entre 0 et 9."
           END-EVALUATE.

      *> ==========================================
      *> MENU EMPLOYES
      *> ==========================================

       MENU-EMPLOYES.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|      GESTION DES EMPLOYES       |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Ajouter un employe        |"
               DISPLAY "|  [2]  Modifier un employe       |"
               DISPLAY "|  [3]  Supprimer un employe      |"
               DISPLAY "|  [4]  Lister les employes       |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       DISPLAY "  >> Lancement ajout employe..."
                       CALL "SYSTEM" USING "./bin/employe"
                   WHEN 2
                       DISPLAY "  >> Lancement modification..."
                       CALL "SYSTEM" USING "./bin/employe-modifier"
                   WHEN 3
                       DISPLAY "  >> Lancement suppression..."
                       CALL "SYSTEM" USING "./bin/employe-supprimer"
                   WHEN 4
                       DISPLAY "  >> Chargement de la liste..."
                       CALL "SYSTEM" USING "./bin/employe-liste"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 4)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU DEPARTEMENTS
      *> ==========================================

       MENU-DEPARTEMENTS.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|    GESTION DES DEPARTEMENTS     |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Ajouter un departement    |"
               DISPLAY "|  [2]  Modifier un departement   |"
               DISPLAY "|  [3]  Supprimer un departement  |"
               DISPLAY "|  [4]  Lister les departements   |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       CALL "SYSTEM" USING "./bin/departement"
                   WHEN 2
                       CALL "SYSTEM" USING "./bin/departement-modifier"
                   WHEN 3
                       CALL "SYSTEM" USING "./bin/departement-supprimer"
                   WHEN 4
                       CALL "SYSTEM" USING "./bin/departement-liste"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 4)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU POSTES
      *> ==========================================

       MENU-POSTES.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|        GESTION DES POSTES       |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Ajouter un poste          |"
               DISPLAY "|  [2]  Modifier un poste         |"
               DISPLAY "|  [3]  Supprimer un poste        |"
               DISPLAY "|  [4]  Lister les postes         |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       CALL "SYSTEM" USING "./bin/poste"
                   WHEN 2
                       CALL "SYSTEM" USING "./bin/poste-modifier"
                   WHEN 3
                       CALL "SYSTEM" USING "./bin/poste-supprimer"
                   WHEN 4
                       CALL "SYSTEM" USING "./bin/poste-liste"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 4)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU PRESENCES
      *> ==========================================

       MENU-PRESENCES.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|      GESTION DES PRESENCES      |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Enregistrer une presence  |"
               DISPLAY "|  [2]  Lister les presences      |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       CALL "SYSTEM" USING "./bin/presence-ajouter"
                   WHEN 2
                       CALL "SYSTEM" USING "./bin/presence-liste"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 2)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU CONGES
      *> ==========================================

       MENU-CONGES.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|        GESTION DES CONGES       |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Faire une demande         |"
               DISPLAY "|  [2]  Valider une demande       |"
               DISPLAY "|  [3]  Lister les conges         |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       CALL "SYSTEM" USING "./bin/conge-demande"
                   WHEN 2
                       CALL "SYSTEM" USING "./bin/conge-valider"
                   WHEN 3
                       CALL "SYSTEM" USING "./bin/conge-liste"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 3)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU PAIE
      *> ==========================================

       MENU-PAIE.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|        GESTION DE LA PAIE       |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Calculer la paie          |"
               DISPLAY "|  [2]  Lister les fiches de paie |"
               DISPLAY "|  [3]  Rapport de paie           |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       CALL "SYSTEM" USING "./bin/calculer-paie"
                   WHEN 2
                       CALL "SYSTEM" USING "./bin/lister-paie"
                   WHEN 3
                       CALL "SYSTEM" USING "./bin/rapport-paie"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 3)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MENU EXPORTS CSV
      *> ==========================================

       MENU-EXPORTS.
           MOVE 9 TO WS-SOUS-CHOIX
           PERFORM UNTIL WS-SOUS-CHOIX = 0
               DISPLAY SPACE
               DISPLAY "+----------------------------------+"
               DISPLAY "|          EXPORTS CSV            |"
               DISPLAY "+----------------------------------+"
               DISPLAY "|  [1]  Exporter les employes     |"
               DISPLAY "|  [2]  Exporter la paie          |"
               DISPLAY "|  [3]  Exporter les conges       |"
               DISPLAY "|  [4]  Tout exporter             |"
               DISPLAY "|  [0]  Retour au menu principal  |"
               DISPLAY "+----------------------------------+"
               DISPLAY "  Votre choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX
               EVALUATE WS-SOUS-CHOIX
                   WHEN 1
                       DISPLAY "  >> Export employes en cours..."
                       CALL "SYSTEM" USING "./bin/export-employes"
                       DISPLAY "Fichier genere : exports/employes.csv"
                   WHEN 2
                       DISPLAY "  >> Export paie en cours..."
                       CALL "SYSTEM" USING "./bin/export-paie"
                       DISPLAY "Fichier genere : exports/paie.csv"
                   WHEN 3
                       DISPLAY "  >> Export conges en cours..."
                       CALL "SYSTEM" USING "./bin/export-conges"
                       DISPLAY "Fichier genere : exports/conges.csv"
                   WHEN 4
                       DISPLAY "  >> Export complet en cours..."
                       CALL "SYSTEM" USING "./bin/export-employes"
                       CALL "SYSTEM" USING "./bin/export-paie"
                       CALL "SYSTEM" USING "./bin/export-conges"
                       DISPLAY SPACE
                       DISPLAY "+----------------------------------+"
                       DISPLAY "|  [OK] TOUS LES EXPORTS GENERES  |"
                       DISPLAY "|  exports/employes.csv           |"
                       DISPLAY "|  exports/paie.csv               |"
                       DISPLAY "|  exports/conges.csv             |"
                       DISPLAY "+----------------------------------+"
                   WHEN 0  CONTINUE
                   WHEN OTHER
                       DISPLAY "  [!] Choix invalide (0 a 4)"
               END-EVALUATE
           END-PERFORM.

      *> ==========================================
      *> MESSAGE DE FIN
      *> ==========================================

       AFFICHER-AUREVOIR.
           DISPLAY SPACE
           DISPLAY "+==========================================+"
           DISPLAY "|   Merci d'avoir utilise le Systeme RH   |"
           DISPLAY "|          A bientot !                     |"
           DISPLAY "+==========================================+"
           DISPLAY SPACE.