//CLI0200D JOB (ACCT),'CREATE TABLE',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*------------------------------------------------------------
//* TP20 : Exécution du DDL de création de la table CLIENTS
//* Remplacer DSN1 par le nom réel de ton subsystem DB2
//*------------------------------------------------------------
//STEP1    EXEC PGM=DSNTIAD,PARM='DSN1'
//STEPLIB  DD DSN=DSN1.SDSNEXIT,DISP=SHR
//         DD DSN=DSN1.SDSNLOAD,DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DSN=BANK.DB2.DDL(CLICRTAB),DISP=SHR
//*
//* Variante USS (si ton DDL est en fichier Unix plutôt qu'en PDS) :
//* //SYSIN    DD PATH='/u/tonuserid/bank/ddl/DDL_CLIENTS.sql'
