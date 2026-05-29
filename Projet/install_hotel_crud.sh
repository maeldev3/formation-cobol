#!/bin/bash
# hotel_crud_complet.sh - Installation complète du système hôtelier avec CRUD

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║              SYSTEME DE GESTION HOTELIERE                         ║"
echo "║                     Version CRUD Complete                         ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet

# Supprimer l'ancien projet si existe
rm -rf hotel_crud

# =========================================================================
# 1. CREATION DE LA STRUCTURE DES DOSSIERS
# =========================================================================

mkdir -p hotel_crud/{bin,src/{modules,includes},data/{input,output,backup},docs,logs,batch}

cd hotel_crud

# Création des sous-dossiers modules
mkdir -p src/modules/{CLIENTS,CHAMBRES,RESERVATIONS,PAIEMENTS,RAPPORTS}

echo "✅ Structure des dossiers créée"

# =========================================================================
# 2. CREATION DE LA BASE SQLITE (Structure complète)
# =========================================================================

cat > data/input/hotel.db.sql << 'SQL'
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
SQL

echo "✅ Script SQL créé"

# =========================================================================
# 3. INSERTION DES DONNEES INITIALES
# =========================================================================

cat > data/input/init_data.sql << 'SQL'
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
SQL

# Exécution des scripts SQL
sqlite3 data/input/hotel.db < data/input/hotel.db.sql
sqlite3 data/input/hotel.db < data/input/init_data.sql

echo "✅ Base de données SQLite créée avec données initiales"

# =========================================================================
# 4. CREATION DES FICHIERS COBOL (CRUD COMPLET)
# =========================================================================

# -------------------------------------------------------------------------
# MODULE CLIENTS (CRUD complet)
# -------------------------------------------------------------------------

# CREATE - Ajouter un client
cat > src/modules/CLIENTS/CREER_CLIENT.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-NOM        PIC X(20).
       01 WS-PRENOM     PIC X(15).
       01 WS-EMAIL      PIC X(30).
       01 WS-TEL        PIC X(12).
       01 WS-ADRESSE    PIC X(40).
       01 WS-VILLE      PIC X(20).
       01 WS-CP         PIC X(5).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              CREER UN NOUVEAU CLIENT               ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Client (C00001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "NOM : " WITH NO ADVANCING
           ACCEPT WS-NOM
           DISPLAY "PRENOM : " WITH NO ADVANCING
           ACCEPT WS-PRENOM
           DISPLAY "EMAIL : " WITH NO ADVANCING
           ACCEPT WS-EMAIL
           DISPLAY "TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "ADRESSE : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE
           DISPLAY "VILLE : " WITH NO ADVANCING
           ACCEPT WS-VILLE
           DISPLAY "CODE POSTAL : " WITH NO ADVANCING
           ACCEPT WS-CP
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO CLIENTS VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-NOM) "', '"
               FUNCTION TRIM(WS-PRENOM) "', '"
               FUNCTION TRIM(WS-EMAIL) "', '"
               FUNCTION TRIM(WS-TEL) "', '"
               FUNCTION TRIM(WS-ADRESSE) "', '"
               FUNCTION TRIM(WS-VILLE) "', '"
               FUNCTION TRIM(WS-CP) "', date('now'), 'ACTIF');\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CLIENT CREE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Nom: " FUNCTION TRIM(WS-NOM) " " FUNCTION TRIM(WS-PRENOM)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# READ - Lister les clients
cat > src/modules/CLIENTS/LISTER_CLIENTS.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CLIENTS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE     PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════════════════╗"
           DISPLAY "║                    LISTE DES CLIENTS                         ║"
           DISPLAY "╠══════════════════════════════════════════════════════════════╣"
           DISPLAY "║ ID      NOM                 PRENOM          TELEPHONE        ║"
           DISPLAY "╠══════════════════════════════════════════════════════════════╣"
           
           STRING "sqlite3 data/input/hotel.db 'SELECT ID_CLIENT || \" | \" || "
               "NOM || \" | \" || PRENOM || \" | \" || TELEPHONE "
               "FROM CLIENTS ORDER BY ID_CLIENT;'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚══════════════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# READ - Rechercher un client
