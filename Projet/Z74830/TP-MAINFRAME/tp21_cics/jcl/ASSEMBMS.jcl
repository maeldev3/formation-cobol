//ASSEMBMS JOB (COMPTE),'ASSEMB BMS',CLASS=A,MSGCLASS=X,
//         NOTIFY=&SYSUID
//*--------------------------------------------------------------*
//* TP21 - Assemblage du mapset MENUSET (genere la map physique  *
//* + la carte symbolique COBOL copiee dans la lib COPYLIB)      *
//*--------------------------------------------------------------*
//ASM      EXEC DFHMAPS,MAPNAME=MENUSET
//ASM.SYSIN DD DSN=VOTRE.HLQ.SOURCE.BMS(MENUSET),DISP=SHR
//*  Remarque : adapter SUFFIX= dans la proc DFHMAPS de votre site si
//*  votre installation en exige un (ex: SUFFIX=D pour un support DBCS).
//*
//* Sorties generees par la procedure DFHMAPS :
//*   - Load module de la map   -> VOTRE.HLQ.LOAD
//*   - Copybook COBOL MENUMAP  -> VOTRE.HLQ.COPYLIB(MENUMAP)
//*
