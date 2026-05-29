-- =====================================================
-- DONNEES INITIALES - TRANSPORT
-- =====================================================

INSERT INTO BUS VALUES 
('BUS001', 'AB-123-CD', 'MERCEDES', 'TRAVEGO', 55, 2020, 'DISPONIBLE', '2025-05-01', 'Climatisation, WiFi'),
('BUS002', 'EF-456-GH', 'VOLVO', '9700', 50, 2021, 'DISPONIBLE', '2025-05-10', 'Toilettes, Prise USB'),
('BUS003', 'IJ-789-KL', 'SCANIA', 'INTERLINK', 60, 2019, 'MAINTENANCE', '2025-05-15', 'Revision moteur'),
('BUS004', 'MN-012-OP', 'MAN', 'LION COACH', 55, 2022, 'DISPONIBLE', '2025-05-05', 'Neuf'),
('BUS005', 'QR-345-ST', 'IRIZAR', 'I6', 50, 2021, 'DISPONIBLE', '2025-05-08', NULL);

INSERT INTO CONDUCTEURS VALUES 
('DRV001', 'DUPONT', 'Jean', 'jean.dupont@transport.com', '0612345678', '12 Rue des Conducteurs', 'Paris', '75001', 'P12345678', '2023-01-15', 'ACTIF', 2500.00),
('DRV002', 'MARTIN', 'Sophie', 'sophie.martin@transport.com', '0623456789', '5 Avenue Lyon', 'Lyon', '69001', 'P87654321', '2023-02-20', 'ACTIF', 2600.00),
('DRV003', 'DURAND', 'Pierre', 'pierre.durand@transport.com', '0634567890', '8 Place Marseille', 'Marseille', '13001', 'P11223344', '2023-03-10', 'ACTIF', 2400.00),
('DRV004', 'LEROY', 'Claire', 'claire.leroy@transport.com', '0645678901', '15 Rue Bordeaux', 'Bordeaux', '33000', 'P55667788', '2023-04-05', 'CONGE', 2500.00),
('DRV005', 'PETIT', 'Laurent', 'laurent.petit@transport.com', '0656789012', '25 Boulevard Toulouse', 'Toulouse', '31000', 'P99887766', '2023-05-12', 'ACTIF', 2550.00);

INSERT INTO TRAJETS VALUES 
('TRJ001', 'BUS001', 'DRV001', 'Paris', 'Lyon', '2025-06-01', '08:00', '2025-06-01', '11:30', 465, 45.00, 55, 'PROGRAMME'),
('TRJ002', 'BUS002', 'DRV002', 'Lyon', 'Marseille', '2025-06-01', '14:00', '2025-06-01', '17:30', 313, 35.00, 50, 'PROGRAMME'),
('TRJ003', 'BUS001', 'DRV003', 'Paris', 'Bordeaux', '2025-06-02', '09:00', '2025-06-02', '14:00', 580, 55.00, 55, 'PROGRAMME'),
('TRJ004', 'BUS004', 'DRV004', 'Marseille', 'Nice', '2025-06-03', '10:00', '2025-06-03', '12:30', 200, 25.00, 55, 'PROGRAMME'),
('TRJ005', 'BUS005', 'DRV005', 'Lille', 'Paris', '2025-06-04', '07:30', '2025-06-04', '10:00', 220, 30.00, 50, 'PROGRAMME');
