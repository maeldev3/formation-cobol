      ******************************************************************
      * PROGRAMME   : FACTSOLD                                        *
      * DESCRIPTION : EDITION DU RAPPORT DES FACTURES IMPAYEES OU     *
      *               PARTIELLEMENT PAYEES, AVEC SOLDE RESTANT DU     *
      * ENTREE      : FACTMAST (INDEXE - LECTURE SEQUENTIELLE)        *
      * ENTREE      : CLIMAST  (INDEXE - CONSULTATION CLIENT)         *
      * SORTIE      : SOLDRPT  (LISTING DES IMPAYES)                  *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTSOLD.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FACTURE-HDR-FILE  ASSIGN TO FACTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS FAC-NUMERO
               FILE STATUS IS WS-FACTMAST-STATUS.

           SELECT CLIENT-MASTER-FILE ASSIGN TO CLIMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CLI-ID
               FILE STATUS IS WS-CLIMAST-STATUS.

           SELECT SOLDE-REPORT-FILE ASSIGN TO SOLDRPT
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FACTURE-HDR-FILE
           RECORDING MODE IS F.
       COPY FACTHDRC.

       FD  CLIENT-MASTER-FILE
           RECORDING MODE IS F.
       COPY CLIENTRC.

       FD  SOLDE-REPORT-FILE
           RECORDING MODE IS F.
       01  SOLDE-REPORT-REC            PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FACTMAST-STATUS          PIC X(02).
       01  WS-CLIMAST-STATUS           PIC X(02).

       01  WS-SWITCHES.
           05  WS-EOF-FACTURE           PIC X(01) VALUE 'N'.
               88  FACTURE-EOF                    VALUE 'Y'.

       01  WS-TOTAUX.
           05  WS-TOT-SOLDE             PIC S9(9)V99 COMP-3
                                                    VALUE ZEROES.
           05  WS-CNT-IMPAYEES          PIC 9(05)  VALUE ZEROES.

       01  WS-HEADER-LINE-1.
           05  FILLER  PIC X(50) VALUE
               'RAPPORT DES FACTURES EN ATTENTE DE PAIEMENT'.

       01  WS-HEADER-LINE-2.
           05  FILLER  PIC X(10) VALUE 'FACTURE'.
           05  FILLER  PIC X(08) VALUE 'CLIENT'.
           05  FILLER  PIC X(32) VALUE 'NOM CLIENT'.
           05  FILLER  PIC X(12) VALUE 'ECHEANCE'.
           05  FILLER  PIC X(14) VALUE 'MONTANT TTC'.
           05  FILLER  PIC X(14) VALUE 'SOLDE DU'.
           05  FILLER  PIC X(10) VALUE 'STATUT'.

       01  WS-DETAIL-LINE.
           05  WS-D-FACNUM             PIC X(10).
           05  WS-D-CLIID              PIC X(08).
           05  WS-D-NOM                PIC X(32).
           05  WS-D-ECHEANCE           PIC X(12).
           05  WS-D-TTC                PIC Z(7)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-SOLDE              PIC Z(7)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-STATUT             PIC X(12).

       01  WS-GRAND-TOTAL-LINE.
           05  FILLER  PIC X(28) VALUE
               'NOMBRE DE FACTURES IMPAYEES:'.
           05  WS-GT-CNT               PIC ZZZZ9.
           05  FILLER  PIC X(20) VALUE '   TOTAL SOLDE DU : '.
           05  WS-GT-SOLDE              PIC Z(8)9.99.

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL FACTURE-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           OPEN INPUT  FACTURE-HDR-FILE
           OPEN INPUT  CLIENT-MASTER-FILE
           OPEN OUTPUT SOLDE-REPORT-FILE
           WRITE SOLDE-REPORT-REC FROM WS-HEADER-LINE-1
           MOVE SPACES TO SOLDE-REPORT-REC
           WRITE SOLDE-REPORT-REC
           WRITE SOLDE-REPORT-REC FROM WS-HEADER-LINE-2
           PERFORM 9100-READ-FACTURE.

       2000-TRAITEMENT.
           IF FAC-OUVERTE OR FAC-PAYEE-PARTIEL
               PERFORM 2100-EDITER-FACTURE-IMPAYEE
           END-IF
           PERFORM 9100-READ-FACTURE.

       2100-EDITER-FACTURE-IMPAYEE.
           ADD 1 TO WS-CNT-IMPAYEES
           ADD FAC-MONTANT-SOLDE TO WS-TOT-SOLDE

           MOVE FAC-CLI-ID TO CLI-ID
           READ CLIENT-MASTER-FILE
               INVALID KEY
                   MOVE 'CLIENT INCONNU' TO WS-D-NOM
               NOT INVALID KEY
                   STRING CLI-PRENOM DELIMITED BY '  '
                          ' '        DELIMITED BY SIZE
                          CLI-NOM    DELIMITED BY '  '
                          INTO WS-D-NOM
           END-READ

           MOVE FAC-NUMERO          TO WS-D-FACNUM
           MOVE FAC-CLI-ID          TO WS-D-CLIID
           MOVE FAC-DATE-ECHEANCE   TO WS-D-ECHEANCE
           MOVE FAC-MONTANT-TTC     TO WS-D-TTC
           MOVE FAC-MONTANT-SOLDE   TO WS-D-SOLDE
           IF FAC-OUVERTE
               MOVE 'OUVERTE'        TO WS-D-STATUT
           ELSE
               MOVE 'PAIEMENT PART'  TO WS-D-STATUT
           END-IF
           WRITE SOLDE-REPORT-REC FROM WS-DETAIL-LINE.

       3000-FINALISATION.
           MOVE SPACES TO SOLDE-REPORT-REC
           WRITE SOLDE-REPORT-REC
           MOVE WS-CNT-IMPAYEES TO WS-GT-CNT
           MOVE WS-TOT-SOLDE    TO WS-GT-SOLDE
           WRITE SOLDE-REPORT-REC FROM WS-GRAND-TOTAL-LINE
           CLOSE FACTURE-HDR-FILE
                 CLIENT-MASTER-FILE
                 SOLDE-REPORT-FILE.

       9100-READ-FACTURE.
           READ FACTURE-HDR-FILE NEXT RECORD
               AT END
                   MOVE 'Y' TO WS-EOF-FACTURE
           END-READ.
