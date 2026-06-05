# ==============================
# COBOL INVENTORY SYSTEM
# ==============================

APP_NAME = bin/app
COBOL = cobc
COBFLAGS = -free -I copybooks/

SRC = \
src/main.cob \
src/menu.cob \
src/category/create_category.cob

# ==============================
# DEFAULT TARGET
# ==============================
all: clean build

# ==============================
# BUILD PROJECT
# ==============================
build:
	@mkdir -p bin
	$(COBOL) -x $(COBFLAGS) $(SRC) -o $(APP_NAME)
	@echo "Build completed: $(APP_NAME)"

# ==============================
# RUN PROJECT
# ==============================
run: build
	@echo "Running application..."
	./$(APP_NAME)

# ==============================
# CLEAN PROJECT
# ==============================
clean:
	@echo "Cleaning project..."
	@rm -rf bin/*
	@echo "Clean done"

# ==============================
# TEST DATABASE
# ==============================
db-test:
	@echo "Compiling DB test program..."
	@mkdir -p bin
	$(COBOL) $(COBFLAGS) -x src/db/db_test.cob -o bin/db_test
	@echo "Running DB test..."
	./bin/db_test