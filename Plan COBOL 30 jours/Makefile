COBC = cobc
COBFLAGS = -x -free
SRC_DIR = src
BIN_DIR = bin
DATA_DIR = data
TARGET = $(BIN_DIR)/jour8_program

.PHONY: all setup run clean

all: setup $(TARGET)

setup:
	@mkdir -p $(BIN_DIR) $(DATA_DIR)
	@*> Création d'un jeu de données de test au format fixe (30 caractères par ligne)
	@echo "C0001Jean Dupont         42   " > $(DATA_DIR)/clients.dat
	@echo "C0002Marie Curie         29   " >> $(DATA_DIR)/clients.dat
	@echo "C0003Alan Turing         35   " >> $(DATA_DIR)/clients.dat
	@echo "🗃️ Fichier de données data/clients.dat initialisé."

$(TARGET): $(SRC_DIR)/jour8_fichiers.cbl
	$(COBC) $(COBFLAGS) -o $(TARGET) $(SRC_DIR)/jour8_fichiers.cbl
	@echo "✅ Compilation du Jour 8 réussie."

run: all
	@./$(TARGET)

clean:
	rm -rf $(BIN_DIR) $(DATA_DIR)/*
	@echo "🧹 Nettoyage effectué."
