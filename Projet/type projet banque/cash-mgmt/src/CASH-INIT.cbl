*============================================================
      * CASH-INIT.cbl - Initialisation base SQLite
      * Branch Cash Management System
      * Cree les tables et insere des donnees de demo
      *============================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASH-INIT.
       AUTHOR. GnuCOBOL-CashMgmt.

       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
           COPY "DB-BRIDGE.cpy".

       PROCEDURE DIVISION.
       000-MAIN.
           DISPLAY "================================================"
           DISPLAY "  CASH-INIT : Initialisation base SQLite"
           DISPLAY "================================================"

           CALL "db_open" USING DB-PATH
               RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR ouverture DB: " DB-RC
               STOP RUN
           END-IF
           DISPLAY "  Base: " DB-PATH

           PERFORM 100-CREATE-TABLES
           PERFORM 200-INSERT-DEMO-DATA
           PERFORM 999-CLOSE-DB

           DISPLAY "  Initialisation terminee avec succes."
           DISPLAY "================================================"
           STOP RUN.

      *------------------------------------------------------------
       100-CREATE-TABLES.
      *--- Table AGENCES ---
           MOVE SPACES TO DB-SQL
           STRING
               "CREATE TABLE IF NOT EXISTS agences ("
               "id_agence TEXT PRIMARY KEY,"
               "nom TEXT NOT NULL,"
               "ville TEXT,"
               "solde_ouverture INTEGER DEFAULT 0,"
               "solde_actuel INTEGER DEFAULT 0,"
               "date_crea TEXT,"
               "statut TEXT DEFAULT 'A'"
               ")"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR CREATE agences: " DB-RC
           ELSE
               DISPLAY "  TABLE agences : OK"
           END-IF

      *--- Table CAISSES ---
           MOVE SPACES TO DB-SQL
           STRING
               "CREATE TABLE IF NOT EXISTS caisses ("
               "id_caisse INTEGER PRIMARY KEY AUTOINCREMENT,"
               "id_agence TEXT NOT NULL,"
               "date_journee TEXT NOT NULL,"
               "solde_ouverture INTEGER DEFAULT 0,"
               "total_entrees INTEGER DEFAULT 0,"
               "total_sorties INTEGER DEFAULT 0,"
               "solde_theorique INTEGER DEFAULT 0,"
               "solde_physique INTEGER DEFAULT 0,"
               "ecart INTEGER DEFAULT 0,"
               "statut TEXT DEFAULT 'O',"
               "heure_ouverture TEXT,"
               "heure_cloture TEXT,"
               "caissier TEXT,"
               "observations TEXT"
               ")"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR CREATE caisses: " DB-RC
           ELSE
               DISPLAY "  TABLE caisses : OK"
           END-IF

      *--- Table MOUVEMENTS ---
           MOVE SPACES TO DB-SQL
           STRING
               "CREATE TABLE IF NOT EXISTS mouvements ("
               "id_mouvement INTEGER PRIMARY KEY AUTOINCREMENT,"
               "id_caisse INTEGER NOT NULL,"
               "id_agence TEXT NOT NULL,"
               "date_op TEXT NOT NULL,"
               "heure_op TEXT NOT NULL,"
               "type_op TEXT NOT NULL,"
               "sens TEXT NOT NULL,"
               "montant INTEGER NOT NULL,"
               "solde_apres INTEGER NOT NULL,"
               "libelle TEXT,"
               "reference TEXT,"
               "operateur TEXT,"
               "valide INTEGER DEFAULT 1"
               ")"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR CREATE mouvements: " DB-RC
           ELSE
               DISPLAY "  TABLE mouvements : OK"
           END-IF

      *--- Table BILLETS (inventaire especes) ---
           MOVE SPACES TO DB-SQL
           STRING
               "CREATE TABLE IF NOT EXISTS billets ("
               "id_billet INTEGER PRIMARY KEY AUTOINCREMENT,"
               "id_caisse INTEGER NOT NULL,"
               "denomination INTEGER NOT NULL,"
               "quantite INTEGER DEFAULT 0,"
               "montant INTEGER DEFAULT 0,"
               "type_inventaire TEXT DEFAULT 'C'"
               ")"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           IF DB-RC NOT = 0
               DISPLAY "ERREUR CREATE billets: " DB-RC
           ELSE
               DISPLAY "  TABLE billets : OK"
           END-IF

      *--- Index utiles ---
           MOVE "CREATE INDEX IF NOT EXISTS idx_mvt_caisse"
               & " ON mouvements(id_caisse)"
               TO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           MOVE "CREATE INDEX IF NOT EXISTS idx_mvt_date"
               & " ON mouvements(date_op)"
               TO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC
           DISPLAY "  INDEX : OK".

      *------------------------------------------------------------
       200-INSERT-DEMO-DATA.
           DISPLAY "  Insertion donnees demo..."

      *--- Agences ---
           MOVE SPACES TO DB-SQL
           STRING "INSERT OR IGNORE INTO agences VALUES("
               "'AG001','AGENCE ANTANANARIVO CENTRE',"
               "'Antananarivo',50000000,50000000,"
               "'2026-01-01','A')"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

           MOVE SPACES TO DB-SQL
           STRING "INSERT OR IGNORE INTO agences VALUES("
               "'AG002','AGENCE TOAMASINA',"
               "'Toamasina',30000000,30000000,"
               "'2026-01-01','A')"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

           MOVE SPACES TO DB-SQL
           STRING "INSERT OR IGNORE INTO agences VALUES("
               "'AG003','AGENCE FIANARANTSOA',"
               "'Fianarantsoa',20000000,20000000,"
               "'2026-01-01','A')"
               DELIMITED SIZE INTO DB-SQL
           CALL "db_exec" USING DB-SQL RETURNING DB-RC

           DISPLAY "  3 agences inserees : OK".

       999-CLOSE-DB.
           CALL "db_close" RETURNING DB-RC.