cat > src/modules/CLIENTS/RECHERCHER_CLIENT.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECHERCHER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              RECHERCHER UN CLIENT                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "'ID: ' || ID_CLIENT || CHAR(10) || "
               "'NOM: ' || NOM || CHAR(10) || "
               "'PRENOM: ' || PRENOM || CHAR(10) || "
               "'EMAIL: ' || EMAIL || CHAR(10) || "
               "'TEL: ' || TELEPHONE || CHAR(10) || "
               "'ADRESSE: ' || ADRESSE || CHAR(10) || "
               "'STATUT: ' || STATUT "
               "FROM CLIENTS WHERE ID_CLIENT = '\''" 
               FUNCTION TRIM(WS-ID) "'\'';'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# UPDATE - Modifier un client
cat > src/modules/CLIENTS/MODIFIER_CLIENT.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-TEL        PIC X(12).
       01 WS-ADRESSE    PIC X(40).
       01 WS-STATUT     PIC X(10).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              MODIFIER UN CLIENT                    ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "NOUVEAU TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "NOUVELLE ADRESSE : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE
           DISPLAY "NOUVEAU STATUT (ACTIF/INACTIF) : " WITH NO ADVANCING
           ACCEPT WS-STATUT
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CLIENTS SET "
               "TELEPHONE = '" FUNCTION TRIM(WS-TEL) "', "
               "ADRESSE = '" FUNCTION TRIM(WS-ADRESSE) "', "
               "STATUT = '" FUNCTION TRIM(WS-STATUT) "' "
               "WHERE ID_CLIENT = '" FUNCTION TRIM(WS-ID) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CLIENT MODIFIE AVEC SUCCES !"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# DELETE - Supprimer un client
cat > src/modules/CLIENTS/SUPPRIMER_CLIENT.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPPRIMER-CLIENT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-CONFIRM    PIC X.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              SUPPRIMER UN CLIENT                   ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Confirmer suppression (O/N) : " WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR 'o'
               STRING "sqlite3 data/input/hotel.db \"DELETE FROM CLIENTS "
                   "WHERE ID_CLIENT = '" FUNCTION TRIM(WS-ID) "';\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               DISPLAY " "
               DISPLAY "✓ CLIENT SUPPRIME AVEC SUCCES !"
           ELSE
               DISPLAY "Suppression annulee"
           END-IF
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# -------------------------------------------------------------------------
# MODULE CHAMBRES (CRUD complet)
# -------------------------------------------------------------------------

# CREATE - Ajouter une chambre
cat > src/modules/CHAMBRES/CREER_CHAMBRE.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CHAMBRE.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-NUMERO     PIC X(5).
       01 WS-TYPE       PIC X(6).
       01 WS-ETAGE      PIC 99.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              CREER UNE CHAMBRE                     ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Chambre (CH001) : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Numero : " WITH NO ADVANCING
           ACCEPT WS-NUMERO
           DISPLAY "Type (TYP001-TYP005) : " WITH NO ADVANCING
           ACCEPT WS-TYPE
           DISPLAY "Etage : " WITH NO ADVANCING
           ACCEPT WS-ETAGE
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO CHAMBRES VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-NUMERO) "', '"
               FUNCTION TRIM(WS-TYPE) "', " WS-ETAGE
               ", 'DISPONIBLE', date('now'), NULL);\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ CHAMBRE CREEE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID " - Numero: " FUNCTION TRIM(WS-NUMERO)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# READ - Lister les chambres
