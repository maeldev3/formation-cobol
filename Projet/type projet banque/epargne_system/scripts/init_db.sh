#!/bin/bash
# Fichier : init_db.sh
# Rôle : Crée la base de données SQLite pour le système d'épargne
DB_PATH="../data/epargne.db"
mkdir -p ../data
rm -f $DB_PATH
sqlite3 $DB_PATH <<SQL
CREATE TABLE clients (
    client_id   INTEGER PRIMARY KEY,
    nom         TEXT NOT NULL,
    prenom      TEXT NOT NULL,
    login       TEXT UNIQUE NOT NULL,
    pin         TEXT NOT NULL
);
CREATE TABLE comptes_epargne (
    compte_id   INTEGER PRIMARY KEY,
    client_id   INTEGER NOT NULL,
    solde       REAL DEFAULT 0.0,
    taux_interet REAL DEFAULT 2.5,
    date_ouverture TEXT DEFAULT CURRENT_DATE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
CREATE TABLE transactions (
    trans_id    INTEGER PRIMARY KEY,
    client_id   INTEGER NOT NULL,
    type_trans  TEXT NOT NULL,
    montant     REAL NOT NULL,
    date_trans  TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
INSERT INTO clients (nom, prenom, login, pin) VALUES 
    ('DUPONT', 'Jean', 'jean', '1234'),
    ('MARTIN', 'Sophie', 'sophie', '1234');
INSERT INTO comptes_epargne (client_id, solde, taux_interet) VALUES 
    (1, 5000.0, 2.5),
    (2, 3000.0, 2.5);
SQL
echo "Base de données épargne initialisée."
echo "Compte 1 (Jean DUPONT) - Solde: 5000€ - Taux: 2.5%"
echo "Compte 2 (Sophie MARTIN) - Solde: 3000€ - Taux: 2.5%"
