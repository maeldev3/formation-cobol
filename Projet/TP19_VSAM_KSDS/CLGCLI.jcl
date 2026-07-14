//Z74830R  JOB (ACCTNO),'CLIGEST CLG',CLASS=A,MSGCLASS=H,
//             NOTIFY=&SYSUID,REGION=0M
//*--------------------------------------------------------------*
//* TP19 - COMPILE + LINK + GO DE CLIGEST (PROCEDURE IGYWCLG)     *
//* PRE-REQUIS : DEFCLI.jcl DEJA EXECUTE (CLUSTER VSAM CREE)      *
//* ADAPTER : NOM DU JOB, ACCTNO, DSN SOURCE/COPYLIB/LOAD          *
//*--------------------------------------------------------------*
//STEP1   EXEC IGYWCLG,
//        PARM.COBOL='LIB,APOST'
//COBOL.SYSLIB   DD DSN=Z74830.COBOL.COPYLIB,DISP=SHR
//COBOL.SYSIN    DD DSN=Z74830.COBOL.SOURCE(CLIGEST),DISP=SHR
//LKED.SYSLMOD   DD DSN=Z74830.LOAD(CLIGEST),DISP=SHR
//*--------------------------------------------------------------*
//* ETAPE GO : EXECUTION DU PROGRAMME                             *
//* CLIENTVS = DDNAME DU FICHIER VSAM (SELECT ... ASSIGN CLIENTVS)*
//* SYSIN    = CARTES DE CONTROLE (W/R/U/D/S) - VOIR CLIGEST.SYSIN*
//*--------------------------------------------------------------*
//GO.CLIENTVS DD DSN=Z74830.CLIENTS.VSAM,DISP=SHR
//GO.SYSOUT   DD SYSOUT=*
//GO.SYSIN    DD *
W000000001DUPONT              JEAN                ANTANANARIVO        0150000000
W000000002RAKOTO              MARIE               TOAMASINA           0085000000
W000000003RABE                PAUL                FIANARANTSOA        0220000000
W000000004RASOA               HELENE              MAHAJANGA           0050000000
W000000005ANDRY               NIRINA              ANTSIRABE           0300000000
R000000001                                                            0000000000
U000000002RAKOTO              MARIE               TOAMASINA           0125000000
D000000004                                                            0000000000
S000000001                                                            0000000005
/*
