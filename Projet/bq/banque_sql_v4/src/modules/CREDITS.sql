-- =====================================================
-- MODULE CRÉDITS BANCAIRES
-- =====================================================

-- Calcul de mensualité
CREATE OR REPLACE FUNCTION calculer_mensualite(
    p_montant DECIMAL,
    p_taux DECIMAL,
    p_duree INTEGER
) RETURNS DECIMAL AS $$
DECLARE
    v_taux_mensuel DECIMAL;
    v_puissance DECIMAL;
    v_mensualite DECIMAL;
BEGIN
    v_taux_mensuel := p_taux / 1200;
    v_puissance := POWER(1 + v_taux_mensuel, p_duree);
    v_mensualite := (p_montant * v_taux_mensuel * v_puissance) / (v_puissance - 1);
    
    RETURN ROUND(v_mensualite, 2);
END;
$$ LANGUAGE plpgsql;

-- Demande de crédit
CREATE OR REPLACE FUNCTION demander_credit(
    p_id_compte TEXT,
    p_type_credit TEXT,
    p_montant DECIMAL,
    p_duree INTEGER,
    p_garantie TEXT DEFAULT NULL
) RETURNS TEXT AS $$
DECLARE
    v_id_credit TEXT;
    v_id_client TEXT;
    v_revenu DECIMAL;
    v_patrimoine DECIMAL;
    v_capacite DECIMAL;
    v_taux DECIMAL;
    v_mensualite DECIMAL;
    v_frais_dossier DECIMAL;
BEGIN
    -- Récupérer infos client
    SELECT c.id_client, cl.revenu_annuel, cl.patrimoine 
    INTO v_id_client, v_revenu, v_patrimoine
    FROM comptes c
    JOIN clients cl ON c.id_client = cl.id_client
    WHERE c.id_compte = p_id_compte;
    
    -- Capacité d'emprunt (max 35% revenus)
    v_capacite := v_revenu * 0.35;
    
    IF p_montant > v_capacite THEN
        RAISE EXCEPTION 'Montant dépasse la capacité d''emprunt (max: %)', v_capacite;
    END IF;
    
    -- Déterminer taux selon type
    CASE p_type_credit
        WHEN 'CONSOMMATION' THEN
            v_taux := 4.50;
            v_frais_dossier := 250.00;
        WHEN 'AUTO' THEN
            v_taux := 3.80;
            v_frais_dossier := 200.00;
        WHEN 'IMMOBILIER' THEN
            v_taux := 2.80;
            v_frais_dossier := 1000.00;
        WHEN 'PROFESSIONNEL' THEN
            v_taux := 4.00;
            v_frais_dossier := 500.00;
        WHEN 'LOMBARD' THEN
            IF p_montant > v_patrimoine * 0.5 THEN
                RAISE EXCEPTION 'Crédit Lombard: montant supérieur à 50%% du patrimoine';
            END IF;
            v_taux := 2.50;
            v_frais_dossier := 150.00;
        ELSE
            RAISE EXCEPTION 'Type de crédit invalide';
    END CASE;
    
    -- Calcul mensualité
    v_mensualite := calculer_mensualite(p_montant, v_taux, p_duree);
    
    -- Générer ID crédit
    v_id_credit := 'CR' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_credit,3) AS INTEGER)) FROM credits), 0) + 1)::TEXT, 4, '0');
    
    -- Insérer crédit
    INSERT INTO credits (id_credit, id_compte, type_credit, montant, taux_annuel, 
                         duree_mois, mensualite, capital_restant, date_octroi, 
                         garantie, frais_dossier, statut, conseiller)
    VALUES (v_id_credit, p_id_compte, p_type_credit, p_montant, v_taux, 
            p_duree, v_mensualite, p_montant, CURRENT_DATE, 
            p_garantie, v_frais_dossier, 'ACTIF', CURRENT_USER);
    
    -- Créditer le compte
    UPDATE comptes SET solde = solde + p_montant WHERE id_compte = p_id_compte;
    
    -- Générer échéances
    PERFORM generer_echeances(v_id_credit, p_duree, v_mensualite, p_montant, v_taux);
    
    RETURN v_id_credit;
END;
$$ LANGUAGE plpgsql;

-- Générer échéances
CREATE OR REPLACE FUNCTION generer_echeances(
    p_id_credit TEXT,
    p_duree INTEGER,
    p_mensualite DECIMAL,
    p_montant DECIMAL,
    p_taux DECIMAL
) RETURNS VOID AS $$
DECLARE
    v_i INTEGER;
    v_date_echeance DATE;
    v_capital_restant DECIMAL;
    v_interet DECIMAL;
    v_capital DECIMAL;
