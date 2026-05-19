CREATE TABLE clients (
    id INT PRIMARY KEY,
    nom VARCHAR(100),
    adresse VARCHAR(150),
    telephone VARCHAR(20)
);

CREATE TABLE contrats (
    id INT PRIMARY KEY,
    client_id INT,
    type_police VARCHAR(50),
    prime DECIMAL(10,2)
);

CREATE TABLE sinistres (
    id INT PRIMARY KEY,
    contrat_id INT,
    date_sinistre DATE,
    montant DECIMAL(10,2),
    statut VARCHAR(20)
);

CREATE TABLE paiements (
    id INT PRIMARY KEY,
    contrat_id INT,
    date_paiement DATE,
    montant DECIMAL(10,2)
);
