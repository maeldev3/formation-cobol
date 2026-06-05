-- =============================================
-- 1. Table des catégories
-- =============================================
CREATE TABLE IF NOT EXISTS categories (
    id_categorie INTEGER PRIMARY KEY AUTOINCREMENT,
    nom_categorie VARCHAR(50) NOT NULL,
    description TEXT
);

-- =============================================
-- 2. Table des fournisseurs
-- =============================================
CREATE TABLE IF NOT EXISTS fournisseurs (
    id_fournisseur INTEGER PRIMARY KEY AUTOINCREMENT,
    nom_fournisseur VARCHAR(100) NOT NULL,
    contact VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100),
    adresse TEXT
);

-- =============================================
-- 3. Table des produits (inventaire principal)
-- =============================================
CREATE TABLE IF NOT EXISTS produits (
    id_produit INTEGER PRIMARY KEY AUTOINCREMENT,
    code_produit VARCHAR(20) UNIQUE NOT NULL,
    nom_produit VARCHAR(100) NOT NULL,
    description TEXT,
    prix_achat DECIMAL(10,2) NOT NULL,
    prix_vente DECIMAL(10,2) NOT NULL,
    stock_actuel INTEGER NOT NULL DEFAULT 0,
    stock_min INTEGER DEFAULT 0,
    stock_max INTEGER DEFAULT NULL,
    id_categorie INTEGER,
    id_fournisseur_principal INTEGER,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_categorie) REFERENCES categories(id_categorie) ON DELETE SET NULL,
    FOREIGN KEY (id_fournisseur_principal) REFERENCES fournisseurs(id_fournisseur) ON DELETE SET NULL
);

-- =============================================
-- 4. Table des mouvements de stock
-- =============================================
CREATE TABLE IF NOT EXISTS mouvements_stock (
    id_mouvement INTEGER PRIMARY KEY AUTOINCREMENT,
    id_produit INTEGER NOT NULL,
    type_mouvement CHAR(1) NOT NULL,   -- 'E' = entrée, 'S' = sortie
    quantite INTEGER NOT NULL,
    raison VARCHAR(50) NOT NULL,
    date_mouvement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_doc VARCHAR(50),
    notes TEXT,
    FOREIGN KEY (id_produit) REFERENCES produits(id_produit) ON DELETE CASCADE
);

-- =============================================
-- 5. Table de liaison produit-fournisseur
-- =============================================
CREATE TABLE IF NOT EXISTS produit_fournisseur (
    id_produit INTEGER,
    id_fournisseur INTEGER,
    prix_achat_specifique DECIMAL(10,2),
    delai_livraison INTEGER,
    PRIMARY KEY (id_produit, id_fournisseur),
    FOREIGN KEY (id_produit) REFERENCES produits(id_produit) ON DELETE CASCADE,
    FOREIGN KEY (id_fournisseur) REFERENCES fournisseurs(id_fournisseur) ON DELETE CASCADE
);

-- =============================================
-- 6. Table des utilisateurs
-- =============================================
CREATE TABLE IF NOT EXISTS utilisateurs (
    id_utilisateur INTEGER PRIMARY KEY AUTOINCREMENT,
    login VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    nom_complet VARCHAR(100),
    actif BOOLEAN DEFAULT 1
);

-- =============================================
-- 7. Table des logs
-- =============================================
CREATE TABLE IF NOT EXISTS logs_inventaire (
    id_log INTEGER PRIMARY KEY AUTOINCREMENT,
    id_utilisateur INTEGER,
    action VARCHAR(100),
    description TEXT,
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES utilisateurs(id_utilisateur) ON DELETE SET NULL
);

-- =============================================
-- DONNÉES EXEMPLES (pour tester)
-- =============================================

-- Catégories
INSERT INTO categories (nom_categorie, description) VALUES
('Électronique', 'Appareils électroniques, gadgets'),
('Vêtements', 'Habits, accessoires'),
('Alimentation', 'Produits alimentaires, boissons');

-- Fournisseurs
INSERT INTO fournisseurs (nom_fournisseur, contact, telephone, email, adresse) VALUES
('TechDistrib', 'Jean Dupont', '0102030405', 'contact@techdistrib.fr', '12 rue de l’électronique, Paris'),
('ModeExpress', 'Marie Martin', '0607080910', 'commercial@modeexpress.fr', '45 avenue des modes, Lyon'),
('AlimPlus', 'Philippe Durand', '0456789123', 'philippe@alimplu s.fr', '99 rue des entrepôts, Marseille');

-- Produits
INSERT INTO produits (code_produit, nom_produit, description, prix_achat, prix_vente, stock_actuel, stock_min, id_categorie, id_fournisseur_principal) VALUES
('ELEC001', 'Smartphone X', 'Smartphone 128Go', 250.00, 399.99, 50, 10, 1, 1),
('ELEC002', 'Casque Audio', 'Casque sans fil Bluetooth', 30.00, 59.99, 120, 20, 1, 1),
('VET001', 'T‑shirt coton', 'T‑shirt unisexe', 5.00, 14.99, 200, 30, 2, 2),
('ALIM001', 'Café grain', 'Paquet 1kg', 8.50, 12.90, 75, 15, 3, 3);

-- Mouvements de stock (entrées et sorties)
INSERT INTO mouvements_stock (id_produit, type_mouvement, quantite, raison, reference_doc) VALUES
(1, 'E', 100, 'Réapprovisionnement initial', 'FACT-001'),
(1, 'S', 50, 'Vente client', 'CMD-1001'),
(2, 'E', 200, 'Commande fournisseur', 'FACT-002'),
(2, 'S', 80, 'Vente en ligne', 'CMD-1002'),
(3, 'E', 300, 'Stock initial', 'INIT-001'),
(4, 'E', 100, 'Réapprovisionnement', 'FACT-003');

-- Liaison produit-fournisseur (un produit peut avoir plusieurs fournisseurs)
INSERT INTO produit_fournisseur (id_produit, id_fournisseur, prix_achat_specifique, delai_livraison) VALUES
(1, 1, 245.00, 5),
(1, 2, 260.00, 7),
(2, 1, 28.00, 4),
(3, 2, 4.50, 3),
(4, 3, 8.00, 2);

-- Utilisateurs (mot de passe en clair pour l’exemple, mais dans un vrai projet on hache)
INSERT INTO utilisateurs (login, mot_de_passe, role, nom_complet) VALUES
('admin', 'admin123', 'admin', 'Administrateur système'),
('user1', 'pass456', 'user', 'Utilisateur standard');

-- Log d’exemple
INSERT INTO logs_inventaire (id_utilisateur, action, description) VALUES
(1, 'CREATION_BASE', 'Création de la base de données avec données initiales');