/* REXX ============================================================
   NOM      : BSTMTEXC
   DESC     : EXEC ISPF - LANCEUR APPLICATION RELEVES BANCAIRES
   AUTEUR   : BANK STATEMENT GENERATOR
   DATE     : 2024-01-01
   ============================================================== */

TRACE OFF
ADDRESS ISPEXEC

/* ---------------------------------------------------------------- */
/* INITIALISATION                                                    */
/* ---------------------------------------------------------------- */
BSTMT_LIB = "BANK.DEVLIB.PANELS"
MSG = ''

/* Allouer les panneaux */
"LIBDEF ISPPLIB LIBRARY ID('"BSTMT_LIB"') STACK"
IF RC <> 0 THEN DO
   MSG = 'ERREUR ALLOCATION PANNEAUX RC='RC
   SAY MSG
   EXIT 8
END

/* Allouer les tables */
"LIBDEF ISPTLIB LIBRARY ID('BANK.DEVLIB.TABLES') STACK"

/* ---------------------------------------------------------------- */
/* BOUCLE PRINCIPALE ISPF                                            */
/* ---------------------------------------------------------------- */
DO FOREVER
   "DISPLAY PANEL(BSTMMENU)"
   SEL_RC = RC

   IF SEL_RC = 8 THEN LEAVE      /* PF3 - Quitter */

   /* Recuperer la selection */
   "VGET (OPTION) SHARED"

   SELECT
      WHEN OPTION = 'X' THEN LEAVE
      WHEN OPTION = '1' THEN CALL GEN_RELEVE
      WHEN OPTION = '2' THEN CALL AFF_HISTORIQUE
      WHEN OPTION = '3' THEN CALL RECH_CLIENT
      WHEN OPTION = '4' THEN CALL PARAMETRES
      OTHERWISE NOP
   END
END

/* ---------------------------------------------------------------- */
/* LIBERATION DES RESSOURCES                                         */
/* ---------------------------------------------------------------- */
"LIBDEF ISPPLIB"
"LIBDEF ISPTLIB"
EXIT 0

/* ================================================================ */
/* ROUTINE: GENERATION RELEVE                                        */
/* ================================================================ */
GEN_RELEVE:
   "DISPLAY PANEL(BSTM01)"
   IF RC = 8 THEN RETURN

   "VGET (COMPTE DTDEBUT DTFIN FORMAT) SHARED"

   /* Validation basique */
   IF COMPTE = '' THEN DO
      ZEDLMSG = 'NUMERO DE COMPTE OBLIGATOIRE'
      "SETMSG MSG(ISRZ001)"
      RETURN
   END

   /* Lancer la transaction CICS via TSO */
   RELEVE_CMD = "CICS TRANSACTION(BSTM)"
   RELEVE_CMD = RELEVE_CMD "COMMAREA(COMPTE="COMPTE
   RELEVE_CMD = RELEVE_CMD "DEBUT="DTDEBUT
   RELEVE_CMD = RELEVE_CMD "FIN="DTFIN")"

   /* Afficher message de confirmation */
   ZEDLMSG = 'RELEVE GENERE POUR COMPTE: 'COMPTE
   "SETMSG MSG(ISRZ001)"

   IF FORMAT = 'E' THEN DO
      /* Afficher a l ecran */
      "DISPLAY PANEL(BSTM02)"
   END
   ELSE IF FORMAT = 'I' THEN DO
      /* Envoyer a l imprimante */
      CALL PRINT_RELEVE
   END
   ELSE IF FORMAT = 'F' THEN DO
      /* Sauvegarder en fichier */
      CALL SAVE_RELEVE
   END
   RETURN

/* ================================================================ */
/* ROUTINE: AFFICHAGE HISTORIQUE                                     */
/* ================================================================ */
AFF_HISTORIQUE:
   "DISPLAY PANEL(BSTM02)"
   RETURN

/* ================================================================ */
/* ROUTINE: RECHERCHE CLIENT                                         */
/* ================================================================ */
RECH_CLIENT:
   "DISPLAY PANEL(BSTM03)"
   IF RC = 8 THEN RETURN
   "VGET (NOMRECH CPTRECH IDRECH) SHARED"
   /* Effectuer la recherche via DB2 REXX */
   CALL DO_SEARCH
   RETURN

DO_SEARCH:
   ADDRESS DSNREXX
   "CONNECT DB2P"
   IF SQLCODE <> 0 THEN DO
      ZEDLMSG = 'ERREUR CONNEXION DB2: 'SQLCODE
      ADDRESS ISPEXEC "SETMSG MSG(ISRZ001)"
      RETURN
   END

   IF CPTRECH <> '' THEN DO
      "EXECSQL SELECT CLIENT_ID, NOM, PRENOM, ADRESSE, VILLE",
              "INTO :CLI_ID, :CLI_NOM, :CLI_PRENOM,",
              "     :CLI_ADR, :CLI_VILLE",
              "FROM BANKDB.CLIENTS",
              "WHERE NUM_COMPTE = '"CPTRECH"'"
   END
   ELSE IF NOMRECH <> '' THEN DO
      "EXECSQL SELECT CLIENT_ID, NOM, PRENOM, ADRESSE, VILLE",
              "INTO :CLI_ID, :CLI_NOM, :CLI_PRENOM,",
              "     :CLI_ADR, :CLI_VILLE",
              "FROM BANKDB.CLIENTS",
              "WHERE NOM LIKE '"NOMRECH"%'"
   END

   IF SQLCODE = 0 THEN DO
      ZEDLMSG = 'CLIENT TROUVE: 'CLI_NOM' 'CLI_PRENOM
      ADDRESS ISPEXEC "SETMSG MSG(ISRZ001)"
   END
   ELSE IF SQLCODE = 100 THEN DO
      ZEDLMSG = 'AUCUN CLIENT TROUVE'
      ADDRESS ISPEXEC "SETMSG MSG(ISRZ001)"
   END

   "DISCONNECT"
   ADDRESS ISPEXEC
   RETURN

/* ================================================================ */
/* ROUTINE: PARAMETRES                                               */
/* ================================================================ */
PARAMETRES:
   "DISPLAY PANEL(BSTM04)"
   RETURN

/* ================================================================ */
/* ROUTINE: IMPRESSION                                               */
/* ================================================================ */
PRINT_RELEVE:
   ZEDLMSG = 'RELEVE ENVOYE A LIMPRIMANTE'
   ADDRESS ISPEXEC "SETMSG MSG(ISRZ001)"
   RETURN

/* ================================================================ */
/* ROUTINE: SAUVEGARDE FICHIER                                       */
/* ================================================================ */
SAVE_RELEVE:
   DSN_OUT = "'"SYSVAR('SYSUID')".BANK.RELEVE.D"DATE('S')"'"
   ZEDLMSG = 'RELEVE SAUVEGARDE: 'DSN_OUT
   ADDRESS ISPEXEC "SETMSG MSG(ISRZ001)"
   RETURN
