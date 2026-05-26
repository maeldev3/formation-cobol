-- =====================================================
-- MODULE RAPPORTS ET DASHBOARD
-- =====================================================

-- Rapport journalier
CREATE VIEW vue_rapport_journalier AS
SELECT 
    CURRENT_DATE as date_rapport,
    (SELECT COUNT(*) FROM clients WHERE date(date_creation) = CURRENT_DATE) as nouveaux_clients,
    (SELECT COUNT(*) FROM comptes WHERE date(date_ouverture) = CURRENT_DATE) as nouveaux_comptes,
    (SELECT COUNT(*) FROM transactions WHERE date(date_transaction) = CURRENT_DATE) as nb_transactions,
    (SELECT COALESCE(SUM(montant), 0) FROM transactions 
     WHERE type_transaction = 'DEPOT' AND date(date_transaction) = CURRENT_DATE) as total_depots,
    (SELECT COALESCE(SUM(montant), 0) FROM transactions 
     WHERE type_transaction = 'RETRAIT' AND date(date_transaction) = CURRENT_DATE) as total_retraits,
    (SELECT COALESCE(SUM(montant), 0) FROM transactions 
     WHERE type_transaction = 'VIREMENT' AND date(date_transaction) = CURRENT_DATE) as total_virements,
    (SELECT COUNT(*) FROM alertes WHERE date(date_alerte) = CURRENT_DATE AND statut = 'ACTIVE') as alertes_nouvelles;

-- Rapport mensuel
CREATE VIEW vue_rapport_mensuel AS
SELECT 
    strftime('%Y-%m', date_transaction) as mois,
    COUNT(*) as nb_transactions,
    SUM(CASE WHEN type_transaction = 'DEPOT' THEN montant ELSE 0 END) as total_depots,
    SUM(CASE WHEN type_transaction = 'RETRAIT' THEN montant ELSE 0 END) as total_retraits,
    SUM(CASE WHEN type_transaction = 'VIREMENT' THEN montant ELSE 0 END) as total_virements,
    SUM(CASE WHEN type_transaction IN ('DEPOT', 'VIREMENT') THEN montant ELSE 0 END) - 
    SUM(CASE WHEN type_transaction IN ('RETRAIT', 'PAIEMENT_CB') THEN montant ELSE 0 END) as solde_mois
FROM transactions
GROUP BY strftime('%Y-%m', date_transaction)
ORDER BY mois DESC;

-- Rapport annuel
CREATE VIEW vue_rapport_annuel AS
SELECT 
    strftime('%Y', date_creation) as annee,
    COUNT(*) as nb_clients,
    SUM(CASE WHEN strftime('%m', date_creation) BETWEEN '01' AND '03' THEN 1 ELSE 0 END) as trim1,
    SUM(CASE WHEN strftime('%m', date_creation) BETWEEN '04' AND '06' THEN 1 ELSE 0 END) as trim2,
    SUM(CASE WHEN strftime('%m', date_creation) BETWEEN '07' AND '09' THEN 1 ELSE 0 END) as trim3,
    SUM(CASE WHEN strftime('%m', date_creation) BETWEEN '10' AND '12' THEN 1 ELSE 0 END) as trim4,
    ROUND(AVG(revenu_annuel), 2) as revenu_moyen
FROM clients
GROUP BY strftime('%Y', date_creation)
ORDER BY annee DESC;

-- Dashboard global
CREATE VIEW vue_dashboard_global AS
SELECT 
    'Clients' as indicateur,
    COUNT(*) as valeur,
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', date_creation)) as evolution
FROM clients
GROUP BY strftime('%Y-%m', date_creation)
UNION ALL
SELECT 
    'Comptes',
    COUNT(*),
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', date_ouverture))
FROM comptes
GROUP BY strftime('%Y-%m', date_ouverture)
UNION ALL
SELECT 
    'Transactions',
    COUNT(*),
    COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY strftime('%Y-%m', date_transaction))
FROM transactions
GROUP BY strftime('%Y-%m', date_transaction);

-- Rapport rentabilité
CREATE VIEW vue_rentabilite AS
SELECT 
    strftime('%Y-%m', date_transaction) as mois,
    SUM(CASE WHEN type_transaction IN ('DEPOT', 'VIREMENT') THEN montant ELSE 0 END) as entrees,
    SUM(CASE WHEN type_transaction IN ('RETRAIT', 'PAIEMENT_CB', 'PRELEVEMENT') THEN montant ELSE 0 END) as sorties,
    SUM(CASE WHEN type_transaction IN ('DEPOT', 'VIREMENT') THEN montant ELSE 0 END) - 
    SUM(CASE WHEN type_transaction IN ('RETRAIT', 'PAIEMENT_CB', 'PRELEVEMENT') THEN montant ELSE 0 END) as flux_net,
    (SELECT COALESCE(SUM(montant), 0) FROM credits 
     WHERE strftime('%Y-%m', date_octroi) = strftime('%Y-%m', date_transaction)) as credits_accordes,
    (SELECT COALESCE(SUM(montant), 0) FROM echeances 
     WHERE strftime('%Y-%m', date_paiement) = strftime('%Y-%m', date_transaction) AND statut = 'PAYE') as remboursements
FROM transactions
GROUP BY strftime('%Y-%m', date_transaction)
ORDER BY mois DESC;
