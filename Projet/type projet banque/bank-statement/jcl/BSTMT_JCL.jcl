//******************************************************************
//* JOB: BSTMTCMP
//* DESC: COMPILE ET LINK-EDIT BSTMTGEN (CICS/DB2/COBOL)
//******************************************************************
//BSTMTCMP JOB (ACCT),'BANK STMT COMPILE',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,
//             REGION=0M

//*-------------------------------------------------------------------
//* STEP 1: PRECOMPILE DB2
//*-------------------------------------------------------------------
//STEP010  EXEC PGM=DSNHPC,
//             PARM='HOST(COB2),SOURCE,XREF,NOFLAG(I)',
//             REGION=4096K
//DBRMLIB  DD  DISP=SHR,
//             DSN=BANK.DEVLIB.DBRMLIB
//SYSCIN   DD  DSN=&&DSNTEMP,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(32000,(30,30)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//SYSLIB   DD  DISP=SHR,DSN=BANK.DEVLIB.SRCLIB
//         DD  DISP=SHR,DSN=SDSF.SDSF.SFSSAMP
//SYSPRINT DD  SYSOUT=*
//SYSTERM  DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//SYSIN    DD  DISP=SHR,
//             DSN=BANK.DEVLIB.SRCLIB(BSTMTGEN)

//*-------------------------------------------------------------------
//* STEP 2: CICS/COBOL PREPROCESS (DFHECP1$)
//*-------------------------------------------------------------------
//STEP020  EXEC PGM=DFHECP1$,
//             PARM='COBOL2,CICS,NOEDF',
//             REGION=4096K,
//             COND=(4,LT,STEP010)
//SYSPRINT DD  SYSOUT=*
//SYSPUNCH DD  DSN=&&CICSOUT,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(32000,(30,30)),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=3200)
//SYSIN    DD  DSN=&&DSNTEMP,DISP=(OLD,DELETE)

//*-------------------------------------------------------------------
//* STEP 3: COMPILATION COBOL
//*-------------------------------------------------------------------
//STEP030  EXEC PGM=IGYCRCTL,
//             PARM='LIB,SOURCE,XREF,LIST,MAP,RENT,RMODE(ANY),
//             AMODE(31),TRUNC(BIN),NUMPROC(PFD),DYNAM,
//             NODYNAM,OPT(FULL)',
//             REGION=4096K,
//             COND=(4,LT,STEP020)
//SYSLIB   DD  DISP=SHR,DSN=CICS.SDFHCOB
//         DD  DISP=SHR,DSN=DB2.SDSNLOAD
//         DD  DISP=SHR,DSN=SYS1.MACLIB
//SYSLIN   DD  DSN=&&LOADOBJ,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(32000,(30,30)),
//             DCB=(RECFM=FB,LRECL=80)
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT4   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT5   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT6   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT7   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSIN    DD  DSN=&&CICSOUT,DISP=(OLD,DELETE)

//*-------------------------------------------------------------------
//* STEP 4: LINK-EDIT
//*-------------------------------------------------------------------
//STEP040  EXEC PGM=IEWL,
//             PARM='RENT,REUS,AMODE(31),RMODE(ANY),LIST,MAP,XREF',
//             REGION=4096K,
//             COND=(4,LT,STEP030)
//SYSLIB   DD  DISP=SHR,DSN=CICS.SDFHLOAD
//         DD  DISP=SHR,DSN=DB2.SDSNLOAD
//         DD  DISP=SHR,DSN=SYS1.LINKLIB
//SYSLMOD  DD  DISP=SHR,DSN=BANK.LOADLIB(BSTMTGEN)
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(1024,(50,20))
//SYSLIN   DD  DSN=&&LOADOBJ,DISP=(OLD,DELETE)
//         DD  *
 ENTRY BSTMTGEN
 NAME  BSTMTGEN(R)
