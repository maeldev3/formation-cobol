# 🏦 ATM Banking System — COBOL

**Projet #7 | Difficulté : ⭐⭐⭐ | GnuCOBOL**

---

## 📋 Description

Système ATM bancaire complet développé en GnuCOBOL avec fichiers indexés ISAM.
Simule un vrai terminal de banque avec gestion des cartes, PIN, transactions et sessions.

---

## 🗂️ Structure du projet

```
atm-cobol/
├── src/
│   ├── ATM-MAIN.cbl    ← Programme principal (menu, session)
│   ├── ATM-INIT.cbl    ← Initialisation de la base de données
│   ├── ATM-SECU.cbl    ← Module sécurité (PIN, blocage, audit)
│   └── ATM-TRANS.cbl   ← Module transactions (validations)
├── data/               ← Fichiers ISAM (générés automatiquement)
├── bin/                ← Exécutables compilés
├── Makefile
└── README.md
```

---

## 🚀 Installation & Exécution

### Prérequis
```bash
sudo apt install gnucobol
# ou
sudo apt install open-cobol
```

### Compilation + Lancement
```bash
# Tout en une commande
make start

# Ou étape par étape
make all        # Compiler
make init       # Initialiser la BD
make run        # Lancer l'ATM
```

---

## 💳 Cartes de test

| Numéro de carte       | PIN  | Titulaire      | Type    | Solde     |
|-----------------------|------|----------------|---------|-----------|
| 4978 1234 5678 9012   | 1234 | DUPONT Jean    | COURANT | 1 250,75€ |
| 4978 2345 6789 0123   | 1111 | DUPONT Jean    | EPARGNE | 5 000,00€ |
| 4978 3456 7890 1234   | 4321 | MARTIN Sophie  | COURANT |   850,30€ |
| 5368 9876 5432 1098   | 0000 | RAKOTO Hery    | COURANT | 2 500,00€ |

---

## ✅ Fonctionnalités

- **Insertion de carte** : Validation du numéro, vérification activité
- **Saisie PIN** : Code masqué, 3 tentatives max, blocage automatique
- **Retrait** : Montants rapides (20/50/100/150/200€) ou libre (multiple de 10)
- **Dépôt** : Crédit immédiat, plafond 10 000€/opération
- **Consultation solde** : Affichage complet du compte
- **Mini-relevé** : 5 dernières opérations de la session
- **Changement PIN** : Avec vérification de l'ancien code
- **Fin de session** : Fermeture propre avec horodatage

---

## 🛡️ Sécurité

- Blocage après **3 PIN incorrects** consécutifs
- Journalisation de tous les événements dans `AUDIT.DAT`
- Validation des montants (plafond, solde, multiple de 10)
- Sessions horodatées avec statut (ACTIVE / FERMEE)

---

## 📊 Base de données (Fichiers ISAM)

| Fichier        | Description                        |
|----------------|------------------------------------|
| CLIENTS.DAT    | Données personnelles des clients   |
| COMPTES.DAT    | Numéros IBAN, soldes, plafonds     |
| CARTES.DAT     | Cartes bancaires et codes PIN      |
| SESSIONS.DAT   | Sessions ATM (debut/fin/statut)    |
| TRANSACT.DAT   | Historique de toutes les opérations|
| AUDIT.DAT      | Journal de sécurité (séquentiel)   |

---

## 📚 Concepts COBOL illustrés

| Concept                    | Fichier          |
|----------------------------|------------------|
| Fichiers ISAM indexés      | ATM-MAIN.cbl     |
| Clés primaires/alternatives| ATM-MAIN.cbl     |
| READ/WRITE/REWRITE         | ATM-MAIN.cbl     |
| EVALUATE (switch/case)     | ATM-MAIN.cbl     |
| Sécurité & validation      | ATM-SECU.cbl     |
| Logique de transaction     | ATM-TRANS.cbl    |
| Initialisation fichiers    | ATM-INIT.cbl     |
| PERFORM UNTIL / VARYING    | ATM-MAIN.cbl     |
| LINKAGE SECTION / CALL     | ATM-SECU.cbl     |
| FUNCTION CURRENT-DATE      | ATM-MAIN.cbl     |

---

*Projet COBOL #7 — ATM Banking System*