cat > src/modules/CHAMBRES/LISTER_CHAMBRES.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-CHAMBRES.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════════════════╗"
           DISPLAY "║                    LISTE DES CHAMBRES                          ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════╣"
           DISPLAY "║ ID      NUMERO   TYPE            PRIX    STATUT      ETAGE     ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════╣"
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "CH.ID_CHAMBRE || \" | \" || CH.NUMERO || \" | \" || "
               "TCH.LIBELLE || \" | \" || TCH.PRIX_BASE || \"€ | \" || "
               "CH.STATUT || \" | \" || CH.ETAGE "
               "FROM CHAMBRES CH JOIN TYPES_CHAMBRE TCH ON CH.ID_TYPE = TCH.ID_TYPE "
               "ORDER BY CH.NUMERO;'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# UPDATE - Modifier statut chambre
cat > src/modules/CHAMBRES/MODIFIER_CHAMBRE.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODIFIER-CHAMBRE.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(6).
       01 WS-STATUT     PIC X(15).
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           MODIFIER STATUT CHAMBRE                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Chambre : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Nouveau statut (DISPONIBLE/OCCUPEE/RESERVEE) : " 
               WITH NO ADVANCING
           ACCEPT WS-STATUT
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = '"
               FUNCTION TRIM(WS-STATUT) "' WHERE ID_CHAMBRE = '"
               FUNCTION TRIM(WS-ID) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ STATUT MODIFIE AVEC SUCCES !"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# -------------------------------------------------------------------------
# MODULE RESERVATIONS (CRUD complet)
# -------------------------------------------------------------------------

# CREATE - Créer une réservation
cat > src/modules/RESERVATIONS/CREER_RESERVATION.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-RESERVATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(8).
       01 WS-CLIENT     PIC X(6).
       01 WS-CHAMBRE    PIC X(6).
       01 WS-DEBUT      PIC X(10).
       01 WS-FIN        PIC X(10).
       01 WS-PERSONNES  PIC 99.
       01 WS-PRIX       PIC 9(5)V99.
       01 WS-NB-JOURS   PIC 9(3).
       01 WS-MONTANT    PIC 9(6)V99.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           CREER UNE RESERVATION                    ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           DISPLAY "ID Client : " WITH NO ADVANCING
           ACCEPT WS-CLIENT
           DISPLAY "ID Chambre : " WITH NO ADVANCING
           ACCEPT WS-CHAMBRE
           DISPLAY "Date debut (YYYY-MM-DD) : " WITH NO ADVANCING
           ACCEPT WS-DEBUT
           DISPLAY "Date fin (YYYY-MM-DD) : " WITH NO ADVANCING
           ACCEPT WS-FIN
           DISPLAY "Nombre de personnes : " WITH NO ADVANCING
           ACCEPT WS-PERSONNES
           
           STRING "RES" FUNCTION CURRENT-DATE(1:12)
               INTO WS-ID
           END-STRING
           
           STRING "sqlite3 data/input/hotel.db 'SELECT PRIX_BASE FROM TYPES_CHAMBRE "
               "WHERE ID_TYPE = (SELECT ID_TYPE FROM CHAMBRES WHERE ID_CHAMBRE = '\''"
               FUNCTION TRIM(WS-CHAMBRE) "'\'');'"
               INTO WS-COMMANDE
           END-STRING
           
           MOVE 80.00 TO WS-PRIX
           MOVE 3 TO WS-NB-JOURS
           COMPUTE WS-MONTANT = WS-PRIX * WS-NB-JOURS
           
           STRING "sqlite3 data/input/hotel.db \"INSERT INTO RESERVATIONS VALUES ('"
               FUNCTION TRIM(WS-ID) "', '"
               FUNCTION TRIM(WS-CLIENT) "', '"
               FUNCTION TRIM(WS-CHAMBRE) "', '"
               FUNCTION TRIM(WS-DEBUT) "', '"
               FUNCTION TRIM(WS-FIN) "', " WS-PERSONNES
               ", 'CONFIRMEE', date('now'), " WS-MONTANT ", NULL);\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = 'RESERVEE' "
               "WHERE ID_CHAMBRE = '" FUNCTION TRIM(WS-CHAMBRE) "';\""
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           
           DISPLAY " "
           DISPLAY "✓ RESERVATION CREEE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Montant: " WS-MONTANT " €"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# READ - Lister les réservations
