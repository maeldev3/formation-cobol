*============================================================
      * CASH-MAIN.cbl - Gestion Caisse Agence Bancaire
      * Branch Cash Management System - Projet COBOL + SQLite
      *
      * Fonctionnalites:
      *   - Ouverture caisse journee
      *   - Entrees / Sorties especes
      *   - Controle et inventaire billets
      *   - Cloture journee avec calcul ecart
      *   - Historique mouvements
      *   - Rapport journalier
      *============================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASH-MAIN.
       AUTHOR. GnuCOBOL-CashMgmt.
       DATE-WRITTEN. 2026-06-09.

       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

           COPY "DB-BRIDGE.cpy".

      *--- Date/Heure ---
       01  WS-DATETIME    PIC X(21).
       01  WS-DATE        PIC X(10).
       01  WS-HEURE       PIC X(08).
       01  WS-YEAR        PIC X(04).
       01  WS-MONTH       PIC X(02).
       01  WS-DAY         PIC X(02).
       01  WS-HH          PIC X(02).
       01  WS-MM          PIC X(02).
       01  WS-SS          PIC X(02).

      *--- Session courante ---
       01  WS-ID-AGENCE   PIC X(10) VALUE SPACES.
       01  WS-NOM-AGENCE  PIC X(40) VALUE SPACES.
       01  WS-ID-CAISSE   PIC S9(18) COMP-5 VALUE 0.
       01  WS-CAISSIER    PIC X(30) VALUE SPACES.
       01  WS-CAISSE-OUV  PIC X VALUE 'N'.

      *--- Soldes (stockes en centimes entiers, ex: 5000000 = 50 000,00 MGA) ---
       01  WS-SOLDE-OUV   PIC S9(18) COMP-5 VALUE 0.
       01  WS-SOLDE-ACT   PIC S9(18) COMP-5 VALUE 0.
       01  WS-TOT-ENT     PIC S9(18) COMP-5 VALUE 0.
       01  WS-TOT-SOR     PIC S9(18) COMP-5 VALUE 0.
       01  WS-SOLDE-PHYS  PIC S9(18) COMP-5 VALUE 0.
       01  WS-ECART       PIC S9(18) COMP-5 VALUE 0.

      *--- Saisie ---
       01  WS-MONTANT-IN  PIC X(15) VALUE SPACES.
       01  WS-MONTANT     PIC S9(15)V99 VALUE 0.
       01  WS-MONTANT-INT PIC S9(18) COMP-5 VALUE 0.
       01  WS-LIBELLE     PIC X(40) VALUE SPACES.
       01  WS-REF         PIC X(12) VALUE SPACES.
       01  WS-TYPE-OP     PIC X(03) VALUE SPACES.
       01  WS-SENS        PIC X(01) VALUE SPACES.

      *--- Inventaire billets ---
       01  WS-DENOM-TABLE.
           05 WS-DENOM OCCURS 8 TIMES.
               10 DN-VALEUR PIC 9(07) VALUE 0.
               10 DN-QTE    PIC 9(06) VALUE 0.
               10 DN-TOTAL  PIC S9(14) COMP-5 VALUE 0.
       01  WS-INV-TOTAL   PIC S9(18) COMP-5 VALUE 0.
       01  WS-IDX         PIC 9(02) VALUE 0.
       01  WS-QTE-IN      PIC X(06) VALUE SPACES.
       01  WS-QTE-NUM     PIC 9(06) VALUE 0.

      *--- Affichage ---
       01  WS-DISP-SOLDE  PIC ZZ,ZZZ,ZZZ,ZZZ,ZZ9.
       01  WS-DISP-MNT    PIC ZZ,ZZZ,ZZZ,ZZZ,ZZ9.
       01  WS-DISP-ECT    PIC -ZZ,ZZZ,ZZZ,ZZZ,ZZ9.
       01  WS-DISP-64     PIC S9(18).
       01  WS-CALC-DISP   PIC S9(18) COMP-5 VALUE 0.
      *--- SQL numeric (no sign, trimmed) ---
       01  WS-SQL-NUM     PIC 9(18) VALUE 0.
       01  WS-SQL-SGN     PIC S9(18) VALUE 0.

      *--- Navigation ---
       01  WS-CHOIX       PIC 9 VALUE 0.
       01  WS-CHOIX2      PIC 9 VALUE 0.
       01  WS-CONTINUE    PIC X VALUE 'Y'.
       01  WS-CONFIRM     PIC X VALUE 'N'.
       01  WS-OK          PIC X VALUE 'N'.

       01  WS-SEP.
           05 FILLER PIC X(60) VALUE ALL '='.
       01  WS-DASH.
           05 FILLER PIC X(60) VALUE ALL '-'.

      *--- Boucle fetch ---
       01  WS-EOF         PIC X VALUE 'N'.
       01  WS-CTR         PIC 9(07) VALUE 0.

       PROCEDURE DIVISION.

       000-MAIN.
           PERFORM 010-INIT
           PERFORM 020-LOGIN
           PERFORM 030-MENU UNTIL WS-CONTINUE = 'N'
           PERFORM 099-CLOSE
           STOP RUN.

      *============================================================
       010-INIT.
           MOVE FUNCTION CURRENT-DATE TO WS-DATETIME
           MOVE WS-DATETIME(1:4)  TO WS-YEAR
           MOVE WS-DATETIME(5:2)  TO WS-MONTH
           MOVE WS-DATETIME(7:2)  TO WS-DAY
           MOVE WS-DATETIME(9:2)  TO WS-HH
           MOVE WS-DATETIME(11:2) TO WS-MM
           MOVE WS-DATETIME(13:2) TO WS-SS
           STRING WS-YEAR "-" WS-MONTH "-" WS-DAY
               DELIMITED SIZE INTO WS-DATE
           STRING WS-HH ":" WS-MM ":" WS-SS
               DELIMITED SIZE INTO WS-HEURE

           CALL "db_open" USING DB-PATH RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR: Base SQLite inaccessible."
               DISPLAY "  Lancer d'abord: ./bin/cash-init"
               STOP RUN
           END-IF

      *--- Init denominations billets MGA ---
           MOVE 50000 TO DN-VALEUR(1)
           MOVE 20000 TO DN-VALEUR(2)
           MOVE 10000 TO DN-VALEUR(3)
           MOVE  5000 TO DN-VALEUR(4)
           MOVE  2000 TO DN-VALEUR(5)
           MOVE  1000 TO DN-VALEUR(6)
           MOVE   500 TO DN-VALEUR(7)
           MOVE   100 TO DN-VALEUR(8).

      *============================================================
       020-LOGIN.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  BRANCH CASH MANAGEMENT SYSTEM"
           DISPLAY "  Gestion Caisse Agence Bancaire"
           DISPLAY "  Date: " WS-DATE " Heure: " WS-HEURE
           DISPLAY WS-SEP
           PERFORM 021-SELECT-AGENCE
           DISPLAY "  Nom caissier : " WITH NO ADVANCING
           ACCEPT WS-CAISSIER.

       021-SELECT-AGENCE.
           DISPLAY "  Agences disponibles:"
           MOVE SPACES TO DB-SQL
           STRING "SELECT id_agence,nom,ville FROM agences"
               " WHERE statut='A' ORDER BY id_agence"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           PERFORM UNTIL DB-RC NOT = 0
               CALL "db_step" RETURNING DB-RC
               IF DB-RC = 100
                   MOVE 0 TO DB-COL
                   CALL "db_col_str10" USING DB-COL DB-COL-S10
                   MOVE 1 TO DB-COL
                   CALL "db_col_str40" USING DB-COL DB-COL-S40
                   DISPLAY "    " DB-COL-S10 " - " DB-COL-S40
               ELSE
                   MOVE 0 TO DB-RC
               END-IF
           END-PERFORM
           CALL "db_finalize" RETURNING DB-RC
           DISPLAY "  ID agence    : " WITH NO ADVANCING
           ACCEPT WS-ID-AGENCE
           PERFORM 022-LOAD-AGENCE.

       022-LOAD-AGENCE.
           MOVE SPACES TO DB-SQL
           STRING "SELECT nom FROM agences WHERE id_agence='"
               FUNCTION TRIM(WS-ID-AGENCE) "'"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           CALL "db_step" RETURNING DB-RC
           IF DB-RC = 100
               MOVE 0 TO DB-COL
               CALL "db_col_str40" USING DB-COL WS-NOM-AGENCE
           ELSE
               DISPLAY "  Agence non trouvee. Utilisation AG001."
               MOVE "AG001" TO WS-ID-AGENCE
               MOVE "AGENCE PRINCIPALE" TO WS-NOM-AGENCE
           END-IF
           CALL "db_finalize" RETURNING DB-RC.

      *============================================================
       030-MENU.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  CAISSE - " WS-NOM-AGENCE
           DISPLAY "  Agence: " WS-ID-AGENCE
               "  Date: " WS-DATE
           IF WS-CAISSE-OUV = 'O'
               MOVE WS-SOLDE-ACT TO WS-DISP-64
               MOVE WS-DISP-64   TO WS-DISP-SOLDE
               DISPLAY "  Solde actuel: " WS-DISP-SOLDE " MGA"
           ELSE
               DISPLAY "  [ Caisse non ouverte ]"
           END-IF
           DISPLAY WS-SEP
           DISPLAY "  -- CAISSE --"
           DISPLAY "  1. Ouvrir la caisse du jour"
           DISPLAY "  2. Entree especes"
           DISPLAY "  3. Sortie especes"
           DISPLAY "  4. Inventaire / Controle billets"
           DISPLAY "  5. Cloture de journee"
           DISPLAY "  -- CONSULTATION --"
           DISPLAY "  6. Mouvements du jour"
           DISPLAY "  7. Rapport journalier"
           DISPLAY "  8. Historique par type"
           DISPLAY "  0. Quitter"
           DISPLAY WS-DASH
           DISPLAY "  Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 PERFORM 100-OUVRIR-CAISSE
               WHEN 2 PERFORM 200-ENTREE-ESPECES
               WHEN 3 PERFORM 300-SORTIE-ESPECES
               WHEN 4 PERFORM 400-INVENTAIRE-BILLETS
               WHEN 5 PERFORM 500-CLOTURE-JOURNEE
               WHEN 6 PERFORM 600-MOUVEMENTS-JOUR
               WHEN 7 PERFORM 700-RAPPORT-JOURNALIER
               WHEN 8 PERFORM 800-HISTORIQUE-TYPE
               WHEN 0 MOVE 'N' TO WS-CONTINUE
               WHEN OTHER DISPLAY "  Choix invalide."
           END-EVALUATE.

      *============================================================
      * MODULE 1 : OUVERTURE CAISSE
      *============================================================
       100-OUVRIR-CAISSE.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  OUVERTURE CAISSE - " WS-DATE
           DISPLAY WS-SEP

           IF WS-CAISSE-OUV = 'O'
               DISPLAY "  Caisse deja ouverte (ID="
                   WS-ID-CAISSE ")."
               GO TO 100-EXIT
           END-IF

      *--- Verifier si deja ouverte pour ce jour ---
           MOVE SPACES TO DB-SQL
           STRING "SELECT id_caisse,solde_ouverture FROM caisses"
               " WHERE id_agence='"
               FUNCTION TRIM(WS-ID-AGENCE)
               "' AND date_journee='" WS-DATE "'"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           CALL "db_step" RETURNING DB-RC
           IF DB-RC = 100
               MOVE 0 TO DB-COL
               CALL "db_col_int64" USING DB-COL WS-ID-CAISSE
               MOVE 1 TO DB-COL
               CALL "db_col_int64" USING DB-COL WS-SOLDE-OUV
               MOVE WS-SOLDE-OUV TO WS-SOLDE-ACT
               MOVE 'O' TO WS-CAISSE-OUV
               CALL "db_finalize" RETURNING DB-RC
               DISPLAY "  Caisse du jour rechargee (ID="
                   WS-ID-CAISSE ")."
               GO TO 100-EXIT
           END-IF
           CALL "db_finalize" RETURNING DB-RC

      *--- Recuperer solde precedent ---
           MOVE SPACES TO DB-SQL
           STRING "SELECT solde_actuel FROM agences"
               " WHERE id_agence='"
               FUNCTION TRIM(WS-ID-AGENCE) "'"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           CALL "db_step" RETURNING DB-RC
           IF DB-RC = 100
               MOVE 0 TO DB-COL
               CALL "db_col_int64" USING DB-COL WS-SOLDE-OUV
           END-IF
           CALL "db_finalize" RETURNING DB-RC

           MOVE WS-SOLDE-OUV TO WS-DISP-64
           MOVE WS-DISP-64   TO WS-DISP-SOLDE
           DISPLAY "  Solde d'ouverture: " WS-DISP-SOLDE " MGA"
           DISPLAY "  Confirmer l'ouverture? (O/N): "
               WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM NOT = 'O' AND WS-CONFIRM NOT = 'o'
               DISPLAY "  Ouverture annulee."
               GO TO 100-EXIT
           END-IF

      *--- INSERT caisse ---
           MOVE WS-SOLDE-OUV TO WS-SQL-NUM
           MOVE SPACES TO DB-SQL
           STRING "INSERT INTO caisses("
               "id_agence,date_journee,"
               "solde_ouverture,total_entrees,total_sorties,"
               "solde_theorique,statut,"
               "heure_ouverture,caissier) VALUES('"
               FUNCTION TRIM(WS-ID-AGENCE) "','"
               WS-DATE "',"
               FUNCTION TRIM(WS-SQL-NUM) ",0,0,"
               FUNCTION TRIM(WS-SQL-NUM) ",'O','"
               WS-HEURE "','"
               FUNCTION TRIM(WS-CAISSIER) "')"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "  ERREUR ouverture caisse: " DB-RC
               GO TO 100-EXIT
           END-IF

           CALL "db_last_rowid" USING DB-ROWID
           MOVE DB-ROWID      TO WS-ID-CAISSE
           MOVE WS-SOLDE-OUV  TO WS-SOLDE-ACT
           MOVE 0             TO WS-TOT-ENT
           MOVE 0             TO WS-TOT-SOR
           MOVE 'O'           TO WS-CAISSE-OUV

           DISPLAY "  Caisse ouverte avec succes!"
           DISPLAY "  ID Caisse : " WS-ID-CAISSE
           DISPLAY "  Caissier  : " WS-CAISSIER.
       100-EXIT. CONTINUE.

      *============================================================
      * MODULE 2 : ENTREE ESPECES
      *============================================================
       200-ENTREE-ESPECES.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  ENTREE ESPECES"
           DISPLAY WS-SEP
           IF WS-CAISSE-OUV = 'N'
               DISPLAY "  Ouvrir la caisse d'abord (option 1)."
               GO TO 200-EXIT
           END-IF
           DISPLAY "  Types: DEP=Depot  VIR=Virement  ALM=Aliment"
           DISPLAY "         RBT=Rembt  AUT=Autre"
           DISPLAY "  Type operation : " WITH NO ADVANCING
           ACCEPT WS-TYPE-OP
           DISPLAY "  Montant (MGA)  : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-IN
           MOVE FUNCTION NUMVAL(WS-MONTANT-IN) TO WS-MONTANT
           COMPUTE WS-MONTANT-INT = FUNCTION INTEGER(WS-MONTANT)
           IF WS-MONTANT-INT <= 0
               DISPLAY "  Montant invalide."
               GO TO 200-EXIT
           END-IF
           DISPLAY "  Libelle        : " WITH NO ADVANCING
           ACCEPT WS-LIBELLE
           DISPLAY "  Reference      : " WITH NO ADVANCING
           ACCEPT WS-REF

           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT + WS-MONTANT-INT
           ADD WS-MONTANT-INT TO WS-TOT-ENT
           MOVE 'E' TO WS-SENS
           PERFORM 999-WRITE-MOUVEMENT
           PERFORM 999-UPDATE-CAISSE

           MOVE WS-MONTANT-INT TO WS-DISP-64
           MOVE WS-DISP-64     TO WS-DISP-MNT
           MOVE WS-SOLDE-ACT   TO WS-DISP-64
           MOVE WS-DISP-64     TO WS-DISP-SOLDE
           DISPLAY "  Entree enregistree: +" WS-DISP-MNT " MGA"
           DISPLAY "  Nouveau solde     : " WS-DISP-SOLDE " MGA".
       200-EXIT. CONTINUE.

      *============================================================
      * MODULE 3 : SORTIE ESPECES
      *============================================================
       300-SORTIE-ESPECES.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  SORTIE ESPECES"
           DISPLAY WS-SEP
           IF WS-CAISSE-OUV = 'N'
               DISPLAY "  Ouvrir la caisse d'abord (option 1)."
               GO TO 300-EXIT
           END-IF
           DISPLAY "  Types: RET=Retrait  PAY=Paiement"
           DISPLAY "         CHG=Change   AUT=Autre"
           DISPLAY "  Type operation : " WITH NO ADVANCING
           ACCEPT WS-TYPE-OP
           DISPLAY "  Montant (MGA)  : " WITH NO ADVANCING
           ACCEPT WS-MONTANT-IN
           MOVE FUNCTION NUMVAL(WS-MONTANT-IN) TO WS-MONTANT
           COMPUTE WS-MONTANT-INT = FUNCTION INTEGER(WS-MONTANT)
           IF WS-MONTANT-INT <= 0
               DISPLAY "  Montant invalide."
               GO TO 300-EXIT
           END-IF
           IF WS-MONTANT-INT > WS-SOLDE-ACT
               DISPLAY "  REFUSE: solde insuffisant."
               MOVE WS-SOLDE-ACT TO WS-DISP-64
               MOVE WS-DISP-64   TO WS-DISP-SOLDE
               DISPLAY "  Solde disponible: " WS-DISP-SOLDE " MGA"
               GO TO 300-EXIT
           END-IF
           DISPLAY "  Libelle        : " WITH NO ADVANCING
           ACCEPT WS-LIBELLE
           DISPLAY "  Reference      : " WITH NO ADVANCING
           ACCEPT WS-REF

           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT - WS-MONTANT-INT
           ADD WS-MONTANT-INT TO WS-TOT-SOR
           MOVE 'S' TO WS-SENS
           PERFORM 999-WRITE-MOUVEMENT
           PERFORM 999-UPDATE-CAISSE

           MOVE WS-MONTANT-INT TO WS-DISP-64
           MOVE WS-DISP-64     TO WS-DISP-MNT
           MOVE WS-SOLDE-ACT   TO WS-DISP-64
           MOVE WS-DISP-64     TO WS-DISP-SOLDE
           DISPLAY "  Sortie enregistree: -" WS-DISP-MNT " MGA"
           DISPLAY "  Nouveau solde     : " WS-DISP-SOLDE " MGA".
       300-EXIT. CONTINUE.

      *============================================================
      * MODULE 4 : INVENTAIRE BILLETS
      *============================================================
       400-INVENTAIRE-BILLETS.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  INVENTAIRE / CONTROLE ESPECES"
           DISPLAY WS-SEP
           IF WS-CAISSE-OUV = 'N'
               DISPLAY "  Ouvrir la caisse d'abord."
               GO TO 400-EXIT
           END-IF
           DISPLAY "  Saisir le nombre de billets par coupure:"
           DISPLAY WS-DASH
           MOVE 0 TO WS-INV-TOTAL
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > 8
               MOVE DN-VALEUR(WS-IDX) TO WS-DISP-MNT
               DISPLAY "    " WS-DISP-MNT " MGA x ? : "
                   WITH NO ADVANCING
               ACCEPT WS-QTE-IN
               MOVE FUNCTION NUMVAL(WS-QTE-IN) TO WS-QTE-NUM
               MOVE WS-QTE-NUM TO DN-QTE(WS-IDX)
               COMPUTE DN-TOTAL(WS-IDX) =
                   DN-VALEUR(WS-IDX) * WS-QTE-NUM
               ADD DN-TOTAL(WS-IDX) TO WS-INV-TOTAL
           END-PERFORM

           DISPLAY WS-DASH
           DISPLAY "  RECAPITULATIF INVENTAIRE"
           DISPLAY WS-DASH
           DISPLAY "  Denomination | Quantite | Montant"
           DISPLAY WS-DASH
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > 8
               IF DN-QTE(WS-IDX) > 0
                   MOVE DN-VALEUR(WS-IDX) TO WS-DISP-MNT
                   MOVE DN-TOTAL(WS-IDX)  TO WS-CALC-DISP
                   MOVE WS-CALC-DISP      TO WS-DISP-64
                   MOVE WS-DISP-64        TO WS-DISP-SOLDE
                   DISPLAY "  " WS-DISP-MNT
                       "  | " DN-QTE(WS-IDX)
                       " | " WS-DISP-SOLDE " MGA"
               END-IF
           END-PERFORM
           DISPLAY WS-DASH
           MOVE WS-INV-TOTAL TO WS-DISP-64
           MOVE WS-DISP-64   TO WS-DISP-SOLDE
           DISPLAY "  TOTAL INVENTAIRE : " WS-DISP-SOLDE " MGA"

           MOVE WS-SOLDE-ACT TO WS-DISP-64
           MOVE WS-DISP-64   TO WS-DISP-MNT
           DISPLAY "  SOLDE THEORIQUE  : " WS-DISP-MNT " MGA"

           COMPUTE WS-ECART = WS-INV-TOTAL - WS-SOLDE-ACT
           MOVE WS-ECART  TO WS-DISP-ECT
           DISPLAY "  ECART            : " WS-DISP-ECT " MGA"

           IF WS-ECART = 0
               DISPLAY "  RESULTAT: CAISSE EQUILIBREE ✓"
           ELSE IF WS-ECART > 0
               DISPLAY "  RESULTAT: EXCEDENT - A VERIFIER"
           ELSE
               DISPLAY "  RESULTAT: MANQUANT - A SIGNALER"
           END-IF

      *--- Sauvegarder inventaire ---
           MOVE WS-ID-CAISSE TO WS-SQL-NUM
           MOVE SPACES TO DB-SQL
           STRING "DELETE FROM billets WHERE id_caisse="
               FUNCTION TRIM(WS-SQL-NUM)
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > 8
               IF DN-QTE(WS-IDX) > 0
                   MOVE SPACES TO DB-SQL
                   MOVE DN-TOTAL(WS-IDX) TO WS-CALC-DISP
                   STRING "INSERT INTO billets("
                       "id_caisse,denomination,"
                       "quantite,montant) VALUES("
                       FUNCTION TRIM(WS-SQL-NUM) ","
                       DN-VALEUR(WS-IDX) ","
                       DN-QTE(WS-IDX) ","
                       WS-CALC-DISP ")"
                       DELIMITED SIZE INTO DB-SQL
                   CALL "db_exec" USING DB-SQL RETURNING DB-RC
               END-IF
           END-PERFORM

           MOVE WS-INV-TOTAL TO WS-SOLDE-PHYS
           PERFORM 999-UPDATE-CAISSE-PHYS
           DISPLAY "  Inventaire sauvegarde en base.".
       400-EXIT. CONTINUE.

      *============================================================
      * MODULE 5 : CLOTURE JOURNEE
      *============================================================
       500-CLOTURE-JOURNEE.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  CLOTURE DE JOURNEE - " WS-DATE
           DISPLAY WS-SEP
           IF WS-CAISSE-OUV = 'N'
               DISPLAY "  Aucune caisse ouverte pour cette journee."
               GO TO 500-EXIT
           END-IF

           MOVE WS-SOLDE-OUV  TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-SOLDE
           DISPLAY "  Solde ouverture  : " WS-DISP-SOLDE " MGA"
           MOVE WS-TOT-ENT    TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-MNT
           DISPLAY "  Total entrees    : " WS-DISP-MNT " MGA"
           MOVE WS-TOT-SOR    TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-MNT
           DISPLAY "  Total sorties    : " WS-DISP-MNT " MGA"
           MOVE WS-SOLDE-ACT  TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-SOLDE
           DISPLAY "  Solde theorique  : " WS-DISP-SOLDE " MGA"
           IF WS-SOLDE-PHYS NOT = 0
               MOVE WS-SOLDE-PHYS TO WS-DISP-64
               MOVE WS-DISP-64    TO WS-DISP-MNT
               DISPLAY "  Solde inventaire : " WS-DISP-MNT " MGA"
               COMPUTE WS-ECART = WS-SOLDE-PHYS - WS-SOLDE-ACT
               MOVE WS-ECART TO WS-DISP-ECT
               DISPLAY "  Ecart            : " WS-DISP-ECT " MGA"
           END-IF
           DISPLAY WS-DASH
           DISPLAY "  Confirmer la cloture? (O/N): "
               WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           IF WS-CONFIRM NOT = 'O' AND WS-CONFIRM NOT = 'o'
               DISPLAY "  Cloture annulee."
               GO TO 500-EXIT
           END-IF

      *--- UPDATE caisse statut C ---
           MOVE WS-SOLDE-ACT  TO WS-SQL-SGN
           MOVE WS-ID-CAISSE  TO WS-SQL-NUM
           MOVE SPACES TO DB-SQL
           STRING "UPDATE caisses SET statut='C',"
               "heure_cloture='" WS-HEURE "',"
               "solde_theorique=" WS-SQL-SGN
               " WHERE id_caisse="
               FUNCTION TRIM(WS-SQL-NUM)
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

      *--- UPDATE solde agence ---
           MOVE SPACES TO DB-SQL
           STRING "UPDATE agences SET solde_actuel="
               WS-SQL-SGN
               " WHERE id_agence='"
               FUNCTION TRIM(WS-ID-AGENCE) "'"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

           MOVE 'N' TO WS-CAISSE-OUV
           DISPLAY "  CLOTURE EFFECTUEE AVEC SUCCES"
           DISPLAY "  Caisse fermee a " WS-HEURE.
       500-EXIT. CONTINUE.

      *============================================================
      * MODULE 6 : MOUVEMENTS DU JOUR
      *============================================================
       600-MOUVEMENTS-JOUR.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  MOUVEMENTS DU JOUR - " WS-DATE
           DISPLAY WS-SEP
           IF WS-CAISSE-OUV = 'N'
               DISPLAY "  Aucune caisse ouverte."
               GO TO 600-EXIT
           END-IF
           DISPLAY "  Heure  | Type | S | Montant"
               "        | Solde apres      | Libelle"
           DISPLAY WS-DASH
           MOVE 0 TO WS-CTR
           MOVE SPACES TO DB-SQL
           MOVE WS-ID-CAISSE TO WS-SQL-NUM
           STRING "SELECT heure_op,type_op,sens,montant,"
               "solde_apres,libelle FROM mouvements"
               " WHERE id_caisse="
               FUNCTION TRIM(WS-SQL-NUM)
               " ORDER BY id_mouvement"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           PERFORM UNTIL DB-RC NOT = 100
               CALL "db_step" RETURNING DB-RC
               IF DB-RC = 100
                   ADD 1 TO WS-CTR
                   MOVE 0 TO DB-COL
                   CALL "db_col_str10" USING DB-COL DB-COL-S10
                   MOVE 1 TO DB-COL
                   CALL "db_col_str40" USING DB-COL DB-COL-S40
                   MOVE DB-COL-S40(1:3) TO WS-TYPE-OP
                   MOVE 2 TO DB-COL
                   CALL "db_col_str10" USING DB-COL DB-COL-S12
                   MOVE DB-COL-S12(1:1) TO WS-SENS
                   MOVE 3 TO DB-COL
                   CALL "db_col_int64" USING DB-COL WS-MONTANT-INT
                   MOVE WS-MONTANT-INT TO WS-DISP-64
                   MOVE WS-DISP-64     TO WS-DISP-MNT
                   MOVE 4 TO DB-COL
                   CALL "db_col_int64" USING DB-COL WS-CALC-DISP
                   MOVE WS-CALC-DISP   TO WS-DISP-64
                   MOVE WS-DISP-64     TO WS-DISP-SOLDE
                   MOVE 5 TO DB-COL
                   CALL "db_col_str40" USING DB-COL WS-LIBELLE
                   DISPLAY "  " DB-COL-S10(1:8)
                       " | " WS-TYPE-OP
                       " | " WS-SENS
                       " | " WS-DISP-MNT
                       " | " WS-DISP-SOLDE
                       " | " WS-LIBELLE(1:20)
               END-IF
           END-PERFORM
           CALL "db_finalize" RETURNING DB-RC
           DISPLAY WS-DASH
           DISPLAY "  Total : " WS-CTR " mouvement(s)".
       600-EXIT. CONTINUE.

      *============================================================
      * MODULE 7 : RAPPORT JOURNALIER
      *============================================================
       700-RAPPORT-JOURNALIER.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  RAPPORT JOURNALIER - " WS-DATE
           DISPLAY "  Agence: " WS-NOM-AGENCE
           DISPLAY WS-SEP
           MOVE 0 TO WS-CTR
           MOVE SPACES TO DB-SQL
           STRING "SELECT c.id_caisse,c.date_journee,"
               "c.solde_ouverture,c.total_entrees,"
               "c.total_sorties,c.solde_theorique,"
               "c.statut,c.caissier,c.heure_ouverture,"
               "c.heure_cloture"
               " FROM caisses c WHERE c.id_agence='"
               FUNCTION TRIM(WS-ID-AGENCE)
               "' AND c.date_journee='" WS-DATE "'"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           CALL "db_step" RETURNING DB-RC
           IF DB-RC NOT = 100
               DISPLAY "  Aucune caisse pour ce jour."
               CALL "db_finalize" RETURNING DB-RC
               GO TO 700-EXIT
           END-IF

           MOVE 0 TO DB-COL
           CALL "db_col_int64" USING DB-COL DB-COL-INT
           MOVE 2 TO DB-COL
           CALL "db_col_int64" USING DB-COL WS-SOLDE-OUV
           MOVE 3 TO DB-COL
           CALL "db_col_int64" USING DB-COL WS-TOT-ENT
           MOVE 4 TO DB-COL
           CALL "db_col_int64" USING DB-COL WS-TOT-SOR
           MOVE 5 TO DB-COL
           CALL "db_col_int64" USING DB-COL WS-SOLDE-ACT
           MOVE 6 TO DB-COL
           CALL "db_col_str10" USING DB-COL DB-COL-S10
           MOVE 7 TO DB-COL
           CALL "db_col_str40" USING DB-COL WS-CAISSIER
           MOVE 8 TO DB-COL
           CALL "db_col_str10" USING DB-COL DB-COL-S12
           MOVE DB-COL-S12 TO WS-HH
           MOVE 9 TO DB-COL
           CALL "db_col_str10" USING DB-COL DB-COL-S12

           CALL "db_finalize" RETURNING DB-RC

           DISPLAY WS-DASH
           DISPLAY "  Caissier    : " WS-CAISSIER
           DISPLAY "  Ouverture   : " WS-HH
           DISPLAY "  Cloture     : " DB-COL-S12
           DISPLAY "  Statut      : " DB-COL-S10
           DISPLAY WS-DASH
           MOVE WS-SOLDE-OUV  TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-SOLDE
           DISPLAY "  Solde ouvert.: " WS-DISP-SOLDE " MGA"
           MOVE WS-TOT-ENT    TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-MNT
           DISPLAY "  Total entrees: " WS-DISP-MNT " MGA"
           MOVE WS-TOT-SOR    TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-MNT
           DISPLAY "  Total sorties: " WS-DISP-MNT " MGA"
           MOVE WS-SOLDE-ACT  TO WS-DISP-64
           MOVE WS-DISP-64    TO WS-DISP-SOLDE
           DISPLAY "  Solde theoriq: " WS-DISP-SOLDE " MGA"
           DISPLAY WS-DASH

      *--- Stats par type ---
           DISPLAY "  ENTREES PAR TYPE:"
           MOVE DB-COL-INT TO WS-SQL-NUM
           MOVE SPACES TO DB-SQL
           STRING "SELECT type_op,COUNT(*),SUM(montant)"
               " FROM mouvements WHERE id_caisse="
               FUNCTION TRIM(WS-SQL-NUM)
               " AND sens='E' GROUP BY type_op"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           PERFORM UNTIL DB-RC NOT = 100
               CALL "db_step" RETURNING DB-RC
               IF DB-RC = 100
                   MOVE 0 TO DB-COL
                   CALL "db_col_str10" USING DB-COL DB-COL-S10
                   MOVE 2 TO DB-COL
                   CALL "db_col_int64" USING DB-COL WS-CALC-DISP
                   MOVE WS-CALC-DISP TO WS-DISP-64
                   MOVE WS-DISP-64   TO WS-DISP-MNT
                   DISPLAY "    " DB-COL-S10(1:3)
                       " : " WS-DISP-MNT " MGA"
               END-IF
           END-PERFORM
           CALL "db_finalize" RETURNING DB-RC

           DISPLAY "  SORTIES PAR TYPE:"
           MOVE SPACES TO DB-SQL
           STRING "SELECT type_op,COUNT(*),SUM(montant)"
               " FROM mouvements WHERE id_caisse="
               FUNCTION TRIM(WS-SQL-NUM)
               " AND sens='S' GROUP BY type_op"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_prepare" USING DB-SQL RETURNING DB-RC
           PERFORM UNTIL DB-RC NOT = 100
               CALL "db_step" RETURNING DB-RC
               IF DB-RC = 100
                   MOVE 0 TO DB-COL
                   CALL "db_col_str10" USING DB-COL DB-COL-S10
                   MOVE 2 TO DB-COL
                   CALL "db_col_int64" USING DB-COL WS-CALC-DISP
                   MOVE WS-CALC-DISP TO WS-DISP-64
                   MOVE WS-DISP-64   TO WS-DISP-MNT
                   DISPLAY "    " DB-COL-S10(1:3)
                       " : " WS-DISP-MNT " MGA"
               END-IF
           END-PERFORM
           CALL "db_finalize" RETURNING DB-RC
           DISPLAY WS-SEP.
       700-EXIT. CONTINUE.

      *============================================================
      * MODULE 8 : HISTORIQUE PAR TYPE
      *============================================================
       800-HISTORIQUE-TYPE.
           DISPLAY SPACES
           DISPLAY WS-SEP
           DISPLAY "  HISTORIQUE PAR TYPE - " WS-ID-AGENCE
           DISPLAY WS-SEP
           DISPLAY "  1. Tous les mouvements (7 jours)"
           DISPLAY "  2. Entrees uniquement"
           DISPLAY "  3. Sorties uniquement"
           DISPLAY "  4. Totaux par journee"
           DISPLAY "  Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX2
           DISPLAY WS-DASH
           MOVE 0 TO WS-CTR

           EVALUATE WS-CHOIX2
           WHEN 1
               MOVE SPACES TO DB-SQL
               STRING "SELECT date_op,heure_op,type_op,sens,"
                   "montant,libelle FROM mouvements"
                   " WHERE id_agence='"
                   FUNCTION TRIM(WS-ID-AGENCE)
                   "' ORDER BY id_mouvement DESC LIMIT 50"
                   DELIMITED SIZE INTO DB-SQL
               CALL "db_prepare" USING DB-SQL RETURNING DB-RC
               DISPLAY "  Date       | H     | Tp |S"
                   "| Montant          | Libelle"
               DISPLAY WS-DASH
               PERFORM UNTIL DB-RC NOT = 100
                   CALL "db_step" RETURNING DB-RC
                   IF DB-RC = 100
                       ADD 1 TO WS-CTR
                       MOVE 0 TO DB-COL
                       CALL "db_col_str10" USING DB-COL
                           DB-COL-S10
                       MOVE 1 TO DB-COL
                       CALL "db_col_str10" USING DB-COL
                           DB-COL-S12
                       MOVE 2 TO DB-COL
                       CALL "db_col_str10" USING DB-COL
                           DB-COL-TXT
                       MOVE WS-SENS TO WS-TYPE-OP
                       MOVE 3 TO DB-COL
                       CALL "db_col_str10" USING DB-COL
                           DB-COL-S40
                       MOVE DB-COL-S40(1:1) TO WS-SENS
                       MOVE 4 TO DB-COL
                       CALL "db_col_int64" USING DB-COL
                           WS-MONTANT-INT
                       MOVE WS-MONTANT-INT TO WS-DISP-64
                       MOVE WS-DISP-64     TO WS-DISP-MNT
                       MOVE 5 TO DB-COL
                       CALL "db_col_str40" USING DB-COL
                           WS-LIBELLE
                       DISPLAY "  " DB-COL-S10
                           " | " DB-COL-S12(1:5)
                           " | " DB-COL-TXT(1:3)
                           " |" WS-SENS
                           "| " WS-DISP-MNT
                           " | " WS-LIBELLE(1:18)
                   END-IF
               END-PERFORM
               CALL "db_finalize" RETURNING DB-RC

           WHEN 4
               MOVE SPACES TO DB-SQL
               STRING "SELECT date_op,"
                   "SUM(CASE WHEN sens='E' THEN montant ELSE 0 END),"
                   "SUM(CASE WHEN sens='S' THEN montant ELSE 0 END),"
                   "COUNT(*) FROM mouvements"
                   " WHERE id_agence='"
                   FUNCTION TRIM(WS-ID-AGENCE)
                   "' GROUP BY date_op ORDER BY date_op DESC"
                   " LIMIT 30"
                   DELIMITED SIZE INTO DB-SQL
               CALL "db_prepare" USING DB-SQL RETURNING DB-RC
               DISPLAY "  Date       | Entrees          "
                   "| Sorties          | Nb"
               DISPLAY WS-DASH
               PERFORM UNTIL DB-RC NOT = 100
                   CALL "db_step" RETURNING DB-RC
                   IF DB-RC = 100
                       ADD 1 TO WS-CTR
                       MOVE 0 TO DB-COL
                       CALL "db_col_str10" USING DB-COL
                           DB-COL-S10
                       MOVE 1 TO DB-COL
                       CALL "db_col_int64" USING DB-COL
                           WS-TOT-ENT
                       MOVE WS-TOT-ENT TO WS-DISP-64
                       MOVE WS-DISP-64 TO WS-DISP-MNT
                       MOVE 2 TO DB-COL
                       CALL "db_col_int64" USING DB-COL
                           WS-TOT-SOR
                       MOVE WS-TOT-SOR TO WS-DISP-64
                       MOVE WS-DISP-64 TO WS-DISP-SOLDE
                       MOVE 3 TO DB-COL
                       CALL "db_col_int64" USING DB-COL
                           WS-CALC-DISP
                       DISPLAY "  " DB-COL-S10
                           " | " WS-DISP-MNT
                           " | " WS-DISP-SOLDE
                           " | " WS-CALC-DISP
                   END-IF
               END-PERFORM
               CALL "db_finalize" RETURNING DB-RC

           WHEN OTHER
               DISPLAY "  Choix non implemente."
           END-EVALUATE

           DISPLAY WS-DASH
           DISPLAY "  Total : " WS-CTR " ligne(s)".
       800-EXIT. CONTINUE.

      *============================================================
      * UTILITAIRES : WRITE MOUVEMENT + UPDATE CAISSE
      *============================================================
       999-WRITE-MOUVEMENT.
           MOVE WS-ID-CAISSE   TO WS-SQL-NUM
           MOVE WS-MONTANT-INT TO WS-SQL-SGN
           MOVE WS-SOLDE-ACT   TO WS-DISP-64
           MOVE SPACES TO DB-SQL
           STRING "INSERT INTO mouvements("
               "id_caisse,id_agence,date_op,heure_op,"
               "type_op,sens,montant,solde_apres,"
               "libelle,reference,operateur) VALUES("
               FUNCTION TRIM(WS-SQL-NUM) ",'"
               FUNCTION TRIM(WS-ID-AGENCE) "','"
               WS-DATE "','"
               WS-HEURE "','"
               FUNCTION TRIM(WS-TYPE-OP) "','"
               WS-SENS "',"
               FUNCTION TRIM(WS-SQL-SGN) ","
               WS-DISP-64 ",'"
               FUNCTION TRIM(WS-LIBELLE) "','"
               FUNCTION TRIM(WS-REF) "','"
               FUNCTION TRIM(WS-CAISSIER) "')"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC.

       999-UPDATE-CAISSE.
           MOVE WS-TOT-ENT   TO WS-SQL-NUM
           MOVE WS-TOT-SOR   TO WS-DISP-64
           MOVE WS-SOLDE-ACT TO WS-SQL-SGN
           MOVE WS-ID-CAISSE TO WS-CALC-DISP
           MOVE SPACES TO DB-SQL
           STRING "UPDATE caisses SET total_entrees="
               FUNCTION TRIM(WS-SQL-NUM) ",total_sorties="
               WS-DISP-64 ",solde_theorique="
               WS-SQL-SGN
               " WHERE id_caisse=" WS-CALC-DISP
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC.

       999-UPDATE-CAISSE-PHYS.
           MOVE WS-SOLDE-PHYS TO WS-SQL-NUM
           MOVE WS-ECART      TO WS-SQL-SGN
           MOVE WS-ID-CAISSE  TO WS-CALC-DISP
           MOVE SPACES TO DB-SQL
           STRING "UPDATE caisses SET solde_physique="
               FUNCTION TRIM(WS-SQL-NUM) ",ecart="
               WS-SQL-SGN
               " WHERE id_caisse=" WS-CALC-DISP
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC.

      *============================================================
       099-CLOSE.
           CALL "db_close" RETURNING DB-RC
           DISPLAY "  Au revoir - Branch Cash Management System"
           DISPLAY WS-SEP.
