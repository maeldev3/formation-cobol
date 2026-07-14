//CLI0200C JOB (ACCT),'PRECOMPIL DB2',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*------------------------------------------------------------
//* TP20 : Précompilation + compilation + link-edit de CLI0200
//* Ordre obligatoire pour un programme COBOL-DB2 :
//*   1) DSNHPC   (précompilateur : extrait le SQL -> DBRM)
//*   2) IGYCRCTL (compilateur COBOL standard)
//*   3) IEWL     (link-edit avec le module DB2 DSNELI)
//*------------------------------------------------------------
//PRECOMP  EXEC PGM=DSNHPC,
//         PARM='HOST(IBMCOB),APOST,SOURCE'
//STEPLIB  DD DSN=DSN1.SDSNLOAD,DISP=SHR
//DBRMLIB  DD DSN=BANK.DB2.DBRMLIB(CLI0200),DISP=SHR
//SYSCIN   DD DSN=&&DSNHOUT,DISP=(NEW,PASS),
//            UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSLIB   DD DSN=BANK.COPY,DISP=SHR
//SYSIN    DD DSN=BANK.SOURCE(CLI0200),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSTERM  DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//*
//* Variante USS pour SYSIN/SYSLIB (si tes sources sont en fichiers
//* Unix plutôt qu'en PDS) :
//* //SYSIN    DD PATH='/u/tonuserid/bank/source/CLI0200.cbl'
//* //SYSLIB   DD PATH='/u/tonuserid/bank/copy',PATHOPTS=(ORDONLY)
//*
//COMPIL   EXEC PGM=IGYCRCTL,
//         PARM='LIB,APOST',COND=(4,LT,PRECOMP)
//STEPLIB  DD DSN=IGY.SIGYCOMP,DISP=SHR
//SYSLIB   DD DSN=BANK.COPY,DISP=SHR
//SYSIN    DD DSN=&&DSNHOUT,DISP=(OLD,DELETE)
//SYSLIN   DD DSN=&&LOADSET,DISP=(NEW,PASS),
//            UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT2   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSUT3   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//*
//LKED     EXEC PGM=IEWL,
//         PARM='LIST,MAP',COND=(4,LT,COMPIL)
//SYSLIB   DD DSN=DSN1.SDSNLOAD,DISP=SHR
//         DD DSN=CEE.SCEELKED,DISP=SHR
//SYSLIN   DD DSN=&&LOADSET,DISP=(OLD,DELETE)
//         DD DDNAME=SYSIN
//SYSLMOD  DD DSN=BANK.LOAD(CLI0200),DISP=SHR
//SYSPRINT DD SYSOUT=*
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(1,1))
//SYSIN    DD *
  INCLUDE SYSLIB(DSNELI)
  NAME CLI0200(R)
/*
