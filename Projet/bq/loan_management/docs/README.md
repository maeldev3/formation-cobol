# Loan Management System - Gestion des Prêts Bancaires
## Projet #9 GnuCOBOL

---

## Description

Système complet de gestion des prêts bancaires en GnuCOBOL.
Couvre le cycle de vie complet : demande → validation → amortissement → rapport.

---

## Fonctionnalités

| Module | Description |
|--------|-------------|
| Demande de prêt | Saisie, calcul mensualité, confirmation |
| Validation | Approbation ou rejet par un responsable |
| Consultation | Détail complet d'un prêt |
| Amortissement | Tableau mensuel capital/intérêts/solde |
| Liste | Filtrée par statut |
| Simulateur | Calcul rapide sans sauvegarde |
| Rapport | Statistiques et export texte |

---

## Formule de calcul

```
          C × t
M = ─────────────────
      1 - (1 + t)^-n
```

- **M** = mensualité
- **C** = capital emprunté
- **t** = taux mensuel (taux annuel / 12 / 100)
- **n** = nombre de mois

---

## Structure des fichiers

```
loan_management/
├── src/
│   ├── LOAN-MAIN.cbl      Programme principal (menu + logique)
│   ├── LOAN-UTILS.cbl     Module utilitaires
│   └── LOAN-REPORT.cbl    Générateur de rapports
├── data/
│   ├── LOANS.dat          Fichier indexé des prêts (ISAM)
│   ├── AMORT.dat          Tableau d'amortissement (ISAM)
│   └── LOAN_REPORT.txt    Rapport généré
├── scripts/
│   ├── build.sh           Script de compilation
│   └── run-demo.sh        Lancement démo
├── docs/
│   └── README.md          Cette documentation
└── bin/
    ├── loan-main          Exécutable principal
    └── loan-report        Générateur rapport standalone
```

---

## Prérequis

```bash
sudo apt-get install gnucobol
```

---

## Compilation et lancement

```bash
# Donner droits d'exécution
chmod +x scripts/build.sh scripts/run-demo.sh

# Compiler
./scripts/build.sh

# Lancer
./bin/loan-main

# Rapport standalone
./bin/loan-report
```

---

## Statuts des prêts

| Code | Statut | Description |
|------|--------|-------------|
| D | En attente | Demande soumise, validation requise |
| A | Approuvé | Validé, prêt à démarrer |
| R | Rejeté | Refusé par le responsable |
| E | Actif | En cours de remboursement |
| C | Clôturé | Remboursement terminé |

---

## Fichiers ISAM

### LOANS.dat - Clés
- Clé primaire : `LN-ID` (ex: LN100001)
- Clé alternative : `LN-CLIENT-ID` (avec duplicates)

### AMORT.dat - Clés
- Clé primaire composite : `AM-LOAN-ID` + `AM-MONTH-NUM`

---

## Concepts COBOL appris

- Calcul financier avancé (puissance itérative, formule annuité)
- Fichiers ISAM multi-clés avec `ALTERNATE RECORD KEY`
- `START ... KEY >= ...` pour balayage séquentiel
- Modules séparés (LOAN-MAIN, LOAN-UTILS, LOAN-REPORT)
- Gestion des statuts avec `88 level`
- Rapport texte avec FILE SECTION

---

## Exemple de simulation

Pour un prêt de **10 000 000 MGA** à **12%/an** sur **24 mois** :

```
Mensualité    :   470 735.25 MGA
Total remb.   : 11 297 646.00 MGA
Total intérêts:  1 297 646.00 MGA
```

---

*GnuCOBOL Banking System - Projet #9*
