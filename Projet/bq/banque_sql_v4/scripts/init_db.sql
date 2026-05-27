-- =====================================================
-- SYSTÈME BANCAIRE PROFESSIONNEL V4.0
-- BASE DE DONNÉES SQLITE
-- =====================================================

-- Activation des clés étrangères
PRAGMA foreign_keys = ON;

-- =====================================================
-- TABLE: clients
-- =====================================================
CREATE TABLE IF NOT EXISTS clients (
    id_client       TEXT PRIMARY KEY,
    civilite        TEXT CHECK(civilite IN ('M', 'MME', 'MLLE')),
    nom             TEXT NOT NULL,
    prenom          TEXT NOT NULL,
    date_naissance  DATE NOT NULL,
    lieu_naissance  TEXT,
    nationalite     TEXT DEFAULT 'FRANCAISE',
    adresse         TEXT NOT NULL,
    code_postal     TEXT NOT NULL,
    ville           TEXT NOT NULL,
    pays            TEXT DEFAULT 'FRANCE',
    telephone       TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    profession      TEXT,
    revenu_annuel   DECIMAL(12,2),
    patrimoine      DECIMAL(15,2),
    score_credit    INTEGER DEFAULT 0,
    statut          TEXT DEFAULT 'ACTIF',
    date_creation   DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modification DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_by      TEXT,
    modified_by     TEXT
);

-- =====================================================
-- TABLE: comptes
-- =====================================================
CREATE TABLE IF NOT EXISTS comptes (
    id_compte       TEXT PRIMARY KEY,
    id_client       TEXT NOT NULL,
    type_compte     TEXT NOT NULL CHECK(type_compte IN ('COURANT', 'EPARGNE', 'TERME', 'TITRES', 'DEVISES')),
    devise         TEXT DEFAULT 'EUR',
    solde          DECIMAL(15,2) DEFAULT 0.00,
    decouvert_autorise DECIMAL(10,2) DEFAULT 0.00,
    taux_interet   DECIMAL(5,2) DEFAULT 0.00,
    frais_tenue    DECIMAL(5,2) DEFAULT 0.00,
    statut         TEXT DEFAULT 'ACTIF',
    date_ouverture DATE NOT NULL,
    date_fermeture DATE,
    agence_ouverture TEXT,
    dernier_mouvement DATETIME,
    FOREIGN KEY (id_client) REFERENCES clients(id_client)
);

-- =====================================================
-- TABLE: cartes
-- =====================================================
CREATE TABLE IF NOT EXISTS cartes (
    id_carte        TEXT PRIMARY KEY,
    id_compte       TEXT NOT NULL,
    type_carte      TEXT NOT NULL CHECK(type_carte IN ('CLASSIC', 'GOLD', 'PLATINUM', 'BLACK', 'BUSINESS')),
    numero_carte    TEXT UNIQUE NOT NULL,
    cryptogramme    TEXT NOT NULL,
    date_expiration DATE NOT NULL,
    plafond_mensuel DECIMAL(10,2) NOT NULL,
    plafond_retrait DECIMAL(8,2),
    plafond_paiement DECIMAL(10,2),
    sans_contact    INTEGER DEFAULT 1,
    assurable       INTEGER DEFAULT 1,
    statut          TEXT DEFAULT 'ACTIF',
    date_emission   DATE NOT NULL,
    date_blocage    DATE,
    raison_blocage  TEXT,
    FOREIGN KEY (id_compte) REFERENCES comptes(id_compte)
);

