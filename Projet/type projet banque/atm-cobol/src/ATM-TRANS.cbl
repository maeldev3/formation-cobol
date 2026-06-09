      *================================================================*
      *  ATM-TRANS.CBL - MODULE DE TRAITEMENT DES TRANSACTIONS        *
      *  Calculs : retrait, dépôt, virement, validation               *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-TRANS.
       AUTHOR. SYSTEME-BANCAIRE.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-CONSTANTES.
           05  WS-SEUIL-ALERTE     PIC S9(8)V99 VALUE 100,00.
           05  WS-MAX-DEPOT        PIC S9(8)V99 VALUE 10000,00.
           05  WS-MIN-RETRAIT      PIC S9(8)V99 VALUE 10,00.

       01  WS-TRANS-WORK.
           05  WS-NOUVEAU-SOLDE    PIC S9(13)V99.
           05  WS-COMMISSION       PIC S9(8)V99.
           05  WS-VALIDE           PIC 9.
           05  WS-ERREUR-CODE      PIC 99.
           05  WS-ERREUR-MSG       PIC X(60).

      *--- Codes erreur ---
       88  ERR-AUCUNE             VALUE 0.
       88  ERR-MONTANT-NEG        VALUE 1.
       88  ERR-SOLDE-INSUF        VALUE 2.
       88  ERR-PLAFOND-DEP        VALUE 3.
       88  ERR-MONTANT-MAX        VALUE 4.
       88  ERR-MULTIPLE           VALUE 5.

       LINKAGE SECTION.
       01  LS-TYPE-OPER            PIC X(15).
       01  LS-MONTANT              PIC S9(13)V99.
       01  LS-SOLDE-ACTUEL         PIC S9(13)V99.
       01  LS-PLAFOND              PIC S9(8)V99.
       01  LS-RESULTAT             PIC 9.
       01  LS-MSG-ERREUR           PIC X(60).
       01  LS-NOUVEAU-SOLDE        PIC S9(13)V99.

       PROCEDURE DIVISION USING LS-TYPE-OPER
                                 LS-MONTANT
                                 LS-SOLDE-ACTUEL
                                 LS-PLAFOND
                                 LS-RESULTAT
                                 LS-MSG-ERREUR
                                 LS-NOUVEAU-SOLDE.

       TRAITER-TRANSACTION.
           MOVE 0 TO WS-VALIDE
           MOVE SPACES TO WS-ERREUR-MSG

           EVALUATE LS-TYPE-OPER
               WHEN "RETRAIT"
                   PERFORM VALIDER-RETRAIT
               WHEN "DEPOT"
                   PERFORM VALIDER-DEPOT
               WHEN "CONSULTATION"
                   MOVE 1 TO WS-VALIDE
                   MOVE LS-SOLDE-ACTUEL TO WS-NOUVEAU-SOLDE
               WHEN OTHER
                   MOVE 0 TO WS-VALIDE
                   MOVE "Type d'opération inconnu" TO WS-ERREUR-MSG
           END-EVALUATE

           MOVE WS-VALIDE TO LS-RESULTAT
           MOVE WS-ERREUR-MSG TO LS-MSG-ERREUR
           MOVE WS-NOUVEAU-SOLDE TO LS-NOUVEAU-SOLDE
           STOP RUN.

       VALIDER-RETRAIT.
           IF LS-MONTANT <= 0
               MOVE 0 TO WS-VALIDE
               MOVE "Montant invalide (doit être positif)"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           IF LS-MONTANT < WS-MIN-RETRAIT
               MOVE 0 TO WS-VALIDE
               MOVE "Montant minimum de retrait : 10,00 EUR"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           IF FUNCTION MOD(LS-MONTANT, 10) NOT = 0
               MOVE 0 TO WS-VALIDE
               MOVE "Le montant doit être un multiple de 10 EUR"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           IF LS-MONTANT > LS-PLAFOND
               MOVE 0 TO WS-VALIDE
               MOVE "Montant supérieur au plafond autorisé"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           IF LS-MONTANT > LS-SOLDE-ACTUEL
               MOVE 0 TO WS-VALIDE
               MOVE "Solde insuffisant pour ce retrait"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           SUBTRACT LS-MONTANT FROM LS-SOLDE-ACTUEL
               GIVING WS-NOUVEAU-SOLDE
           MOVE 1 TO WS-VALIDE.

       VALIDER-DEPOT.
           IF LS-MONTANT <= 0
               MOVE 0 TO WS-VALIDE
               MOVE "Montant invalide (doit être positif)"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           IF LS-MONTANT > WS-MAX-DEPOT
               MOVE 0 TO WS-VALIDE
               MOVE "Montant dépasse le plafond de dépôt (10 000 EUR)"
                   TO WS-ERREUR-MSG
               EXIT PARAGRAPH
           END-IF

           ADD LS-MONTANT TO LS-SOLDE-ACTUEL
               GIVING WS-NOUVEAU-SOLDE
           MOVE 1 TO WS-VALIDE.
