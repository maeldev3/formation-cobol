#!/bin/bash
DB_PATH="../data/banque.db"
mkdir -p ../data
rm -f $DB_PATH
sqlite3 $DB_PATH <<SQL
CREATE TABLE clients (
    client_id   INTEGER PRIMARY KEY,
    nom         TEXT NOT NULL,
    prenom      TEXT NOT NULL,
    login       TEXT UNIQUE NOT NULL,
    pin         TEXT NOT NULL,
    iban        TEXT UNIQUE NOT NULL
);
CREATE TABLE comptes (
    compte_id   INTEGER PRIMARY KEY,
    client_id   INTEGER NOT NULL,
    solde       REAL DEFAULT 0.0,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
CREATE TABLE transactions (
    trans_id    INTEGER PRIMARY KEY,
    client_id   INTEGER NOT NULL,
    type_trans  TEXT NOT NULL,
    montant     REAL NOT NULL,
    iban_dest   TEXT,
    date_trans  TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);
INSERT INTO clients (nom, prenom, login, pin, iban) VALUES 
    ('DUPONT', 'Jean', 'jean', '1234', 'FR7612345000012345678901'),
    ('MARTIN', 'Sophie', 'sophie', '1234', 'FR7612345000023456789012');
INSERT INTO comptes (client_id, solde) VALUES (1, 5000.0), (2, 3000.0);
SQL
echo "Base initialisée avec deux comptes."
echo "Compte 1 (Jean DUPONT) - IBAN: FR7612345000012345678901 - Solde: 5000€"
echo "Compte 2 (Sophie MARTIN) - IBAN: FR7612345000023456789012 - Solde: 3000€"
