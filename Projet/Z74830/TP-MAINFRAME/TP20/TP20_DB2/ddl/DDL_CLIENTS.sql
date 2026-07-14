-------------------------------------------------------------------
-- TP20 : Création de la table CLIENTS
-------------------------------------------------------------------
-- Adapter DATABASE1 / TABLESPACE1 / STOGROUP au nom réel de ton
-- environnement DB2 (demande à l'admin DBA si tu ne les connais pas)
-------------------------------------------------------------------

CREATE TABLE CLIENTS
   (CLI_ID          INTEGER       NOT NULL,
    CLI_NOM         CHAR(20)      NOT NULL,
    CLI_PRENOM      CHAR(20)      NOT NULL,
    CLI_SALAIRE     DECIMAL(9,2)  NOT NULL,
    CLI_DATE_NAIS   DATE,
    PRIMARY KEY (CLI_ID)
   )
   IN DATABASE1.TABLESPACE1;

CREATE UNIQUE INDEX IX_CLIENTS_ID
   ON CLIENTS (CLI_ID)
   USING STOGROUP SYSDEFLT
   PRIORQTY 720
   SECQTY   720
   ERASE NO
   BUFFERPOOL BP0
   CLOSE NO;

-- Quelques lignes de test (optionnel, pratique pour valider le SELECT/CURSOR)
INSERT INTO CLIENTS VALUES (100, 'MARTIN',   'PAUL',   28000.00, '1985-03-12');
INSERT INTO CLIENTS VALUES (101, 'BERNARD',  'LUCIE',  35000.00, '1990-07-25');
INSERT INTO CLIENTS VALUES (102, 'PETIT',    'MARIE',  42000.00, '1978-11-02');
INSERT INTO CLIENTS VALUES (103, 'DUBOIS',   'ALAIN',  22000.00, '1995-01-30');

COMMIT;
