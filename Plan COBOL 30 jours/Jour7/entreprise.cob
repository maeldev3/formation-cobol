       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKSYS.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-CHOICE     PIC 9.
       01 WS-I          PIC 9.
       01 WS-ID         PIC 9.

       01 WS-AMOUNT     PIC 9(7)V99.

       01 WS-ACC-NAME OCCURS 3 TIMES PIC X(20).
       01 WS-ACC-BAL  OCCURS 3 TIMES PIC 9(7)V99.

       PROCEDURE DIVISION.

       000-MAIN.

           PERFORM 100-INIT

           PERFORM UNTIL WS-CHOICE = 4
               PERFORM 200-MENU
               EVALUATE WS-CHOICE
                   WHEN 1
                       PERFORM 300-INIT-DATA
                   WHEN 2
                       PERFORM 400-DEPOSIT
                   WHEN 3
                       PERFORM 500-WITHDRAW
                   WHEN 4
                       DISPLAY "EXIT SYSTEM"
                   WHEN OTHER
                       DISPLAY "INVALID CHOICE"
               END-EVALUATE
           END-PERFORM

           STOP RUN.

       100-INIT.

           MOVE "ISMAEL" TO WS-ACC-NAME(1)
           MOVE "JOHN"   TO WS-ACC-NAME(2)
           MOVE "PAUL"   TO WS-ACC-NAME(3)

           MOVE 100000 TO WS-ACC-BAL(1)
           MOVE 200000 TO WS-ACC-BAL(2)
           MOVE 150000 TO WS-ACC-BAL(3).

       200-MENU.

           DISPLAY "======================"
           DISPLAY "1 SHOW ACCOUNTS"
           DISPLAY "2 DEPOSIT"
           DISPLAY "3 WITHDRAW"
           DISPLAY "4 EXIT"
           DISPLAY "CHOICE : "
           ACCEPT WS-CHOICE.

       300-INIT-DATA.

           PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
               DISPLAY "ACCOUNT " WS-I
               DISPLAY "NAME   : " WS-ACC-NAME(WS-I)
               DISPLAY "BALANCE: " WS-ACC-BAL(WS-I)
           END-PERFORM.

       400-DEPOSIT.

           DISPLAY "ACCOUNT ID (1-3) : "
           ACCEPT WS-ID

           DISPLAY "AMOUNT : "
           ACCEPT WS-AMOUNT

           IF WS-ID >= 1 AND WS-ID <= 3
               ADD WS-AMOUNT TO WS-ACC-BAL(WS-ID)
               DISPLAY "DEPOSIT OK"
           ELSE
               DISPLAY "INVALID ACCOUNT"
           END-IF.

       500-WITHDRAW.

           DISPLAY "ACCOUNT ID (1-3) : "
           ACCEPT WS-ID

           DISPLAY "AMOUNT : "
           ACCEPT WS-AMOUNT

           IF WS-ID >= 1 AND WS-ID <= 3
               IF WS-AMOUNT <= WS-ACC-BAL(WS-ID)
                   SUBTRACT WS-AMOUNT FROM WS-ACC-BAL(WS-ID)
                   DISPLAY "WITHDRAW OK"
               ELSE
                   DISPLAY "INSUFFICIENT BALANCE"
               END-IF
           ELSE
               DISPLAY "INVALID ACCOUNT"
           END-IF.