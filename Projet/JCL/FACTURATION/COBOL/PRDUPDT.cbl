      ******************************************************************
      * PROGRAMME   : PRDUPDT                                         *
      * DESCRIPTION : MISE A JOUR DU FICHIER MAITRE PRODUITS A PARTIR *
      *               D'UN FICHIER DE TRANSACTIONS (AJOUT/MODIF/SUPP) *
      * ENTREE      : PRDTRAN  (SEQUENTIEL)                           *
      * E/S         : PRODMAST (INDEXE SUR PRD-CODE)                  *
      * SORTIE      : PRDRPT   (LISTING DES MOUVEMENTS)                *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PRDUPDT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRODUIT-TRAN-FILE  ASSIGN TO PRDTRAN
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT PRODUIT-MASTER-FILE ASSIGN TO PRODMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS PRD-CODE
               FILE STATUS IS WS-PRODMAST-STATUS.

           SELECT PRODUIT-REPORT-FILE ASSIGN TO PRDRPT
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PRODUIT-TRAN-FILE
           RECORDING MODE IS F.
       01  PRODUIT-TRAN-REC            PIC X(80).

       FD  PRODUIT-MASTER-FILE
           RECORDING MODE IS F.
       COPY PRODUITRC.

       FD  PRODUIT-REPORT-FILE
           RECORDING MODE IS F.
       01  PRODUIT-REPORT-REC          PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-PRODMAST-STATUS          PIC X(02).

       01  WS-SWITCHES.
           05  WS-EOF-TRAN              PIC X(01) VALUE 'N'.
               88  TRAN-EOF                       VALUE 'Y'.

       01  WS-COUNTERS.
           05  WS-CNT-LUS               PIC 9(05) VALUE ZEROES.
           05  WS-CNT-AJOUTS            PIC 9(05) VALUE ZEROES.
           05  WS-CNT-MODIFS            PIC 9(05) VALUE ZEROES.
           05  WS-CNT-SUPPR             PIC 9(05) VALUE ZEROES.
           05  WS-CNT-REJETS            PIC 9(05) VALUE ZEROES.

       COPY PRDTRNRC.

       01  WS-DETAIL-LINE.
           05  WS-D-ACTION             PIC X(08).
           05  WS-D-CODE               PIC X(10).
           05  WS-D-LIBELLE            PIC X(32).
           05  WS-D-STATUT             PIC X(20).

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL TRAN-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           OPEN INPUT  PRODUIT-TRAN-FILE
           OPEN I-O    PRODUIT-MASTER-FILE
           OPEN OUTPUT PRODUIT-REPORT-FILE
           PERFORM 9100-READ-TRAN.

       2000-TRAITEMENT.
           ADD 1 TO WS-CNT-LUS
           EVALUATE PRT-CODE-ACTION
               WHEN 'A'
                   PERFORM 2100-AJOUT-PRODUIT
               WHEN 'M'
                   PERFORM 2200-MODIFICATION-PRODUIT
               WHEN 'S'
                   PERFORM 2300-SUPPRESSION-PRODUIT
               WHEN OTHER
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'    TO WS-D-ACTION
                   MOVE PRT-CODE   TO WS-D-CODE
                   MOVE 'CODE ACTION INVALIDE' TO WS-D-STATUT
                   WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE
           END-EVALUATE
           PERFORM 9100-READ-TRAN.

       2100-AJOUT-PRODUIT.
           MOVE SPACES                TO PRODUIT-RECORD
           MOVE PRT-CODE                TO PRD-CODE
           MOVE PRT-LIBELLE              TO PRD-LIBELLE
           MOVE PRT-PRIX-UNITAIRE        TO PRD-PRIX-UNITAIRE
           MOVE PRT-TAUX-TVA             TO PRD-TAUX-TVA
           MOVE PRT-STOCK-DISPO          TO PRD-STOCK-DISPO
           MOVE PRT-CATEGORIE            TO PRD-CATEGORIE
           SET  PRD-ACTIF                TO TRUE

           WRITE PRODUIT-RECORD
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE PRT-CODE  TO WS-D-CODE
                   MOVE 'PRODUIT DEJA EXISTANT' TO WS-D-STATUT
               NOT INVALID KEY
                   ADD 1 TO WS-CNT-AJOUTS
                   MOVE 'AJOUT'    TO WS-D-ACTION
                   MOVE PRT-CODE   TO WS-D-CODE
                   MOVE PRT-LIBELLE TO WS-D-LIBELLE
                   MOVE 'CREE'     TO WS-D-STATUT
           END-WRITE
           WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE.

       2200-MODIFICATION-PRODUIT.
           MOVE PRT-CODE TO PRD-CODE
           READ PRODUIT-MASTER-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE PRT-CODE  TO WS-D-CODE
                   MOVE 'PRODUIT INTROUVABLE' TO WS-D-STATUT
                   WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   MOVE PRT-LIBELLE        TO PRD-LIBELLE
                   MOVE PRT-PRIX-UNITAIRE  TO PRD-PRIX-UNITAIRE
                   MOVE PRT-TAUX-TVA       TO PRD-TAUX-TVA
                   MOVE PRT-STOCK-DISPO    TO PRD-STOCK-DISPO
                   MOVE PRT-CATEGORIE      TO PRD-CATEGORIE
                   REWRITE PRODUIT-RECORD
                   ADD 1 TO WS-CNT-MODIFS
                   MOVE 'MODIF'    TO WS-D-ACTION
                   MOVE PRT-CODE   TO WS-D-CODE
                   MOVE PRT-LIBELLE TO WS-D-LIBELLE
                   MOVE 'MIS A JOUR' TO WS-D-STATUT
                   WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE
           END-READ.

       2300-SUPPRESSION-PRODUIT.
           MOVE PRT-CODE TO PRD-CODE
           READ PRODUIT-MASTER-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE PRT-CODE  TO WS-D-CODE
                   MOVE 'PRODUIT INTROUVABLE' TO WS-D-STATUT
                   WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   SET PRD-INACTIF TO TRUE
                   REWRITE PRODUIT-RECORD
                   ADD 1 TO WS-CNT-SUPPR
                   MOVE 'SUPPR'    TO WS-D-ACTION
                   MOVE PRT-CODE   TO WS-D-CODE
                   MOVE PRD-LIBELLE TO WS-D-LIBELLE
                   MOVE 'DESACTIVE' TO WS-D-STATUT
                   WRITE PRODUIT-REPORT-REC FROM WS-DETAIL-LINE
           END-READ.

       3000-FINALISATION.
           MOVE SPACES TO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           STRING 'TOTAL LUS    : ' WS-CNT-LUS
               DELIMITED BY SIZE INTO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           STRING 'TOTAL AJOUTS : ' WS-CNT-AJOUTS
               DELIMITED BY SIZE INTO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           STRING 'TOTAL MODIFS : ' WS-CNT-MODIFS
               DELIMITED BY SIZE INTO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           STRING 'TOTAL SUPPR  : ' WS-CNT-SUPPR
               DELIMITED BY SIZE INTO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           STRING 'TOTAL REJETS : ' WS-CNT-REJETS
               DELIMITED BY SIZE INTO PRODUIT-REPORT-REC
           WRITE PRODUIT-REPORT-REC
           CLOSE PRODUIT-TRAN-FILE
                 PRODUIT-MASTER-FILE
                 PRODUIT-REPORT-FILE.

       9100-READ-TRAN.
           READ PRODUIT-TRAN-FILE INTO PRODUIT-TRANSACTION
               AT END
                   MOVE 'Y' TO WS-EOF-TRAN
           END-READ.
