# =====================================================
# MAKEFILE - SYSTÈME BANCAIRE V4
# =====================================================

.PHONY: all install test clean backup restore

all: install test

install:
	@echo "========================================="
	@echo "Installation du système bancaire"
	@echo "========================================="
	@chmod +x scripts/*.sh
	@./scripts/install_modules.sh
	@echo "✅ Installation terminée"

test:
	@echo "========================================="
	@echo "Tests des modules"
	@echo "========================================="
	@./scripts/test_modules.sh

run:
	@./scripts/main.sh

backup:
	@mkdir -p data/backup
	@cp data/sqlite/banque.db data/backup/banque_$(shell date +%Y%m%d_%H%M%S).db
	@echo "✅ Sauvegarde effectuée"

restore:
	@echo "Liste des sauvegardes:"
	@ls -la data/backup/*.db 2>/dev/null || echo "Aucune sauvegarde"
	@read -p "Fichier à restaurer: " file; \
	if [ -f "$$file" ]; then \
		cp "$$file" data/sqlite/banque.db; \
		echo "✅ Restauration effectuée"; \
	else \
		echo "❌ Fichier non trouvé"; \
	fi

clean:
	@rm -f data/sqlite/banque.db
	@echo "✅ Base supprimée"

reset: clean install

help:
	@echo "Commandes disponibles:"
	@echo "  make install  - Installer les modules"
	@echo "  make test     - Tester les modules"
	@echo "  make run      - Lancer l'application"
	@echo "  make backup   - Sauvegarder la base"
	@echo "  make restore  - Restaurer une sauvegarde"
	@echo "  make clean    - Supprimer la base"
	@echo "  make reset    - Réinitialiser complètement"