BEGIN
    v_capital_restant := p_montant;
    
    FOR v_i IN 1..p_duree LOOP
        v_date_echeance := CURRENT_DATE + (v_i || ' months')::INTERVAL;
        v_interet := v_capital_restant * p_taux / 1200;
        v_capital := p_mensualite - v_interet;
        v_capital_restant := v_capital_restant - v_capital;
        
        INSERT INTO echeances (id_echeance, id_credit, numero_echeance, date_echeance,
                               montant_capital, montant_interet, montant_total)
        VALUES ('ECH' || LPAD(v_i::TEXT, 6, '0') || '_' || p_id_credit,
                p_id_credit, v_i, v_date_echeance,
                ROUND(v_capital, 2), ROUND(v_interet, 2), p_mensualite);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Rembourser une échéance
CREATE OR REPLACE FUNCTION rembourser_echeance(
    p_id_credit TEXT,
    p_numero_echeance INTEGER
) RETURNS TEXT AS $$
DECLARE
    v_montant DECIMAL;
    v_id_compte TEXT;
    v_solde DECIMAL;
    v_id_transaction TEXT;
BEGIN
    -- Récupérer montant et compte
    SELECT e.montant_total, c.id_compte, c.solde 
    INTO v_montant, v_id_compte, v_solde
    FROM echeances e
    JOIN credits cr ON e.id_credit = cr.id_credit
    JOIN comptes c ON cr.id_compte = c.id_compte
    WHERE e.id_credit = p_id_credit AND e.numero_echeance = p_numero_echeance;
    
    IF v_solde < v_montant THEN
        RAISE EXCEPTION 'Solde insuffisant pour rembourser l''échéance';
    END IF;
    
    -- Générer transaction
    v_id_transaction := 'T' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDDHH24MISS') || 
                        LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_transaction,16) AS INTEGER)) 
                               FROM transactions WHERE date_transaction >= CURRENT_DATE), 0) + 1)::TEXT, 4, '0');
    
    -- Insérer transaction
    INSERT INTO transactions (id_transaction, id_compte, type_transaction, montant, 
                              description, reference_externe, date_transaction, statut)
    VALUES (v_id_transaction, v_id_compte, 'PRELEVEMENT', v_montant, 
            'Remboursement crédit ' || p_id_credit || ' - Échéance ' || p_numero_echeance,
            p_id_credit, CURRENT_TIMESTAMP, 'VALIDEE');
    
    -- Mettre à jour échéance
    UPDATE echeances 
    SET statut = 'PAYE', date_paiement = CURRENT_DATE, id_transaction = v_id_transaction
    WHERE id_credit = p_id_credit AND numero_echeance = p_numero_echeance;
    
    -- Mettre à jour capital restant
    UPDATE credits 
    SET capital_restant = capital_restant - 
        (SELECT montant_capital FROM echeances WHERE id_credit = p_id_credit AND numero_echeance = p_numero_echeance)
    WHERE id_credit = p_id_credit;
    
    -- Débiter le compte
    UPDATE comptes SET solde = solde - v_montant WHERE id_compte = v_id_compte;
    
    RETURN 'Échéance remboursée avec succès';
END;
$$ LANGUAGE plpgsql;

-- Vue crédits client
CREATE VIEW vue_credits_client AS
SELECT 
    c.id_client,
    c.nom,
    c.prenom,
    cr.id_credit,
    cr.type_credit,
    cr.montant,
    cr.taux_annuel,
    cr.duree_mois,
    cr.mensualite,
    cr.capital_restant,
    cr.statut,
    (cr.montant - cr.capital_restant) as capital_rembourse,
    ROUND((cr.montant - cr.capital_restant) / cr.montant * 100, 2) as pourcentage_rembourse,
    (SELECT COUNT(*) FROM echeances WHERE id_credit = cr.id_credit AND statut = 'PAYE') as echeances_payees,
    (SELECT COUNT(*) FROM echeances WHERE id_credit = cr.id_credit) as total_echeances
FROM clients c
JOIN comptes cp ON c.id_client = cp.id_client
JOIN credits cr ON cp.id_compte = cr.id_compte;

-- Alertes crédits
CREATE VIEW vue_alertes_credits AS
SELECT 
    cr.id_credit,
    cr.id_compte,
    c.id_client,
    c.nom,
    c.prenom,
    cr.montant,
    cr.capital_restant,
    cr.mensualite,
    (SELECT date_echeance FROM echeances 
     WHERE id_credit = cr.id_credit AND statut = 'EN_ATTENTE' 
     ORDER BY date_echeance LIMIT 1) as prochaine_echeance,
    CASE 
        WHEN cr.capital_restant < cr.montant * 0.2 THEN 'CREDIT_PRESQUE_TERMINE'
        WHEN (SELECT date_echeance FROM echeances WHERE id_credit = cr.id_credit AND statut = 'EN_ATTENTE' 
              ORDER BY date_echeance LIMIT 1) < CURRENT_DATE + INTERVAL '7 days' THEN 'ECHEANCE_PROCHE'
        WHEN cr.statut = 'IMPAGAYE' THEN 'CREDIT_IMPAGAYE'
        ELSE 'NORMAL'
    END as alerte
FROM credits cr
JOIN comptes cp ON cr.id_compte = cp.id_compte
JOIN clients c ON cp.id_client = c.id_client
WHERE cr.statut = 'ACTIF';
