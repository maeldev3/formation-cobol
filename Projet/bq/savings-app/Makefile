# Variables de configuration
COBC = cobc
COBFLAGS = -x
SRC_DIR = src
BIN_DIR = bin
TARGET = $(BIN_DIR)/savings_system
SRC = $(SRC_DIR)/savings.cbl

.PHONY: all run clean setup

# Regle par defaut : compile le projet
all: setup $(TARGET)

# Cree les dossiers et fichiers de donnees necessaires
setup:
	@mkdir -p $(BIN_DIR) data
	@touch data/accounts.dat data/history.dat

# Compilation de l'executable dans le dossier bin
$(TARGET): $(SRC)
	$(COBC) $(COBFLAGS) -o $(TARGET) $(SRC)
	@echo "✅ Compilation reussie ! L'executable est dans '$(TARGET)'"

# Regle pour compiler et lancer directement l'application
run: all
	@./$(TARGET)

# Nettoyage des fichiers compiles
clean:
	rm -rf $(BIN_DIR)
	@echo "🧹 Dossier de build nettoye."
