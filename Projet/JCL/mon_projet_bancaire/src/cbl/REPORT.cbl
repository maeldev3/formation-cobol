       IDENTIFICATION DIVISION.
       PROGRAM-ID. REPORT.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TOTAL-FILE
               ASSIGN TO TOTAL
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FS-TOT.
       DATA DIVISION.
       FILE SECTION.
       FD TOTAL-FILE
           RECORDING MODE F
           LABEL RECORDS STANDARD.
       01 TOTAL-RECORD.
           05 TOTAL-AMOUNT   PIC 9(12)V99.
       WORKING-STORAGE SECTION.
       01 WS-FS-TOT          PIC X(02) VALUE '00'.
       01 WS-TOTAL           PIC 9(12)V99 VALUE 0.
       01 WS-EOF             PIC X VALUE 'N'.
           88 WS-END-OF-FILE VALUE 'Y'.
       PROCEDURE DIVISION.
       MAIN.
           PERFORM INITIALIZE
           PERFORM OPEN-FILE
           IF WS-FS-TOT = '00'
               PERFORM READ-TOTAL
               IF WS-FS-TOT = '00'
                   PERFORM PRINT-REPORT
                   PERFORM CLOSE-FILE
                   MOVE 0 TO RETURN-CODE
               ELSE
                   MOVE 4 TO RETURN-CODE
               END-IF
           ELSE
               MOVE 4 TO RETURN-CODE
           END-IF
           GOBACK.
       INITIALIZE.
           MOVE 'N' TO WS-EOF
           MOVE 0 TO WS-TOTAL.
       OPEN-FILE.
           OPEN INPUT TOTAL-FILE.
       READ-TOTAL.
           READ TOTAL-FILE
               AT END DISPLAY 'FICHIER TOTAL VIDE'
               NOT AT END MOVE TOTAL-AMOUNT TO WS-TOTAL
           END-READ.
       PRINT-REPORT.
           DISPLAY '*************************************'
           DISPLAY '*      RAPPORT BANCAIRE             *'
           DISPLAY '*************************************'
           DISPLAY 'DATE : ' FUNCTION CURRENT-DATE(1:10)
           DISPLAY 'TOTAL DES SOLDES : '
           DISPLAY WS-TOTAL.
       CLOSE-FILE.
           CLOSE TOTAL-FILE.
