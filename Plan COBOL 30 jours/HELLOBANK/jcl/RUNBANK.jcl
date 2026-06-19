//Z74830R  JOB (ACCT),'RUN HELLOBANK',CLASS=A,MSGCLASS=X,
//   NOTIFY=&SYSUID,REGION=0M
//*--------------------------------------------------------------*
//* JOB     : Z74830R                                            *
//* OBJET   : EXECUTION BATCH DU PROGRAMME HELLOBANK              *
//* USER    : Z74830                                              *
//* ENTREES : CLIENTI  -> Z74830.HELLOBNK.CLIENTS                *
//*           TRANSI   -> Z74830.HELLOBNK.TRANS                 *
//* SORTIE  : REPORTO  -> Z74830.HELLOBNK.REPORT                 *
//*--------------------------------------------------------------*
//STEP1    EXEC PGM=HELLOBNK
//STEPLIB  DD DSN=Z74830.HELLOBNK.LOAD,DISP=SHR
//CLIENTI  DD DSN=Z74830.HELLOBNK.CLIENTS,DISP=SHR
//TRANSI   DD DSN=Z74830.HELLOBNK.TRANS,DISP=SHR
//REPORTO  DD DSN=Z74830.HELLOBNK.REPORT,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(5,5),RLSE),
//   DCB=(RECFM=FB,LRECL=132,BLKSIZE=0)
//SYSOUT   DD SYSOUT=*
//SYSUDUMP DD SYSOUT=*
