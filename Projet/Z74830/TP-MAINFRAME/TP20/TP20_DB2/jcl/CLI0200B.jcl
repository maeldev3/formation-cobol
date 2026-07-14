//CLI0200B JOB (ACCT),'BIND PKG/PLAN',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*------------------------------------------------------------
//* TP20 : Bind du package et du plan DB2 pour CLI0200
//* Le BIND transforme le DBRM (généré par DSNHPC) en un objet
//* exécutable connu de DB2. Sans bind, RUN échouera.
//*------------------------------------------------------------
//BINDSTEP EXEC PGM=IKJEFT01,DYNAMNBR=20
//STEPLIB  DD DSN=DSN1.SDSNLOAD,DISP=SHR
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
  DSN SYSTEM(DSN1)
  BIND PACKAGE(BANKPKG)        -
       MEMBER(CLI0200)         -
       LIBRARY('BANK.DB2.DBRMLIB') -
       ACTION(REPLACE)         -
       ISOLATION(CS)           -
       VALIDATE(BIND)
  BIND PLAN(BANKPLAN)          -
       PKLIST(BANKPKG.*)       -
       ACTION(REPLACE)         -
       ISOLATION(CS)
  END
/*
