.PHONY: all clean run

CC = cobc
CFLAGS = -x -free
TARGET_DIR = bin

all: directories
	@echo "Compilation du projet..."
	@for file in src/*.cob; do \
		name=$$(basename $$file .cob); \
		$(CC) $(CFLAGS) -o $(TARGET_DIR)/$$name $$file 2>/dev/null && echo "✓ $$name" || echo "✗ $$name"; \
	done
	@for dir in src/modules/*; do \
		for file in $$dir/*.cob; do \
			name=$$(basename $$file .cob); \
			$(CC) $(CFLAGS) -o $(TARGET_DIR)/$$name $$file 2>/dev/null && echo "✓ $$name" || echo "✗ $$name"; \
		done; \
	done
	@echo "✅ Compilation terminee"

directories:
	@mkdir -p $(TARGET_DIR) data/backup data/exports

run: all
	@./$(TARGET_DIR)/MENU_PRINCIPAL

clean:
	@rm -rf $(TARGET_DIR)/*
	@echo "✅ Nettoyage termine"