cat > src/modules/RESERVATIONS/LISTER_RESERVATIONS.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-RESERVATIONS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════════════════════╗"
           DISPLAY "║                    LISTE DES RESERVATIONS                          ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════════╣"
           DISPLAY "║ ID         CLIENT   CHAMBRE  DEBUT       FIN         STATUT        ║"
           DISPLAY "╠════════════════════════════════════════════════════════════════════╣"
           
           STRING "sqlite3 data/input/hotel.db 'SELECT "
               "ID_RESERVATION || \" | \" || ID_CLIENT || \" | \" || "
               "ID_CHAMBRE || \" | \" || DATE_DEBUT || \" | \" || DATE_FIN || "
               "\" | \" || STATUT FROM RESERVATIONS ORDER BY DATE_DEBUT;'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# UPDATE - Annuler une réservation
cat > src/modules/RESERVATIONS/ANNULER_RESERVATION.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ANNULER-RESERVATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-ID         PIC X(8).
       01 WS-CONFIRM    PIC X.
       01 WS-COMMANDE   PIC X(500).
       01 WS-CHAMBRE    PIC X(6).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║           ANNULER UNE RESERVATION                  ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "ID Reservation : " WITH NO ADVANCING
           ACCEPT WS-ID
           DISPLAY "Confirmer annulation (O/N) : " WITH NO ADVANCING
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR 'o'
               STRING "sqlite3 data/input/hotel.db \"UPDATE RESERVATIONS SET STATUT = 'ANNULEE' "
                   "WHERE ID_RESERVATION = '" FUNCTION TRIM(WS-ID) "';\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               
               STRING "sqlite3 data/input/hotel.db \"UPDATE CHAMBRES SET STATUT = 'DISPONIBLE' "
                   "WHERE ID_CHAMBRE = (SELECT ID_CHAMBRE FROM RESERVATIONS "
                   "WHERE ID_RESERVATION = '" FUNCTION TRIM(WS-ID) "');\""
                   INTO WS-COMMANDE
               END-STRING
               CALL "SYSTEM" USING WS-COMMANDE
               
               DISPLAY " "
               DISPLAY "✓ RESERVATION ANNULEE"
           ELSE
               DISPLAY "Annulation annulee"
           END-IF
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# -------------------------------------------------------------------------
# MODULE RAPPORTS
# -------------------------------------------------------------------------

cat > src/modules/RAPPORTS/RAPPORT_OCCUPATION.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-OCCUPATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════════════════╗"
           DISPLAY "║              RAPPORT D'OCCUPATION                              ║"
           DISPLAY "╚════════════════════════════════════════════════════════════════╝"
           
           STRING "echo '=== CHAMBRES OCCUPEES ===' && "
               "sqlite3 data/input/hotel.db 'SELECT NUMERO || \" - \" || STATUT "
               "FROM CHAMBRES WHERE STATUT != \"DISPONIBLE\";' && "
               "echo '' && "
               "echo '=== STATISTIQUES ===' && "
               "sqlite3 data/input/hotel.db 'SELECT \"Taux occupation: \" || "
               "ROUND(CAST((SELECT COUNT(*) FROM CHAMBRES WHERE STATUT != \"DISPONIBLE\") "
               "AS REAL) / (SELECT COUNT(*) FROM CHAMBRES) * 100, 2) || \"%\";'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════════════════╝"
           STOP RUN.
COB

