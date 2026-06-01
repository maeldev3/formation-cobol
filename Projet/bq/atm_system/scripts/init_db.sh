#!/bin/bash
DB_PATH="../data/atm.db"
mkdir -p ../data
rm -f $DB_PATH
sqlite3 $DB_PATH <<SQL
CREATE TABLE cartes (
    carte_id     INTEGER PRIMARY KEY,
    numero_carte TEXT UNIQUE NOT NULL,
    pin          TEXT NOT NULL,
    bloquee      INTEGER DEFAULT 0
);
CREATE TABLE comptes (
    compte_id   INTEGER PRIMARY KEY,
    carte_id    INTEGER NOT NULL,
    solde       REAL DEFAULT 0.0,
    FOREIGN KEY (carte_id) REFERENCES cartes(carte_id)
);
CREATE TABLE transactions (
    trans_id    INTEGER PRIMARY KEY,
    carte_id    INTEGER NOT NULL,
    type_trans  TEXT NOT NULL,
    montant     REAL NOT NULL,
    date_trans  TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (carte_id) REFERENCES cartes(carte_id)
);
INSERT INTO cartes (numero_carte, pin) VALUES ('1111222233334444', '1234');
INSERT INTO comptes (carte_id, solde) VALUES (1, 500.0);
SQL
echo "Base SQLite initialisée avec carte 1111222233334444 (PIN 1234) - Solde 500€"
