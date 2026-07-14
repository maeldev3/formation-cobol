//COMPCBL  JOB (COMPTE),'COMPIL COBOL-CICS',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*--------------------------------------------------------------*
//* TP21 - Compilation + edition de liens des 5 programmes CICS  *
//* (a soumettre une fois par programme, ou en repetant le step  *
//* pour chacun : MENU00, AJOU00, MODI00, SUPP00, RECH00)        *
//*--------------------------------------------------------------*
//CICSCOB  EXEC DFHEITVL              (ou DFHEIP1$/IGYWCLG selon site)
//TRN.SYSIN DD DSN=VOTRE.HLQ.SOURCE.COBOL(MENU00),DISP=SHR
//LKED.SYSLMOD DD DSN=VOTRE.HLQ.LOAD,DISP=SHR
//*
//* Copybook genere par le step d'assemblage BMS a rendre visible :
//COB.SYSLIB DD DSN=VOTRE.HLQ.COPYLIB,DISP=SHR
//           DD DSN=CICSTS.SDFHCOB,DISP=SHR
//*
//* NB : le nom exact de la procedure catalogee (DFHEITVL, DFHYITVL,
//* IGYWCLG + CICS translator...) depend de la version CICS/COBOL de
//* votre etablissement. Demandez la proc standard utilisee par votre
//* centre de formation si celle-ci differe.
