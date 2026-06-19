# Makefile pour projet COBOL mainframe
# Utilisation : make <target>

USERID ?= Z74830
PREFIX := $(USERID).HELLOBNK

all: allocate createinput upload hello seq

allocate:
	zowe zos-jobs submit local-file jcl/ALLOC.jcl

createinput:
	zowe zos-jobs submit local-file jcl/CREATEINPUT.jcl

upload:
	for f in src/*.cob; do \
		member=$$(basename "$$f" .cob); \
		zowe zos-files upload file-to-data-set "$$f" "$(PREFIX).COBOL($$member)"; \
	done

hello: upload
	zowe zos-jobs submit local-file jcl/HELLOBNK.jcl

seq: upload
	zowe zos-jobs submit local-file jcl/SEQPROC.jcl

compile-seq:
	zowe zos-jobs submit local-file jcl/COMPILE_SEQ.jcl

run-seq:
	zowe zos-jobs submit local-file jcl/SEQPROC.jcl

seq: upload compile-seq run-seq

vsam: upload
	zowe zos-jobs submit local-file jcl/VSAMPROC.jcl

clean:
	echo "Nettoyage local (fichiers .bin, etc.)"
	rm -f bin/*.bin

.PHONY: all allocate createinput upload hello seq vsam clean