/*

//******************************************************************
//* JOB: BSTMTBND
//* DESC: DB2 BIND PLAN POUR BSTMTGEN ET BSTMTBAT
//******************************************************************
//BSTMTBND JOB (ACCT),'BANK STMT DB2 BIND',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID

//STEP010  EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//SYSTSIN  DD  *
  DSN SYSTEM(DB2P)
  BIND PACKAGE(BSTMTPKG) -
       MEMBER(BSTMTGEN) -
       LIBRARY('BANK.DEVLIB.DBRMLIB') -
       VALIDATE(BIND) -
       ISOLATION(CS) -
       RELEASE(COMMIT) -
       OWNER(BANKUSR) -
       QUALIFIER(BANKDB) -
       ACTION(REPLACE)
  BIND PACKAGE(BSTMTPKG) -
       MEMBER(BSTMTBAT) -
       LIBRARY('BANK.DEVLIB.DBRMLIB') -
       VALIDATE(BIND) -
       ISOLATION(CS) -
       RELEASE(COMMIT) -
       OWNER(BANKUSR) -
       QUALIFIER(BANKDB) -
       ACTION(REPLACE)
  BIND PLAN(BSTMTPLN) -
       PKLIST(BSTMTPKG.BSTMTGEN -
              BSTMTPKG.BSTMTBAT) -
       ISOLATION(CS) -
       CURRENTDATA(NO) -
       VALIDATE(BIND) -
       ACQUIRE(USE) -
       RELEASE(COMMIT) -
       OWNER(BANKUSR) -
       ACTION(REPLACE)
  GRANT EXECUTE ON PLAN BSTMTPLN TO PUBLIC
  END
/*

//******************************************************************
//* JOB: BSTMTRUN
//* DESC: EXECUTION BATCH BSTMTBAT
//******************************************************************
//BSTMTRUN JOB (ACCT),'BANK STMT BATCH RUN',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,REGION=0M

//STEP010  EXEC PGM=BSTMTBAT,
//             PARM='',
//             REGION=4096K
//STEPLIB  DD  DISP=SHR,DSN=BANK.LOADLIB
//         DD  DISP=SHR,DSN=DB2.SDSNLOAD
//DSNAOINI DD  DISP=SHR,DSN=DB2.DSNAOINI
//PARMIN   DD  *
FR7630001007941234567890185 2024-01-01 2024-12-31
FR7630001007949876543210174 2024-01-01 2024-12-31
/*
//RELVOUT  DD  SYSOUT=*,DCB=(RECFM=FA,LRECL=133)
//SYSABEND DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*

//******************************************************************
//* JOB: BSTMTDDL
//* DESC: EXECUTION DDL DB2 (CREATION TABLES)
//******************************************************************
//BSTMTDDL JOB (ACCT),'BANK STMT DDL',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID

//STEP010  EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*
//SYSTSIN  DD  *
  DSN SYSTEM(DB2P)
  RUN PROGRAM(DSNTIAD) PLAN(DSNTIA)
    PARMS('/') -
    LIBRARY('DB2.SDSNLOAD')
  END
/*
//SYSIN    DD  DISP=SHR,
//             DSN=BANK.DEVLIB.SRCLIB(BSTMTDDL)

//******************************************************************
//* JOB: BSTMTCMB
//* DESC: COMPILE ET LINK-EDIT BSTMTBAT (VERSION BATCH)
//******************************************************************
//BSTMTCMB JOB (ACCT),'BANK STMT BAT COMPILE',
//             CLASS=A,MSGCLASS=X,MSGLEVEL=(1,1),
//             NOTIFY=&SYSUID,REGION=0M

//STEP010  EXEC PGM=DSNHPC,
//             PARM='HOST(COB2),SOURCE,XREF',
//             REGION=4096K
//DBRMLIB  DD  DISP=SHR,DSN=BANK.DEVLIB.DBRMLIB
//SYSCIN   DD  DSN=&&DSNTEMP,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSPRINT DD  SYSOUT=*
//SYSTERM  DD  SYSOUT=*
//SYSUDUMP DD  SYSOUT=*
//SYSIN    DD  DISP=SHR,
//             DSN=BANK.DEVLIB.SRCLIB(BSTMTBAT)

//STEP020  EXEC PGM=IGYCRCTL,
//             PARM='LIB,SOURCE,XREF,LIST,RENT,RMODE(ANY),AMODE(31)',
//             REGION=4096K,
//             COND=(4,LT,STEP010)
//SYSLIB   DD  DISP=SHR,DSN=DB2.SDSNLOAD
//         DD  DISP=SHR,DSN=SYS1.MACLIB
//SYSLIN   DD  DSN=&&LOADOBJ,DISP=(NEW,PASS),
//             UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT2   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT3   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSUT4   DD  UNIT=SYSDA,SPACE=(32000,(30,30))
//SYSIN    DD  DSN=&&DSNTEMP,DISP=(OLD,DELETE)

//STEP030  EXEC PGM=IEWL,
//             PARM='RENT,REUS,AMODE(31),RMODE(ANY),LIST',
//             REGION=4096K,
//             COND=(4,LT,STEP020)
//SYSLIB   DD  DISP=SHR,DSN=DB2.SDSNLOAD
//         DD  DISP=SHR,DSN=SYS1.LINKLIB
//SYSLMOD  DD  DISP=SHR,DSN=BANK.LOADLIB(BSTMTBAT)
//SYSPRINT DD  SYSOUT=*
//SYSUT1   DD  UNIT=SYSDA,SPACE=(1024,(50,20))
//SYSLIN   DD  DSN=&&LOADOBJ,DISP=(OLD,DELETE)
//         DD  *
 ENTRY BSTMTBAT
 NAME  BSTMTBAT(R)
/*
