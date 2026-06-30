      ******************************************************************
      * PROGRAMME   : CLIUPDT                                         *
      * AUTEUR      : SYSTEME DE FACTURATION                          *
      * DESCRIPTION : MISE A JOUR DU FICHIER MAITRE CLIENTS A PARTIR  *
      *               D'UN FICHIER DE TRANSACTIONS (AJOUT/MODIF/SUPP) *
      * ENTREE      : CLITRAN  (SEQUENTIEL)                           *
      * E/S         : CLIMAST  (INDEXE SUR CLI-ID)                    *
      * SORTIE      : CLIRPT   (LISTING DES MOUVEMENTS)                *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIUPDT.
       AUTHOR. SYSTEME-FACTURATION.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENT-TRAN-FILE  ASSIGN TO CLITRAN
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT CLIENT-MASTER-FILE ASSIGN TO CLIMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CLI-ID
               FILE STATUS IS WS-CLIMAST-STATUS.

           SELECT CLIENT-REPORT-FILE ASSIGN TO CLIRPT
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CLIENT-TRAN-FILE
           RECORDING MODE IS F.
       01  CLIENT-TRAN-REC             PIC X(150).

       FD  CLIENT-MASTER-FILE
           RECORDING MODE IS F.
       COPY CLIENTRC.

       FD  CLIENT-REPORT-FILE
           RECORDING MODE IS F.
       01  CLIENT-REPORT-REC           PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-CLIMAST-STATUS           PIC X(02).
           88  WS-CLIMAST-OK                  VALUE '00'.
           88  WS-CLIMAST-NOTFOUND            VALUE '23'.
           88  WS-CLIMAST-DUPLICATE           VALUE '22'.

       01  WS-SWITCHES.
           05  WS-EOF-TRAN              PIC X(01) VALUE 'N'.
               88  TRAN-EOF                       VALUE 'Y'.

       01  WS-COUNTERS.
           05  WS-CNT-LUS               PIC 9(05) VALUE ZEROES.
           05  WS-CNT-AJOUTS            PIC 9(05) VALUE ZEROES.
           05  WS-CNT-MODIFS            PIC 9(05) VALUE ZEROES.
           05  WS-CNT-SUPPR             PIC 9(05) VALUE ZEROES.
           05  WS-CNT-REJETS            PIC 9(05) VALUE ZEROES.

       COPY CLITRNRC.

       01  WS-HEADING-1.
           05  FILLER                  PIC X(35)
               VALUE 'LISTING DES MOUVEMENTS CLIENTS'.
       01  WS-HEADING-2.
           05  FILLER                  PIC X(08) VALUE 'ACTION'.
           05  FILLER                  PIC X(08) VALUE 'CLI-ID'.
           05  FILLER                  PIC X(30) VALUE 'NOM'.
           05  FILLER                  PIC X(20) VALUE 'STATUT'.

       01  WS-DETAIL-LINE.
           05  WS-D-ACTION             PIC X(08).
           05  WS-D-CLIID              PIC X(08).
           05  WS-D-NOM                PIC X(30).
           05  WS-D-STATUT             PIC X(20).

       01  WS-TODAY-DATE               PIC X(08).

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL TRAN-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           ACCEPT WS-TODAY-DATE FROM DATE YYYYMMDD
           OPEN INPUT  CLIENT-TRAN-FILE
           OPEN I-O    CLIENT-MASTER-FILE
           OPEN OUTPUT CLIENT-REPORT-FILE
           WRITE CLIENT-REPORT-REC FROM WS-HEADING-1
           WRITE CLIENT-REPORT-REC FROM WS-HEADING-2
           PERFORM 9100-READ-TRAN.

       2000-TRAITEMENT.
           ADD 1 TO WS-CNT-LUS
           EVALUATE CLT-CODE-ACTION
               WHEN 'A'
                   PERFORM 2100-AJOUT-CLIENT
               WHEN 'M'
                   PERFORM 2200-MODIFICATION-CLIENT
               WHEN 'S'
                   PERFORM 2300-SUPPRESSION-CLIENT
               WHEN OTHER
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE 'CODE ACTION INVALIDE' TO WS-D-STATUT
                   WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE
           END-EVALUATE
           PERFORM 9100-READ-TRAN.

       2100-AJOUT-CLIENT.
           MOVE SPACES               TO CLIENT-RECORD
           MOVE CLT-ID                TO CLI-ID
           MOVE CLT-NOM                TO CLI-NOM
           MOVE CLT-PRENOM             TO CLI-PRENOM
           MOVE CLT-RUE                TO CLI-RUE
           MOVE CLT-VILLE              TO CLI-VILLE
           MOVE CLT-CODE-POSTAL        TO CLI-CODE-POSTAL
           MOVE CLT-TELEPHONE          TO CLI-TELEPHONE
           MOVE CLT-EMAIL              TO CLI-EMAIL
           MOVE ZEROES                 TO CLI-SOLDE-COMPTE
           MOVE WS-TODAY-DATE          TO CLI-DATE-CREATION
           SET CLI-ACTIF               TO TRUE

           WRITE CLIENT-RECORD
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE 'CLIENT DEJA EXISTANT' TO WS-D-STATUT
               NOT INVALID KEY
                   ADD 1 TO WS-CNT-AJOUTS
                   MOVE 'AJOUT'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE CLT-NOM   TO WS-D-NOM
                   MOVE 'CREE'    TO WS-D-STATUT
           END-WRITE
           WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE.

       2200-MODIFICATION-CLIENT.
           MOVE CLT-ID    TO CLI-ID
           READ CLIENT-MASTER-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE 'CLIENT INTROUVABLE' TO WS-D-STATUT
                   WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   MOVE CLT-NOM            TO CLI-NOM
                   MOVE CLT-PRENOM         TO CLI-PRENOM
                   MOVE CLT-RUE            TO CLI-RUE
                   MOVE CLT-VILLE          TO CLI-VILLE
                   MOVE CLT-CODE-POSTAL    TO CLI-CODE-POSTAL
                   MOVE CLT-TELEPHONE      TO CLI-TELEPHONE
                   MOVE CLT-EMAIL          TO CLI-EMAIL
                   REWRITE CLIENT-RECORD
                   ADD 1 TO WS-CNT-MODIFS
                   MOVE 'MODIF'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE CLT-NOM   TO WS-D-NOM
                   MOVE 'MIS A JOUR' TO WS-D-STATUT
                   WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE
           END-READ.

       2300-SUPPRESSION-CLIENT.
           MOVE CLT-ID    TO CLI-ID
           READ CLIENT-MASTER-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE 'REJET'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE 'CLIENT INTROUVABLE' TO WS-D-STATUT
                   WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   SET CLI-SUPPRIME TO TRUE
                   REWRITE CLIENT-RECORD
                   ADD 1 TO WS-CNT-SUPPR
                   MOVE 'SUPPR'   TO WS-D-ACTION
                   MOVE CLT-ID    TO WS-D-CLIID
                   MOVE CLI-NOM   TO WS-D-NOM
                   MOVE 'DESACTIVE'  TO WS-D-STATUT
                   WRITE CLIENT-REPORT-REC FROM WS-DETAIL-LINE
           END-READ.

       3000-FINALISATION.
           MOVE SPACES TO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           STRING 'TOTAL LUS    : ' WS-CNT-LUS
               DELIMITED BY SIZE INTO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           STRING 'TOTAL AJOUTS : ' WS-CNT-AJOUTS
               DELIMITED BY SIZE INTO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           STRING 'TOTAL MODIFS : ' WS-CNT-MODIFS
               DELIMITED BY SIZE INTO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           STRING 'TOTAL SUPPR  : ' WS-CNT-SUPPR
               DELIMITED BY SIZE INTO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           STRING 'TOTAL REJETS : ' WS-CNT-REJETS
               DELIMITED BY SIZE INTO CLIENT-REPORT-REC
           WRITE CLIENT-REPORT-REC
           CLOSE CLIENT-TRAN-FILE
                 CLIENT-MASTER-FILE
                 CLIENT-REPORT-FILE.

       9100-READ-TRAN.
           READ CLIENT-TRAN-FILE INTO CLIENT-TRANSACTION
               AT END
                   MOVE 'Y' TO WS-EOF-TRAN
           END-READ.
