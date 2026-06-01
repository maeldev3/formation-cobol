# ==========================================
# ATM BANKING SYSTEM
# MAKEFILE GNUCOBOL
# ==========================================

COBC = cobc
CFLAGS = -x -free

BIN_DIR = bin
SRC_DIR = src

# ==========================================
# COMPILATION RAPIDE
# ==========================================

compile:
	@mkdir -p $(BIN_DIR)
	@echo "================================="
	@echo "COMPILATION ATM BANKING SYSTEM"
	@echo "================================="

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/MENU_PRINCIPAL \
	$(SRC_DIR)/MENU_PRINCIPAL.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/CREER_COMPTE \
	$(SRC_DIR)/modules/ADMIN/CREER_COMPTE.cob

	# $(COBC) $(CFLAGS) \
	# -o $(BIN_DIR)/MODIFIER_COMPTE \
	# $(SRC_DIR)/modules/ADMIN/MODIFIER_COMPTE.cob

	# $(COBC) $(CFLAGS) \
	# -o $(BIN_DIR)/SUPPRIMER_COMPTE \
	# $(SRC_DIR)/modules/ADMIN/SUPPRIMER_COMPTE.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/CONSULTER_SOLDE \
	$(SRC_DIR)/modules/ACCOUNT/CONSULTER_SOLDE.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/MINI_RELEVE \
	$(SRC_DIR)/modules/ACCOUNT/MINI_RELEVE.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/DEPOT \
	$(SRC_DIR)/modules/TRANSACTIONS/DEPOT.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/RETRAIT \
	$(SRC_DIR)/modules/TRANSACTIONS/RETRAIT.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/TRANSFERT \
	$(SRC_DIR)/modules/TRANSACTIONS/TRANSFERT.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/INSERT_CARD \
	$(SRC_DIR)/modules/AUTH/INSERT_CARD.cob

	$(COBC) $(CFLAGS) \
	-o $(BIN_DIR)/VERIFY_PIN \
	$(SRC_DIR)/modules/AUTH/VERIFY_PIN.cob

	@echo ""
	@echo "================================="
	@echo "COMPILATION TERMINEE"
	@echo "================================="
	@ls -lh $(BIN_DIR)

# ==========================================
# EXECUTION
# ==========================================

run:
	./bin/MENU_PRINCIPAL

# ==========================================
# SQLITE
# ==========================================

db:
	sqlite3 data/input/atm.db < data/sql/schema.sql
	sqlite3 data/input/atm.db < data/sql/seed.sql

reset-db:
	rm -f data/input/atm.db
	sqlite3 data/input/atm.db < data/sql/schema.sql
	sqlite3 data/input/atm.db < data/sql/seed.sql

# ==========================================
# TESTS
# ==========================================

test:
	./scripts/tests.sh

# ==========================================
# CLEAN
# ==========================================

clean:
	rm -f $(BIN_DIR)/*

rebuild: clean compile

.PHONY: compile run clean rebuild db reset-db test