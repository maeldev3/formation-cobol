       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-MAIN.
       AUTHOR. SENIOR-DEV.
       INSTALLATION. ATM-BANKING-SYSTEM.
       DATE-WRITTEN. 2024.
       DATE-COMPILED. TODAY.
       SECURITY. CONFIDENTIAL.
       
      *>==============================================================*
      *> PROGRAM:    ATM-MAIN
      *> PURPOSE:    Système ATM Bancaire Complet
      *> AUTHOR:     Senior COBOL Developer
      *> VERSION:    2.0
      *>==============================================================*
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-390.
       OBJECT-COMPUTER. IBM-390.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE ASSIGN TO "data/customers.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CUST-CARD-NUM
               FILE STATUS IS WS-FILE-STATUS.
           
           COPY 'fileio.cpy' REPLACING ==:FILE-SELECT:==
               BY ==SELECT TRANSACTION-FILE==.
       
       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE.
       01  CUSTOMER-RECORD.
           05 CUST-CARD-NUM         PIC X(19).
           05 CUST-PIN              PIC X(04).
           05 CUST-BALANCE          PIC S9(12)V99.
           05 CUST-NAME             PIC X(30).
           05 CUST-STATUS           PIC X(01).
           05 CUST-LAST-LOGIN       PIC X(26).
           05 CUST-FAILED-ATTEMPTS  PIC 9(02).
       
       COPY 'fileio.cpy' REPLACING ==:FILE-FD:==
           BY ==FD TRANSACTION-FILE==.
       
       WORKING-STORAGE SECTION.
      *> Inclusion des copybooks
       COPY 'atmvars.cpy'.
       COPY 'screens.cpy'.
       
      *> Variables locales supplémentaires
       01  WS-CURRENT-CUSTOMER.
           05 WS-CUST-CARD          PIC X(19).
           05 WS-CUST-PIN           PIC X(04).
           05 WS-CUST-NAME          PIC X(30).
           05 WS-CUST-BAL           PIC S9(12)V99.
           05 WS-CUST-STATUS        PIC X(01).
           05 WS-CUST-LAST-LOGIN    PIC X(26).
           05 WS-CUST-ATTEMPTS      PIC 9(02).
       
       01  WS-OPERATION-COUNTER.
           05 WS-LOGIN-ATTEMPTS     PIC 9(02) VALUE 0.
           05 WS-TRN-COUNTER        PIC 9(04) VALUE 0.
       
       01  WS-TEMP-DATA.
           05 CARD-INPUT            PIC X(19).
           05 PIN-INPUT             PIC X(04).
           05 MENU-CHOICE           PIC 9(01).
           05 TRANS-AMOUNT          PIC S9(12)V99.
           05 CONFIRM-RESPONSE      PIC X(01).
           05 OPERATION-TYPE        PIC X(10).
           05 CONFIRM-MESSAGE       PIC X(60).
           05 DISPLAY-NAME          PIC X(30).
           05 DISPLAY-BALANCE       PIC ZZZ,ZZZ,ZZ9.99.
           
      *> Écran mini-relevé
           05 STMT-DATE             PIC X(10).
           05 STMT-TIME             PIC X(08).
           05 STMT-NAME             PIC X(30).
           05 STMT-CARD             PIC X(19).
           05 STMT-STATUS           PIC X(10).
           05 STMT-BALANCE          PIC ZZZ,ZZZ,ZZ9.99.
           05 STMT-LINE-1           PIC X(60).
           05 STMT-LINE-2           PIC X(60).
           05 STMT-LINE-3           PIC X(60).
           05 STMT-LINE-4           PIC X(60).
           05 STMT-LINE-5           PIC X(60).
           
      *> Messages d'erreur
           05 ERROR-MESSAGE         PIC X(60).
           05 ERROR-CODE            PIC 9(04).
       
       PROCEDURE DIVISION.
       
      *>==============================================================*
      *> SECTION PRINCIPALE - CONTROLE DU PROGRAMME
      *>==============================================================*
       MAIN-CONTROL.
           PERFORM 1000-INITIALIZE-SYSTEM
           
           PERFORM UNTIL WS-PROGRAM-STATUS = '99'
               PERFORM 2000-AUTHENTICATE-USER
               
               IF WS-LOGGED-IN
                   PERFORM 3000-PROCESS-MAIN-MENU
               END-IF
           END-PERFORM
           
           PERFORM 9000-SHUTDOWN-SYSTEM
           GOBACK.
       
      *>==============================================================*
      *> 1000 - INITIALISATION DU SYSTEME
      *>==============================================================*
       1000-INITIALIZE-SYSTEM.
           MOVE '00' TO WS-PROGRAM-STATUS
           MOVE 'N' TO WS-SESSION-ACTIVE
           MOVE 0 TO WS-RETRY-COUNT
           MOVE 'ATM-TERM-001' TO WS-TERMINAL-ID
           
           PERFORM 1100-GENERATE-SESSION-ID
           PERFORM 1200-LOAD-SYSTEM-CONFIG
           
           DISPLAY '========================================='
           DISPLAY '   ATM BANKING SYSTEM v2.0'
           DISPLAY '   Initialisation complete'
           DISPLAY '========================================='.
       
       1100-GENERATE-SESSION-ID.
           ACCEPT WS-SESSION-ID FROM TIME
           STRING 
               'SESS-' DELIMITED BY SIZE
               WS-SESSION-ID(1:8) DELIMITED BY SIZE
               '-' DELIMITED BY SIZE
               WS-TERMINAL-ID(5:4) DELIMITED BY SIZE
           INTO WS-SESSION-ID.
       
       1200-LOAD-SYSTEM-CONFIG.
      *> Charger configuration système
           EXIT PARAGRAPH.
       
      *>==============================================================*
      *> 2000 - AUTHENTIFICATION UTILISATEUR
      *>==============================================================*
       2000-AUTHENTICATE-USER.
           PERFORM 2100-DISPLAY-WELCOME
           PERFORM 2200-VALIDATE-CREDENTIALS
           
           IF NOT WS-LOGGED-IN
               ADD 1 TO WS-LOGIN-ATTEMPTS
               IF WS-LOGIN-ATTEMPTS >= 3
                   MOVE '99' TO WS-PROGRAM-STATUS
                   MOVE 'Maximum login attempts exceeded'
                     TO WS-MSG-TEXT
                   PERFORM 8000-DISPLAY-ERROR
               ELSE
                   MOVE 'Invalid card or PIN. Please try again.'
                     TO WS-MSG-TEXT
                   PERFORM 8000-DISPLAY-ERROR
               END-END
           ELSE
               PERFORM 2300-UPDATE-LAST-LOGIN
           END-IF.
       
       2100-DISPLAY-WELCOME.
           MOVE SPACES TO CARD-INPUT PIN-INPUT
           DISPLAY SCREEN-WELCOME
           ACCEPT SCREEN-WELCOME.
       
       2200-VALIDATE-CREDENTIALS.
           MOVE 'N' TO WS-SESSION-ACTIVE
           
           OPEN I-O CUSTOMER-FILE
           IF WS-FILE-STATUS NOT = '00'
               MOVE 'System error - Cannot access customer data'
                 TO WS-MSG-TEXT
               PERFORM 8000-DISPLAY-ERROR
               EXIT PARAGRAPH
           END-IF
           
           MOVE CARD-INPUT TO CUST-CARD-NUM
           READ CUSTOMER-FILE
               INVALID KEY
                   MOVE 'N' TO WS-SESSION-ACTIVE
               NOT INVALID KEY
                   IF CUST-PIN = PIN-INPUT 
                      AND CUST-STATUS = 'A'
                      MOVE 'Y' TO WS-SESSION-ACTIVE
                      MOVE CUST-CARD-NUM TO WS-CUST-CARD
                      MOVE CUST-NAME TO WS-CUST-NAME
                      MOVE CUST-BALANCE TO WS-CUST-BAL
                      MOVE 0 TO CUST-FAILED-ATTEMPTS
                      REWRITE CUSTOMER-RECORD
                   ELSE
                      ADD 1 TO CUST-FAILED-ATTEMPTS
                      IF CUST-FAILED-ATTEMPTS >= 3
                          MOVE 'B' TO CUST-STATUS
                      END-IF
                      REWRITE CUSTOMER-RECORD
                   END-IF
           END-READ
           
           CLOSE CUSTOMER-FILE.
       
       2300-UPDATE-LAST-LOGIN.
           OPEN I-O CUSTOMER-FILE
           MOVE WS-CUST-CARD TO CUST-CARD-NUM
           READ CUSTOMER-FILE
           PERFORM GET-TIMESTAMP
           MOVE WS-CURRENT-TIMESTAMP TO CUST-LAST-LOGIN
           REWRITE CUSTOMER-RECORD
           CLOSE CUSTOMER-FILE.
       
      *>==============================================================*
      *> 3000 - MENU PRINCIPAL
      *>==============================================================*
       3000-PROCESS-MAIN-MENU.
           PERFORM UNTIL WS-PROGRAM-STATUS = '99' 
                     OR NOT WS-LOGGED-IN
               PERFORM 3100-DISPLAY-MENU
               PERFORM 3200-HANDLE-MENU-CHOICE
           END-PERFORM.
       
       3100-DISPLAY-MENU.
           MOVE WS-CUST-NAME TO DISPLAY-NAME
           MOVE WS-CUST-BAL TO DISPLAY-BALANCE
           MOVE SPACES TO MENU-CHOICE
           DISPLAY SCREEN-MAIN-MENU
           ACCEPT SCREEN-MAIN-MENU.
       
       3200-HANDLE-MENU-CHOICE.
           EVALUATE MENU-CHOICE
               WHEN 1
                   PERFORM 4000-PROCESS-WITHDRAWAL
               WHEN 2
                   PERFORM 5000-PROCESS-DEPOSIT
               WHEN 3
                   PERFORM 6000-CHECK-BALANCE
               WHEN 4
                   PERFORM 7000-MINI-STATEMENT
               WHEN 5
                   PERFORM 7100-CHANGE-PIN
               WHEN 6
                   PERFORM 7200-TRANSFER-FUNDS
               WHEN 7
                   PERFORM 7300-FULL-HISTORY
               WHEN 8
                   MOVE '99' TO WS-PROGRAM-STATUS
                   MOVE 'N' TO WS-SESSION-ACTIVE
               WHEN OTHER
                   MOVE 'Invalid choice. Please try again.'
                     TO WS-MSG-TEXT
                   PERFORM 8000-DISPLAY-ERROR
           END-EVALUATE.
       
      *>==============================================================*
      *> 4000 - TRAITEMENT RETRAIT
      *>==============================================================*
       4000-PROCESS-WITHDRAWAL.
           MOVE 'RETIRER' TO OPERATION-TYPE
           PERFORM 4100-GET-AMOUNT
           
           IF WS-AMOUNT-VALID
               IF WS-TRANS-AMOUNT <= WS-CUST-BAL
                   PERFORM 4200-CONFIRM-TRANSACTION
                   IF CONFIRM-RESPONSE = 'O' OR 'o'
                       SUBTRACT WS-TRANS-AMOUNT 
                         FROM WS-CUST-BAL
                       PERFORM 4300-SAVE-TRANSACTION
                       PERFORM 4400-UPDATE-CUSTOMER-FILE
                       MOVE 'Withdrawal successful!' 
                         TO WS-MSG-TEXT
                       PERFORM 8000-DISPLAY-MESSAGE
                   END-IF
               ELSE
                   MOVE 'Insufficient balance!' 
                     TO WS-MSG-TEXT
                   PERFORM 8000-DISPLAY-ERROR
               END-IF
           END-IF.
       
       4100-GET-AMOUNT.
           MOVE 0 TO WS-TRANS-AMOUNT
           MOVE 'N' TO WS-VALID-AMOUNT
           DISPLAY SCREEN-AMOUNT
           ACCEPT SCREEN-AMOUNT
           
           IF WS-TRANS-AMOUNT > 0 AND 
              WS-TRANS-AMOUNT <= 1000000
               MOVE 'Y' TO WS-VALID-AMOUNT
           ELSE
               MOVE 'Invalid amount (1 - 1,000,000)' 
                 TO WS-MSG-TEXT
               PERFORM 8000-DISPLAY-ERROR
           END-IF.
       
       4200-CONFIRM-TRANSACTION.
           MOVE 'Confirm withdrawal of $' TO CONFIRM-MESSAGE
           STRING CONFIRM-MESSAGE DELIMITED BY SIZE
                  WS-TRANS-AMOUNT DELIMITED BY SIZE
                  '?' DELIMITED BY SIZE
             INTO CONFIRM-MESSAGE
           END-STRING
           MOVE SPACES TO CONFIRM-RESPONSE
           DISPLAY SCREEN-CONFIRMATION
           ACCEPT SCREEN-CONFIRMATION.
       
       4300-SAVE-TRANSACTION.
           CALL 'TRANSACTION-MANAGER' 
             USING WS-CUST-CARD
                   'WD'
                   WS-TRANS-AMOUNT
                   WS-CUST-BAL
                   WS-SESSION-ID
                   WS-TRANS-REF-NUM
                   ERROR-CODE.
       
       4400-UPDATE-CUSTOMER-FILE.
           OPEN I-O CUSTOMER-FILE
           MOVE WS-CUST-CARD TO CUST-CARD-NUM
           READ CUSTOMER-FILE
           MOVE WS-CUST-BAL TO CUST-BALANCE
           REWRITE CUSTOMER-RECORD
           CLOSE CUSTOMER-FILE.
       
      *>==============================================================*
      *> 5000 - TRAITEMENT DEPOT
      *>==============================================================*
       5000-PROCESS-DEPOSIT.
           MOVE 'DEPOSER' TO OPERATION-TYPE
           PERFORM 4100-GET-AMOUNT
           
           IF WS-AMOUNT-VALID
               PERFORM 4200-CONFIRM-TRANSACTION
               IF CONFIRM-RESPONSE = 'O' OR 'o'
                   ADD WS-TRANS-AMOUNT TO WS-CUST-BAL
                   PERFORM 4300-SAVE-TRANSACTION
                   PERFORM 4400-UPDATE-CUSTOMER-FILE
                   MOVE 'Deposit successful!'
                     TO WS-MSG-TEXT
                   PERFORM 8000-DISPLAY-MESSAGE
               END-IF
           END-IF.
       
      *>==============================================================*
      *> 6000 - CONSULTATION SOLDE
      *>==============================================================*
       6000-CHECK-BALANCE.
           MOVE 'YOUR CURRENT BALANCE: $' TO WS-MSG-TEXT
           STRING WS-MSG-TEXT DELIMITED BY SIZE
                  WS-CUST-BAL DELIMITED BY SIZE
             INTO WS-MSG-TEXT
           END-STRING
           PERFORM 8000-DISPLAY-MESSAGE.
       
      *>==============================================================*
      *> 7000 - MINI RELEVE
      *>==============================================================*
       7000-MINI-STATEMENT.
           PERFORM GET-TIMESTAMP
           MOVE WS-CURRENT-DATE TO STMT-DATE
           MOVE WS-CURRENT-TIME TO STMT-TIME
           MOVE WS-CUST-NAME TO STMT-NAME
           MOVE WS-CUST-CARD TO STMT-CARD
           MOVE WS-CUST-BAL TO STMT-BALANCE
           
           MOVE 'ACTIVE' TO STMT-STATUS
           
           PERFORM 7010-GET-LAST-TRANSACTIONS
           
           DISPLAY SCREEN-MINI-STATEMENT
           ACCEPT SCREEN-MINI-STATEMENT.
       
       7010-GET-LAST-TRANSACTIONS.
      *> Simulation des dernières transactions
           MOVE '1. 2024-01-15 10:30:00  WITHDRAWAL    $500.00'
             TO STMT-LINE-1
           MOVE '2. 2024-01-10 14:20:00  DEPOSIT       $1000.00'
             TO STMT-LINE-2
           MOVE '3. 2024-01-05 09:15:00  WITHDRAWAL    $200.00'
             TO STMT-LINE-3
           MOVE '4. 2024-01-01 16:45:00  DEPOSIT       $500.00'
             TO STMT-LINE-4
           MOVE '5. 2023-12-28 11:00:00  BALANCE CHECK $0.00'
             TO STMT-LINE-5.
       
      *>==============================================================*
      *> 7100 - CHANGEMENT DE PIN
      *>==============================================================*
       7100-CHANGE-PIN.
           MOVE 'CHANGEMENT PIN' TO OPERATION-TYPE.
      *> Implémentation du changement de PIN
       
      *>==============================================================*
      *> 7200 - TRANSFERT DE FONDS
      *>==============================================================*
       7200-TRANSFER-FUNDS.
           MOVE 'TRANSFERT' TO OPERATION-TYPE.
      *> Implémentation du transfert de fonds
       
      *>==============================================================*
      *> 7300 - HISTORIQUE COMPLET
      *>==============================================================*
       7300-FULL-HISTORY.
           MOVE 'HISTORIQUE' TO OPERATION-TYPE.
      *> Implémentation de l'historique complet
       
      *>==============================================================*
      *> 8000 - GESTION DES MESSAGES ET ERREURS
      *>==============================================================*
       8000-DISPLAY-MESSAGE.
           DISPLAY SCREEN-ERROR
           ACCEPT SCREEN-ERROR.
       
       8000-DISPLAY-ERROR.
           MOVE WS-MSG-TEXT TO ERROR-MESSAGE
           MOVE 1001 TO ERROR-CODE
           DISPLAY SCREEN-ERROR
           ACCEPT SCREEN-ERROR.
       
      *>==============================================================*
      *> 9000 - ARRET DU SYSTEME
      *>==============================================================*
       9000-SHUTDOWN-SYSTEM.
           DISPLAY '========================================='
           DISPLAY '   ATM BANKING SYSTEM SHUTDOWN'
           DISPLAY '   Thank you for using our service'
           DISPLAY '========================================='.
       
      *>==============================================================*
      *> FONCTIONS UTILITAIRES
      *>==============================================================*
       GET-TIMESTAMP.
           ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
           ACCEPT WS-CURRENT-TIME FROM TIME
           STRING 
               WS-CUR-DATE-DD DELIMITED BY SIZE
               '/' DELIMITED BY SIZE
               WS-CUR-DATE-MM DELIMITED BY SIZE
               '/' DELIMITED BY SIZE
               WS-CUR-DATE-YYYY DELIMITED BY SIZE
           INTO WS-CURRENT-DATE
           STRING
               WS-CUR-TIME-HH DELIMITED BY SIZE
               ':' DELIMITED BY SIZE
               WS-CUR-TIME-MM DELIMITED BY SIZE
               ':' DELIMITED BY SIZE
               WS-CUR-TIME-SS DELIMITED BY SIZE
           INTO WS-CURRENT-TIME.
       
       END PROGRAM ATM-MAIN.
