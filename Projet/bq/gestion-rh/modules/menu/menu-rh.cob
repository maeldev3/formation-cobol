       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-RH.
       AUTHOR. DEV.

      *> ==========================================
      *> MENU PRINCIPAL SYSTEME RH
      *> ==========================================

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-CHOIX            PIC 9 VALUE 9.
       01 WS-SOUS-CHOIX       PIC 9 VALUE 9.
       01 WS-PAUSE            PIC X.

       PROCEDURE DIVISION.

       DEBUT.

           PERFORM UNTIL WS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===================================="
               DISPLAY "         SYSTEME RH COBOL"
               DISPLAY "===================================="
               DISPLAY "1 - Gestion Employes"
               DISPLAY "2 - Gestion Departements"
               DISPLAY "3 - Gestion Postes"
               DISPLAY "4 - Gestion Presences"
               DISPLAY "5 - Gestion Conges"
               DISPLAY "6 - Paie"
               DISPLAY "7 - Rapport RH"
               DISPLAY "0 - Quitter"
               DISPLAY "===================================="

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX

               EVALUATE WS-CHOIX

                   WHEN 1
                       PERFORM MENU-EMPLOYES

                   WHEN 2
                       PERFORM MENU-DEPARTEMENTS

                   WHEN 3
                       PERFORM MENU-POSTES

                   WHEN 4
                       PERFORM MENU-PRESENCES

                   WHEN 5
                       PERFORM MENU-CONGES

                   WHEN 6
                       CALL "SYSTEM"
                           USING "./bin/paie"

                   WHEN 7
                       CALL "SYSTEM"
                           USING "./bin/rapport-mensuel"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM

           STOP RUN.

      *> ==========================================
      *> MENU EMPLOYES
      *> ==========================================

       MENU-EMPLOYES.

           MOVE 9 TO WS-SOUS-CHOIX

           PERFORM UNTIL WS-SOUS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===== GESTION EMPLOYES ====="
               DISPLAY "1 - Ajouter"
               DISPLAY "2 - Modifier"
               DISPLAY "3 - Supprimer"
               DISPLAY "4 - Lister"
               DISPLAY "0 - Retour"

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX

               EVALUATE WS-SOUS-CHOIX

                   WHEN 1
                       CALL "SYSTEM"
                           USING "./bin/employe-ajouter"

                   WHEN 2
                       CALL "SYSTEM"
                           USING "./bin/employe-modifier"

                   WHEN 3
                       CALL "SYSTEM"
                           USING "./bin/employe-supprimer"

                   WHEN 4
                       CALL "SYSTEM"
                           USING "./bin/employe-liste"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.

      *> ==========================================
      *> MENU DEPARTEMENTS
      *> ==========================================

       MENU-DEPARTEMENTS.

           MOVE 9 TO WS-SOUS-CHOIX

           PERFORM UNTIL WS-SOUS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===== GESTION DEPARTEMENTS ====="
               DISPLAY "1 - Ajouter"
               DISPLAY "2 - Modifier"
               DISPLAY "3 - Supprimer"
               DISPLAY "4 - Lister"
               DISPLAY "0 - Retour"

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX

               EVALUATE WS-SOUS-CHOIX

                   WHEN 1
                       CALL "SYSTEM"
                           USING "./bin/departement"

                   WHEN 2
                       CALL "SYSTEM"
                           USING "./bin/departement-modifier"

                   WHEN 3
                       CALL "SYSTEM"
                           USING "./bin/departement-supprimer"

                   WHEN 4
                       CALL "SYSTEM"
                           USING "./bin/departement-liste"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.

      *> ==========================================
      *> MENU POSTES
      *> ==========================================

       MENU-POSTES.

           MOVE 9 TO WS-SOUS-CHOIX

           PERFORM UNTIL WS-SOUS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===== GESTION POSTES ====="
               DISPLAY "1 - Ajouter"
               DISPLAY "2 - Modifier"
               DISPLAY "3 - Supprimer"
               DISPLAY "4 - Lister"
               DISPLAY "0 - Retour"

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX

               EVALUATE WS-SOUS-CHOIX

                   WHEN 1
                       CALL "SYSTEM"
                           USING "./bin/poste"

                   WHEN 2
                       CALL "SYSTEM"
                           USING "./bin/poste-modifier"

                   WHEN 3
                       CALL "SYSTEM"
                           USING "./bin/poste-supprimer"

                   WHEN 4
                       CALL "SYSTEM"
                           USING "./bin/poste-liste"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.

      *> ==========================================
      *> MENU PRESENCES
      *> ==========================================

       MENU-PRESENCES.

           MOVE 9 TO WS-SOUS-CHOIX

           PERFORM UNTIL WS-SOUS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===== GESTION PRESENCES ====="
               DISPLAY "1 - Ajouter"
               DISPLAY "2 - Lister"
               DISPLAY "0 - Retour"

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX

               EVALUATE WS-SOUS-CHOIX

                   WHEN 1
                       CALL "SYSTEM"
                           USING "./bin/presence-ajouter"

                   WHEN 2
                       CALL "SYSTEM"
                           USING "./bin/presence-liste"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.

      *> ==========================================
      *> MENU CONGES
      *> ==========================================

       MENU-CONGES.

           MOVE 9 TO WS-SOUS-CHOIX

           PERFORM UNTIL WS-SOUS-CHOIX = 0

               DISPLAY SPACE
               DISPLAY "===== GESTION CONGES ====="
               DISPLAY "1 - Demande"
               DISPLAY "2 - Validation"
               DISPLAY "3 - Lister"
               DISPLAY "0 - Retour"

               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-SOUS-CHOIX

               EVALUATE WS-SOUS-CHOIX

                   WHEN 1
                       CALL "SYSTEM"
                           USING "./bin/conge-demande"

                   WHEN 2
                       CALL "SYSTEM"
                           USING "./bin/conge-valider"

                   WHEN 3
                       CALL "SYSTEM"
                           USING "./bin/conge-liste"

                   WHEN 0
                       CONTINUE

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.