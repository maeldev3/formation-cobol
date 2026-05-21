# Création du dossier docs et du cahier de charge
cd ~/projet/PR\ OLIVIER/cobol/formation-cobol/Projet/hotel_crud
mkdir -p docs

cat > docs/CAHIER_CHARGE_HOTEL.md << 'EOF'
# CAHIER DE CHARGE - SYSTÈME DE GESTION HOTELIERE

## PROJET "HOTEL PARADISE"

---

## 1. INTRODUCTION

### 1.1 Identification du projet
| Champ | Information |
|-------|-------------|
| **Nom du projet** | Hotel Paradise - Système de Réservation Hôtelière |
| **Version** | 1.0 |
| **Date** | 21 Mai 2026 |
| **Client** | Hotel Paradise SA |
| **Développeur** | MAEL |

### 1.2 Objectif du projet
Développer un système complet de gestion hôtelière permettant de gérer:
- Les clients (CRUD complet)
- Les chambres (CRUD)
- Les réservations (CRUD)
- Les paiements
- Les rapports d'occupation et financiers

### 1.3 Périmètre du projet
Le système couvre les fonctionnalités suivantes:
- Gestion des données clients (inscription, modification, suppression)
- Gestion des chambres (ajout, modification statut)
- Gestion des réservations (création, annulation)
- Génération de rapports (occupation, CA)
- Interface utilisateur conviviale

---

## 2. DESCRIPTION DU BESOIN

### 2.1 Contexte
L'hôtel "Hotel Paradise" souhaite moderniser sa gestion en remplaçant son système manuel par une application informatisée. L'établissement dispose de:
- 12 chambres réparties sur 3 étages
- 5 types de chambres différents
- Une capacité d'accueil de 50 clients par jour

### 2.2 Problématique actuelle
| Problème | Impact |
|----------|--------|
| Gestion manuelle des réservations | Double réservations fréquentes |
| Suivi papier des clients | Perte d'informations |
| Calcul manuel des tarifs | Erreurs fréquentes |
| Absence de rapports | Difficulté de pilotage |

### 2.3 Objectifs visés
| Objectif | Critère de réussite |
|----------|---------------------|
| Réduction des erreurs | Taux d'erreur < 1% |
| Gain de temps | Saisie < 2 min par réservation |
| Centralisation des données | Base unique accessible |
| Reporting fiable | Rapports quotidiens disponibles |

---

## 3. ANALYSE FONCTIONNELLE

### 3.1 Acteurs du système

### 3.2 Cas d'utilisation

| ID | Cas d'utilisation | Acteur | Description |
|----|-------------------|--------|-------------|
| UC01 | Créer client | Réceptionniste | Saisir un nouveau client |
| UC02 | Lister clients | Réceptionniste | Afficher tous les clients |
| UC03 | Rechercher client | Réceptionniste | Trouver un client par ID |
| UC04 | Modifier client | Réceptionniste | Mettre à jour coordonnées |
| UC05 | Supprimer client | Manager | Retirer un client |
| UC06 | Ajouter chambre | Manager | Créer une nouvelle chambre |
| UC07 | Lister chambres | Réceptionniste | Voir disponibilités |
| UC08 | Modifier statut chambre | Réceptionniste | Changer état chambre |
| UC09 | Créer réservation | Réceptionniste | Enregistrer séjour |
| UC10 | Annuler réservation | Réceptionniste | Supprimer réservation |
| UC11 | Consulter occupation | Manager | Voir taux remplissage |
| UC12 | Consulter CA | Manager | Voir chiffre d'affaires |

### 3.3 Règles de gestion

#### Règles Clients
| Règle | Description |
|-------|-------------|
| RG01 | ID client unique format C00001 à C99999 |
| RG02 | Email unique dans la base |
| RG03 | Téléphone obligatoire (10 chiffres) |
| RG04 | Un client peut avoir plusieurs réservations |

#### Règles Chambres
| Règle | Description |
|-------|-------------|
| RG05 | ID chambre unique format CH001 à CH999 |
| RG06 | Numéro de chambre unique |
| RG07 | Statuts possibles: DISPONIBLE, OCCUPEE, RESERVEE |
| RG08 | Prix par nuit selon type de chambre |

#### Règles Réservations
| Règle | Description |
|-------|-------------|
| RG09 | Dates: date_fin > date_debut |
| RG10 | Une chambre ne peut être réservée 2x sur mêmes dates |
| RG11 | Réservation confirmée = mise à jour statut chambre |
| RG12 | Annulation = libération de la chambre |

### 3.4 Matrice CRUD

| Entité | Create | Read | Update | Delete |
|--------|--------|------|--------|--------|
| CLIENTS | ✅ | ✅ | ✅ | ✅ |
| CHAMBRES | ✅ | ✅ | ✅ | ❌ |
| RESERVATIONS | ✅ | ✅ | ✅ | ❌ |
| PAIEMENTS | ✅ | ✅ | ❌ | ❌ |

---

## 4. SPÉCIFICATIONS TECHNIQUES

### 4.1 Architecture technique