-- =====================================================
-- TABLE: transactions
-- =====================================================
CREATE TABLE IF NOT EXISTS transactions (
    id_transaction  TEXT PRIMARY KEY,
    id_compte       TEXT NOT NULL,
    type_transaction TEXT NOT NULL CHECK(type_transaction IN ('DEPOT', 'RETRAIT', 'VIREMENT', 'PAIEMENT_CB', 'PRELEVEMENT', 'INTERET', 'FRAIS')),
    montant         DECIMAL(12,2) NOT NULL,
    devise         TEXT DEFAULT 'EUR',
    date_transaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_valeur     DATE,
    description     TEXT,
    reference_externe TEXT,
    id_compte_dest  TEXT,
    statut          TEXT DEFAULT 'VALIDEE',
    code_autorisation TEXT,
    agence          TEXT,
    point_vente     TEXT,
    latitude        REAL,
    longitude       REAL,
    ip_address      TEXT,
    device_info     TEXT,
    FOREIGN KEY (id_compte) REFERENCES comptes(id_compte),
    FOREIGN KEY (id_compte_dest) REFERENCES comptes(id_compte)
);

-- =====================================================
-- TABLE: credits
-- =====================================================
CREATE TABLE IF NOT EXISTS credits (
    id_credit       TEXT PRIMARY KEY,
    id_compte       TEXT NOT NULL,
    type_credit     TEXT NOT NULL CHECK(type_credit IN ('CONSOMMATION', 'AUTO', 'IMMOBILIER', 'PROFESSIONNEL', 'LOMBARD')),
    montant         DECIMAL(15,2) NOT NULL,
    taux_annuel     DECIMAL(5,2) NOT NULL,
    duree_mois      INTEGER NOT NULL,
    mensualite      DECIMAL(10,2) NOT NULL,
    capital_restant DECIMAL(15,2) NOT NULL,
    date_octroi     DATE NOT NULL,
    date_premiere_echeance DATE,
    date_derniere_echeance DATE,
    statut          TEXT DEFAULT 'ACTIF',
    garantie        TEXT,
    assure          INTEGER DEFAULT 0,
    taux_assurance  DECIMAL(5,2),
    frais_dossier   DECIMAL(10,2),
    penalite_remb_anticipe DECIMAL(5,2),
    conseiller      TEXT,
    FOREIGN KEY (id_compte) REFERENCES comptes(id_compte)
);

-- =====================================================
-- TABLE: echeances
-- =====================================================
CREATE TABLE IF NOT EXISTS echeances (
    id_echeance     TEXT PRIMARY KEY,
    id_credit       TEXT NOT NULL,
    numero_echeance INTEGER NOT NULL,
    date_echeance   DATE NOT NULL,
    montant_capital DECIMAL(10,2),
    montant_interet DECIMAL(10,2),
    montant_assurance DECIMAL(10,2),
    montant_total   DECIMAL(10,2) NOT NULL,
    statut          TEXT DEFAULT 'EN_ATTENTE',
    date_paiement   DATE,
    id_transaction  TEXT,
    FOREIGN KEY (id_credit) REFERENCES credits(id_credit),
    FOREIGN KEY (id_transaction) REFERENCES transactions(id_transaction)
);

-- =====================================================
-- TABLE: agences
-- =====================================================
CREATE TABLE IF NOT EXISTS agences (
    id_agence       TEXT PRIMARY KEY,
    code_agence     TEXT UNIQUE,
    nom_agence      TEXT NOT NULL,
    adresse         TEXT NOT NULL,
    code_postal     TEXT NOT NULL,
    ville           TEXT NOT NULL,
    telephone       TEXT NOT NULL,
    email           TEXT NOT NULL,
    gerant          TEXT,
    nombre_employes INTEGER DEFAULT 0,
    capital         DECIMAL(15,2),
    region          TEXT,
    statut          TEXT DEFAULT 'ACTIF',
    date_creation   DATE,
    horaires        TEXT,
    coord_gps       TEXT
);

-- =====================================================
-- TABLE: employes
-- =====================================================
CREATE TABLE IF NOT EXISTS employes (
    id_employe      TEXT PRIMARY KEY,
    id_agence       TEXT NOT NULL,
    nom             TEXT NOT NULL,
    prenom          TEXT NOT NULL,
    fonction        TEXT NOT NULL,
    email           TEXT UNIQUE NOT NULL,
    telephone       TEXT,
    date_embauche   DATE NOT NULL,
    salaire_base    DECIMAL(10,2),
    prime           DECIMAL(10,2),
    login           TEXT UNIQUE NOT NULL,
    mot_de_passe    TEXT NOT NULL,
    role            TEXT CHECK(role IN ('ADMIN', 'MANAGER', 'AGENT', 'AUDITEUR', 'SUPPORT')),
    statut          TEXT DEFAULT 'ACTIF',
    date_creation   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_agence) REFERENCES agences(id_agence)
);

