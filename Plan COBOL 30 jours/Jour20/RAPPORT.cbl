      *===============================================================
      * JOUR 20 — REPORTING BATCH : RAPPORT JOURNALIER
      *
      * LEÇON : Produire des rapports formatés professionnels
      *
      * CONCEPTS COUVERTS :
      *   - Formatage avec PICTURES d'édition (Z, ., ,, -, $)
      *   - Gestion des sauts de page (WRITE AFTER ADVANCING)
      *   - En-têtes et pieds de page automatiques
      *   - Ruptures de contrôle (break on key change)
      *   - Totalisation par groupe et grand total
      *   - Formatage des dates pour affichage
      *
      * SCÉNARIO MÉTIER :
      *   Produire le rapport journalier des paiements traités.
      *   Le rapport est organisé par type de paiement,
      *   avec sous-totaux par type et grand total final.
      *
      *   FORMAT DU RAPPORT :
      *   ┌─────────────────────────────────────────────────────┐
      *   │  BANQUE EXEMPLE - RAPPORT JOURNALIER PAIEMENTS   P.1│
      *   │  DATE : 15/01/2024          HEURE : 14:32:00        │
      *   ├─────┬──────────────────────┬──────────────┬─────────┤
      *   │TYPE │ CLIENT               │ MONTANT      │ DEVISE  │
      *   ├─────┼──────────────────────┼──────────────┼─────────┤
      *   │ VIR │ DUPONT JEAN          │   1,500.00   │  EUR    │
      *   │ VIR │ MARTIN SOPHIE        │     750.50   │  EUR    │
      *   ├─────┴──────────────────────┼──────────────┼─────────┤
      *   │ SOUS-TOTAL VIR (2 enreg.)  │   2,250.50   │         │
      *   ├─────────────────────────────────────────────────────┤
      *   │ GRAND TOTAL (N enreg.)     │  XX,XXX.XX   │         │
      *   └─────────────────────────────────────────────────────┘
      *
      *===============================================================

       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT.
       AUTHOR.     STAGIAIRE-MAINFRAME.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Fichier de paiements traités (trié par TYPE puis CLIENT)
           SELECT FIC-PAIE     ASSIGN TO PAIEMNT
               FILE STATUS IS WS-STAT-PAI.
      *    Fichier rapport (sortie imprimante)
           SELECT FIC-RAPPORT  ASSIGN TO RAPPORT
               FILE STATUS IS WS-STAT-RAP.

       DATA DIVISION.
       FILE SECTION.

      *--- Enregistrement d'entrée
       FD  FIC-PAIE RECORD CONTAINS 100 CHARACTERS.
       01  ENREG-PAIE.
           05  PAI-NUM-CLIENT      PIC X(10).
           05  PAI-NOM-CLIENT      PIC X(30).
           05  PAI-DATE            PIC 9(8).
           05  PAI-MONTANT         PIC 9(9)V99.
           05  PAI-TYPE            PIC X(3).
           05  PAI-DEVISE          PIC X(3).
           05  PAI-FILLER          PIC X(43).

      *--- Enregistrement rapport (132 colonnes = largeur imprimante standard)
       FD  FIC-RAPPORT
           RECORDING MODE IS F
           RECORD CONTAINS 133 CHARACTERS.
      *                    ^ 1 char de contrôle carriage + 132 data
       01  ENREG-RAPPORT           PIC X(133).

       WORKING-STORAGE SECTION.

      *--- Statuts
       01  WS-STAT-PAI             PIC X(2).
       01  WS-STAT-RAP             PIC X(2).

      *--- Indicateurs
       01  WS-FIN-FICHIER          PIC X  VALUE 'N'.
           88  FIN-FICHIER         VALUE 'O'.
       01  WS-PREMIER-ENREG        PIC X  VALUE 'O'.
           88  PREMIER-ENREG       VALUE 'O'.

      *--- Clé de rupture : changement de type
       01  WS-TYPE-PREC            PIC X(3) VALUE SPACES.
      *    Quand PAI-TYPE ≠ WS-TYPE-PREC → rupture de contrôle

      *--- COMPTEURS ET TOTAUX PAR GROUPE (sous-total)
       01  WS-GROUPE.
           05  WS-GRP-NB           PIC 9(7)   VALUE ZEROS.
           05  WS-GRP-MONTANT      PIC 9(13)V99 VALUE ZEROS.

      *--- TOTAUX GÉNÉRAUX
       01  WS-TOTAUX.
           05  WS-TOT-NB           PIC 9(7)   VALUE ZEROS.
           05  WS-TOT-MONTANT      PIC 9(13)V99 VALUE ZEROS.

      *--- Pagination
       01  WS-NUM-PAGE             PIC 9(4)   VALUE ZEROS.
       01  WS-NB-LIGNES            PIC 9(3)   VALUE ZEROS.
       01  WS-MAX-LIGNES           PIC 9(3)   VALUE 55.
      *                                              ^ 55 lignes par page

      *--- Date et heure système
       01  WS-DATE-SYST            PIC 9(8)   VALUE ZEROS.
       01  WS-HEURE-SYST           PIC 9(8)   VALUE ZEROS.

      *--- PICTURES D'ÉDITION pour l'affichage
      *    Ces pictures formatent les nombres pour la lisibilité humaine
       01  WS-MONTANT-EDIT         PIC ZZZ,ZZZ,ZZ9.99.
      *                                ^              ^
      *                                |              └── .99 = 2 décimales
      *                                └── Z = supprimer les zéros non significatifs
      *                                    , = virgule de séparation des milliers
      *                                    9 = toujours afficher ce chiffre
      *    Exemple : 1500.50 → "  1,500.50"

       01  WS-PAGE-EDIT            PIC ZZZ9.
      *    Exemple : 3 → "   3"

       01  WS-NB-EDIT              PIC ZZZ,ZZZ,ZZ9.
      *    Exemple : 1234 → "      1,234"

      *--- DATE FORMATÉE pour affichage (JJ/MM/AAAA)
       01  WS-DATE-AFFICHE.
           05  WS-DA-JOUR          PIC 9(2).
           05  FILLER              PIC X     VALUE '/'.
           05  WS-DA-MOIS          PIC 9(2).
           05  FILLER              PIC X     VALUE '/'.
           05  WS-DA-ANNEE         PIC 9(4).

      *--- HEURE FORMATÉE pour affichage (HH:MM:SS)
       01  WS-HEURE-AFFICHE.
           05  WS-HA-HEURE         PIC 9(2).
           05  FILLER              PIC X     VALUE ':'.
           05  WS-HA-MINUTE        PIC 9(2).
           05  FILLER              PIC X     VALUE ':'.
           05  WS-HA-SECONDE       PIC 9(2).

      *===============================================================
      *  ZONES DE RAPPORT — Les lignes préformatées
      *  Chaque zone représente un type de ligne du rapport
      *===============================================================

      *--- Ligne d'en-tête titre
       01  WS-ENT-TITRE.
           05  FILLER  PIC X(50)
               VALUE 'BANQUE EXEMPLE - RAPPORT JOURNALIER PAIEMENTS  '.
           05  FILLER  PIC X(15) VALUE 'PAGE : '.
           05  WS-ENT-PAGE        PIC ZZZ9.
           05  FILLER  PIC X(64) VALUE SPACES.
      *    Total = 133 caractères

      *--- Ligne d'en-tête date/heure
       01  WS-ENT-DATEHEURE.
           05  FILLER             PIC X(8)  VALUE 'DATE : '.
           05  WS-ENT-DATE        PIC X(10).
           05  FILLER             PIC X(5)  VALUE '     '.
           05  FILLER             PIC X(8)  VALUE 'HEURE : '.
           05  WS-ENT-HEURE       PIC X(8).
           05  FILLER             PIC X(94) VALUE SPACES.

      *--- Ligne de séparation
       01  WS-SEPARATEUR          PIC X(133)
           VALUE ALL '-'.

      *--- Ligne d'en-tête de colonnes
       01  WS-ENT-COLONNES.
           05  FILLER  PIC X(5)  VALUE 'TYPE '.
           05  FILLER  PIC X(12) VALUE 'NUMERO      '.
           05  FILLER  PIC X(32) VALUE 'NOM CLIENT                      '.
           05  FILLER  PIC X(16) VALUE 'MONTANT         '.
           05  FILLER  PIC X(8)  VALUE 'DEVISE  '.
           05  FILLER  PIC X(60) VALUE SPACES.

      *--- Ligne de détail (une ligne par paiement)
       01  WS-LIGNE-DETAIL.
           05  WS-LIG-TYPE        PIC X(5).
           05  WS-LIG-NUM         PIC X(12).
           05  WS-LIG-NOM         PIC X(32).
           05  WS-LIG-MONTANT     PIC ZZZ,ZZZ,ZZ9.99.
      *                                ^
      *                                PIC d'édition directement dans la zone
           05  FILLER             PIC X(2)  VALUE SPACES.
           05  WS-LIG-DEVISE      PIC X(3).
           05  FILLER             PIC X(67) VALUE SPACES.

      *--- Ligne de sous-total (rupture de type)
       01  WS-LIGNE-STOTAL.
           05  FILLER             PIC X(5)  VALUE SPACES.
           05  FILLER             PIC X(12) VALUE 'SOUS-TOTAL '.
           05  WS-STL-TYPE        PIC X(3).
           05  FILLER             PIC X(2)  VALUE ' ('.
           05  WS-STL-NB          PIC ZZZ,ZZZ,ZZ9.
           05  FILLER             PIC X(10) VALUE ' enreg.)  '.
           05  WS-STL-MONTANT     PIC ZZZ,ZZZ,ZZ9.99.
           05  FILLER             PIC X(70) VALUE SPACES.

      *--- Ligne de grand total
       01  WS-LIGNE-GTOTAL.
           05  FILLER             PIC X(5)  VALUE SPACES.
           05  FILLER             PIC X(15) VALUE 'GRAND TOTAL ('.
           05  WS-GTL-NB          PIC ZZZ,ZZZ,ZZ9.
           05  FILLER             PIC X(10) VALUE ' enreg.)  '.
           05  WS-GTL-MONTANT     PIC ZZZ,ZZZ,ZZ9.99.
           05  FILLER             PIC X(71) VALUE SPACES.

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
           OPEN INPUT  FIC-PAIE
                OUTPUT FIC-RAPPORT.

      *    Récupérer la date et l'heure système
           ACCEPT WS-DATE-SYST  FROM DATE YYYYMMDD
           ACCEPT WS-HEURE-SYST FROM TIME.

      *    Formater la date : AAAAMMJJ → JJ/MM/AAAA
           MOVE WS-DATE-SYST(1:4) TO WS-DA-ANNEE
           MOVE WS-DATE-SYST(5:2) TO WS-DA-MOIS
           MOVE WS-DATE-SYST(7:2) TO WS-DA-JOUR.
      *         ^          ^ ^
      *         |          | └── Longueur de la référence
      *         |          └──── Position de début (reference modification)
      *         └──────────────── Variable source

      *    Formater l'heure : HHMMSSCC → HH:MM:SS
           MOVE WS-HEURE-SYST(1:2) TO WS-HA-HEURE
           MOVE WS-HEURE-SYST(3:2) TO WS-HA-MINUTE
           MOVE WS-HEURE-SYST(5:2) TO WS-HA-SECONDE.

      *    Écrire la première page
           PERFORM 5000-ECRIRE-ENTETES.

      *===============================================================
      *  2000 — LIRE PREMIER
      *===============================================================
       2000-LIRE-PREMIER.
           READ FIC-PAIE
               AT END MOVE 'O' TO WS-FIN-FICHIER
           END-READ
           IF NOT FIN-FICHIER
               MOVE PAI-TYPE TO WS-TYPE-PREC
           END-IF.

      *===============================================================
      *  3000 — TRAITEMENT (BOUCLE PRINCIPALE)
      *===============================================================
       3000-TRAITEMENT.

      *    ─── DÉTECTION DE RUPTURE DE CONTRÔLE ───
      *    Si le type a changé → écrire le sous-total du groupe précédent
           IF PAI-TYPE NOT = WS-TYPE-PREC
               PERFORM 3100-ECRIRE-SOUS-TOTAL
               PERFORM 3200-INIT-GROUPE
           END-IF

      *    Vérifier si besoin de nouvelle page
           IF WS-NB-LIGNES >= WS-MAX-LIGNES
               PERFORM 5000-ECRIRE-ENTETES
           END-IF

      *    Remplir et écrire la ligne de détail
           PERFORM 3300-ECRIRE-DETAIL

      *    Accumuler les totaux du groupe et généraux
           ADD 1           TO WS-GRP-NB   WS-TOT-NB
           ADD PAI-MONTANT TO WS-GRP-MONTANT WS-TOT-MONTANT

      *    Mémoriser le type courant pour la prochaine itération
           MOVE PAI-TYPE TO WS-TYPE-PREC

      *    Lire suivant
           READ FIC-PAIE
               AT END MOVE 'O' TO WS-FIN-FICHIER
           END-READ.

      *---------------------------------------------------------------
      *  3100 — ÉCRIRE SOUS-TOTAL DU GROUPE
      *---------------------------------------------------------------
       3100-ECRIRE-SOUS-TOTAL.
           MOVE WS-TYPE-PREC    TO WS-STL-TYPE
           MOVE WS-GRP-NB       TO WS-STL-NB
           MOVE WS-GRP-MONTANT  TO WS-STL-MONTANT

      *    Écrire ligne de séparation avant sous-total
           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-NB-LIGNES

           WRITE ENREG-RAPPORT FROM WS-LIGNE-STOTAL
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-NB-LIGNES

           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR
               AFTER ADVANCING 1 LINE
           ADD 1 TO WS-NB-LIGNES.

      *---------------------------------------------------------------
      *  3200 — INITIALISER LE NOUVEAU GROUPE
      *---------------------------------------------------------------
       3200-INIT-GROUPE.
           MOVE ZEROS TO WS-GRP-NB WS-GRP-MONTANT.

      *---------------------------------------------------------------
      *  3300 — ÉCRIRE UNE LIGNE DE DÉTAIL
      *---------------------------------------------------------------
       3300-ECRIRE-DETAIL.
           MOVE PAI-TYPE    TO WS-LIG-TYPE
           MOVE PAI-NUM-CLIENT TO WS-LIG-NUM
           MOVE PAI-NOM-CLIENT TO WS-LIG-NOM
           MOVE PAI-MONTANT TO WS-LIG-MONTANT
      *    ^ WS-LIG-MONTANT est une PIC ZZZ,ZZZ,ZZ9.99 → formatage automatique !
           MOVE PAI-DEVISE  TO WS-LIG-DEVISE

           WRITE ENREG-RAPPORT FROM WS-LIGNE-DETAIL
               AFTER ADVANCING 1 LINE
      *                              ^ Avancer d'1 ligne avant écriture
           ADD 1 TO WS-NB-LIGNES.

      *===============================================================
      *  4000 — FINALISATION
      *===============================================================
       4000-FINALISATION.
      *    Écrire le sous-total du dernier groupe
           PERFORM 3100-ECRIRE-SOUS-TOTAL.

      *    Écrire le grand total
           MOVE WS-TOT-NB      TO WS-GTL-NB
           MOVE WS-TOT-MONTANT TO WS-GTL-MONTANT
           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR AFTER ADVANCING 2 LINES
           WRITE ENREG-RAPPORT FROM WS-LIGNE-GTOTAL AFTER ADVANCING 1 LINE
           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR AFTER ADVANCING 1 LINE

           CLOSE FIC-PAIE FIC-RAPPORT.

      *===============================================================
      *  5000 — ÉCRIRE LES EN-TÊTES DE PAGE
      *===============================================================
       5000-ECRIRE-ENTETES.
           ADD 1 TO WS-NUM-PAGE
           MOVE WS-NUM-PAGE TO WS-ENT-PAGE.

      *    Sauter à la page suivante
           WRITE ENREG-RAPPORT FROM WS-ENT-TITRE
               AFTER ADVANCING PAGE
      *                               ^ PAGE = saut de page (form feed)

      *    Remplir les zones variables de l'en-tête
           MOVE WS-DATE-AFFICHE TO WS-ENT-DATE
           MOVE WS-HEURE-AFFICHE TO WS-ENT-HEURE
           WRITE ENREG-RAPPORT FROM WS-ENT-DATEHEURE AFTER ADVANCING 1 LINE
           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR    AFTER ADVANCING 1 LINE
           WRITE ENREG-RAPPORT FROM WS-ENT-COLONNES  AFTER ADVANCING 1 LINE
           WRITE ENREG-RAPPORT FROM WS-SEPARATEUR    AFTER ADVANCING 1 LINE

           MOVE 5 TO WS-NB-LIGNES.
      *    ^ 5 lignes utilisées pour les en-têtes
