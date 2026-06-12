      ******************************************************************
      * PROGRAMME  : BSTMTBAT                                          *
      * DESCRIPTION: GENERATEUR RELEVES BANCAIRES - VERSION BATCH      *
      *              DB2/COBOL BATCH                                    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BSTMTBAT.
       AUTHOR.        BANK STATEMENT GENERATOR.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT RELEVE-FILE
               ASSIGN TO RELVOUT
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.

           SELECT PARAM-FILE
               ASSIGN TO PARMIN
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-PARAM-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  RELEVE-FILE
           RECORDING MODE IS F
           BLOCK CONTAINS 0 RECORDS
           RECORD CONTAINS 133 CHARACTERS.
       01  RELEVE-RECORD         PIC X(133).

       FD  PARAM-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.
       01  PARAM-RECORD.
           05  PM-NUM-COMPTE     PIC X(26).
           05  PM-DATE-DEBUT     PIC X(10).
           05  FILLER            PIC X(1).
           05  PM-DATE-FIN       PIC X(10).
           05  FILLER            PIC X(33).

       WORKING-STORAGE SECTION.

       01  WS-FILE-STATUS        PIC X(2) VALUE SPACES.
       01  WS-PARAM-STATUS       PIC X(2) VALUE SPACES.
       01  WS-EOF-PARAM          PIC X(1) VALUE 'N'.
           88  WS-EOF-PARAM-Y              VALUE 'Y'.
       01  WS-EOF-TRANS          PIC X(1) VALUE 'N'.
           88  WS-EOF-TRANS-Y              VALUE 'Y'.

       01  WS-COUNTERS.
           05  WS-REC-IN         PIC 9(6)  VALUE ZERO.
           05  WS-REC-OUT        PIC 9(6)  VALUE ZERO.
           05  WS-TRANS-COUNT    PIC 9(4)  VALUE ZERO.
           05  WS-IDX            PIC 9(4)  VALUE ZERO.

       01  WS-HOST-VARS.
           05  HV-NUM-COMPTE     PIC X(26).
           05  HV-DATE-DEBUT     PIC X(10).
           05  HV-DATE-FIN       PIC X(10).
           05  HV-CLIENT-ID      PIC X(10).
           05  HV-NOM            PIC X(40).
           05  HV-PRENOM         PIC X(40).
           05  HV-ADRESSE        PIC X(80).
           05  HV-VILLE          PIC X(30).
           05  HV-CODE-POSTAL    PIC X(5).
           05  HV-DATE-OUVERTURE PIC X(10).
           05  HV-STATUT         PIC X(1).
           05  HV-TRANS-ID       PIC X(12).
           05  HV-DATE-TRANS     PIC X(10).
           05  HV-HEURE-TRANS    PIC X(8).
           05  HV-TYPE-TRANS     PIC X(3).
           05  HV-MONTANT        PIC S9(13)V99 COMP-3.
           05  HV-SOLDE-APRES    PIC S9(13)V99 COMP-3.
           05  HV-LIBELLE        PIC X(50).

       01  WS-TRANS-TABLE.
           05  WS-TRANS-ENTRY    OCCURS 100 TIMES
                                 INDEXED BY WS-T-IDX.
               10  WT-DATE       PIC X(10).
               10  WT-HEURE      PIC X(8).
               10  WT-TYPE       PIC X(3).
               10  WT-MONTANT    PIC S9(13)V99 COMP-3.
               10  WT-SOLDE      PIC S9(13)V99 COMP-3.
               10  WT-LIBELLE    PIC X(50).

       01  WS-SOLDES.
           05  WS-SOLDE-INITIAL  PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-SOLDE-FINAL    PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-TOTAL-CREDIT   PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-TOTAL-DEBIT    PIC S9(13)V99 COMP-3 VALUE ZERO.

       01  WS-PRINT-LINE         PIC X(133).
       01  WS-MONTANT-DISP       PIC Z(11)9.99-.
       01  WS-SOLDE-DISP         PIC Z(11)9.99-.
       01  WS-CREDIT-DISP        PIC Z(11)9.99-.
       01  WS-DEBIT-DISP         PIC Z(11)9.99-.

       01  WS-LINE-SEP           PIC X(133)
           VALUE ALL '='.

           EXEC SQL INCLUDE SQLCA END-EXEC.

           EXEC SQL DECLARE CUR-TRANS-BATCH CURSOR FOR
               SELECT  TRANS_ID,
                       CHAR(DATE_TRANS,ISO),
                       CHAR(HEURE_TRANS,ISO),
                       TYPE_TRANS,
                       MONTANT,
                       SOLDE_APRES,
                       LIBELLE
               FROM    BANKDB.TRANSACTIONS
               WHERE   NUM_COMPTE   = :HV-NUM-COMPTE
               AND     DATE_TRANS  BETWEEN
                       DATE(:HV-DATE-DEBUT) AND DATE(:HV-DATE-FIN)
               AND     STATUT_TRANS = 'V'
               ORDER BY DATE_TRANS, HEURE_TRANS
           END-EXEC.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************

       0000-MAIN.
           PERFORM 1000-OPEN-FILES
           PERFORM 2000-PROCESS-PARAMS
               UNTIL WS-EOF-PARAM-Y
           PERFORM 9000-CLOSE-FILES
           STOP RUN.

       1000-OPEN-FILES.
           OPEN INPUT  PARAM-FILE
           OPEN OUTPUT RELEVE-FILE
           READ PARAM-FILE
               AT END MOVE 'Y' TO WS-EOF-PARAM.

       2000-PROCESS-PARAMS.
           ADD 1 TO WS-REC-IN
           MOVE PM-NUM-COMPTE TO HV-NUM-COMPTE
           MOVE PM-DATE-DEBUT TO HV-DATE-DEBUT
           MOVE PM-DATE-FIN   TO HV-DATE-FIN
           INITIALIZE WS-SOLDES
           MOVE ZERO          TO WS-TRANS-COUNT
           PERFORM 2100-GET-CLIENT
           PERFORM 2200-LOAD-TRANS
           PERFORM 2300-CALC-SOLDES
           PERFORM 2400-WRITE-RELEVE
           READ PARAM-FILE
               AT END MOVE 'Y' TO WS-EOF-PARAM.

       2100-GET-CLIENT.
           EXEC SQL
               SELECT  CLIENT_ID, NOM, PRENOM, ADRESSE,
                       VILLE, CODE_POSTAL, CHAR(DATE_OUVERTURE,ISO)
               INTO    :HV-CLIENT-ID, :HV-NOM, :HV-PRENOM,
                       :HV-ADRESSE, :HV-VILLE, :HV-CODE-POSTAL,
                       :HV-DATE-OUVERTURE
               FROM    BANKDB.CLIENTS
               WHERE   NUM_COMPTE = :HV-NUM-COMPTE
           END-EXEC.

       2200-LOAD-TRANS.
           EXEC SQL OPEN CUR-TRANS-BATCH END-EXEC
           MOVE 'N' TO WS-EOF-TRANS
           PERFORM UNTIL WS-EOF-TRANS-Y
               EXEC SQL FETCH CUR-TRANS-BATCH
                   INTO :HV-TRANS-ID, :HV-DATE-TRANS,
                        :HV-HEURE-TRANS, :HV-TYPE-TRANS,
                        :HV-MONTANT, :HV-SOLDE-APRES, :HV-LIBELLE
               END-EXEC
               IF SQLCODE = 0
                   ADD 1 TO WS-TRANS-COUNT
                   SET WS-T-IDX TO WS-TRANS-COUNT
                   MOVE HV-DATE-TRANS  TO WT-DATE(WS-T-IDX)
                   MOVE HV-HEURE-TRANS TO WT-HEURE(WS-T-IDX)
                   MOVE HV-TYPE-TRANS  TO WT-TYPE(WS-T-IDX)
                   MOVE HV-MONTANT     TO WT-MONTANT(WS-T-IDX)
                   MOVE HV-SOLDE-APRES TO WT-SOLDE(WS-T-IDX)
                   MOVE HV-LIBELLE     TO WT-LIBELLE(WS-T-IDX)
               ELSE
                   MOVE 'Y' TO WS-EOF-TRANS
               END-IF
           END-PERFORM
           EXEC SQL CLOSE CUR-TRANS-BATCH END-EXEC.

       2300-CALC-SOLDES.
           IF WS-TRANS-COUNT > 0
               SET WS-T-IDX TO 1
               MOVE WT-SOLDE(WS-T-IDX)   TO WS-SOLDE-INITIAL
               SUBTRACT WT-MONTANT(WS-T-IDX)
                   FROM WS-SOLDE-INITIAL
               SET WS-T-IDX TO WS-TRANS-COUNT
               MOVE WT-SOLDE(WS-T-IDX)   TO WS-SOLDE-FINAL
           END-IF
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-TRANS-COUNT
               SET WS-T-IDX TO WS-IDX
               EVALUATE WT-TYPE(WS-T-IDX)
                   WHEN 'CRE' WHEN 'DEP' WHEN 'VIR'
                       ADD WT-MONTANT(WS-T-IDX) TO WS-TOTAL-CREDIT
                   WHEN OTHER
                       ADD WT-MONTANT(WS-T-IDX) TO WS-TOTAL-DEBIT
               END-EVALUATE
           END-PERFORM.

       2400-WRITE-RELEVE.
           PERFORM 2410-WRITE-HEADER
           PERFORM 2420-WRITE-DETAIL
           PERFORM 2430-WRITE-FOOTER.

       2410-WRITE-HEADER.
           MOVE WS-LINE-SEP     TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           STRING 'RELEVE BANCAIRE - COMPTE: ' HV-NUM-COMPTE
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           STRING 'CLIENT: '
                  FUNCTION TRIM(HV-PRENOM) ' '
                  FUNCTION TRIM(HV-NOM)
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           STRING 'PERIODE: ' HV-DATE-DEBUT ' AU ' HV-DATE-FIN
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE WS-LINE-SEP     TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE WS-SOLDE-INITIAL TO WS-SOLDE-DISP
           STRING 'SOLDE INITIAL                           '
                  WS-SOLDE-DISP
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE WS-LINE-SEP     TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE.

       2420-WRITE-DETAIL.
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-TRANS-COUNT
               SET WS-T-IDX TO WS-IDX
               MOVE WT-MONTANT(WS-T-IDX) TO WS-MONTANT-DISP
               MOVE WT-SOLDE(WS-T-IDX)   TO WS-SOLDE-DISP
               STRING WT-DATE(WS-T-IDX)   ' '
                      WT-HEURE(WS-T-IDX)(1:5) ' '
                      WT-TYPE(WS-T-IDX)   ' '
                      WT-LIBELLE(WS-T-IDX)(1:40) ' '
                      WS-MONTANT-DISP     ' '
                      WS-SOLDE-DISP
                      DELIMITED SIZE INTO WS-PRINT-LINE
               WRITE RELEVE-RECORD FROM WS-PRINT-LINE
               ADD 1 TO WS-REC-OUT
           END-PERFORM.

       2430-WRITE-FOOTER.
           MOVE WS-LINE-SEP     TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE WS-TOTAL-CREDIT TO WS-CREDIT-DISP
           MOVE WS-TOTAL-DEBIT  TO WS-DEBIT-DISP
           MOVE WS-SOLDE-FINAL  TO WS-SOLDE-DISP
           STRING 'TOTAL CREDITS : ' WS-CREDIT-DISP
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           STRING 'TOTAL DEBITS  : ' WS-DEBIT-DISP
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           STRING 'SOLDE FINAL   : ' WS-SOLDE-DISP
                  DELIMITED SIZE INTO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE WS-LINE-SEP     TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE
           MOVE SPACES          TO WS-PRINT-LINE
           WRITE RELEVE-RECORD  FROM WS-PRINT-LINE.

       9000-CLOSE-FILES.
           CLOSE PARAM-FILE
           CLOSE RELEVE-FILE.