cat > src/modules/RAPPORTS/RAPPORT_CA.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RAPPORT-CA.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMMANDE   PIC X(500).
       
       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║          RAPPORT CHIFFRE D'AFFAIRES                ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           
           STRING "echo '=== CA TOTAL ===' && "
               "sqlite3 data/input/hotel.db 'SELECT \"CA Global: \" || "
               "COALESCE(SUM(MONTANT), 0) || \" €\" FROM PAIEMENTS;' && "
               "echo '' && "
               "echo '=== CA PAR MOIS ===' && "
               "sqlite3 data/input/hotel.db 'SELECT strftime(\"%Y-%m\", DATE_PAIEMENT) "
               "|| \" | \" || SUM(MONTANT) || \"€\" FROM PAIEMENTS GROUP BY "
               "strftime(\"%Y-%m\", DATE_PAIEMENT);'"
               INTO WS-COMMANDE
           END-STRING
           CALL "SYSTEM" USING WS-COMMANDE
           DISPLAY "╚════════════════════════════════════════════════════╝"
           STOP RUN.
COB

# -------------------------------------------------------------------------
# MENU PRINCIPAL
# -------------------------------------------------------------------------

cat > src/MENU_PRINCIPAL.cob << 'COB'
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU-PRINCIPAL.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOIX         PIC 9.
       01 WS-QUITTER       PIC X VALUE 'N'.
       
       PROCEDURE DIVISION.
       DEBUT.
           PERFORM UNTIL WS-QUITTER = 'O'
               DISPLAY " "
               DISPLAY "╔══════════════════════════════════════════════════════════════╗"
               DISPLAY "║                    HOTEL PARADISE                            ║"
               DISPLAY "║              SYSTEME COMPLET DE GESTION                      ║"
               DISPLAY "╠══════════════════════════════════════════════════════════════╣"
               DISPLAY "║  1. GESTION CLIENTS (CRUD)                                   ║"
               DISPLAY "║  2. GESTION CHAMBRES (CRUD)                                  ║"
               DISPLAY "║  3. GESTION RESERVATIONS (CRUD)                              ║"
               DISPLAY "║  4. RAPPORTS                                                 ║"
               DISPLAY "║  0. QUITTER                                                  ║"
               DISPLAY "╚══════════════════════════════════════════════════════════════╝"
               DISPLAY "Choix : " WITH NO ADVANCING
               ACCEPT WS-CHOIX
               
               EVALUATE WS-CHOIX
                   WHEN 1 PERFORM GESTION-CLIENTS
                   WHEN 2 PERFORM GESTION-CHAMBRES
                   WHEN 3 PERFORM GESTION-RESERVATIONS
                   WHEN 4 PERFORM GESTION-RAPPORTS
                   WHEN 0 MOVE 'O' TO WS-QUITTER
                   WHEN OTHER DISPLAY "Choix invalide"
               END-EVALUATE
           END-PERFORM.
       
       GESTION-CLIENTS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║               GESTION CLIENTS (CRUD)               ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Ajouter un client                    ║"
           DISPLAY "║  2. LIRE    - Lister les clients                   ║"
           DISPLAY "║  3. LIRE    - Rechercher un client                 ║"
           DISPLAY "║  4. MODIFIER- Modifier un client                   ║"
           DISPLAY "║  5. SUPPRIMER- Supprimer un client                 ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_CLIENT"
               WHEN 2 CALL "./bin/LISTER_CLIENTS"
               WHEN 3 CALL "./bin/RECHERCHER_CLIENT"
               WHEN 4 CALL "./bin/MODIFIER_CLIENT"
               WHEN 5 CALL "./bin/SUPPRIMER_CLIENT"
           END-EVALUATE.
       
       GESTION-CHAMBRES.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║               GESTION CHAMBRES (CRUD)              ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Ajouter une chambre                  ║"
           DISPLAY "║  2. LIRE    - Lister les chambres                  ║"
           DISPLAY "║  3. MODIFIER- Modifier statut chambre              ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_CHAMBRE"
               WHEN 2 CALL "./bin/LISTER_CHAMBRES"
               WHEN 3 CALL "./bin/MODIFIER_CHAMBRE"
           END-EVALUATE.
       
       GESTION-RESERVATIONS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║             GESTION RESERVATIONS (CRUD)            ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. CREER   - Creer une reservation                ║"
           DISPLAY "║  2. LIRE    - Lister les reservations              ║"
           DISPLAY "║  3. MODIFIER- Annuler une reservation              ║"
           DISPLAY "║  0. Retour                                         ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/CREER_RESERVATION"
               WHEN 2 CALL "./bin/LISTER_RESERVATIONS"
               WHEN 3 CALL "./bin/ANNULER_RESERVATION"
           END-EVALUATE.
       
       GESTION-RAPPORTS.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║                    RAPPORTS                        ║"
           DISPLAY "╠════════════════════════════════════════════════════╣"
           DISPLAY "║  1. Rapport occupation                            ║"
           DISPLAY "║  2. Rapport chiffre d'affaires                    ║"
           DISPLAY "║  0. Retour                                        ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "Choix : " WITH NO ADVANCING
           ACCEPT WS-CHOIX
           EVALUATE WS-CHOIX
               WHEN 1 CALL "./bin/RAPPORT_OCCUPATION"
               WHEN 2 CALL "./bin/RAPPORT_CA"
           END-EVALUATE.
       
       STOP RUN.
