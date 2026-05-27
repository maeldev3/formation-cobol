-- =====================================================
-- MODULE EMPLOYÉS
-- =====================================================

-- Créer un employé
CREATE OR REPLACE FUNCTION creer_employe(
    p_id_agence TEXT,
    p_nom TEXT,
    p_prenom TEXT,
    p_fonction TEXT,
    p_email TEXT,
    p_telephone TEXT,
    p_salaire_base DECIMAL,
    p_login TEXT,
    p_password TEXT,
    p_role TEXT
) RETURNS TEXT AS $$
DECLARE
    v_id_employe TEXT;
BEGIN
    -- Générer ID
    v_id_employe := 'EMP' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_employe,4) AS INTEGER)) FROM employes), 0) + 1)::TEXT, 4, '0');
    
    INSERT INTO employes (id_employe, id_agence, nom, prenom, fonction, email, 
                          telephone, date_embauche, salaire_base, login, mot_de_passe, role, statut)
    VALUES (v_id_employe, p_id_agence, p_nom, p_prenom, p_fonction, p_email,
            p_telephone, CURRENT_DATE, p_salaire_base, p_login, p_password, p_role, 'ACTIF');
    
    -- Mettre à jour compteur agence
    UPDATE agences SET nombre_employes = nombre_employes + 1 WHERE id_agence = p_id_agence;
    
    RETURN v_id_employe;
END;
$$ LANGUAGE plpgsql;

-- Authentification
CREATE OR REPLACE FUNCTION authentifier(
    p_login TEXT,
    p_password TEXT
) RETURNS TABLE(
    id_employe TEXT,
    nom TEXT,
    prenom TEXT,
    role TEXT,
    id_agence TEXT,
    nom_agence TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT e.id_employe, e.nom, e.prenom, e.role, e.id_agence, a.nom_agence
    FROM employes e
    JOIN agences a ON e.id_agence = a.id_agence
    WHERE e.login = p_login AND e.mot_de_passe = p_password AND e.statut = 'ACTIF';
END;
$$ LANGUAGE plpgsql;

-- Performance employé
CREATE VIEW vue_performance_employe AS
SELECT 
    e.id_employe,
    e.nom,
    e.prenom,
    e.fonction,
    e.role,
    a.nom_agence,
    e.date_embauche,
    e.salaire_base,
    COUNT(DISTINCT c.id_client) as clients_crees,
    COUNT(DISTINCT cp.id_compte) as comptes_ouverts,
    COUNT(DISTINCT cr.id_credit) as credits_accordes,
    SUM(cr.montant) as montant_credits,
    (SELECT COUNT(*) FROM transactions t 
     WHERE t.agence = a.id_agence 
     AND date(t.date_transaction) >= date('now', '-30 days')) as transactions_30j
FROM employes e
JOIN agences a ON e.id_agence = a.id_agence
LEFT JOIN clients c ON c.created_by = e.id_employe
LEFT JOIN comptes cp ON cp.id_client = c.id_client
LEFT JOIN credits cr ON cr.id_compte = cp.id_compte AND cr.conseiller = e.id_employe
GROUP BY e.id_employe, e.nom, e.prenom, e.fonction, e.role, a.nom_agence, e.date_embauche, e.salaire_base;
