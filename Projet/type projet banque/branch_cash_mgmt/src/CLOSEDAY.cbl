       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLOSEDAY.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-TOTAL-ENTRY        PIC 9(12)V99.
       01 WS-TOTAL-EXIT         PIC 9(12)V99.
       01 WS-COUNT-TRANS        PIC 9(6).
       01 WS-TEMP-TYPE          PIC X(01).
       01 WS-TEMP-AMOUNT        PIC 9(12)V99.
       01 WS-CONFIRM            PIC X(01).

       LINKAGE SECTION.
       01 LS-CURRENT-BAL        PIC 9(12)V99.
       01 LS-TRANS-COUNT        PIC 9(6).
       01 LS-DATE               PIC X(10).

       PROCEDURE DIVISION USING LS-CURRENT-BAL
                                LS-TRANS-COUNT
                                LS-DATE.
       
       MAIN-PROCESS.
           DISPLAY "=============================="
           DISPLAY "      CLOTURE DE JOURNEE      "
           DISPLAY "=============================="
           DISPLAY "DATE : " LS-DATE
           DISPLAY " "
           
           PERFORM ANALYZE-TRANSACTIONS
           PERFORM DISPLAY-SUMMARY
           PERFORM GENERATE-REPORT
           PERFORM RESET-CASH
           
           DISPLAY " "
           DISPLAY "CLOTURE DE JOURNEE EFFECTUEE"
           DISPLAY "RAPPORT DANS reports/daily_report.txt"
           DISPLAY " "
           DISPLAY "APPUYEZ SUR ENTREE"
           ACCEPT WS-CONFIRM
           GOBACK.

       ANALYZE-TRANSACTIONS.
           MOVE 0 TO WS-TOTAL-ENTRY
           MOVE 0 TO WS-TOTAL-EXIT
           MOVE 0 TO WS-COUNT-TRANS
           
           OPEN INPUT HIST-FILE
           IF WS-HIST-STATUS = "00"
               PERFORM UNTIL WS-HIST-STATUS NOT = "00"
                   READ HIST-FILE
                   IF WS-HIST-STATUS = "00"
                       IF HR-DATE = LS-DATE
                           ADD 1 TO WS-COUNT-TRANS
                           IF HR-TYPE = 'E'
                               COMPUTE WS-TOTAL-ENTRY = 
                                   WS-TOTAL-ENTRY + HR-AMOUNT
                           END-IF
                           IF HR-TYPE = 'S'
                               COMPUTE WS-TOTAL-EXIT = 
                                   WS-TOTAL-EXIT + HR-AMOUNT
                           END-IF
                       END-IF
                   END-IF
               END-PERFORM
               CLOSE HIST-FILE
           END-IF
           .

       DISPLAY-SUMMARY.
           DISPLAY "=== RECAPITULATIF DE LA JOURNEE ==="
           DISPLAY "TOTAL ENTREES  : " WS-TOTAL-ENTRY
           DISPLAY "TOTAL SORTIES  : " WS-TOTAL-EXIT
           DISPLAY "NB TRANSACTIONS : " WS-COUNT-TRANS
           DISPLAY "SOLDE FINAL    : " LS-CURRENT-BAL
           .

       GENERATE-REPORT.
           OPEN OUTPUT RPT-FILE
           MOVE "=== RAPPORT QUOTIDIEN ===" TO RPT-RECORD
           WRITE RPT-RECORD
           MOVE "DATE: " TO RPT-RECORD
           STRING "DATE: " LS-DATE DELIMITED BY SIZE
               INTO RPT-RECORD
           WRITE RPT-RECORD
           MOVE "TOTAL ENTREES: " TO RPT-RECORD
           STRING "TOTAL ENTREES: " WS-TOTAL-ENTRY
               DELIMITED BY SIZE INTO RPT-RECORD
           WRITE RPT-RECORD
           MOVE "TOTAL SORTIES: " TO RPT-RECORD
           STRING "TOTAL SORTIES: " WS-TOTAL-EXIT
               DELIMITED BY SIZE INTO RPT-RECORD
           WRITE RPT-RECORD
           MOVE "NB TRANSACTIONS: " TO RPT-RECORD
           STRING "NB TRANSACTIONS: " WS-COUNT-TRANS
               DELIMITED BY SIZE INTO RPT-RECORD
           WRITE RPT-RECORD
           MOVE "SOLDE CLOTURE: " TO RPT-RECORD
           STRING "SOLDE CLOTURE: " LS-CURRENT-BAL
               DELIMITED BY SIZE INTO RPT-RECORD
           WRITE RPT-RECORD
           CLOSE RPT-FILE
           .

       RESET-CASH.
           MOVE 0 TO LS-CURRENT-BAL
           MOVE 0 TO LS-TRANS-COUNT
           .

       COPY COMMON.
       
       END PROGRAM CLOSEDAY.
