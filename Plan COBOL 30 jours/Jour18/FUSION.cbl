      *===============================================================
      * JOUR 18 — TRAITEMENT FICHIERS MULTIPLES : FUSION COMPTES
      *
      * LEÇON : Traiter plusieurs fichiers d'entrée simultanément
      *
      * CONCEPTS COUVERTS :
      *   - Ouvrir/lire plusieurs fichiers en parallèle
      *   - Logique de correspondance (matching) entre fichiers
      *   - Fusion par clé commune
      *   - Gestion des enregistrements sans correspondance
      *   - Fichiers de détail vs fichiers maîtres
      *
      * SCÉNARIO MÉTIER :
      *   Fusionner un fichier COMPTES (données clients) avec
      *   un fichier TRANSACTIONS (mouvements) pour créer
      *   un relevé complet par client.
      *
      * STRUCTURE DES FICHIERS :
      *
      *   FICHIER COMPTES (trié par NUM-CLIENT) :
      *   ┌────────────┬─────────────────────┬──────────────────┐
      *   │ NUM-CLIENT │ NOM-CLIENT          │ SOLDE-INITIAL    │
      *   │ (10 car)   │ (30 car)            │ 9(9)V99 (11 car) │
      *   └────────────┴─────────────────────┴──────────────────┘
      *
      *   FICHIER TRANSACTIONS (trié par NUM-CLIENT, DATE) :
      *   ┌────────────┬──────────┬──────────────────┬──────────┐
      *   │ NUM-CLIENT │ DATE     │ MONTANT          │ TYPE     │
      *   │ (10 car)   │ (8 car)  │ S9(9)V99 (11car)│ (1 car)  │
      *   └────────────┴──────────┴──────────────────┴──────────┘
      *   TYPE : C=Crédit (versement), D=Débit (retrait)
      *
      *===============================================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. FUSION.
       AUTHOR.     STAGIAIRE-MAINFRAME.
      *
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Fichier maître : comptes clients
           SELECT FIC-COMPTES
               ASSIGN TO COMPTES
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STAT-CPT.

      *    Fichier détail : transactions
           SELECT FIC-TRANSAC
               ASSIGN TO TRANSAC
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STAT-TRA.

      *    Fichier de sortie : relevés fusionnés
           SELECT FIC-RELEVES
               ASSIGN TO RELEVES
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STAT-REL.

      *    Fichier anomalies : transactions sans compte
           SELECT FIC-ANOMAL
               ASSIGN TO ANOMAL
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STAT-ANO.
      *
       DATA DIVISION.
       FILE SECTION.

      *--- Enregistrement COMPTES
       FD  FIC-COMPTES
           RECORD CONTAINS 51 CHARACTERS.
       01  ENREG-COMPTE.
           05  CPT-NUM-CLIENT    PIC X(10).
           05  CPT-NOM-CLIENT    PIC X(30).
           05  CPT-SOLDE-INIT    PIC S9(9)V99.
      *                              ^ S = signé (peut être négatif)

      *--- Enregistrement TRANSACTIONS
       FD  FIC-TRANSAC
           RECORD CONTAINS 30 CHARACTERS.
       01  ENREG-TRANSAC.
           05  TRA-NUM-CLIENT    PIC X(10).
           05  TRA-DATE          PIC 9(8).
           05  TRA-MONTANT       PIC S9(9)V99.
           05  TRA-TYPE          PIC X(1).
      *                              C=Crédit, D=Débit

      *--- Enregistrement RELEVÉ (sortie)
       FD  FIC-RELEVES
           RECORD CONTAINS 120 CHARACTERS.
       01  ENREG-RELEVE.
           05  REL-NUM-CLIENT    PIC X(10).
           05  REL-NOM-CLIENT    PIC X(30).
           05  REL-SOLDE-INIT    PIC S9(9)V99.
           05  REL-TOTAL-CREDITS PIC S9(9)V99.
           05  REL-TOTAL-DEBITS  PIC S9(9)V99.
           05  REL-SOLDE-FINAL   PIC S9(9)V99.
           05  REL-NB-TRANSAC    PIC 9(5).
           05  REL-FILLER        PIC X(37).

      *--- Enregistrement ANOMALIES
       FD  FIC-ANOMAL
           RECORD CONTAINS 30 CHARACTERS.
       01  ENREG-ANOMAL          PIC X(30).
      *
       WORKING-STORAGE SECTION.

      *--- Statuts fichiers
       01  WS-STAT-CPT           PIC X(2).
       01  WS-STAT-TRA           PIC X(2).
       01  WS-STAT-REL           PIC X(2).
       01  WS-STAT-ANO           PIC X(2).

      *--- Indicateurs fin de fichier
       01  WS-FIN-COMPTES        PIC X     VALUE 'N'.
           88  FIN-COMPTES       VALUE 'O'.
       01  WS-FIN-TRANSAC        PIC X     VALUE 'N'.
           88  FIN-TRANSAC       VALUE 'O'.

      *--- Accumulateurs par compte (remis à zéro pour chaque compte)
       01  WS-ACCUM-COMPTE.
           05  WS-TOT-CREDITS    PIC S9(11)V99 VALUE ZEROS.
           05  WS-TOT-DEBITS     PIC S9(11)V99 VALUE ZEROS.
           05  WS-NB-TRANSAC     PIC 9(5)      VALUE ZEROS.

      *--- Totaux généraux
       01  WS-TOTAUX-GENERAUX.
           05  WS-NB-COMPTES     PIC 9(7)  VALUE ZEROS.
           05  WS-NB-TRANS-OK    PIC 9(7)  VALUE ZEROS.
           05  WS-NB-ANOMALIES   PIC 9(7)  VALUE ZEROS.

      *--- Sauvegarde de la clé client (pour détection changement)
       01  WS-CLE-COURANTE       PIC X(10) VALUE SPACES.
      *
       PROCEDURE DIVISION.

      *===============================================================
      *  PRINCIPAL — Logique de fusion (matching algorithm)
      *===============================================================
       0000-PRINCIPAL.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-LIRE-PREMIERS
      *
      *    ┌─────────────────────────────────────────────────────────┐
      *    │ ALGORITHME DE FUSION PAR CLÉ                            │
      *    │                                                          │
      *    │ Les deux fichiers sont triés par NUM-CLIENT.            │
      *    │ On compare les clés et on avance dans le fichier        │
      *    │ avec la clé la plus petite.                             │
      *    │                                                          │
      *    │   Si Clé Compte < Clé Transaction :                    │
      *    │     → Compte sans transactions (solde inchangé)         │
      *    │   Si Clé Compte = Clé Transaction :                    │
      *    │     → Correspondance ! Traiter les transactions          │
      *    │   Si Clé Compte > Clé Transaction :                    │
      *    │     → Transaction sans compte (anomalie !)              │
      *    └─────────────────────────────────────────────────────────┘
      *
           PERFORM UNTIL FIN-COMPTES AND FIN-TRANSAC
               EVALUATE TRUE
      *            Cas 1 : Plus de transactions, comptes restants
                   WHEN FIN-TRANSAC AND NOT FIN-COMPTES
                       PERFORM 3100-COMPTE-SANS-TRANS
      *
      *            Cas 2 : Plus de comptes, transactions restantes
                   WHEN FIN-COMPTES AND NOT FIN-TRANSAC
                       PERFORM 3200-TRANS-SANS-COMPTE
      *
      *            Cas 3 : Clé compte < Clé transaction
                   WHEN CPT-NUM-CLIENT < TRA-NUM-CLIENT
                       PERFORM 3100-COMPTE-SANS-TRANS
      *
      *            Cas 4 : Clé compte > Clé transaction
                   WHEN CPT-NUM-CLIENT > TRA-NUM-CLIENT
                       PERFORM 3200-TRANS-SANS-COMPTE
      *
      *            Cas 5 : Correspondance ! (clés égales)
                   WHEN CPT-NUM-CLIENT = TRA-NUM-CLIENT
                       PERFORM 3300-TRAITER-CORRESPONDANCE
               END-EVALUATE
           END-PERFORM

           PERFORM 4000-FINALISATION
           STOP RUN.

      *===============================================================
      *  1000 — INITIALISATION
      *===============================================================
       1000-INITIALISATION.
           OPEN INPUT  FIC-COMPTES
                       FIC-TRANSAC
                OUTPUT FIC-RELEVES
                       FIC-ANOMAL.

           IF WS-STAT-CPT NOT = '00' OR WS-STAT-TRA NOT = '00'
               DISPLAY 'ERREUR OUVERTURE FICHIERS'
               DISPLAY 'COMPTES : ' WS-STAT-CPT
               DISPLAY 'TRANSAC : ' WS-STAT-TRA
               MOVE 16 TO RETURN-CODE
               STOP RUN
           END-IF.

      *===============================================================
      *  2000 — LECTURE DES PREMIERS ENREGISTREMENTS
      *===============================================================
       2000-LIRE-PREMIERS.
           PERFORM 2100-LIRE-COMPTE
           PERFORM 2200-LIRE-TRANSAC.

       2100-LIRE-COMPTE.
           READ FIC-COMPTES
               AT END MOVE 'O' TO WS-FIN-COMPTES
           END-READ.

       2200-LIRE-TRANSAC.
           READ FIC-TRANSAC
               AT END MOVE 'O' TO WS-FIN-TRANSAC
           END-READ.

      *===============================================================
      *  3100 — COMPTE SANS TRANSACTIONS
      *  Le compte existe mais n'a aucun mouvement
      *===============================================================
       3100-COMPTE-SANS-TRANS.
           MOVE CPT-NUM-CLIENT TO REL-NUM-CLIENT
           MOVE CPT-NOM-CLIENT TO REL-NOM-CLIENT
           MOVE CPT-SOLDE-INIT TO REL-SOLDE-INIT
           MOVE ZEROS TO REL-TOTAL-CREDITS
                         REL-TOTAL-DEBITS
                         REL-NB-TRANSAC
           MOVE CPT-SOLDE-INIT TO REL-SOLDE-FINAL
           MOVE SPACES         TO REL-FILLER
           WRITE ENREG-RELEVE
           ADD 1 TO WS-NB-COMPTES
           PERFORM 2100-LIRE-COMPTE.

      *===============================================================
      *  3200 — TRANSACTION SANS COMPTE
      *  La transaction n'a pas de compte correspondant = ANOMALIE
      *===============================================================
       3200-TRANS-SANS-COMPTE.
           DISPLAY 'ANOMALIE - TRANSACTION SANS COMPTE : '
                   TRA-NUM-CLIENT ' DATE:' TRA-DATE
           MOVE ENREG-TRANSAC TO ENREG-ANOMAL
           WRITE ENREG-ANOMAL
           ADD 1 TO WS-NB-ANOMALIES
           PERFORM 2200-LIRE-TRANSAC.

      *===============================================================
      *  3300 — CORRESPONDANCE COMPTE / TRANSACTIONS
      *  Traiter toutes les transactions de ce compte
      *===============================================================
       3300-TRAITER-CORRESPONDANCE.
      *    Initialiser les accumulateurs pour ce compte
           MOVE ZEROS TO WS-TOT-CREDITS
                         WS-TOT-DEBITS
                         WS-NB-TRANSAC

      *    Boucle sur toutes les transactions du même client
           PERFORM UNTIL FIN-TRANSAC
               OR TRA-NUM-CLIENT NOT = CPT-NUM-CLIENT

               IF TRA-TYPE = 'C'
                   ADD TRA-MONTANT TO WS-TOT-CREDITS
               ELSE
                   ADD TRA-MONTANT TO WS-TOT-DEBITS
               END-IF

               ADD 1 TO WS-NB-TRANSAC
               ADD 1 TO WS-NB-TRANS-OK
               PERFORM 2200-LIRE-TRANSAC

           END-PERFORM

      *    Calculer et écrire le relevé
           MOVE CPT-NUM-CLIENT    TO REL-NUM-CLIENT
           MOVE CPT-NOM-CLIENT    TO REL-NOM-CLIENT
           MOVE CPT-SOLDE-INIT    TO REL-SOLDE-INIT
           MOVE WS-TOT-CREDITS    TO REL-TOTAL-CREDITS
           MOVE WS-TOT-DEBITS     TO REL-TOTAL-DEBITS
           COMPUTE REL-SOLDE-FINAL =
               CPT-SOLDE-INIT + WS-TOT-CREDITS - WS-TOT-DEBITS
           MOVE WS-NB-TRANSAC     TO REL-NB-TRANSAC
           MOVE SPACES            TO REL-FILLER
           WRITE ENREG-RELEVE
           ADD 1 TO WS-NB-COMPTES

      *    Lire le compte suivant
           PERFORM 2100-LIRE-COMPTE.

      *===============================================================
      *  4000 — FINALISATION
      *===============================================================
       4000-FINALISATION.
           DISPLAY '========================================='
           DISPLAY 'RAPPORT FUSION COMPTES/TRANSACTIONS'
           DISPLAY 'NB COMPTES TRAITES  : ' WS-NB-COMPTES
           DISPLAY 'NB TRANSACTIONS OK  : ' WS-NB-TRANS-OK
           DISPLAY 'NB ANOMALIES        : ' WS-NB-ANOMALIES
           DISPLAY '========================================='
           CLOSE FIC-COMPTES FIC-TRANSAC FIC-RELEVES FIC-ANOMAL
           IF WS-NB-ANOMALIES > ZEROS
               MOVE 4 TO RETURN-CODE
           END-IF.
