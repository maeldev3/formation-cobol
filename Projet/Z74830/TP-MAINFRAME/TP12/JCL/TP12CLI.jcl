//TP12CLI  JOB (ACCT),'TP12 COBOL',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID,REGION=0M
//*--------------------------------------------------------------*
//* JCL D'EXEMPLE - COMPILE + LINK + GO POUR z/OS (IBM Enterprise
//* COBOL). A ADAPTER SELON VOTRE ENVIRONNEMENT (SYSAFF, LOADLIB,
//* NOMS DE DATASETS ...)
//*--------------------------------------------------------------*
//STEP1   EXEC IGYWCL,
//             PARM.COB=('LIB','APOST'),
//             PARM.LKED='LIST,MAP'
//COB.SYSIN   DD DISP=SHR,DSN=VOTRE.SOURCE.COBOL(TP12CLI)
//LKED.SYSLMOD DD DISP=SHR,DSN=VOTRE.LOAD.LIBRARY(TP12CLI)
//*
//*--------------------------------------------------------------*
//* ETAPE D'EXECUTION DU PROGRAMME
//*--------------------------------------------------------------*
//STEP2   EXEC PGM=TP12CLI,COND=(4,LT,STEP1)
//STEPLIB  DD DISP=SHR,DSN=VOTRE.LOAD.LIBRARY
//SYSIN    DD *
1
3
1
005
4
5
6
/*
//SYSOUT   DD SYSOUT=*
//SYSPRINT DD SYSOUT=*
//
