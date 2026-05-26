-- =====================================================
-- MODULE ALERTES ET SURVEILLANCE
-- =====================================================

-- Créer alerte automatique
CREATE OR REPLACE FUNCTION creer_alerte_automatique() RETURNS TRIGGER AS $$
DECLARE
    v_id_alerte TEXT;
BEGIN
    -- Alerte solde faible
    IF NEW.solde < 100 AND OLD.solde >= 100 THEN
        v_id_alerte := 'ALT' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_alerte,4) AS INTEGER)) FROM alertes), 0) + 1)::TEXT, 5, '0');
        INSERT INTO alertes (id_alerte, id_client, id_compte, type_alerte, niveau, message, statut)
        SELECT NEW.id_compte, c.id_client, NEW.id_compte, 'SOLDE_FAIBLE', 'WARNING',
               'Solde du compte ' || NEW.id_compte || ' est faible: ' || NEW.solde || '€',
               'ACTIVE'
        FROM comptes cp
        JOIN clients c ON cp.id_client = c.id_client
        WHERE cp.id_compte = NEW.id_compte;
    END IF;
    
    -- Alerte découvert
    IF NEW.solde < 0 AND OLD.solde >= 0 THEN
        v_id_alerte := 'ALT' || LPAD((COALESCE((SELECT MAX(CAST(SUBSTR(id_alerte,4) AS INTEGER)) FROM alertes), 0) + 1)::TEXT, 5, '0');
        INSERT INTO alertes (id_alerte, id_client, id_compte, type_alerte, niveau, message, statut)
        SELECT NEW.id_compte, c.id_client, NEW.id_compte, 'DECOUVERT', 'CRITICAL',
               'Compte ' || NEW.id_compte || ' en découvert: ' || ABS(NEW.solde) || '€',
               'ACTIVE'
        FROM comptes cp
        JOIN clients c ON cp.id_client = c.id_client
        WHERE cp.id_compte = NEW.id_compte;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger sur comptes
CREATE TRIGGER trigger_alerte_compte
AFTER UPDATE OF solde ON comptes
FOR EACH ROW
EXECUTE FUNCTION creer_alerte_automatique();

-- Vue alertes actives
CREATE VIEW vue_alertes_actives AS
SELECT 
    a.id_alerte,
    a.type_alerte,
    a.niveau,
    a.message,
    a.date_alerte,
    c.id_client,
    c.nom,
    c.prenom,
    c.telephone,
    c.email,
    cp.id_compte,
    cp.solde
FROM alertes a
JOIN clients c ON a.id_client = c.id_client
LEFT JOIN comptes cp ON a.id_compte = cp.id_compte
WHERE a.statut = 'ACTIVE'
ORDER BY a.niveau DESC, a.date_alerte DESC;

-- Dashboard alertes
CREATE VIEW vue_dashboard_alertes AS
SELECT 
    niveau,
    type_alerte,
    COUNT(*) as nombre,
    MIN(date_alerte) as plus_ancienne,
    MAX(date_alerte) as plus_recente
FROM alertes
WHERE statut = 'ACTIVE'
GROUP BY niveau, type_alerte
ORDER BY 
    CASE niveau 
        WHEN 'CRITICAL' THEN 1
        WHEN 'WARNING' THEN 2
        ELSE 3
    END;
