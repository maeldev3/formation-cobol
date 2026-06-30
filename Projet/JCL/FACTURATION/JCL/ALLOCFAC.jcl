//Z74830B  JOB (ACCT),'ALLOC VSAM FACT',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID
//*****************************************************************
//* JOB   : ALLOCFAC                                              *
//* DESC  : DEFINITION DES CLUSTERS VSAM (KSDS) DU SYSTEME DE     *
//*         FACTURATION VIA IDCAMS                                *
//* NOTE  : ADAPTER LE QUALIFICATEUR Z74830 A VOTRE IDENTIFIANT Z *
//*         EXECUTER UNE SEULE FOIS AVANT LA PREMIERE UTILISATION *
//*****************************************************************
//DEFINE   EXEC PGM=IDCAMS
//SYSPRINT DD SYSOUT=*
//SYSIN    DD *
   DELETE Z74830.FACT.CLIMAST  CLUSTER PURGE
   SET MAXCC = 0
   DELETE Z74830.FACT.PRODMAST CLUSTER PURGE
   SET MAXCC = 0
   DELETE Z74830.FACT.FACTMAST CLUSTER PURGE
   SET MAXCC = 0
   DELETE Z74830.FACT.FACTLIGN CLUSTER PURGE
   SET MAXCC = 0

   DEFINE CLUSTER (NAME(Z74830.FACT.CLIMAST)               -
          INDEXED                                          -
          KEYS(6 0)                                        -
          RECORDSIZE(100 100)                              -
          RECORDS(1000 500)                                -
          FREESPACE(10 10)                                 -
          SHAREOPTIONS(2 3))                                -
          DATA (NAME(Z74830.FACT.CLIMAST.DATA))             -
          INDEX(NAME(Z74830.FACT.CLIMAST.INDEX))

   DEFINE CLUSTER (NAME(Z74830.FACT.PRODMAST)              -
          INDEXED                                          -
          KEYS(8 0)                                        -
          RECORDSIZE(80 80)                                -
          RECORDS(1000 500)                                -
          FREESPACE(10 10)                                 -
          SHAREOPTIONS(2 3))                                -
          DATA (NAME(Z74830.FACT.PRODMAST.DATA))            -
          INDEX(NAME(Z74830.FACT.PRODMAST.INDEX))

   DEFINE CLUSTER (NAME(Z74830.FACT.FACTMAST)              -
          INDEXED                                          -
          KEYS(8 0)                                        -
          RECORDSIZE(80 80)                                -
          RECORDS(2000 1000)                                -
          FREESPACE(10 10)                                 -
          SHAREOPTIONS(2 3))                                -
          DATA (NAME(Z74830.FACT.FACTMAST.DATA))            -
          INDEX(NAME(Z74830.FACT.FACTMAST.INDEX))

   DEFINE CLUSTER (NAME(Z74830.FACT.FACTLIGN)              -
          INDEXED                                          -
          KEYS(11 0)                                       -
          RECORDSIZE(60 60)                                -
          RECORDS(5000 2000)                                -
          FREESPACE(10 10)                                 -
          SHAREOPTIONS(2 3))                                -
          DATA (NAME(Z74830.FACT.FACTLIGN.DATA))            -
          INDEX(NAME(Z74830.FACT.FACTLIGN.INDEX))
/*
