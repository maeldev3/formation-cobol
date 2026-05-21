-- =====================================================
-- BASE DE DONNEES - GESTION HOTELIERE
-- =====================================================

-- Suppression des tables existantes
DROP TABLE IF EXISTS PAIEMENTS;
DROP TABLE IF EXISTS RESERVATIONS;
DROP TABLE IF EXISTS CHAMBRES;
DROP TABLE IF EXISTS CLIENTS;
DROP TABLE IF EXISTS TYPES_CHAMBRE;

-- =====================================================
-- TABLE TYPES_CHAMBRE (Référentiel)
-- =====================================================
CREATE TABLE TYPES_CHAMBRE (
    ID_TYPE     TEXT PRIMARY KEY,
    LIBELLE     TEXT NOT NULL,
    PRIX_BASE   REAL NOT NULL,
    CAPACITE    INTEGER,
    DESCRIPTION TEXT
);

-- =====================================================
-- TABLE CLIENTS
-- =====================================================
CREATE TABLE CLIENTS (
    ID_CLIENT   TEXT PRIMARY KEY,
    NOM         TEXT NOT NULL,
    PRENOM      TEXT NOT NULL,
    EMAIL       TEXT UNIQUE,
    TELEPHONE   TEXT NOT NULL,
    ADRESSE     TEXT,
    VILLE       TEXT,
    CODE_POSTAL TEXT,
    DATE_INSCRIPTION TEXT,
    STATUT      TEXT DEFAULT 'ACTIF'
);

-- =====================================================
-- TABLE CHAMBRES
-- =====================================================
CREATE TABLE CHAMBRES (
    ID_CHAMBRE  TEXT PRIMARY KEY,
    NUMERO      TEXT NOT NULL UNIQUE,
    ID_TYPE     TEXT,
    ETAGE       INTEGER,
    STATUT      TEXT DEFAULT 'DISPONIBLE',
    DERNIER_NETTOYAGE TEXT,
    REMARQUES   TEXT,
    FOREIGN KEY (ID_TYPE) REFERENCES TYPES_CHAMBRE(ID_TYPE)
);

-- =====================================================
-- TABLE RESERVATIONS
-- =====================================================
CREATE TABLE RESERVATIONS (
    ID_RESERVATION TEXT PRIMARY KEY,
    ID_CLIENT      TEXT,
    ID_CHAMBRE     TEXT,
    DATE_DEBUT     TEXT NOT NULL,
    DATE_FIN       TEXT NOT NULL,
    NB_PERSONNES   INTEGER DEFAULT 1,
    STATUT         TEXT DEFAULT 'CONFIRMEE',
    DATE_RESERVATION TEXT,
    MONTANT_TOTAL  REAL,
    REMARQUES      TEXT,
    FOREIGN KEY (ID_CLIENT) REFERENCES CLIENTS(ID_CLIENT),
    FOREIGN KEY (ID_CHAMBRE) REFERENCES CHAMBRES(ID_CHAMBRE)
);

-- =====================================================
-- TABLE PAIEMENTS
-- =====================================================
CREATE TABLE PAIEMENTS (
    ID_PAIEMENT  TEXT PRIMARY KEY,
    ID_RESERVATION TEXT,
    MONTANT      REAL NOT NULL,
    DATE_PAIEMENT TEXT,
    MODE_PAIEMENT TEXT,
    STATUT       TEXT DEFAULT 'VALIDE',
    REFERENCE    TEXT,
    FOREIGN KEY (ID_RESERVATION) REFERENCES RESERVATIONS(ID_RESERVATION)
);

-- =====================================================
-- INDEXES
-- =====================================================
CREATE INDEX idx_clients_nom ON CLIENTS(NOM);
CREATE INDEX idx_reservations_dates ON RESERVATIONS(DATE_DEBUT, DATE_FIN);
CREATE INDEX idx_reservations_client ON RESERVATIONS(ID_CLIENT);
CREATE INDEX idx_chambres_statut ON CHAMBRES(STATUT);

-- =====================================================
-- VUES
-- =====================================================
CREATE VIEW VUE_OCCUPATION AS
SELECT 
    CH.ID_CHAMBRE,
    CH.NUMERO,
    TCH.LIBELLE AS TYPE_CHAMBRE,
    CL.NOM AS CLIENT_NOM,
    CL.PRENOM AS CLIENT_PRENOM,
    RES.DATE_DEBUT,
    RES.DATE_FIN,
    RES.STATUT
FROM RESERVATIONS RES
JOIN CHAMBRES CH ON RES.ID_CHAMBRE = CH.ID_CHAMBRE
JOIN CLIENTS CL ON RES.ID_CLIENT = CL.ID_CLIENT
JOIN TYPES_CHAMBRE TCH ON CH.ID_TYPE = TCH.ID_TYPE
WHERE RES.STATUT IN ('CONFIRMEE', 'EN_COURS')
AND DATE_FIN >= date('now');

CREATE VIEW VUE_CA_MENSUEL AS
SELECT 
    strftime('%Y-%m', DATE_PAIEMENT) AS MOIS,
    SUM(MONTANT) AS CA_TOTAL,
    COUNT(*) AS NB_PAIEMENTS
FROM PAIEMENTS
GROUP BY strftime('%Y-%m', DATE_PAIEMENT);
