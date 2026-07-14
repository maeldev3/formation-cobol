      *****************************************************
      * DCLCLIENTS.CPY  (style DCLGEN)
      * Declaration DB2 de la table Z74830.CLIENTS
      * + variables hote COBOL associees
      *****************************************************
           EXEC SQL DECLARE Z74830.CLIENTS TABLE
           ( CLI_ID           INTEGER          NOT NULL,
             CLI_NOM          CHAR(20)         NOT NULL,
             CLI_PRENOM       CHAR(20)         NOT NULL,
             CLI_ADRESSE      CHAR(30)         NOT NULL,
             CLI_VILLE        CHAR(20)         NOT NULL,
             CLI_SOLDE        DECIMAL(9,2)     NOT NULL,
             CLI_STATUT       CHAR(1)          NOT NULL,
             CLI_DATE_MAJ     DATE             NOT NULL
           ) END-EXEC.

       01  DCLCLIENTS.
           10  CLI-ID              PIC S9(9)     COMP.
           10  CLI-NOM             PIC X(20).
           10  CLI-PRENOM          PIC X(20).
           10  CLI-ADRESSE         PIC X(30).
           10  CLI-VILLE           PIC X(20).
           10  CLI-SOLDE           PIC S9(7)V99  COMP-3.
           10  CLI-STATUT          PIC X(01).
           10  CLI-DATE-MAJ        PIC X(10).
      *        Format DB2 DATE en variable hote CHAR(10) : 'YYYY-MM-DD'
