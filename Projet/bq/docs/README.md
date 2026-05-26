# Bank Customer Management System
## Système de Gestion des Clients Bancaires en COBOL

Version : 1.0.0 | Niveau : Senior COBOL

---

## Fonctionnalités

| # | Fonctionnalité | Description |
|---|---------------|-------------|
| 1 | **Création client** | Saisie complète avec validation (nom, date, CNI, email, profil, solde) |
| 2 | **Modification** | Mise à jour ciblée (coordonnées, adresse, profil, statut, solde) |
| 3 | **Suppression** | Suppression avec confirmation obligatoire |
| 4 | **Recherche** | Par ID / Nom / Profil / Statut |
| 5 | **Liste complète** | Affichage tabulaire + total des soldes |
| 6 | **Gestion profils** | Promotion/rétrogradation STANDARD ↔ PREMIUM ↔ CORPORATE |
| 7 | **Rapports** | Statistiques console + rapport fichier `.txt` |
| 8 | **Audit** | Journal automatique de toutes les opérations |

---

## Architecture

```
bank-cobol/
├── src/
│   ├── BANKCUST.cbl     Programme principal (menu, CRUD, profils)
│   ├── CUSTINIT.cbl     Initialisation base + données exemple
│   └── CUSTVAL.cbl      Sous-programme de validation (module)
├── data/
│   ├── CUSTFILE.dat     Fichier client indexé (ISAM)
│   ├── AUDITLOG.dat     Journal d'audit séquentiel
│   └── CUSTRPT.txt      Rapport généré
├── bin/                 Exécutables compilés
├── docs/
│   └── README.md        Cette documentation
└── scripts/
    ├── build.sh         Script de compilation
    └── run.sh           Script de lancement
```

---

## Prérequis

**GnuCOBOL** (open-source COBOL compiler) :

```bash
# Ubuntu/Debian
sudo apt-get install gnucobol

# Fedora/RHEL
sudo dnf install gnucobol

# macOS
brew install gnucobol

# Vérification
cobc --version
```

---

## Compilation et Lancement

```bash
# 1. Rendre les scripts exécutables
chmod +x scripts/build.sh scripts/run.sh

# 2. Compiler
./scripts/build.sh

# 3. Initialiser la base avec 5 clients exemples
./scripts/run.sh init

# 4. Lancer le système
./scripts/run.sh
# ou directement :
./bin/BANKCUST
```

---

## Structure des données - Enregistrement Client (300 octets)

| Champ | Type COBOL | Taille | Description |
|-------|-----------|--------|-------------|
| CUST-ID | PIC 9(8) | 8 | Identifiant unique (clé primaire) |
| CUST-NOM | PIC X(30) | 30 | Nom de famille (clé alternée) |
| CUST-PRENOM | PIC X(25) | 25 | Prénom |
| CUST-DATE-NAIS | PIC 9(8) | 8 | Date naissance AAAAMMJJ |
| CUST-CNI | PIC X(15) | 15 | Numéro CNI/Passeport |
| CUST-TELEPHONE | PIC X(15) | 15 | Téléphone |
| CUST-EMAIL | PIC X(50) | 50 | Adresse email |
| CUST-RUE | PIC X(50) | 50 | Rue |
| CUST-VILLE | PIC X(30) | 30 | Ville |
| CUST-CODE-POST | PIC X(10) | 10 | Code postal |
| CUST-PAYS | PIC X(20) | 20 | Pays |
| CUST-PROFIL | PIC X(10) | 10 | STANDARD/PREMIUM/CORPORATE |
| CUST-SOLDE | PIC S9(12)V99 COMP-3 | 8 | Solde (packed decimal) |
| CUST-DATE-OUVERTURE | PIC 9(8) | 8 | Date ouverture |
| CUST-DATE-MAJ | PIC 9(8) | 8 | Dernière modification |
| CUST-STATUT | PIC X(1) | 1 | A=Actif I=Inactif B=Bloqué |
| CUST-NB-COMPTES | PIC 9(3) | 3 | Nombre de comptes |

---

## Profils Clients

| Profil | Solde Minimum | Avantages |
|--------|--------------|-----------|
| **STANDARD** | Aucun | Services bancaires de base |
| **PREMIUM** | 10 000,00 | Conseiller dédié, taux préférentiels, carte Gold |
| **CORPORATE** | 100 000,00 | Gestionnaire privé, investissements exclusifs |

---

## Concepts COBOL utilisés

- **ORGANIZATION IS INDEXED** — fichier ISAM avec clé primaire et clé alternée
- **ACCESS MODE IS DYNAMIC** — accès séquentiel ET direct dans le même programme
- **88-level condition names** — conditions nommées (PROFIL-STANDARD, STATUT-ACTIF…)
- **COMP-3 (Packed Decimal)** — stockage efficace des montants financiers
- **PERFORM ... THRU** — blocs avec point de sortie explicite
- **EVALUATE TRUE** — équivalent du switch/case multi-conditions
- **ALTERNATE RECORD KEY WITH DUPLICATES** — recherche par nom
- **FILE STATUS** — gestion complète des codes retour fichier
- **REWRITE / DELETE** — mise à jour et suppression en fichier indexé
- **LINKAGE SECTION** — passage de paramètres au sous-programme CUSTVAL
- **STRING / MOVE** — manipulation de chaînes
- **FUNCTION CURRENT-DATE** — récupération date/heure système

---

## Données exemples chargées par CUSTINIT

| ID | Nom | Profil | Statut | Solde |
|----|-----|--------|--------|-------|
| 1 | RAKOTO Jean-Baptiste | PREMIUM | Actif | 50 000,00 |
| 2 | RATSIMBA Marie Claire | CORPORATE | Actif | 1 500 000,00 |
| 3 | ANDRIAMAHEFA Paul Emile | STANDARD | Actif | 2 500,00 |
| 4 | RAKOTONDRABE Sophie | STANDARD | Inactif | 850,00 |
| 5 | RANDRIA Hery | PREMIUM | Bloqué | 25 000,00 |

---

## Codes de retour programme

| Code | Constante | Signification |
|------|-----------|---------------|
| 0 | RC-OK | Succès |
| 4 | RC-NOT-FOUND | Enregistrement non trouvé |
| 8 | RC-DUPLICATE | Doublon clé primaire |
| 12 | RC-FILE-ERROR | Erreur I/O fichier |
| 16 | RC-VALIDATION-ERROR | Données invalides |

---

*COBOL — Common Business-Oriented Language*
