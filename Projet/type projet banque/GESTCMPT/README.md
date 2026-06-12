# Projet GESTCMPT - Consultation de compte (CICS+DB2)

Fichiers :
- comptes.sql      : création table DB2 et données test
- ACCTMAP.member   : map BMS pour l'écran CICS
- GESTCMPT.cbl     : programme COBOL (CICS + DB2)
- GCMPT.jcl        : JCL pour précompiler (DB2), traduire (CICS), compiler et linker

Sur le mainframe, déposer les sources dans des datasets adaptés (PDS/PDSE), adapter les noms de librairies (DSNxxx) et lancer le JCL.
