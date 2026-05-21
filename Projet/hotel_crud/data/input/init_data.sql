-- =====================================================
-- DONNEES INITIALES - HOTEL
-- =====================================================

-- Insertion des types de chambres
INSERT INTO TYPES_CHAMBRE VALUES 
('TYP001', 'Standard', 80.00, 2, 'Chambre standard avec salle de bain'),
('TYP002', 'Confort', 120.00, 2, 'Chambre confort avec vue'),
('TYP003', 'Suite', 200.00, 4, 'Suite familiale'),
('TYP004', 'Presidentielle', 350.00, 6, 'Suite presidentielle'),
('TYP005', 'Economique', 50.00, 1, 'Petite chambre economique');

-- Insertion des clients
INSERT INTO CLIENTS VALUES 
('C00001', 'DUPONT', 'Jean', 'jean.dupont@email.com', '0612345678', '12 Rue de Paris', 'Paris', '75001', '2024-01-15', 'ACTIF'),
('C00002', 'MARTIN', 'Sophie', 'sophie.martin@email.com', '0623456789', '5 Avenue Lyon', 'Lyon', '69001', '2024-02-20', 'ACTIF'),
('C00003', 'DURAND', 'Pierre', 'pierre.durand@email.com', '0634567890', '8 Place Marseille', 'Marseille', '13001', '2024-03-10', 'ACTIF'),
('C00004', 'LEROY', 'Claire', 'claire.leroy@email.com', '0645678901', '15 Rue Bordeaux', 'Bordeaux', '33000', '2024-04-05', 'ACTIF'),
('C00005', 'PETIT', 'Laurent', 'laurent.petit@email.com', '0656789012', '25 Boulevard Toulouse', 'Toulouse', '31000', '2024-05-12', 'ACTIF');

-- Insertion des chambres
INSERT INTO CHAMBRES VALUES 
('CH001', '101', 'TYP001', 1, 'DISPONIBLE', '2025-05-15', NULL),
('CH002', '102', 'TYP001', 1, 'DISPONIBLE', '2025-05-15', NULL),
('CH003', '103', 'TYP001', 1, 'OCCUPEE', '2025-05-14', NULL),
('CH004', '104', 'TYP002', 1, 'DISPONIBLE', '2025-05-15', NULL),
('CH005', '105', 'TYP002', 1, 'DISPONIBLE', '2025-05-15', NULL),
('CH006', '201', 'TYP002', 2, 'DISPONIBLE', '2025-05-15', NULL),
('CH007', '202', 'TYP003', 2, 'RESERVEE', '2025-05-10', NULL),
('CH008', '203', 'TYP003', 2, 'DISPONIBLE', '2025-05-15', NULL),
('CH009', '204', 'TYP004', 2, 'DISPONIBLE', '2025-05-15', NULL),
('CH010', '205', 'TYP005', 2, 'DISPONIBLE', '2025-05-15', NULL),
('CH011', '206', 'TYP005', 2, 'DISPONIBLE', '2025-05-15', NULL),
('CH012', '301', 'TYP001', 3, 'DISPONIBLE', '2025-05-15', 'Vue sur piscine');

-- Insertion des réservations
INSERT INTO RESERVATIONS VALUES 
('RES0001', 'C00001', 'CH003', '2025-05-10', '2025-05-15', 2, 'EN_COURS', '2025-04-20', 400.00, NULL),
('RES0002', 'C00002', 'CH007', '2025-05-20', '2025-05-25', 4, 'CONFIRMEE', '2025-05-01', 1000.00, NULL),
('RES0003', 'C00003', 'CH001', '2025-06-01', '2025-06-05', 2, 'CONFIRMEE', '2025-05-10', 320.00, NULL),
('RES0004', 'C00004', 'CH008', '2025-06-10', '2025-06-15', 2, 'CONFIRMEE', '2025-05-12', 600.00, NULL),
('RES0005', 'C00005', 'CH009', '2025-07-01', '2025-07-07', 4, 'CONFIRMEE', '2025-05-15', 2100.00, NULL);

-- Insertion des paiements
INSERT INTO PAIEMENTS VALUES 
('PAY0001', 'RES0001', 200.00, '2025-04-20', 'CB', 'VALIDE', 'REF001'),
('PAY0002', 'RES0001', 200.00, '2025-05-10', 'CB', 'VALIDE', 'REF002'),
('PAY0003', 'RES0002', 500.00, '2025-05-01', 'CB', 'VALIDE', 'REF003'),
('PAY0004', 'RES0003', 320.00, '2025-05-10', 'ESPECES', 'VALIDE', 'REF004');
