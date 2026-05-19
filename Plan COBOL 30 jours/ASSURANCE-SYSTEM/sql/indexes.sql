CREATE INDEX idx_client ON contrats(client_id);
CREATE INDEX idx_contrat ON sinistres(contrat_id);
CREATE INDEX idx_payment ON paiements(contrat_id);
