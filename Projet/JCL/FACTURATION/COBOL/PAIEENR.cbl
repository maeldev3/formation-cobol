      ******************************************************************
      * PROGRAMME   : PAIEENR                                         *
      * DESCRIPTION : ENREGISTREMENT DES PAIEMENTS CLIENTS, MISE A    *
      *               JOUR DU SOLDE ET DU STATUT DES FACTURES         *
      * ENTREE      : PAITRAN  (SEQUENTIEL)                           *
      * E/S         : FACTMAST (INDEXE - MISE A JOUR SOLDE FACTURE)   *
      * SORTIE      : PAIEMENT (SEQUENTIEL - HISTORIQUE DES PAIEMENTS)*
      * SORTIE      : PAIERPT  (LISTING DES PAIEMENTS)                 *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. PAIEENR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PAIEMENT-TRAN-FILE ASSIGN TO PAITRAN
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT FACTURE-HDR-FILE   ASSIGN TO FACTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FAC-NUMERO
               FILE STATUS IS WS-FACTMAST-STATUS.

           SELECT PAIEMENT-FILE      ASSIGN TO PAIEMENT
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT PAIEMENT-REPORT-FILE ASSIGN TO PAIERPT
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  PAIEMENT-TRAN-FILE
           RECORDING MODE IS F.
       01  PAIEMENT-TRAN-REC           PIC X(50).

       FD  FACTURE-HDR-FILE
           RECORDING MODE IS F.
       COPY FACTHDRC.

       FD  PAIEMENT-FILE
           RECORDING MODE IS F.
       01  PAIEMENT-FILE-REC           PIC X(60).

       FD  PAIEMENT-REPORT-FILE
           RECORDING MODE IS F.
       01  PAIEMENT-REPORT-REC         PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FACTMAST-STATUS          PIC X(02).

       01  WS-SWITCHES.
           05  WS-EOF-TRAN              PIC X(01) VALUE 'N'.
               88  TRAN-EOF                       VALUE 'Y'.

       01  WS-COUNTERS.
           05  WS-CNT-LUS               PIC 9(05) VALUE ZEROES.
           05  WS-CNT-ENREGISTRES       PIC 9(05) VALUE ZEROES.
           05  WS-CNT-REJETS            PIC 9(05) VALUE ZEROES.
           05  WS-SEQ-PAIEMENT          PIC 9(08) VALUE ZEROES.

       COPY PAITRNRC.
       COPY PAIEMTRC.

       01  WS-DETAIL-LINE.
           05  WS-D-PAINUM             PIC X(10).
           05  WS-D-FACNUM             PIC X(10).
           05  WS-D-MONTANT            PIC Z(5)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-SOLDE              PIC Z(5)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-STATUT             PIC X(25).

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL TRAN-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           OPEN INPUT  PAIEMENT-TRAN-FILE
           OPEN I-O    FACTURE-HDR-FILE
           OPEN OUTPUT PAIEMENT-FILE
           OPEN OUTPUT PAIEMENT-REPORT-FILE
           PERFORM 9100-READ-TRAN.

       2000-TRAITEMENT.
           ADD 1 TO WS-CNT-LUS
           MOVE PTR-FAC-NUMERO TO FAC-NUMERO
           READ FACTURE-HDR-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE PTR-FAC-NUMERO TO WS-D-FACNUM
                   MOVE 'FACTURE INTROUVABLE' TO WS-D-STATUT
                   WRITE PAIEMENT-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   PERFORM 2100-APPLIQUER-PAIEMENT
           END-READ
           PERFORM 9100-READ-TRAN.

       2100-APPLIQUER-PAIEMENT.
           IF FAC-ANNULEE
               ADD 1 TO WS-CNT-REJETS
               MOVE FAC-NUMERO TO WS-D-FACNUM
               MOVE 'FACTURE ANNULEE - REJET' TO WS-D-STATUT
               WRITE PAIEMENT-REPORT-REC FROM WS-DETAIL-LINE
           ELSE
               ADD 1 TO WS-SEQ-PAIEMENT
               MOVE SPACES                TO PAIEMENT-RECORD
               STRING 'P' WS-SEQ-PAIEMENT
                   DELIMITED BY SIZE INTO PAI-NUMERO
               MOVE FAC-NUMERO             TO PAI-FAC-NUMERO
               MOVE FAC-CLI-ID             TO PAI-CLI-ID
               MOVE PTR-DATE-PAIEMENT      TO PAI-DATE-PAIEMENT
               MOVE PTR-MONTANT            TO PAI-MONTANT
               MOVE PTR-MODE-REGLEMENT     TO PAI-MODE-REGLEMENT
               MOVE PTR-REFERENCE          TO PAI-REFERENCE

               ADD PTR-MONTANT TO FAC-MONTANT-PAYE
               COMPUTE FAC-MONTANT-SOLDE =
                   FAC-MONTANT-TTC - FAC-MONTANT-PAYE

               IF FAC-MONTANT-SOLDE <= 0
                   SET FAC-SOLDEE TO TRUE
                   MOVE ZEROES TO FAC-MONTANT-SOLDE
               ELSE
                   SET FAC-PAYEE-PARTIEL TO TRUE
               END-IF

               REWRITE FACTURE-HEADER

               MOVE PAIEMENT-RECORD TO PAIEMENT-FILE-REC
               WRITE PAIEMENT-FILE-REC

               ADD 1 TO WS-CNT-ENREGISTRES
               MOVE PAI-NUMERO          TO WS-D-PAINUM
               MOVE FAC-NUMERO          TO WS-D-FACNUM
               MOVE PTR-MONTANT         TO WS-D-MONTANT
               MOVE FAC-MONTANT-SOLDE   TO WS-D-SOLDE
               IF FAC-SOLDEE
                   MOVE 'FACTURE SOLDEE' TO WS-D-STATUT
               ELSE
                   MOVE 'PAIEMENT PARTIEL ENREGISTRE'
                       TO WS-D-STATUT
               END-IF
               WRITE PAIEMENT-REPORT-REC FROM WS-DETAIL-LINE
           END-IF.

       3000-FINALISATION.
           MOVE SPACES TO PAIEMENT-REPORT-REC
           WRITE PAIEMENT-REPORT-REC
           STRING 'TOTAL LUS         : ' WS-CNT-LUS
               DELIMITED BY SIZE INTO PAIEMENT-REPORT-REC
           WRITE PAIEMENT-REPORT-REC
           STRING 'TOTAL ENREGISTRES : ' WS-CNT-ENREGISTRES
               DELIMITED BY SIZE INTO PAIEMENT-REPORT-REC
           WRITE PAIEMENT-REPORT-REC
           STRING 'TOTAL REJETS      : ' WS-CNT-REJETS
               DELIMITED BY SIZE INTO PAIEMENT-REPORT-REC
           WRITE PAIEMENT-REPORT-REC
           CLOSE PAIEMENT-TRAN-FILE
                 FACTURE-HDR-FILE
                 PAIEMENT-FILE
                 PAIEMENT-REPORT-FILE.

       9100-READ-TRAN.
           READ PAIEMENT-TRAN-FILE INTO PAIEMENT-TRANSACTION
               AT END
                   MOVE 'Y' TO WS-EOF-TRAN
           END-READ.
