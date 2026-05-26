-- =====================================================
-- MODULE AGENCES BANCAIRES
-- =====================================================

-- Créer une agence
CREATE OR REPLACE FUNCTION creer_agence(
    p_nom TEXT,
    p_adresse TEXT,
    p_code_postal TEXT,
    p_ville TEXT,
    p_telephone TEXT,
    p_email TEXT,
    p_capital DECIMAL,
    p_region TEXT
) RETURNS TEXT AS $$
DECLARE
    v_id_agence TEXT;
    v_code_agence TEXT;
BEGIN
    -- Générer ID
    v_id_agence := 'A' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_agence,2) AS INTEGER)) FROM agences), 0) + 1)::TEXT, 3, '0');
    v_code_agence := 'AG' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(code_agence,3) AS INTEGER)) FROM agences), 0) + 1)::TEXT, 3, '0');
    
    INSERT INTO agences (id_agence, code_agence, nom_agence, adresse, code_postal, 
                         ville, telephone, email, capital, region, statut, date_creation)
    VALUES (v_id_agence, v_code_agence, p_nom, p_adresse, p_code_postal,
            p_ville, p_telephone, p_email, p_capital, p_region, 'ACTIF', CURRENT_DATE);
    
    RETURN v_id_agence;
END;
$$ LANGUAGE plpgsql;

-- Statistiques agence
CREATE VIEW vue_stats_agence AS
SELECT 
    a.id_agence,
    a.nom_agence,
    a.ville,
    a.region,
    COUNT(DISTINCT e.id_employe) as nb_employes,
    COUNT(DISTINCT c.id_client) as nb_clients,
    COUNT(DISTINCT cp.id_compte) as nb_comptes,
    SUM(cp.solde) as encours_total,
    AVG(cp.solde) as solde_moyen,
    (SELECT COUNT(*) FROM transactions t 
     JOIN comptes cp2 ON t.id_compte = cp2.id_compte 
     WHERE cp2.id_compte IN (SELECT id_compte FROM comptes WHERE agence_ouverture = a.id_agence)
     AND date(t.date_transaction) >= date('now', '-30 days')) as transactions_30j
FROM agences a
LEFT JOIN employes e ON a.id_agence = e.id_agence AND e.statut = 'ACTIF'
LEFT JOIN comptes cp ON a.id_agence = cp.agence_ouverture
LEFT JOIN clients c ON cp.id_client = c.id_client
GROUP BY a.id_agence, a.nom_agence, a.ville, a.region;

-- Performance agence
CREATE VIEW vue_performance_agence AS
SELECT 
    a.id_agence,
    a.nom_agence,
    a.region,
    COUNT(DISTINCT cp.id_compte) as nb_comptes,
    SUM(CASE WHEN cp.date_ouverture >= date('now', '-1 year') THEN 1 ELSE 0 END) as nouveaux_comptes_an,
    SUM(cp.solde) as encours,
    ROUND(AVG(cp.solde), 2) as solde_moyen,
    ROUND(SUM(CASE WHEN cp.type_compte = 'EPARGNE' THEN cp.solde ELSE 0 END) / NULLIF(SUM(cp.solde), 0) * 100, 2) as part_epargne,
    (SELECT COUNT(*) FROM credits cr 
     JOIN comptes cp2 ON cr.id_compte = cp2.id_compte 
     WHERE cp2.agence_ouverture = a.id_agence AND cr.statut = 'ACTIF') as credits_actifs,
    (SELECT SUM(cr.montant) FROM credits cr 
     JOIN comptes cp2 ON cr.id_compte = cp2.id_compte 
     WHERE cp2.agence_ouverture = a.id_agence AND cr.statut = 'ACTIF') as encours_credits
FROM agences a
LEFT JOIN comptes cp ON a.id_agence = cp.agence_ouverture AND cp.statut = 'ACTIF'
GROUP BY a.id_agence, a.nom_agence, a.region;
