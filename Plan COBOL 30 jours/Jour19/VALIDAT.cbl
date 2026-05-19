      *===============================================================
      * JOUR 19 — VALIDATION ET GESTION DES REJETS
      *
      * LEÇON : Implémenter des contrôles de qualité sur les données
      *
      * CONCEPTS COUVERTS :
      *   - Validation de format (TYPE, LONGUEUR)
      *   - Validation de contenu (PLAGE, LISTE, RÉFÉRENCE)
      *   - Validation de cohérence (entre champs)
      *   - Fichier de rejets avec motifs
      *   - Code retour selon taux de rejet
      *   - Tables de codes valides
      *
      * SCÉNARIO MÉTIER :
      *   Valider un fichier de virements bancaires entrant.
      *   Produire un fichier des virements valides
      *   et un fichier de rejets avec le motif détaillé.
      *
      *===============================================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDAT.
       AUTHOR.     STAGIAIRE-MAINFRAME.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FIC-ENTREE   ASSIGN TO ENTREE
               FILE STATUS IS WS-STAT-ENT.
           SELECT FIC-VALIDES  ASSIGN TO VALIDES
               FILE STATUS IS WS-STAT-VAL.
           SELECT FIC-REJETS   ASSIGN TO REJETS
               FILE STATUS IS WS-STAT-REJ.
           SELECT FIC-RAPPORT  ASSIGN TO RAPPORT
               FILE STATUS IS WS-STAT-RAP.

       DATA DIVISION.
       FILE SECTION.

      *--- Enregistrement d'entrée : virements à valider
       FD  FIC-ENTREE  RECORD CONTAINS 120 CHARACTERS.
       01  ENREG-ENTREE.
           05  ENT-NUM-VIREMENT    PIC X(12).
           05  ENT-DATE-VIREMENT   PIC 9(8).
      *                                AAAAMMJJ
           05  ENT-COMPTE-DEBIT    PIC X(11).
      *                                Format IBAN simplifié : 11 car
           05  ENT-COMPTE-CREDIT   PIC X(11).
           05  ENT-MONTANT         PIC 9(13)V99.
      *                                Montant en centimes : 13+2
           05  ENT-DEVISE          PIC X(3).
           05  ENT-MOTIF           PIC X(35).
           05  ENT-CODE-URGENCE    PIC X(1).
      *                                N=Normal, U=Urgent, I=Immédiat
           05  ENT-FILLER          PIC X(24).

      *--- Enregistrement valide (même structure + champ statut)
       FD  FIC-VALIDES RECORD CONTAINS 121 CHARACTERS.
       01  ENREG-VALIDE.
           05  VAL-NUM-VIREMENT    PIC X(12).
           05  VAL-DATE-VIREMENT   PIC 9(8).
           05  VAL-COMPTE-DEBIT    PIC X(11).
           05  VAL-COMPTE-CREDIT   PIC X(11).
           05  VAL-MONTANT         PIC 9(13)V99.
           05  VAL-DEVISE          PIC X(3).
           05  VAL-MOTIF           PIC X(35).
           05  VAL-CODE-URGENCE    PIC X(1).
           05  VAL-FILLER          PIC X(24).
           05  VAL-CODE-VALID      PIC X(1).
      *                                V=Validé

      *--- Enregistrement rejet (données originales + motif)
       FD  FIC-REJETS  RECORD CONTAINS 170 CHARACTERS.
       01  ENREG-REJET.
           05  REJ-DONNEES-ORIG    PIC X(120).
      *                                Copie exacte de l'enregistrement d'entrée
           05  REJ-CODE-REJET      PIC X(4).
      *                                Code court du motif
           05  REJ-MOTIF-REJET     PIC X(46).
      *                                Description du motif

      *--- Rapport de validation
       FD  FIC-RAPPORT RECORD CONTAINS 80 CHARACTERS.
       01  ENREG-RAPPORT           PIC X(80).

       WORKING-STORAGE SECTION.

      *--- Statuts fichiers
       01  WS-STAT-ENT             PIC X(2).
       01  WS-STAT-VAL             PIC X(2).
       01  WS-STAT-REJ             PIC X(2).
       01  WS-STAT-RAP             PIC X(2).

      *--- Indicateur de fin
       01  WS-FIN-FICHIER          PIC X  VALUE 'N'.
           88  FIN-FICHIER         VALUE 'O'.

      *--- Résultat de validation courante
       01  WS-STATUT-VALID         PIC X(2) VALUE SPACES.
           88  ENREG-VALIDE-OK     VALUE 'OK'.
           88  ENREG-REJETE        VALUE 'ER'.
       01  WS-CODE-REJET           PIC X(4) VALUE SPACES.
       01  WS-MOTIF-REJET          PIC X(46) VALUE SPACES.

      *--- Compteurs
       01  WS-COMPTEURS.
           05  WS-NB-LUS           PIC 9(7) VALUE ZEROS.
           05  WS-NB-VALIDES       PIC 9(7) VALUE ZEROS.
           05  WS-NB-REJETS        PIC 9(7) VALUE ZEROS.

      *--- Totaux montants
       01  WS-TOTAUX.
           05  WS-TOT-VALIDES      PIC 9(15)V99 VALUE ZEROS.
           05  WS-TOT-REJETS       PIC 9(15)V99 VALUE ZEROS.

      *--- Taux de rejet (calculé en fin)
       01  WS-TAUX-REJET           PIC 9(3)V99 VALUE ZEROS.

      *--- TABLE DES DEVISES ACCEPTÉES
      *    Une table de valeurs valides est plus maintenable qu'une
      *    longue série de IF ... OR IF ... OR IF
       01  WS-TABLE-DEVISES.
           05  WS-DEVISE-VALID     PIC X(3) OCCURS 10 TIMES.
      *                                          ^ La table a 10 entrées
       01  WS-IDX-DEVISE           PIC 9(2) VALUE ZEROS.
       01  WS-NB-DEVISES           PIC 9(2) VALUE 6.
      *                                          ^ 6 devises valides

      *--- Date du jour pour validation
       01  WS-DATE-JOUR            PIC 9(8) VALUE ZEROS.
      *    Obtenue via ACCEPT ... FROM DATE YYYYMMDD

      *--- Ligne de rapport formatée
       01  WS-LIGNE-RAPPORT        PIC X(80) VALUE SPACES.

       PROCEDURE DIVISION.

      *===============================================================
      *  PRINCIPAL
      *===============================================================
       0000-PRINCIPAL.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-LIRE-PREMIER
           PERFORM 3000-TRAITEMENT UNTIL FIN-FICHIER
           PERFORM 4000-FINALISATION
           STOP RUN.

      *===============================================================
      *  1000 — INITIALISATION
      *===============================================================
       1000-INITIALISATION.
           OPEN INPUT  FIC-ENTREE
                OUTPUT FIC-VALIDES
                       FIC-REJETS
                       FIC-RAPPORT.

      *    Initialiser la table des devises acceptées
      *    (Dans un vrai projet, cette table viendrait d'un fichier
      *    de paramètres ou d'une DB2)
           MOVE 'EUR' TO WS-DEVISE-VALID(1)
           MOVE 'USD' TO WS-DEVISE-VALID(2)
           MOVE 'GBP' TO WS-DEVISE-VALID(3)
           MOVE 'CHF' TO WS-DEVISE-VALID(4)
           MOVE 'JPY' TO WS-DEVISE-VALID(5)
           MOVE 'CAD' TO WS-DEVISE-VALID(6)
           MOVE SPACES TO WS-DEVISE-VALID(7)
           MOVE SPACES TO WS-DEVISE-VALID(8)
           MOVE SPACES TO WS-DEVISE-VALID(9)
           MOVE SPACES TO WS-DEVISE-VALID(10).

      *    Récupérer la date du jour
           ACCEPT WS-DATE-JOUR FROM DATE YYYYMMDD.

      *    En-tête du rapport
           MOVE ALL '=' TO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           MOVE 'RAPPORT DE VALIDATION DES VIREMENTS' TO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           MOVE ALL '=' TO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

      *===============================================================
      *  2000 — LIRE PREMIER
      *===============================================================
       2000-LIRE-PREMIER.
           READ FIC-ENTREE
               AT END MOVE 'O' TO WS-FIN-FICHIER
               NOT AT END ADD 1 TO WS-NB-LUS
           END-READ.

      *===============================================================
      *  3000 — TRAITEMENT PAR ENREGISTREMENT
      *===============================================================
       3000-TRAITEMENT.
      *    Réinitialiser le statut de validation
           MOVE 'OK' TO WS-STATUT-VALID
           MOVE SPACES TO WS-CODE-REJET
                          WS-MOTIF-REJET

      *    Effectuer toutes les validations
           PERFORM 3100-VALID-FORMAT
           IF ENREG-VALIDE-OK
               PERFORM 3200-VALID-CONTENU
           END-IF
           IF ENREG-VALIDE-OK
               PERFORM 3300-VALID-COHERENCE
           END-IF

      *    Dispatcher vers valide ou rejet
           IF ENREG-VALIDE-OK
               PERFORM 3400-ECRIRE-VALIDE
           ELSE
               PERFORM 3500-ECRIRE-REJET
           END-IF

      *    Lire suivant
           READ FIC-ENTREE
               AT END MOVE 'O' TO WS-FIN-FICHIER
               NOT AT END ADD 1 TO WS-NB-LUS
           END-READ.

      *---------------------------------------------------------------
      *  3100 — VALIDATION FORMAT
      *  Vérifier que les champs ont la bonne structure
      *---------------------------------------------------------------
       3100-VALID-FORMAT.

      *    CTRL 1 : Numéro de virement non vide
           IF ENT-NUM-VIREMENT = SPACES
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V001' TO WS-CODE-REJET
               MOVE 'NUMERO VIREMENT VIDE OU ABSENT' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 2 : Date format numérique (tous les caractères = chiffres)
           IF ENT-DATE-VIREMENT NOT NUMERIC
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V002' TO WS-CODE-REJET
               MOVE 'DATE FORMAT NON NUMERIQUE' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 3 : Montant numérique et positif
           IF ENT-MONTANT NOT NUMERIC
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V003' TO WS-CODE-REJET
               MOVE 'MONTANT FORMAT NON NUMERIQUE' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

           IF ENT-MONTANT <= ZEROS
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V004' TO WS-CODE-REJET
               MOVE 'MONTANT NUL OU NEGATIF' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 4 : Comptes non vides
           IF ENT-COMPTE-DEBIT = SPACES
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V005' TO WS-CODE-REJET
               MOVE 'COMPTE DEBITEUR VIDE' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

           IF ENT-COMPTE-CREDIT = SPACES
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V006' TO WS-CODE-REJET
               MOVE 'COMPTE CREDITEUR VIDE' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *---------------------------------------------------------------
      *  3200 — VALIDATION CONTENU
      *  Vérifier que les valeurs sont dans les plages acceptables
      *---------------------------------------------------------------
       3200-VALID-CONTENU.

      *    CTRL 5 : Devise dans la table des devises valides
           MOVE 'N' TO WS-DEVISE-TROUVEE
           PERFORM VARYING WS-IDX-DEVISE FROM 1 BY 1
               UNTIL WS-IDX-DEVISE > WS-NB-DEVISES
               IF ENT-DEVISE = WS-DEVISE-VALID(WS-IDX-DEVISE)
                   MOVE 'O' TO WS-DEVISE-TROUVEE
               END-IF
           END-PERFORM.

           IF WS-DEVISE-TROUVEE = 'N'
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V007' TO WS-CODE-REJET
               STRING 'DEVISE INCONNUE : ' DELIMITED SIZE
                      ENT-DEVISE DELIMITED SIZE
                  INTO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 6 : Code urgence dans liste valide
           IF ENT-CODE-URGENCE NOT = 'N'
           AND ENT-CODE-URGENCE NOT = 'U'
           AND ENT-CODE-URGENCE NOT = 'I'
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V008' TO WS-CODE-REJET
               MOVE 'CODE URGENCE INVALIDE (N/U/I attendu)'
                   TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 7 : Montant dans plage raisonnable
           IF ENT-MONTANT > 9999999999999
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V009' TO WS-CODE-REJET
               MOVE 'MONTANT DEPASSE LE PLAFOND AUTORISE'
                   TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *---------------------------------------------------------------
      *  3300 — VALIDATION COHÉRENCE
      *  Vérifier la cohérence ENTRE les différents champs
      *---------------------------------------------------------------
       3300-VALID-COHERENCE.

      *    CTRL 8 : Date dans le passé raisonnable (pas futur)
           IF ENT-DATE-VIREMENT > WS-DATE-JOUR
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V010' TO WS-CODE-REJET
               MOVE 'DATE VIREMENT DANS LE FUTUR' TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 9 : Compte débit ≠ Compte crédit
           IF ENT-COMPTE-DEBIT = ENT-COMPTE-CREDIT
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V011' TO WS-CODE-REJET
               MOVE 'COMPTE DEBIT IDENTIQUE AU COMPTE CREDIT'
                   TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *    CTRL 10 : Virement urgent → montant minimum requis
           IF ENT-CODE-URGENCE = 'U'
           AND ENT-MONTANT < 10000
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'V012' TO WS-CODE-REJET
               MOVE 'VIREMENT URGENT DOIT ETRE > 100.00'
                   TO WS-MOTIF-REJET
               EXIT PARAGRAPH
           END-IF.

      *---------------------------------------------------------------
      *  3400 — ÉCRIRE DANS FICHIER VALIDES
      *---------------------------------------------------------------
       3400-ECRIRE-VALIDE.
           MOVE ENT-NUM-VIREMENT   TO VAL-NUM-VIREMENT
           MOVE ENT-DATE-VIREMENT  TO VAL-DATE-VIREMENT
           MOVE ENT-COMPTE-DEBIT   TO VAL-COMPTE-DEBIT
           MOVE ENT-COMPTE-CREDIT  TO VAL-COMPTE-CREDIT
           MOVE ENT-MONTANT        TO VAL-MONTANT
           MOVE ENT-DEVISE         TO VAL-DEVISE
           MOVE ENT-MOTIF          TO VAL-MOTIF
           MOVE ENT-CODE-URGENCE   TO VAL-CODE-URGENCE
           MOVE ENT-FILLER         TO VAL-FILLER
           MOVE 'V'                TO VAL-CODE-VALID
           WRITE ENREG-VALIDE
           ADD 1           TO WS-NB-VALIDES
           ADD ENT-MONTANT TO WS-TOT-VALIDES.

      *---------------------------------------------------------------
      *  3500 — ÉCRIRE DANS FICHIER REJETS avec motif
      *---------------------------------------------------------------
       3500-ECRIRE-REJET.
           MOVE ENREG-ENTREE   TO REJ-DONNEES-ORIG
           MOVE WS-CODE-REJET  TO REJ-CODE-REJET
           MOVE WS-MOTIF-REJET TO REJ-MOTIF-REJET
           WRITE ENREG-REJET

      *    Écrire aussi dans le rapport
           STRING WS-CODE-REJET DELIMITED SIZE
                  ' - ' DELIMITED SIZE
                  ENT-NUM-VIREMENT DELIMITED SIZE
                  ' : ' DELIMITED SIZE
                  WS-MOTIF-REJET DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT
           ADD 1           TO WS-NB-REJETS
           ADD ENT-MONTANT TO WS-TOT-REJETS.

      *===============================================================
      *  4000 — FINALISATION
      *===============================================================
       4000-FINALISATION.
      *    Calculer le taux de rejet
           IF WS-NB-LUS > ZEROS
               COMPUTE WS-TAUX-REJET =
                   (WS-NB-REJETS * 100) / WS-NB-LUS
                   ROUNDED
           END-IF.

      *    Rapport final
           MOVE ALL '=' TO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           STRING 'TOTAL LUS    : ' DELIMITED SIZE
                  WS-NB-LUS DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           STRING 'TOTAL VALIDES: ' DELIMITED SIZE
                  WS-NB-VALIDES DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           STRING 'TOTAL REJETS : ' DELIMITED SIZE
                  WS-NB-REJETS DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.
           STRING 'TAUX REJET   : ' DELIMITED SIZE
                  WS-TAUX-REJET DELIMITED SIZE
                  '%' DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

           CLOSE FIC-ENTREE FIC-VALIDES FIC-REJETS FIC-RAPPORT.

      *    Code retour selon taux de rejet
           EVALUATE TRUE
               WHEN WS-NB-REJETS = ZEROS
                   MOVE 0 TO RETURN-CODE     ← Tout est valide
               WHEN WS-TAUX-REJET <= 5
                   MOVE 4 TO RETURN-CODE     ← Rejet < 5% : warning
               WHEN WS-TAUX-REJET <= 20
                   MOVE 8 TO RETURN-CODE     ← Rejet 5-20% : erreur
               WHEN OTHER
                   MOVE 12 TO RETURN-CODE    ← Rejet > 20% : grave
           END-EVALUATE.
