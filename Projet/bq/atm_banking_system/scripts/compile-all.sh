#!/bin/bash

# Script de compilation senior
echo "========================================="
echo "   ATM BANKING SYSTEM - COMPILATION"
echo "========================================="

# Variables
BASE_DIR=$(pwd)
COPYBOOK_DIR="${BASE_DIR}/copybooks"
SRC_DIR="${BASE_DIR}/src"
BIN_DIR="${BASE_DIR}/bin"
LOG_DIR="${BASE_DIR}/logs"

# Création des répertoires
mkdir -p ${BIN_DIR} ${LOG_DIR} ${BASE_DIR}/data

# Nettoyage pré-compilation
echo "1. Cleaning previous builds..."
rm -f ${BIN_DIR}/*.o ${BIN_DIR}/*.so ${BIN_DIR}/*.exe
rm -f ${SRC_DIR}/*.o ${SRC_DIR}/*.lst

# Compilation des modules
echo "2. Compiling modules..."

# Module error-handler
echo "   - Compiling ERROR-HANDLER..."
cobc -c ${SRC_DIR}/error-handler.cob \
     -o ${BIN_DIR}/error-handler.o \
     -I ${COPYBOOK_DIR} \
     -Wall -debug

# Module validator
echo "   - Compiling VALIDATOR..."
cobc -c ${SRC_DIR}/validator.cob \
     -o ${BIN_DIR}/validator.o \
     -I ${COPYBOOK_DIR} \
     -Wall -debug

# Module transaction-manager
echo "   - Compiling TRANSACTION-MANAGER..."
cobc -c ${SRC_DIR}/transaction-manager.cob \
     -o ${BIN_DIR}/transaction-manager.o \
     -I ${COPYBOOK_DIR} \
     -Wall -debug

# Programme principal
echo "   - Compiling ATM-MAIN..."
cobc -x ${SRC_DIR}/atm-main.cob \
     ${BIN_DIR}/error-handler.o \
     ${BIN_DIR}/validator.o \
     ${BIN_DIR}/transaction-manager.o \
     -o ${BIN_DIR}/atm-system \
     -I ${COPYBOOK_DIR} \
     -Wall -debug -static

if [ $? -eq 0 ]; then
    echo "========================================="
    echo "   COMPILATION SUCCESSFUL!"
    echo "   Executable: ${BIN_DIR}/atm-system"
    echo "========================================="
    
    # Création du script d'exécution
    cat > ${BASE_DIR}/run-atm.sh << 'RUNSCRIPT'
#!/bin/bash
cd $(dirname $0)
export COB_LIBRARY_PATH=./bin
./bin/atm-system
RUNSCRIPT
    
    chmod +x ${BASE_DIR}/run-atm.sh
    
else
    echo "========================================="
    echo "   COMPILATION FAILED!"
    echo "   Please check errors above"
    echo "========================================="
    exit 1
fi

# Affichage des informations
echo ""
echo "To run the ATM system:"
echo "  ./run-atm.sh"
echo ""
echo "Test credentials:"
echo "  Card: 1234 5678 9012 3456"
echo "  PIN:  1234"
echo "  Balance: $10,000"
echo ""
