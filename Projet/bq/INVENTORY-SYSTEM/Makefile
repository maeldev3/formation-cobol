APP_NAME = bin/app

SRC = src/main.cob \
      src/menu.cob \
      src/product/add_product.cob \
      src/product/list_products.cob \
      src/product/search_product.cob \
      src/product/update_stock.cob
all:
	@mkdir -p bin
	@echo "Compiling COBOL..."
	cobc -x $(SRC) -o $(APP_NAME)
	@echo "Build finished ✔"

run:
	@if [ -f $(APP_NAME) ]; then \
		./$(APP_NAME); \
	else \
		echo "ERROR: binary not found. Run 'make' first."; \
	fi

clean:
	rm -rf bin/*