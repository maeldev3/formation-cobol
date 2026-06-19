//Z74830A  JOB (ACCT),'ALLOC HELLOBANK',CLASS=A,MSGCLASS=X,
//   NOTIFY=&SYSUID
//*--------------------------------------------------------------*
//* JOB     : Z74830A                                            *
//* OBJET   : ALLOCATION DES DATASETS DU PROJET HELLOBANK         *
//* USER    : Z74830                                              *
//* NOTE    : A SOUMETTRE UNE SEULE FOIS, AVANT LA COMPILATION    *
//*           ADAPTER UNIT/VOLUME SELON VOTRE ENVIRONNEMENT       *
//*--------------------------------------------------------------*
//* --- PDS SOURCE COBOL --------------------------------------- *
//ALLOC1   EXEC PGM=IEFBR14
//DD1      DD DSN=Z74830.HELLOBNK.COBOL,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(5,5,2)),
//   DCB=(RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PO)
//* --- PDS COPYBOOKS (RESERVE POUR EVOLUTIONS FUTURES) --------- *
//DD2      DD DSN=Z74830.HELLOBNK.COPY,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(5,5,2)),
//   DCB=(RECFM=FB,LRECL=80,BLKSIZE=0,DSORG=PO)
//* --- PDS LOAD MODULE (PROGRAMME EXECUTABLE) ------------------ *
//DD3      DD DSN=Z74830.HELLOBNK.LOAD,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(5,5,2)),
//   DCB=(RECFM=U,BLKSIZE=19069,DSORG=PO)
//* --- FICHIER CLIENTS (SEQUENTIEL) ----------------------------- *
//DD4      DD DSN=Z74830.HELLOBNK.CLIENTS,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(2,2),RLSE),
//   DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
//* --- FICHIER TRANSACTIONS (SEQUENTIEL) ------------------------ *
//DD5      DD DSN=Z74830.HELLOBNK.TRANS,
//   DISP=(NEW,CATLG,DELETE),
//   SPACE=(TRK,(2,2),RLSE),
//   DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
