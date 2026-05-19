COBC = cobc
COBFLAGS = -x -free -I src/common/COPYBOOKS

SRCDIR = src
BINDIR = bin
MODULES = ADHERENTS LIVRES EMPRUNTS BATCH REPORTS

all: compile

compile:
	mkdir -p $(BINDIR)
	@for module in $(MODULES); do \
		for file in $(SRCDIR)/modules/$$module/*.cob; do \
			if [ -f "$$file" ]; then \
				echo "Compiling $$file"; \
				$(COBC) $(COBFLAGS) -o $(BINDIR)/$$(basename $$file .cob) $$file; \
			fi \
		done \
	done
	@for file in $(SRCDIR)/batch/*.cob; do \
		if [ -f "$$file" ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$(basename $$file .cob) $$file; \
		fi \
	done
	@for file in $(SRCDIR)/reports/*.cob; do \
		if [ -f "$$file" ]; then \
			$(COBC) $(COBFLAGS) -o $(BINDIR)/$$(basename $$file .cob) $$file; \
		fi \
	done

clean:
	rm -f $(BINDIR)/*
	rm -f data/output/*/*

.PHONY: all compile clean