-- =====================================================
-- TABLE: alertes
-- =====================================================
CREATE TABLE IF NOT EXISTS alertes (
    id_alerte       TEXT PRIMARY KEY,
    id_client       TEXT,
    id_compte       TEXT,
    type_alerte     TEXT NOT NULL,
    niveau          TEXT CHECK(niveau IN ('INFO', 'WARNING', 'CRITICAL')),
    message         TEXT NOT NULL,
    date_alerte     DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut          TEXT DEFAULT 'ACTIVE',
    date_traitement DATETIME,
    traite_par      TEXT,
    FOREIGN KEY (id_client) REFERENCES clients(id_client),
    FOREIGN KEY (id_compte) REFERENCES comptes(id_compte),
    FOREIGN KEY (traite_par) REFERENCES employes(id_employe)
);

-- =====================================================
-- TABLE: logs_audit
-- =====================================================
CREATE TABLE IF NOT EXISTS logs_audit (
    id_log          INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur     TEXT NOT NULL,
    action          TEXT NOT NULL,
    table_name      TEXT,
    record_id       TEXT,
    anciennes_valeurs TEXT,
    nouvelles_valeurs TEXT,
    ip_address      TEXT,
    date_action     DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- INDEXES pour performance
-- =====================================================
CREATE INDEX idx_clients_nom ON clients(nom, prenom);
CREATE INDEX idx_clients_email ON clients(email);
CREATE INDEX idx_comptes_client ON comptes(id_client);
CREATE INDEX idx_comptes_type ON comptes(type_compte);
CREATE INDEX idx_transactions_compte ON transactions(id_compte);
CREATE INDEX idx_transactions_date ON transactions(date_transaction);
CREATE INDEX idx_transactions_statut ON transactions(statut);
CREATE INDEX idx_cartes_compte ON cartes(id_compte);
CREATE INDEX idx_credits_compte ON credits(id_compte);
CREATE INDEX idx_credits_statut ON credits(statut);
CREATE INDEX idx_echeances_credit ON echeances(id_credit);
CREATE INDEX idx_echeances_date ON echeances(date_echeance);
CREATE INDEX idx_alertes_client ON alertes(id_client);
CREATE INDEX idx_alertes_statut ON alertes(statut);

-- =====================================================
-- VUES pour reporting
-- =====================================================
CREATE VIEW vue_solde_client AS
SELECT 
    c.id_client,
    c.nom,
    c.prenom,
    COUNT(cpt.id_compte) as nb_comptes,
    SUM(cpt.solde) as total_soldes,
    MAX(cpt.solde) as max_solde,
    AVG(cpt.solde) as avg_solde
FROM clients c
LEFT JOIN comptes cpt ON c.id_client = cpt.id_client
GROUP BY c.id_client;

CREATE VIEW vue_transactions_journalieres AS
SELECT 
    date(date_transaction) as jour,
    type_transaction,
    COUNT(*) as nb_transactions,
    SUM(montant) as total_montant
FROM transactions
GROUP BY date(date_transaction), type_transaction;

CREATE VIEW vue_credits_client AS
SELECT 
    c.id_client,
    c.nom,
    c.prenom,
    COUNT(cr.id_credit) as nb_credits,
    SUM(cr.montant) as total_emprunte,
    SUM(cr.capital_restant) as total_restant
FROM clients c
LEFT JOIN comptes cpt ON c.id_client = cpt.id_client
LEFT JOIN credits cr ON cpt.id_compte = cr.id_compte
GROUP BY c.id_client;

-- =====================================================
-- TRIGGERS pour audit
-- =====================================================
CREATE TRIGGER trigger_clients_update 
AFTER UPDATE ON clients
BEGIN
    INSERT INTO logs_audit (utilisateur, action, table_name, record_id, anciennes_valeurs, nouvelles_valeurs)
    VALUES ('SYSTEM', 'UPDATE', 'clients', NEW.id_client, OLD.nom, NEW.nom);
END;

CREATE TRIGGER trigger_transactions_insert
AFTER INSERT ON transactions
BEGIN
    UPDATE comptes 
    SET dernier_mouvement = CURRENT_TIMESTAMP
    WHERE id_compte = NEW.id_compte;
END;

-- =====================================================
-- DONNEES INITIALES
-- =====================================================

-- Insertion agences
INSERT INTO agences VALUES 
('A001', 'AG001', 'Paris Centre', '12 Rue de la Paix', '75001', 'Paris', '0142000000', 'contact@paris.fr', 'Jean Dupont', 25, 5000000.00, 'IDF', 'ACTIF', '2020-01-01', '09:00-18:00', '48.869,2.331'),
('A002', 'AG002', 'Lyon Part-Dieu', '5 Boulevard Vivier Merle', '69003', 'Lyon', '0472000000', 'contact@lyon.fr', 'Sophie Martin', 15, 3500000.00, 'ARA', 'ACTIF', '2020-02-15', '09:00-18:00', '45.760,4.860');

-- Insertion employes
INSERT INTO employes VALUES 
('EMP001', 'A001', 'ADMIN', 'System', 'Administrateur', 'admin@banque.com', '0100000000', '2020-01-01', 50000.00, 10000.00, 'admin', 'admin123', 'ADMIN', 'ACTIF', CURRENT_TIMESTAMP),
('EMP002', 'A001', 'DUPONT', 'Jean', 'Conseiller', 'jean.dupont@banque.com', '0612345678', '2021-01-15', 35000.00, 5000.00, 'jdupont', 'pass123', 'AGENT', 'ACTIF', CURRENT_TIMESTAMP);

-- Insertion clients
INSERT INTO clients VALUES 
('C00001', 'M', 'DUPONT', 'Jean', '1980-05-15', 'Paris', 'FRANCAISE', '12 Rue de Paris', '75001', 'Paris', 'FRANCE', '0612345678', 'jean.dupont@email.com', 'Ingenieur', 75000.00, 250000.00, 720, 'ACTIF', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'EMP002', 'EMP002'),
('C00002', 'MME', 'MARTIN', 'Sophie', '1985-03-20', 'Lyon', 'FRANCAISE', '5 Avenue Lyon', '69001', 'Lyon', 'FRANCE', '0623456789', 'sophie.martin@email.com', 'Medecin', 120000.00, 450000.00, 850, 'ACTIF', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'EMP002', 'EMP002'),
('C00003', 'M', 'DURAND', 'Pierre', '1990-07-10', 'Marseille', 'FRANCAISE', '8 Place Marseille', '13001', 'Marseille', 'FRANCE', '0634567890', 'pierre.durand@email.com', 'Commercial', 55000.00, 120000.00, 680, 'ACTIF', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'EMP002', 'EMP002');

-- Insertion comptes
INSERT INTO comptes VALUES 
('CPT001', 'C00001', 'COURANT', 'EUR', 15250.50, 500.00, 0.00, 5.00, 'ACTIF', '2023-01-15', NULL, 'A001', NULL),
('CPT002', 'C00001', 'EPARGNE', 'EUR', 35200.00, 0.00, 2.50, 0.00, 'ACTIF', '2023-01-15', NULL, 'A001', NULL),
('CPT003', 'C00002', 'COURANT', 'EUR', 25800.00, 1000.00, 0.00, 5.00, 'ACTIF', '2023-02-20', NULL, 'A002', NULL),
('CPT004', 'C00002', 'EPARGNE', 'EUR', 15800.00, 0.00, 2.50, 0.00, 'ACTIF', '2023-02-20', NULL, 'A002', NULL),
('CPT005', 'C00003', 'COURANT', 'EUR', 18500.00, 2000.00, 0.00, 5.00, 'ACTIF', '2023-03-10', NULL, 'A001', NULL);

-- Insertion cartes
INSERT INTO cartes VALUES 
('CB001', 'CPT001', 'PLATINUM', '4975123456789012', '123', '2028-01-31', 5000.00, 1000.00, 5000.00, 1, 1, 'ACTIF', '2023-01-20', NULL, NULL),
('CB002', 'CPT003', 'GOLD', '4975123456789013', '124', '2028-02-28', 3000.00, 800.00, 3000.00, 1, 1, 'ACTIF', '2023-02-25', NULL, NULL),
('CB003', 'CPT005', 'CLASSIC', '4975123456789014', '125', '2028-03-31', 1500.00, 500.00, 1500.00, 1, 1, 'ACTIF', '2023-03-15', NULL, NULL);

-- Insertion transactions
INSERT INTO transactions VALUES 
('T00001', 'CPT001', 'DEPOT', 5000.00, 'EUR', '2025-01-10 10:30:00', '2025-01-10', 'Depot initial', NULL, NULL, 'VALIDEE', 'AUTH001', 'A001', 'Guichet', 48.869, 2.331, '192.168.1.1', 'MOBILE'),
('T00002', 'CPT001', 'RETRAIT', 200.00, 'EUR', '2025-01-15 14:20:00', '2025-01-15', 'Retrait DAB', NULL, NULL, 'VALIDEE', 'AUTH002', 'A001', 'DAB', NULL, NULL, NULL, NULL),
('T00003', 'CPT001', 'VIREMENT', 1000.00, 'EUR', '2025-01-20 09:15:00', '2025-01-20', 'Virement vers compte epargne', 'CPT002', NULL, 'VALIDEE', 'AUTH003', 'A001', 'MOBILE', NULL, NULL, NULL, NULL),
('T00004', 'CPT003', 'DEPOT', 2500.00, 'EUR', '2025-02-01 11:00:00', '2025-02-01', 'Salaire', NULL, NULL, 'VALIDEE', 'AUTH004', 'A002', 'VIREMENT', 45.760, 4.860, '10.0.0.1', 'WEB'),
('T00005', 'CPT003', 'PAIEMENT_CB', 89.50, 'EUR', '2025-02-05 18:30:00', '2025-02-05', 'Achat Carrefour', NULL, NULL, 'VALIDEE', 'AUTH005', 'A002', 'CB', NULL, NULL, NULL, NULL);

-- Insertion credits
INSERT INTO credits VALUES 
('CR001', 'CPT001', 'CONSOMMATION', 25000.00, 4.50, 60, 466.07, 22500.00, '2024-01-15', '2024-02-15', '2029-01-15', 'ACTIF', 'Aucune', 1, 0.25, 250.00, 3.00, 'EMP002'),
('CR002', 'CPT003', 'AUTO', 35000.00, 3.80, 48, 788.00, 32000.00, '2024-03-20', '2024-04-20', '2028-03-20', 'ACTIF', 'Vehicule', 1, 0.30, 350.00, 3.00, 'EMP002');

-- Insertion echeances
INSERT INTO echeances VALUES 
('ECH001', 'CR001', 1, '2024-02-15', 400.00, 66.07, 10.00, 476.07, 'PAYE', '2024-02-15', 'T00001'),
('ECH002', 'CR001', 2, '2024-03-15', 400.00, 66.07, 10.00, 476.07, 'PAYE', '2024-03-15', 'T00002'),
('ECH003', 'CR002', 1, '2024-04-20', 680.00, 108.00, 15.00, 803.00, 'PAYE', '2024-04-20', 'T00003');

-- Insertion alertes
INSERT INTO alertes VALUES 
('ALT001', 'C00001', 'CPT001', 'SOLDE_FAIBLE', 'INFO', 'Solde compte courant inferieur a 2000€', CURRENT_TIMESTAMP, 'ACTIVE', NULL, NULL),
('ALT002', 'C00003', 'CPT005', 'DECOUVERT', 'WARNING', 'Compte en decouvert autorise', CURRENT_TIMESTAMP, 'ACTIVE', NULL, NULL);