COB

echo "✅ Programmes COBOL créés"

# =========================================================================
# 5. SCRIPT DE COMPILATION
# =========================================================================

cat > compile.sh << 'SH'
#!/bin/bash

echo "========================================="
echo "COMPILATION DU PROJET HOTEL CRUD"
echo "========================================="

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud
mkdir -p bin

echo "Compilation des modules..."

# CLIENTS
cobc -x -free -o bin/CREER_CLIENT src/modules/CLIENTS/CREER_CLIENT.cob 2>/dev/null && echo "✓ CREER_CLIENT" || echo "✗ CREER_CLIENT"
cobc -x -free -o bin/LISTER_CLIENTS src/modules/CLIENTS/LISTER_CLIENTS.cob 2>/dev/null && echo "✓ LISTER_CLIENTS" || echo "✗ LISTER_CLIENTS"
cobc -x -free -o bin/RECHERCHER_CLIENT src/modules/CLIENTS/RECHERCHER_CLIENT.cob 2>/dev/null && echo "✓ RECHERCHER_CLIENT" || echo "✗ RECHERCHER_CLIENT"
cobc -x -free -o bin/MODIFIER_CLIENT src/modules/CLIENTS/MODIFIER_CLIENT.cob 2>/dev/null && echo "✓ MODIFIER_CLIENT" || echo "✗ MODIFIER_CLIENT"
cobc -x -free -o bin/SUPPRIMER_CLIENT src/modules/CLIENTS/SUPPRIMER_CLIENT.cob 2>/dev/null && echo "✓ SUPPRIMER_CLIENT" || echo "✗ SUPPRIMER_CLIENT"

# CHAMBRES
cobc -x -free -o bin/CREER_CHAMBRE src/modules/CHAMBRES/CREER_CHAMBRE.cob 2>/dev/null && echo "✓ CREER_CHAMBRE" || echo "✗ CREER_CHAMBRE"
cobc -x -free -o bin/LISTER_CHAMBRES src/modules/CHAMBRES/LISTER_CHAMBRES.cob 2>/dev/null && echo "✓ LISTER_CHAMBRES" || echo "✗ LISTER_CHAMBRES"
cobc -x -free -o bin/MODIFIER_CHAMBRE src/modules/CHAMBRES/MODIFIER_CHAMBRE.cob 2>/dev/null && echo "✓ MODIFIER_CHAMBRE" || echo "✗ MODIFIER_CHAMBRE"

# RESERVATIONS
cobc -x -free -o bin/CREER_RESERVATION src/modules/RESERVATIONS/CREER_RESERVATION.cob 2>/dev/null && echo "✓ CREER_RESERVATION" || echo "✗ CREER_RESERVATION"
cobc -x -free -o bin/LISTER_RESERVATIONS src/modules/RESERVATIONS/LISTER_RESERVATIONS.cob 2>/dev/null && echo "✓ LISTER_RESERVATIONS" || echo "✗ LISTER_RESERVATIONS"
cobc -x -free -o bin/ANNULER_RESERVATION src/modules/RESERVATIONS/ANNULER_RESERVATION.cob 2>/dev/null && echo "✓ ANNULER_RESERVATION" || echo "✗ ANNULER_RESERVATION"

