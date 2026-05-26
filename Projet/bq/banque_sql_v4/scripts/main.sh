#!/bin/bash

# =====================================================
# SYSTÈME BANCAIRE PROFESSIONNEL V4.0
# =====================================================

cd "$(dirname "$0")/.."

DB_PATH="data/sqlite/banque.db"
LOG_FILE="data/logs/banque.log"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Initialisation de la base de données
init_db() {
    if [ ! -f "$DB_PATH" ]; then
        sqlite3 "$DB_PATH" < scripts/init_db.sql
        echo -e "${GREEN}✓ Base de données initialisée${NC}"
    fi
}

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =====================================================
# FONCTIONS CLIENTS
# =====================================================

creer_client() {
    echo -e "${CYAN}=========================================${NC}"
    echo -e "${CYAN}        CREATION D'UN CLIENT            ${NC}"
    echo -e "${CYAN}=========================================${NC}"
    echo ""
    
    read -p "Civilité (M/MME/MLLE): " civilite
    read -p "Nom: " nom
    read -p "Prénom: " prenom
    read -p "Date de naissance (YYYY-MM-DD): " date_naiss
    read -p "Lieu de naissance: " lieu_naiss
    read -p "Adresse: " adresse
    read -p "Code postal: " cp
    read -p "Ville: " ville
    read -p "Téléphone: " tel
    read -p "Email: " email
    read -p "Profession: " profession
    read -p "Revenu annuel: " revenu
    read -p "Patrimoine: " patrimoine
    
    # Génération ID client
    id_client=$(sqlite3 "$DB_PATH" "SELECT 'C' || printf('%05d', COALESCE(MAX(CAST(SUBSTR(id_client,2) AS INTEGER)),0)+1 FROM clients;")
    
    sqlite3 "$DB_PATH" <<EOF
INSERT INTO clients (id_client, civilite, nom, prenom, date_naissance, lieu_naissance, adresse, code_postal, ville, telephone, email, profession, revenu_annuel, patrimoine, statut, date_creation, created_by)
VALUES ('$id_client', '$civilite', '$nom', '$prenom', '$date_naiss', '$lieu_naiss', '$adresse', '$cp', '$ville', '$tel', '$email', '$profession', $revenu, $patrimoine, 'ACTIF', CURRENT_TIMESTAMP, 'SYSTEM');
