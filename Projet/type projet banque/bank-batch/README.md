# Bank Batch Processing System 🏦
**Traitement Batch Bancaire en COBOL** — Projet ⭐⭐⭐⭐

Système de traitement nocturne bancaire complet développé en GnuCOBOL.
Simule un vrai batch bancaire : intérêts, frais, découverts, dormants.

---

## Structure du Projet

```
bank-batch/
├── src/
│   ├── BATCH-MAIN.cbl      # Orchestrateur principal (menu + 9 modules)
│   ├── BATCH-INIT.cbl      # Initialisation : 20 comptes de démo
│   └── BATCH-HISTORY.cbl   # Historique & consultation transactions
├── scripts/
│   ├── build.sh            # Compilation GnuCOBOL
│   └── run-demo.sh         # Démo automatique complète
├── data/                   # Fichiers indexés ISAM (générés au runtime)
├── logs/                   # Rapport batch + journal
├── bin/                    # Exécutables compilés (générés au build)
└── README.md
```

---

## Prérequis

```bash
# Ubuntu / Debian
sudo apt-get install gnucobol

# Vérification
cobc --version
```

---

## Installation & Démarrage Rapide

```bash
# 1. Compiler
./scripts/build.sh

# 2. Démo automatique complète (recommandé pour commencer)
./scripts/run-demo.sh

# 3. Mode interactif
./bin/batch-init      # Créer les 20 comptes de test
./bin/batch-main      # Lancer le système interactif
./bin/batch-history   # Consulter l'historique
```

---

## Fonctionnalités

### BATCH-MAIN — Menu principal (9 options)

| Option | Fonction |
|--------|----------|
| 1 | **Batch complet nocturne** — enchaîne tous les traitements |
| 2 | Calcul des intérêts (épargne 3.5%/an au quotidien) |
| 3 | Prélèvement frais mensuels (CRT: 5 000 MGA, PRO: 15 000 MGA) |
| 4 | Intérêts de découvert (18%/an pour soldes négatifs) |
| 5 | Détection comptes dormants |
| 6 | Création d'un nouveau compte |
| 7 | Consultation d'un compte |
| 8 | Liste des comptes (filtres: tous/actifs/dormants/découverts) |
| 9 | Afficher le rapport du dernier batch |

### Types de comptes

| Code | Type | Intérêts | Frais |
|------|------|----------|-------|
| CRT  | Courant | 0% | 5 000 MGA/mois |
| EPG  | Épargne | 3.50%/an | 0 MGA |
| PRO  | Professionnel | 0% | 15 000 MGA/mois |

### Données de test (20 comptes)

- **5 comptes CRT** (dont 2 en découvert)
- **5 comptes EPG** (dont 1 gros compte 22M MGA)
- **5 comptes PRO** (entreprises malgaches)
- **5 comptes spéciaux** (zéro, bloqué, dormant, etc.)

---

## Fichiers de données ISAM

| Fichier | Contenu |
|---------|---------|
| `data/ACCOUNTS.dat` | Comptes bancaires (fichier indexé) |
| `data/TRANSACTIONS.dat` | Transactions générées par le batch |
| `logs/BATCH.log` | Journal d'exécution |
| `logs/BATCH_REPORT.txt` | Rapport détaillé du dernier batch |

---

## Concepts COBOL Appris

- **Fichiers ISAM indexés** (`ORGANIZATION IS INDEXED`, `REWRITE`, `START`)
- **Traitement séquentiel de masse** (parcours de tous les comptes)
- **88-levels** pour conditions lisibles (`AC-ACTIVE`, `AC-IS-EPARGNE`)
- **COMPUTE** pour calculs financiers (taux journalier, intérêts composés)
- **Écriture de transactions** avec clé composite
- **Rapports** : fichiers séquentiels formatés
- **Batch multi-phases** : orchestration de modules indépendants

---

## Exemple de Rapport Généré

```
======================================================================
  RAPPORT BATCH NOCTURNE - 2026-06-09 - ID: BATCH-2026-06-09-02:15
======================================================================
  RESUME DES TRAITEMENTS
----------------------------------------------------------------------
  Comptes traites       : 0000020
  Interets calcules     : 0000005
  Total interets payes  :         57,671.23 MGA
  Frais preleves        : 0000019
  Total frais collectes :        255,000.00 MGA
  Decouverts traites    : 0000003
  Interets decouverts   :         13,150.68 MGA
  Comptes dormants      : 0000000
  Erreurs               : 0000000
======================================================================
```

---

## Architecture COBOL

```
BATCH-INIT.cbl
  └── Écrit 20 ACCOUNT-RECORD dans ACCOUNTS.dat (ISAM)

BATCH-MAIN.cbl
  ├── 010-INIT          : ouverture fichiers, construction BATCH-ID
  ├── 020-MAIN-MENU     : dispatch des 9 options
  ├── 100-FULL-BATCH    : orchestration complète (modules 2→5)
  ├── 200-INTEREST      : calcul intérêts journaliers
  ├── 300-FEES          : prélèvement frais mensuels
  ├── 400-OVERDRAFT     : pénalités découvert
  ├── 500-DORMANT       : détection inactivité
  ├── 600-CREATE        : saisie nouveau compte
  ├── 700-CONSULT       : lecture compte par ID
  ├── 800-LIST          : parcours séquentiel avec filtres
  ├── 900-REPORT        : affichage rapport
  └── 999-WRITE-TRN-*   : écriture dans TRANSACTIONS.dat

BATCH-HISTORY.cbl
  ├── Menu 5 choix (toutes, par compte, INT, FRA, DEC)
  └── Lecture séquentielle TRANSACTIONS.dat avec START/READ NEXT
```
