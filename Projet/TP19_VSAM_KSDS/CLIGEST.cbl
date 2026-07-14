      *---------------------------------------------------------*
      * PROGRAMME  : CLIGEST                                    *
      * TP19       : VSAM KSDS - CLIENTS.VSAM                   *
      * OBJET      : PILOTE PAR CARTES SYSIN, DEMONTRE          *
      *              READ / WRITE / REWRITE / DELETE / START    *
      *              SUR UN FICHIER VSAM KSDS                   *
      *---------------------------------------------------------*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIGEST.
       AUTHOR. Z74830.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENT-FILE ASSIGN TO CLIENTVS
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CLI-ID
               FILE STATUS IS WS-FS-CLIENT.

           SELECT CTL-FILE ASSIGN TO SYSIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS-CTL.

       DATA DIVISION.
       FILE SECTION.
       FD  CLIENT-FILE
           RECORDING MODE IS F.
       COPY CLIENTREC.

       FD  CTL-FILE
           RECORDING MODE IS F.
       COPY CTLREC.

       WORKING-STORAGE SECTION.
       01  WS-FS-CLIENT            PIC X(2).
       01  WS-FS-CTL               PIC X(2).
       01  WS-EOF-CTL              PIC X       VALUE 'N'.
           88  EOF-CTL                         VALUE 'Y'.

       01  WS-COMPTEURS.
           05  WS-CPT-LUS          PIC 9(5)    VALUE ZERO.
           05  WS-CPT-ECRITS       PIC 9(5)    VALUE ZERO.
           05  WS-CPT-LUS-OK       PIC 9(5)    VALUE ZERO.
           05  WS-CPT-MAJ          PIC 9(5)    VALUE ZERO.
           05  WS-CPT-SUPPR        PIC 9(5)    VALUE ZERO.
           05  WS-CPT-PARCOURUS    PIC 9(5)    VALUE ZERO.
           05  WS-CPT-ERREURS      PIC 9(5)    VALUE ZERO.

       01  WS-IDX                  PIC 9(3)    VALUE ZERO.
       01  WS-SOLDE-EDIT           PIC -(6)9.99.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITER-CARTE UNTIL EOF-CTL
           PERFORM 8000-BILAN
           PERFORM 9000-TERMINAISON
           STOP RUN.

       1000-INITIALISATION.
           OPEN I-O CLIENT-FILE
           IF WS-FS-CLIENT NOT = '00'
               DISPLAY 'CLIGEST - ERREUR OPEN CLIENTS.VSAM FS='
                       WS-FS-CLIENT
               PERFORM 9999-ABEND
           END-IF

           OPEN INPUT CTL-FILE
           IF WS-FS-CTL NOT = '00'
               DISPLAY 'CLIGEST - ERREUR OPEN SYSIN FS=' WS-FS-CTL
               PERFORM 9999-ABEND
           END-IF

           DISPLAY 'CLIGEST - DEBUT DE TRAITEMENT'
           PERFORM 1100-LIRE-CARTE.

       1100-LIRE-CARTE.
           READ CTL-FILE
               AT END
                   SET EOF-CTL TO TRUE
               NOT AT END
                   ADD 1 TO WS-CPT-LUS
           END-READ.

       2000-TRAITER-CARTE.
           EVALUATE CTL-ACTION
               WHEN 'W'
                   PERFORM 3000-AJOUTER-CLIENT
               WHEN 'R'
                   PERFORM 4000-CONSULTER-CLIENT
               WHEN 'U'
                   PERFORM 5000-MODIFIER-CLIENT
               WHEN 'D'
                   PERFORM 6000-SUPPRIMER-CLIENT
               WHEN 'S'
                   PERFORM 7000-PARCOURIR-CLIENTS
               WHEN OTHER
                   DISPLAY 'CLIGEST - ACTION INCONNUE [' CTL-ACTION
                           ']'
                   ADD 1 TO WS-CPT-ERREURS
           END-EVALUATE
           PERFORM 1100-LIRE-CARTE.

      *---------------------------------------------------------*
      * WRITE : AJOUT D'UN NOUVEAU CLIENT                       *
      *---------------------------------------------------------*
       3000-AJOUTER-CLIENT.
           MOVE SPACES TO CLIENT-RECORD
           MOVE CTL-CLI-ID   TO CLI-ID
           MOVE CTL-NOM      TO CLI-NOM
           MOVE CTL-PRENOM   TO CLI-PRENOM
           MOVE CTL-VILLE    TO CLI-VILLE
           MOVE CTL-SOLDE    TO CLI-SOLDE
           MOVE SPACES       TO CLI-ADRESSE
           MOVE SPACES       TO CLI-TELEPHONE
           MOVE '00000000'   TO CLI-DATE-MAJ

           WRITE CLIENT-RECORD
               INVALID KEY
                   DISPLAY 'WRITE   KO - CLI-ID=' CLI-ID
                           ' FS=' WS-FS-CLIENT
                   ADD 1 TO WS-CPT-ERREURS
               NOT INVALID KEY
                   DISPLAY 'WRITE   OK - CLI-ID=' CLI-ID
                           ' NOM=' CLI-NOM
                   ADD 1 TO WS-CPT-ECRITS
           END-WRITE.

      *---------------------------------------------------------*
      * READ : CONSULTATION D'UN CLIENT PAR CLE                 *
      *---------------------------------------------------------*
       4000-CONSULTER-CLIENT.
           MOVE CTL-CLI-ID TO CLI-ID
           READ CLIENT-FILE
               INVALID KEY
                   DISPLAY 'READ    KO - CLI-ID=' CLI-ID
                           ' FS=' WS-FS-CLIENT
                   ADD 1 TO WS-CPT-ERREURS
               NOT INVALID KEY
                   MOVE CLI-SOLDE TO WS-SOLDE-EDIT
                   DISPLAY 'READ    OK - CLI-ID=' CLI-ID
                           ' NOM=' CLI-NOM
                           ' PRENOM=' CLI-PRENOM
                           ' VILLE=' CLI-VILLE
                           ' SOLDE=' WS-SOLDE-EDIT
                   ADD 1 TO WS-CPT-LUS-OK
           END-READ.

      *---------------------------------------------------------*
      * REWRITE : MODIFICATION D'UN CLIENT EXISTANT             *
      * (LECTURE PREALABLE OBLIGATOIRE AVANT REWRITE)           *
      *---------------------------------------------------------*
       5000-MODIFIER-CLIENT.
           MOVE CTL-CLI-ID TO CLI-ID
           READ CLIENT-FILE
               INVALID KEY
                   DISPLAY 'REWRITE KO - LECTURE PREALABLE '
                           'IMPOSSIBLE CLI-ID=' CLI-ID
                   ADD 1 TO WS-CPT-ERREURS
               NOT INVALID KEY
                   MOVE CTL-VILLE TO CLI-VILLE
                   MOVE CTL-SOLDE TO CLI-SOLDE
                   REWRITE CLIENT-RECORD
                       INVALID KEY
                           DISPLAY 'REWRITE KO - CLI-ID=' CLI-ID
                                   ' FS=' WS-FS-CLIENT
                           ADD 1 TO WS-CPT-ERREURS
                       NOT INVALID KEY
                           DISPLAY 'REWRITE OK - CLI-ID=' CLI-ID
                                   ' NOUVELLE VILLE=' CLI-VILLE
                           ADD 1 TO WS-CPT-MAJ
                   END-REWRITE
           END-READ.

      *---------------------------------------------------------*
      * DELETE : SUPPRESSION D'UN CLIENT PAR CLE                *
      *---------------------------------------------------------*
       6000-SUPPRIMER-CLIENT.
           MOVE CTL-CLI-ID TO CLI-ID
           DELETE CLIENT-FILE
               INVALID KEY
                   DISPLAY 'DELETE  KO - CLI-ID=' CLI-ID
                           ' FS=' WS-FS-CLIENT
                   ADD 1 TO WS-CPT-ERREURS
               NOT INVALID KEY
                   DISPLAY 'DELETE  OK - CLI-ID=' CLI-ID
                   ADD 1 TO WS-CPT-SUPPR
           END-DELETE.

      *---------------------------------------------------------*
      * START + READ NEXT : PARCOURS SEQUENTIEL A PARTIR        *
      * D'UNE CLE DE DEPART (CTL-NBR ENREGISTREMENTS LUS)       *
      *---------------------------------------------------------*
       7000-PARCOURIR-CLIENTS.
           MOVE CTL-CLI-ID TO CLI-ID
           START CLIENT-FILE KEY IS NOT LESS THAN CLI-ID
               INVALID KEY
                   DISPLAY 'START   KO - CLI-ID=' CLI-ID
                           ' FS=' WS-FS-CLIENT
                   ADD 1 TO WS-CPT-ERREURS
               NOT INVALID KEY
                   DISPLAY 'START   OK - POSITIONNE A PARTIR DE '
                           'CLI-ID=' CLI-ID
                   PERFORM 7100-LIRE-N-SUIVANTS
           END-START.

       7100-LIRE-N-SUIVANTS.
           MOVE ZERO TO WS-IDX
           PERFORM UNTIL WS-IDX >= CTL-NBR
                      OR WS-FS-CLIENT NOT = '00'
               READ CLIENT-FILE NEXT RECORD
                   AT END
                       DISPLAY '        FIN DE FICHIER CLIENTS.VSAM'
                   NOT AT END
                       MOVE CLI-SOLDE TO WS-SOLDE-EDIT
                       DISPLAY '        -> CLI-ID=' CLI-ID
                               ' NOM=' CLI-NOM
                               ' VILLE=' CLI-VILLE
                               ' SOLDE=' WS-SOLDE-EDIT
                       ADD 1 TO WS-CPT-PARCOURUS
                       ADD 1 TO WS-IDX
               END-READ
           END-PERFORM.

       8000-BILAN.
           DISPLAY '==========================================='
           DISPLAY 'CLIGEST - BILAN DE TRAITEMENT'
           DISPLAY '  CARTES LUES         : ' WS-CPT-LUS
           DISPLAY '  WRITE   REUSSIS     : ' WS-CPT-ECRITS
           DISPLAY '  READ    REUSSIS     : ' WS-CPT-LUS-OK
           DISPLAY '  REWRITE REUSSIS     : ' WS-CPT-MAJ
           DISPLAY '  DELETE  REUSSIS     : ' WS-CPT-SUPPR
           DISPLAY '  ENREG. PARCOURUS    : ' WS-CPT-PARCOURUS
           DISPLAY '  ERREURS             : ' WS-CPT-ERREURS
           DISPLAY '==========================================='.

       9000-TERMINAISON.
           CLOSE CLIENT-FILE
           CLOSE CTL-FILE
           DISPLAY 'CLIGEST - FIN DE TRAITEMENT'.

       9999-ABEND.
           DISPLAY 'CLIGEST - ARRET ANORMAL DU PROGRAMME'
           MOVE 16 TO RETURN-CODE
           STOP RUN.
