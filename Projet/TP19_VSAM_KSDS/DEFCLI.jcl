//Z74830D  JOB (ACCTNO),'DEFINE VSAM',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID,REGION=0M
//*--------------------------------------------------------------*
//* TP19 - DEFINITION DU CLUSTER VSAM KSDS CLIENTS.VSAM           *
//* ADAPTER LA CARTE JOB (ACCTNO / CLASSE) AU STANDARD DU SITE    *
//*--------------------------------------------------------------*
//STEP1    EXEC PGM=IDCAMS
//SYSPRINT DD  SYSOUT=*
//SYSIN    DD  *
  DELETE (Z74830.CLIENTS.VSAM) CLUSTER
  SET MAXCC = 0
  DEFINE CLUSTER (NAME(Z74830.CLIENTS.VSAM)          -
         INDEXED                                     -
         KEYS(9 0)                                   -
         RECORDSIZE(136 136)                         -
         RECORDS(1000 200)                            -
         FREESPACE(10 10)                             -
         SHAREOPTIONS(2 3) )                          -
       DATA  (NAME(Z74830.CLIENTS.VSAM.DATA) )        -
       INDEX (NAME(Z74830.CLIENTS.VSAM.INDEX) )
/*
