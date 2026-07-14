//Z74830X  JOB (ACCT),'DDL TP20',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID
//*----------------------------------------------------------
//* ETAPE 1 - Execution du DDL (DDLCLI.sql) via DSNTEP2
//* A ADAPTER : remplacer DB2A par le nom du sous-systeme
//*             DB2 fourni par la plateforme (SSID).
//*----------------------------------------------------------
//STEP1    EXEC PGM=DSNTEP2,PARM='DB2A'
//STEPLIB  DD DISP=SHR,DSN=DB2A.SDSNLOAD
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//SYSIN    DD DISP=SHR,DSN=Z74830.DB2.SOURCE(DDLCLI)
