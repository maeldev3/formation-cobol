# Branch Cash Management System
## Gestion Caisse Agence Bancaire — GnuCOBOL + SQLite

---

## Structure du projet

```
cash-mgmt/
├── src/
│   ├── CASH-MAIN.cbl      # Programme principal (menu, modules)
│   ├── CASH-INIT.cbl      # Initialisation base + données démo
│   └── DB-BRIDGE.cpy      # Copybook variables SQLite
├── bridge/
│   └── db_bridge.c        # Pont C → SQLite (appelé depuis COBOL)
├── scripts/
│   ├── build.sh           # Compilation GnuCOBOL + C + SQLite
│   ├── run.sh             # Lancement interactif
│   └── run-demo.sh        # Démo automatique complète
├── db/                    # Base SQLite générée (caisse.db)
├── bin/                   # Exécutables compilés
└── README.md
```

---

## Prérequis

```bash
sudo apt-get install gnucobol libsqlite3-dev sqlite3
```

---

## Démarrage rapide

```bash
# 1. Compiler
./scripts/build.sh

# 2. Initialiser la base (première fois)
./bin/cash-init

# 3. Lancer en mode interactif
./scripts/run.sh

# OU lancer la démo automatique complète
./scripts/run-demo.sh
```

---

## Fonctionnalités

| Option | Module | Description |
|--------|--------|-------------|
| 1 | Ouverture caisse | Ouvre la caisse du jour, récupère le solde précédent |
| 2 | Entrée espèces | Dépôt, virement, alimentation, remboursement |
| 3 | Sortie espèces | Retrait, paiement, change — contrôle solde suffisant |
| 4 | Inventaire billets | Comptage par coupure MGA, calcul écart théorique/physique |
| 5 | Clôture journée | Ferme la caisse, met à jour le solde agence |
| 6 | Mouvements du jour | Liste chronologique des opérations |
| 7 | Rapport journalier | Totaux entrées/sorties par type, statut caissier |
| 8 | Historique | 50 derniers mouvements ou totaux par journée |

---

## Schéma base SQLite

### `agences`
| Colonne | Type | Description |
|---------|------|-------------|
| id_agence | TEXT PK | Code agence (AG001…) |
| nom | TEXT | Nom complet |
| ville | TEXT | Ville |
| solde_ouverture | INTEGER | Solde initial (en unités MGA) |
| solde_actuel | INTEGER | Solde mis à jour à chaque clôture |
| statut | TEXT | A=Actif |

### `caisses`
| Colonne | Type | Description |
|---------|------|-------------|
| id_caisse | INTEGER PK | Auto-incrémenté |
| id_agence | TEXT | Référence agence |
| date_journee | TEXT | YYYY-MM-DD |
| solde_ouverture | INTEGER | Solde début journée |
| total_entrees | INTEGER | Cumul entrées |
| total_sorties | INTEGER | Cumul sorties |
| solde_theorique | INTEGER | = ouverture + entrées - sorties |
| solde_physique | INTEGER | Inventaire physique billets |
| ecart | INTEGER | physique - théorique |
| statut | TEXT | O=Ouvert, C=Clôturé |
| caissier | TEXT | Nom du caissier |

### `mouvements`
| Colonne | Type | Description |
|---------|------|-------------|
| id_mouvement | INTEGER PK | Auto-incrémenté |
| id_caisse | INTEGER | FK → caisses |
| date_op / heure_op | TEXT | Horodatage opération |
| type_op | TEXT | DEP/VIR/RET/PAY/etc. |
| sens | TEXT | E=Entrée, S=Sortie |
| montant | INTEGER | Montant en MGA |
| solde_apres | INTEGER | Solde après opération |
| libelle / reference | TEXT | Description libre |

### `billets`
| Colonne | Type | Description |
|---------|------|-------------|
| denomination | INTEGER | 100/500/1000/2000/5000/10000/20000/50000 |
| quantite | INTEGER | Nombre de billets |
| montant | INTEGER | denomination × quantite |

---

## Agences de démo

| ID | Nom | Ville | Solde initial |
|----|-----|-------|---------------|
| AG001 | AGENCE ANTANANARIVO CENTRE | Antananarivo | 50 000 000 MGA |
| AG002 | AGENCE TOAMASINA | Toamasina | 30 000 000 MGA |
| AG003 | AGENCE FIANARANTSOA | Fianarantsoa | 20 000 000 MGA |

---

## Architecture technique

```
COBOL (CASH-MAIN.cbl)
    │  CALL "db_open" / "db_exec" / "db_prepare" / "db_step" …
    ▼
C Bridge (db_bridge.c)
    │  sqlite3_open / sqlite3_exec / sqlite3_prepare_v2 …
    ▼
SQLite (db/caisse.db)
```

Le pont C (`db_bridge.c`) traduit les types COBOL (champs PIC X avec espaces trailing, entiers COMP-5) vers les types C/SQLite et inversement.
