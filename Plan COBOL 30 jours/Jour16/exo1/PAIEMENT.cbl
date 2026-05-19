      *===============================================================
      * JOUR 16 — PROGRAMME BATCH : TRAITEMENT DES PAIEMENTS
      *
      * LEÇON : Écrire un programme COBOL batch complet
      *
      * CONCEPTS COUVERTS :
      *   - Structure d'un programme COBOL batch
      *   - Lecture séquentielle d'un fichier
      *   - Traitement enregistrement par enregistrement
      *   - Écriture du fichier de sortie
      *   - Compteurs et totaux
      *   - Gestion des erreurs
      *
      * SCÉNARIO MÉTIER :
      *   Traiter un fichier de paiements clients.
      *   Pour chaque paiement : valider, calculer et écrire.
      *   Produire un rapport de synthèse en fin de job.
      *===============================================================

      *---------------------------------------------------------------
      * IDENTIFICATION DIVISION
      * Obligatoire — identifie le programme
      *---------------------------------------------------------------
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAIEMENT.
       AUTHOR.     STAGIAIRE-MAINFRAME.
       DATE-WRITTEN. 2024-01-16.
      *
      *---------------------------------------------------------------
      * ENVIRONMENT DIVISION
      * Déclare les fichiers utilisés et leur association avec les DD
      *
      * SELECT nom-logique ASSIGN TO nom-dd-jcl
      *   → Lie le nom COBOL au nom DD du JCL
      *---------------------------------------------------------------
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Fichier d'entrée : paiements à traiter
           SELECT FIC-PAIEMENTS
               ASSIGN TO PAIEMNT
      *                    ^ nom du DD dans le JCL (//PAIEMNT DD...)
               ORGANIZATION IS SEQUENTIAL
      *                              ^ fichier séquentiel (lu du début à la fin)
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STATUT-PAI.
      *                            ^ variable qui recevra le code statut
      *                              00=OK, 10=fin de fichier, etc.

      *    Fichier de sortie : paiements traités
           SELECT FIC-TRAITES
               ASSIGN TO TRAITES
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STATUT-TRA.

      *    Fichier de rapport
           SELECT FIC-RAPPORT
               ASSIGN TO RAPPORT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-STATUT-RAP.
      *
      *---------------------------------------------------------------
      * DATA DIVISION
      * Déclare TOUTES les données : fichiers, working storage
      *---------------------------------------------------------------
       DATA DIVISION.

      *---------------------------------------------------------------
      * FILE SECTION — Structure des enregistrements de fichiers
      *---------------------------------------------------------------
       FILE SECTION.

      *--- Structure du fichier ENTRÉE (paiements)
       FD  FIC-PAIEMENTS
           RECORDING MODE IS F
      *                       ^ F = Fixed (longueur fixe)
           RECORD CONTAINS 100 CHARACTERS.

       01  ENREG-PAIEMENT.
      *    Description de chaque champ de l'enregistrement d'entrée
           05  PAI-NUM-CLIENT      PIC X(10).
      *                                ^ X = alphanumérique, (10) = 10 caractères
           05  PAI-NOM-CLIENT      PIC X(30).
           05  PAI-DATE-PAIEMENT   PIC 9(8).
      *                                ^ 9 = numérique, (8) = 8 chiffres → AAAAMMJJ
           05  PAI-MONTANT         PIC 9(9)V99.
      *                                      ^ V = virgule implicite
      *                            9 chiffres entiers + 2 décimales
           05  PAI-TYPE-PAIEMENT   PIC X(3).
      *                                VIR=virement, CHQ=chèque, CBK=carte
           05  PAI-CODE-DEVISE     PIC X(3).
      *                                EUR, USD, etc.
           05  PAI-FILLER          PIC X(43).
      *                                ^ Filler = espace réservé inutilisé

      *--- Structure du fichier SORTIE (paiements traités)
       FD  FIC-TRAITES
           RECORDING MODE IS F
           RECORD CONTAINS 120 CHARACTERS.

       01  ENREG-TRAITE.
           05  TRA-NUM-CLIENT      PIC X(10).
           05  TRA-NOM-CLIENT      PIC X(30).
           05  TRA-DATE-PAIEMENT   PIC 9(8).
           05  TRA-MONTANT-ORIG    PIC 9(9)V99.
           05  TRA-COMMISSION      PIC 9(7)V99.
      *                                Commission = 0.5% du montant
           05  TRA-MONTANT-NET     PIC 9(9)V99.
      *                                Montant - Commission
           05  TRA-STATUT          PIC X(2).
      *                                OK=traité, ER=erreur
           05  TRA-FILLER          PIC X(40).

      *--- Structure du fichier RAPPORT
       FD  FIC-RAPPORT
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.

       01  ENREG-RAPPORT           PIC X(80).

      *---------------------------------------------------------------
      * WORKING-STORAGE SECTION
      * Variables de travail internes au programme
      *---------------------------------------------------------------
       WORKING-STORAGE SECTION.

      *--- Statuts des fichiers
       01  WS-STATUT-PAI           PIC X(2).
       01  WS-STATUT-TRA           PIC X(2).
       01  WS-STATUT-RAP           PIC X(2).

      *--- Indicateurs (drapeaux logiques)
       01  WS-FIN-FICHIER          PIC X     VALUE 'N'.
      *                                              ^ N=Non (pas fin), O=Oui (fin)
           88  FIN-FICHIER-OUI     VALUE 'O'.
      *        ^ Niveau 88 = condition booléenne
      *          IF FIN-FICHIER-OUI ... équivaut à IF WS-FIN-FICHIER = 'O'

      *--- Compteurs généraux
       01  WS-COMPTEURS.
           05  WS-NB-LIRE          PIC 9(7)  VALUE ZEROS.
      *                                              ^ Initialisé à 0
           05  WS-NB-TRAITES       PIC 9(7)  VALUE ZEROS.
           05  WS-NB-ERREURS       PIC 9(7)  VALUE ZEROS.

      *--- Accumulateurs de montants
       01  WS-TOTAUX.
           05  WS-TOT-MONTANTS     PIC 9(13)V99 VALUE ZEROS.
           05  WS-TOT-COMMISSIONS  PIC 9(11)V99 VALUE ZEROS.
           05  WS-TOT-NETS         PIC 9(13)V99 VALUE ZEROS.

      *--- Variables de calcul
       01  WS-CALCUL.
           05  WS-COMMISSION       PIC 9(9)V99  VALUE ZEROS.
           05  WS-MONTANT-NET      PIC 9(9)V99  VALUE ZEROS.
           05  WS-TAUX-COMM        PIC V9(4)    VALUE .0050.
      *                                                  ^ 0.50% = 0.0050

      *--- Variables pour le rapport
       01  WS-LIGNE-RAPPORT        PIC X(80)    VALUE SPACES.
       01  WS-DATE-TRAITEMENT      PIC 9(8)     VALUE ZEROS.

      *--- Zone de formatage pour l'affichage des montants
       01  WS-MONTANT-AFFICHE      PIC ZZZ,ZZZ,ZZ9.99.
      *                                ^ Z = zéro supprimé (pas d'affichage si 0)
      *                                  9 = toujours affiché
      *                                  virgule et point inclus

      *--- Constantes du rapport (lignes d'en-tête)
       01  WS-TITRE-RAPPORT.
           05  FILLER  PIC X(80)
               VALUE '============================================
      -            '===================================='.
      *             ^ Continuation de chaîne (tiret en col 7)

       01  WS-EN-TETE.
           05  FILLER  PIC X(30) VALUE 'RAPPORT TRAITEMENT PAIEMENTS  '.
           05  FILLER  PIC X(20) VALUE 'DATE TRAITEMENT: '.
           05  WS-DATE-RAPPORT     PIC X(10) VALUE SPACES.
           05  FILLER  PIC X(20) VALUE SPACES.

      *
      *---------------------------------------------------------------
      * PROCEDURE DIVISION
      * Le code exécutable du programme
      *---------------------------------------------------------------
       PROCEDURE DIVISION.

      *===============================================================
      *  PARAGRAPHE PRINCIPAL — Chef d'orchestre du programme
      *  Il appelle les autres paragraphes dans l'ordre logique
      *===============================================================
       0000-PRINCIPAL.
           PERFORM 1000-INITIALISATION
      *        ^ Ouvrir les fichiers, initialiser les variables
           PERFORM 2000-LIRE-PREMIER
      *        ^ Lire le 1er enregistrement avant la boucle
           PERFORM 3000-TRAITER-PAIEMENTS
               UNTIL FIN-FICHIER-OUI
      *        ^ Boucle : traiter jusqu'à fin de fichier
           PERFORM 4000-FINALISATION
      *        ^ Fermer les fichiers, écrire rapport
           STOP RUN.
      *    ^ Arrêter le programme (code retour 0 par défaut)

      *===============================================================
      *  1000 — INITIALISATION
      *  Ouvre les fichiers et prépare l'environnement
      *===============================================================
       1000-INITIALISATION.
           OPEN INPUT  FIC-PAIEMENTS
      *         ^ INPUT = ouverture en lecture
           OPEN OUTPUT FIC-TRAITES
      *         ^ OUTPUT = ouverture en écriture (nouveau fichier)
           OPEN OUTPUT FIC-RAPPORT.

      *    Vérification d'ouverture des fichiers
           IF WS-STATUT-PAI NOT = '00'
               DISPLAY 'ERREUR OUVERTURE FICHIER PAIEMENTS : '
                       WS-STATUT-PAI
      *             ^ DISPLAY = affichage console/SYSOUT
               MOVE 16 TO RETURN-CODE
      *                      ^ Code de retour du programme (16=fatal)
               STOP RUN
           END-IF.

      *    Initialisation des compteurs
           MOVE ZEROS TO WS-NB-LIRE
                         WS-NB-TRAITES
                         WS-NB-ERREURS
                         WS-TOT-MONTANTS
                         WS-TOT-COMMISSIONS
                         WS-TOT-NETS.

      *    Écriture de l'en-tête du rapport
           WRITE ENREG-RAPPORT FROM WS-TITRE-RAPPORT.
           WRITE ENREG-RAPPORT FROM WS-EN-TETE.
           WRITE ENREG-RAPPORT FROM WS-TITRE-RAPPORT.

      *===============================================================
      *  2000 — LIRE PREMIER ENREGISTREMENT
      *  Pattern "Read First" : lire avant la boucle
      *===============================================================
       2000-LIRE-PREMIER.
           READ FIC-PAIEMENTS
               AT END
                   MOVE 'O' TO WS-FIN-FICHIER
      *                             ^ Positionner indicateur fin fichier
               NOT AT END
                   ADD 1 TO WS-NB-LIRE
           END-READ.

      *===============================================================
      *  3000 — TRAITEMENT PRINCIPAL (BOUCLE)
      *  Traite chaque enregistrement lu
      *===============================================================
       3000-TRAITER-PAIEMENTS.

      *    --- Validation de l'enregistrement ---
           PERFORM 3100-VALIDER-PAIEMENT

      *    --- Traitement si valide ---
           IF WS-STATUT-VALID = 'OK'
               PERFORM 3200-CALCULER-COMMISSION
               PERFORM 3300-ECRIRE-TRAITE
               ADD 1 TO WS-NB-TRAITES
           ELSE
               PERFORM 3400-ECRIRE-ERREUR
               ADD 1 TO WS-NB-ERREURS
           END-IF

      *    --- Lire l'enregistrement suivant ---
           READ FIC-PAIEMENTS
               AT END
                   MOVE 'O' TO WS-FIN-FICHIER
               NOT AT END
                   ADD 1 TO WS-NB-LIRE
           END-READ.

      *---------------------------------------------------------------
      *  3100 — VALIDATION DE L'ENREGISTREMENT
      *---------------------------------------------------------------
       3100-VALIDER-PAIEMENT.
           MOVE 'OK' TO WS-STATUT-VALID.

      *    Vérification : numéro client non vide
           IF PAI-NUM-CLIENT = SPACES
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'NUM CLIENT VIDE         ' TO WS-MOTIF-REJET
           END-IF.

      *    Vérification : montant positif
           IF PAI-MONTANT <= ZEROS
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'MONTANT INVALIDE (<=0)   ' TO WS-MOTIF-REJET
           END-IF.

      *    Vérification : type de paiement valide
           IF PAI-TYPE-PAIEMENT NOT = 'VIR'
           AND PAI-TYPE-PAIEMENT NOT = 'CHQ'
           AND PAI-TYPE-PAIEMENT NOT = 'CBK'
               MOVE 'ER' TO WS-STATUT-VALID
               MOVE 'TYPE PAIEMENT INCONNU    ' TO WS-MOTIF-REJET
           END-IF.

      *---------------------------------------------------------------
      *  3200 — CALCUL DE LA COMMISSION
      *---------------------------------------------------------------
       3200-CALCULER-COMMISSION.
      *    Commission = Montant × Taux (0.50%)
           COMPUTE WS-COMMISSION =
               PAI-MONTANT * WS-TAUX-COMM
               ROUNDED
      *              ^ ROUNDED = arrondi au centième le plus proche

      *    Montant net = Montant - Commission
           COMPUTE WS-MONTANT-NET =
               PAI-MONTANT - WS-COMMISSION

      *    Accumulation des totaux
           ADD PAI-MONTANT    TO WS-TOT-MONTANTS
           ADD WS-COMMISSION  TO WS-TOT-COMMISSIONS
           ADD WS-MONTANT-NET TO WS-TOT-NETS.

      *---------------------------------------------------------------
      *  3300 — ÉCRITURE ENREGISTREMENT TRAITÉ
      *---------------------------------------------------------------
       3300-ECRIRE-TRAITE.
      *    Remplir la zone de sortie
           MOVE PAI-NUM-CLIENT    TO TRA-NUM-CLIENT
           MOVE PAI-NOM-CLIENT    TO TRA-NOM-CLIENT
           MOVE PAI-DATE-PAIEMENT TO TRA-DATE-PAIEMENT
           MOVE PAI-MONTANT       TO TRA-MONTANT-ORIG
           MOVE WS-COMMISSION     TO TRA-COMMISSION
           MOVE WS-MONTANT-NET    TO TRA-MONTANT-NET
           MOVE 'OK'              TO TRA-STATUT
           MOVE SPACES            TO TRA-FILLER.

      *    Écrire dans le fichier de sortie
           WRITE ENREG-TRAITE.

      *    Vérification écriture
           IF WS-STATUT-TRA NOT = '00'
               DISPLAY 'ERREUR ECRITURE FICHIER TRAITES : '
                       WS-STATUT-TRA
               MOVE 12 TO RETURN-CODE
               STOP RUN
           END-IF.

      *---------------------------------------------------------------
      *  3400 — ÉCRITURE ENREGISTREMENT EN ERREUR
      *---------------------------------------------------------------
       3400-ECRIRE-ERREUR.
      *    Afficher le rejet dans le rapport
           STRING 'REJET : ' DELIMITED SIZE
                  PAI-NUM-CLIENT DELIMITED SIZE
                  ' - ' DELIMITED SIZE
                  WS-MOTIF-REJET DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT.
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

      *===============================================================
      *  4000 — FINALISATION
      *  Écriture du rapport de synthèse et fermeture des fichiers
      *===============================================================
       4000-FINALISATION.
      *    Écrire le rapport de synthèse
           WRITE ENREG-RAPPORT FROM WS-TITRE-RAPPORT.

           MOVE WS-NB-LIRE      TO WS-MONTANT-AFFICHE
           STRING 'NB ENREGISTREMENTS LUS    : '
                  WS-NB-LIRE DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

           MOVE WS-NB-TRAITES   TO WS-MONTANT-AFFICHE
           STRING 'NB PAIEMENTS TRAITES      : '
                  WS-NB-TRAITES DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

           MOVE WS-NB-ERREURS   TO WS-MONTANT-AFFICHE
           STRING 'NB REJETS / ERREURS       : '
                  WS-NB-ERREURS DELIMITED SIZE
               INTO WS-LIGNE-RAPPORT
           WRITE ENREG-RAPPORT FROM WS-LIGNE-RAPPORT.

           WRITE ENREG-RAPPORT FROM WS-TITRE-RAPPORT.

      *    Fermeture des fichiers (OBLIGATOIRE avant fin programme)
           CLOSE FIC-PAIEMENTS
                 FIC-TRAITES
                 FIC-RAPPORT.

      *    Code de retour selon présence d'erreurs
           IF WS-NB-ERREURS > ZEROS
               MOVE 4 TO RETURN-CODE
      *             ^ Code 4 = succès avec avertissements
           END-IF.

      *    Fin du paragraphe de finalisation
       4000-FIN. EXIT.

      *===============================================================
      * FIN DU PROGRAMME PAIEMENT
      *===============================================================
