-- =====================================================
-- MODULE CARTES BANCAIRES
-- =====================================================

-- Création d'une carte
CREATE OR REPLACE FUNCTION creer_carte(
    p_id_compte TEXT,
    p_type_carte TEXT
) RETURNS TEXT AS $$
DECLARE
    v_id_carte TEXT;
    v_numero_carte TEXT;
    v_cryptogramme TEXT;
    v_date_exp DATE;
    v_plafond DECIMAL(10,2);
    v_id_client TEXT;
    v_revenu DECIMAL(12,2);
BEGIN
    -- Récupérer les infos du client
    SELECT c.id_client, cl.revenu_annuel INTO v_id_client, v_revenu
    FROM comptes c
    JOIN clients cl ON c.id_client = cl.id_client
    WHERE c.id_compte = p_id_compte;
    
    -- Déterminer plafond selon type
    CASE p_type_carte
        WHEN 'CLASSIC' THEN
            IF v_revenu < 20000 THEN
                RAISE EXCEPTION 'Revenu insuffisant pour carte CLASSIC';
            END IF;
            v_plafond := 1500.00;
        WHEN 'GOLD' THEN
            IF v_revenu < 40000 THEN
                RAISE EXCEPTION 'Revenu insuffisant pour carte GOLD';
            END IF;
            v_plafond := 3000.00;
        WHEN 'PLATINUM' THEN
            IF v_revenu < 70000 THEN
                RAISE EXCEPTION 'Revenu insuffisant pour carte PLATINUM';
            END IF;
            v_plafond := 6000.00;
        WHEN 'BLACK' THEN
            IF v_revenu < 120000 THEN
                RAISE EXCEPTION 'Revenu insuffisant pour carte BLACK';
            END IF;
            v_plafond := 15000.00;
        ELSE
            RAISE EXCEPTION 'Type de carte invalide';
    END CASE;
    
    -- Générer numéro de carte (Luhn-like)
    v_numero_carte := '4975' || LPAD(FLOOR(RANDOM() * 999999999999)::TEXT, 12, '0');
    v_cryptogramme := LPAD(FLOOR(RANDOM() * 999)::TEXT, 3, '0');
    v_date_exp := CURRENT_DATE + INTERVAL '5 years';
    
    -- Générer ID carte
    v_id_carte := 'CB' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_carte,3) AS INTEGER)) FROM cartes), 0) + 1)::TEXT, 4, '0');
    
    -- Insérer la carte
    INSERT INTO cartes (id_carte, id_compte, type_carte, numero_carte, cryptogramme, 
                        date_expiration, plafond_mensuel, plafond_retrait, plafond_paiement,
                        sans_contact, assurable, statut, date_emission)
    VALUES (v_id_carte, p_id_compte, p_type_carte, v_numero_carte, v_cryptogramme,
            v_date_exp, v_plafond, v_plafond * 0.3, v_plafond,
            1, 1, 'ACTIF', CURRENT_DATE);
    
    RETURN v_id_carte;
END;
$$ LANGUAGE plpgsql;

-- Blocquer une carte
CREATE OR REPLACE FUNCTION bloquer_carte(
    p_id_carte TEXT,
    p_raison TEXT
) RETURNS TEXT AS $$
BEGIN
    UPDATE cartes 
    SET statut = 'BLOQUE', 
        date_blocage = CURRENT_DATE,
        raison_blocage = p_raison
    WHERE id_carte = p_id_carte;
    
    -- Créer une alerte
    INSERT INTO alertes (id_alerte, id_compte, type_alerte, niveau, message, statut)
    SELECT 'ALT' || LPAD((COALESCE(MAX(CAST(SUBSTR(id_alerte,4) AS INTEGER)), 0) + 1)::TEXT, 5, '0'),
           id_compte, 'CARTE_BLOQUEE', 'WARNING',
           'Carte ' || p_id_carte || ' bloquee: ' || p_raison,
           'ACTIVE'
    FROM cartes WHERE id_carte = p_id_carte;
    
    RETURN 'Carte bloquée avec succès';
END;
$$ LANGUAGE plpgsql;

-- Débloquer une carte
CREATE OR REPLACE FUNCTION debloquer_carte(p_id_carte TEXT)
RETURNS TEXT AS $$
BEGIN
    UPDATE cartes 
    SET statut = 'ACTIF', date_blocage = NULL, raison_blocage = NULL
    WHERE id_carte = p_id_carte;
    
    RETURN 'Carte débloquée avec succès';
END;
$$ LANGUAGE plpgsql;

-- Modifier plafond
CREATE OR REPLACE FUNCTION modifier_plafond(
    p_id_carte TEXT,
    p_nouveau_plafond DECIMAL
) RETURNS TEXT AS $$
BEGIN
    UPDATE cartes 
    SET plafond_mensuel = p_nouveau_plafond,
        plafond_retrait = p_nouveau_plafond * 0.3,
        plafond_paiement = p_nouveau_plafond
    WHERE id_carte = p_id_carte;
    
    RETURN 'Plafond modifié avec succès';
END;
$$ LANGUAGE plpgsql;

-- Liste des cartes par client
CREATE VIEW vue_cartes_client AS
SELECT 
    c.id_client,
    c.nom,
    c.prenom,
    ct.id_carte,
    ct.type_carte,
    ct.numero_carte,
    ct.date_expiration,
    ct.plafond_mensuel,
    ct.statut,
    CASE 
        WHEN ct.date_expiration < CURRENT_DATE THEN 'EXPIREE'
        WHEN ct.statut = 'BLOQUE' THEN 'BLOQUEE'
        ELSE 'ACTIVE'
    END as etat_carte
FROM clients c
JOIN comptes cp ON c.id_client = cp.id_client
JOIN cartes ct ON cp.id_compte = ct.id_compte;

-- Transactions par carte
CREATE VIEW vue_transactions_carte AS
SELECT 
    ct.id_carte,
    ct.type_carte,
    t.id_transaction,
    t.type_transaction,
    t.montant,
    t.date_transaction,
    t.description,
    t.point_vente
FROM cartes ct
JOIN comptes cp ON ct.id_compte = cp.id_compte
JOIN transactions t ON cp.id_compte = t.id_compte
WHERE t.type_transaction = 'PAIEMENT_CB'
ORDER BY t.date_transaction DESC;
