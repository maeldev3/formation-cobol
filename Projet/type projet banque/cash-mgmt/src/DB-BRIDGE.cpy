      *============================================================
      * DB-BRIDGE.cpy - Copybook pour pont C/SQLite
      * Branch Cash Management System
      *============================================================
      *--- Chemin base SQLite ---
       01  DB-PATH        PIC X(200) VALUE "db/caisse.db".

      *--- Code retour SQLite ---
       01  DB-RC          PIC S9(09) COMP-5 VALUE 0.

      *--- SQL statement buffer ---
       01  DB-SQL         PIC X(2000) VALUE SPACES.

      *--- Colonne courante (index 0-based) ---
       01  DB-COL         PIC S9(09) COMP-5 VALUE 0.

      *--- Buffers de reception colonnes ---
       01  DB-COL-TXT     PIC X(100) VALUE SPACES.
       01  DB-COL-S40     PIC X(40)  VALUE SPACES.
       01  DB-COL-S12     PIC X(12)  VALUE SPACES.
       01  DB-COL-S10     PIC X(10)  VALUE SPACES.
       01  DB-COL-INT     PIC S9(18) COMP-5 VALUE 0.
       01  DB-ROWID       PIC S9(18) COMP-5 VALUE 0.
       01  DB-CHANGES     PIC S9(09) COMP-5 VALUE 0.
