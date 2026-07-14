//CLI0200R JOB (ACCT),'RUN CLI0200',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*------------------------------------------------------------
//* TP20 : Exécution du programme COBOL-DB2 CLI0200
//* Un programme DB2 batch se lance via IKJEFT01 (TSO batch)
//* avec la commande DSN RUN, en précisant le PLAN buildé.
//*------------------------------------------------------------
//STEP1    EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD DSN=BANK.LOAD,DISP=SHR
//         DD DSN=DSN1.SDSNLOAD,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DSN1)
  RUN PROGRAM(CLI0200) PLAN(BANKPLAN) LIB('BANK.LOAD')
  END
/*