# RAPPORTS
cobc -x -free -o bin/RAPPORT_OCCUPATION src/modules/RAPPORTS/RAPPORT_OCCUPATION.cob 2>/dev/null && echo "✓ RAPPORT_OCCUPATION" || echo "✗ RAPPORT_OCCUPATION"
cobc -x -free -o bin/RAPPORT_CA src/modules/RAPPORTS/RAPPORT_CA.cob 2>/dev/null && echo "✓ RAPPORT_CA" || echo "✗ RAPPORT_CA"

# MENU
cobc -x -free -o bin/MENU_PRINCIPAL src/MENU_PRINCIPAL.cob 2>/dev/null && echo "✓ MENU_PRINCIPAL" || echo "✗ MENU_PRINCIPAL"

echo ""
echo "========================================="
echo "COMPILATION TERMINEE"
echo "========================================="
ls -la bin/
SH

chmod +x compile.sh

# =========================================================================
# 6. SCRIPT DE TEST
# =========================================================================

cat > test_hotel.sh << 'SH'
#!/bin/bash

echo "========================================="
echo "TESTS REELS - SYSTEME HOTEL CRUD"
echo "========================================="

cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud

echo ""
echo "=== TEST 1: LISTER LES CLIENTS ==="
./bin/LISTER_CLIENTS

echo ""
echo "=== TEST 2: LISTER LES CHAMBRES ==="
./bin/LISTER_CHAMBRES

echo ""
echo "=== TEST 3: LISTER LES RESERVATIONS ==="
./bin/LISTER_RESERVATIONS

echo ""
echo "=== TEST 4: RAPPORT OCCUPATION ==="
./bin/RAPPORT_OCCUPATION

echo ""
echo "=== TEST 5: RAPPORT CA ==="
./bin/RAPPORT_CA

echo ""
echo "=== TEST 6: CREER UN NOUVEAU CLIENT ==="
echo -e "C00010\nBERNARD\nClaude\nclaude@email.com\n0666666666\n10 Rue Test\nParis\n75000" | ./bin/CREER_CLIENT

echo ""
echo "=== TEST 7: VERIFICATION NOUVEAU CLIENT ==="
./bin/LISTER_CLIENTS

echo ""
echo "========================================="
echo "TESTS TERMINES"
echo "========================================="
SH

chmod +x test_hotel.sh

# =========================================================================
# 7. VERIFICATION FINALE
# =========================================================================

echo ""
echo "========================================="
echo "INSTALLATION COMPLETE !"
echo "========================================="
echo ""
echo "Structure du projet:"
ls -la
echo ""
echo "Tables SQLite:"
sqlite3 data/input/hotel.db ".tables"
echo ""
echo "Donnees:"
sqlite3 data/input/hotel.db "SELECT 'Clients: ' || COUNT(*) FROM CLIENTS;"
sqlite3 data/input/hotel.db "SELECT 'Chambres: ' || COUNT(*) FROM CHAMBRES;"
sqlite3 data/input/hotel.db "SELECT 'Reservations: ' || COUNT(*) FROM RESERVATIONS;"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     PROJET HOTEL CRUD INSTALLE AVEC SUCCES !                  ║"
echo "║                                                               ║"
echo "║  Commande:                                                    ║"
echo "║    cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud"
echo "║    ./compile.sh                                               ║"
echo "║    ./bin/MENU_PRINCIPAL                                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

# Compilation automatique
./compile.sh

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     SYSTEME PRET - DEMARRAGE DU MENU PRINCIPAL                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

./bin/MENU_PRINCIPAL