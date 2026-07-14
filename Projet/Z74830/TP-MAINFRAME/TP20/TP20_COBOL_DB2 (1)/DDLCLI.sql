------------------------------------------------------------
-- TP20 - DDL DB2
-- Creation de la base, du tablespace, de la table CLIENTS
-- et de son index unique
------------------------------------------------------------

CREATE DATABASE Z74830DB;

CREATE TABLESPACE CLITS
       IN Z74830DB
       USING STOGROUP SYSDEFLT
       PRIQTY 720
       SECQTY 720
       BUFFERPOOL BP0
       LOCKSIZE ROW
       SEGSIZE 4;

CREATE TABLE Z74830.CLIENTS
     ( CLI_ID           INTEGER         NOT NULL,
       CLI_NOM          CHAR(20)        NOT NULL,
       CLI_PRENOM       CHAR(20)        NOT NULL,
       CLI_ADRESSE      CHAR(30)        NOT NULL WITH DEFAULT,
       CLI_VILLE        CHAR(20)        NOT NULL WITH DEFAULT,
       CLI_SOLDE        DECIMAL(9,2)    NOT NULL WITH DEFAULT,
       CLI_STATUT       CHAR(1)         NOT NULL WITH DEFAULT 'A',
       CLI_DATE_MAJ     DATE            NOT NULL WITH DEFAULT,
       PRIMARY KEY (CLI_ID)
     )
     IN Z74830DB.CLITS;

CREATE UNIQUE INDEX Z74830.XCLIENTS
       ON Z74830.CLIENTS (CLI_ID)
       USING STOGROUP SYSDEFLT
       PRIQTY 360
       SECQTY 360
       BUFFERPOOL BP0
       CLUSTER;

COMMIT;
