       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANSACTION-MANAGER.
       AUTHOR. SENIOR-DEV.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANSACTION-FILE ASSIGN TO "data/transactions.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS TRN-REF-NUM.
       
       DATA DIVISION.
       FILE SECTION.
       FD  TRANSACTION-FILE.
       01  TRANSACTION-RECORD.
           05 TRN-REF-NUM          PIC X(15).
           05 TRN-CARD-NUM         PIC X(19).
           05 TRN-TYPE             PIC X(02).
           05 TRN-AMOUNT           PIC S9(12)V99.
           05 TRN-BALANCE-AFTER    PIC S9(12)V99.
           05 TRN-TIMESTAMP        PIC X(26).
           05 TRN-DESCRIPTION      PIC X(40).
           05 TRN-TERMINAL-ID      PIC X(10).
           05 TRN-SESSION-ID       PIC X(32).
       
       WORKING-STORAGE SECTION.
       01  WS-TRANSACTION-INFO.
           05 WS-TRN-REF-NUM       PIC X(15).
           05 WS-TRN-CARD-NUM      PIC X(19).
           05 WS-TRN-TYPE          PIC X(02).
           05 WS-TRN-AMOUNT        PIC S9(12)V99.
           05 WS-TRN-BALANCE       PIC S9(12)V99.
           05 WS-TRN-DESC          PIC X(40).
           05 WS-TRN-TERMINAL      PIC X(10).
           05 WS-TRN-SESSION       PIC X(32).
       
       01  WS-COUNTERS.
           05 WS-LAST-5-COUNT      PIC 9(02).
           05 WS-TRN-COUNT         PIC 9(04).
       
       01  WS-TEMP-TABLE.
           05 WS-TRANSACTIONS OCCURS 5.
               10 WS-TRN-DATE      PIC X(26).
               10 WS-TRN-AMT       PIC ZZZ,ZZZ,ZZ9.99.
               10 WS-TRN-DESC-TXT  PIC X(40).
       
       LINKAGE SECTION.
       01  LS-CARD-NUMBER          PIC X(19).
       01  LS-TRANSACTION-TYPE     PIC X(02).
       01  LS-AMOUNT               PIC S9(12)V99.
       01  LS-BALANCE-AFTER        PIC S9(12)V99.
       01  LS-SESSION-ID           PIC X(32).
       01  LS-TRANSACTION-REF      PIC X(15).
       01  LS-ERROR-CODE           PIC 9(04).
       
       PROCEDURE DIVISION USING LS-CARD-NUMBER 
                               LS-TRANSACTION-TYPE 
                               LS-AMOUNT 
                               LS-BALANCE-AFTER 
                               LS-SESSION-ID 
                               LS-TRANSACTION-REF
                               LS-ERROR-CODE.
       
       MAIN-PROCESS.
           MOVE 0 TO LS-ERROR-CODE
           
           PERFORM GENERATE-REFERENCE
           PERFORM GET-TIMESTAMP
           PERFORM WRITE-TRANSACTION
           
           GOBACK.
       
       GENERATE-REFERENCE.
           ACCEPT WS-TRN-REF-NUM FROM TIME
           STRING 
               'TRN' DELIMITED BY SIZE
               WS-TRN-REF-NUM(1:8) DELIMITED BY SIZE
               LS-CARD-NUMBER(1:4) DELIMITED BY SIZE
           INTO WS-TRN-REF-NUM
           END-STRING
           MOVE WS-TRN-REF-NUM TO LS-TRANSACTION-REF.
       
       GET-TIMESTAMP.
           ACCEPT WS-TRN-REF-NUM FROM DATE YYYYMMDDHHMMSS.
       
       WRITE-TRANSACTION.
           OPEN I-O TRANSACTION-FILE
           IF FILE-STATUS = '35'
               OPEN OUTPUT TRANSACTION-FILE
           END-IF
           
           MOVE LS-TRANSACTION-REF TO TRN-REF-NUM
           MOVE LS-CARD-NUMBER TO TRN-CARD-NUM
           MOVE LS-TRANSACTION-TYPE TO TRN-TYPE
           MOVE LS-AMOUNT TO TRN-AMOUNT
           MOVE LS-BALANCE-AFTER TO TRN-BALANCE-AFTER
           MOVE LS-SESSION-ID TO TRN-SESSION-ID
           
           EVALUATE LS-TRANSACTION-TYPE
               WHEN 'WD'
                   MOVE 'WITHDRAWAL' TO TRN-DESCRIPTION
               WHEN 'DP'
                   MOVE 'DEPOSIT' TO TRN-DESCRIPTION
               WHEN 'PC'
                   MOVE 'PIN CHANGE' TO TRN-DESCRIPTION
               WHEN OTHER
                   MOVE 'OTHER' TO TRN-DESCRIPTION
           END-EVALUATE
           
           WRITE TRANSACTION-RECORD
               INVALID KEY
                   DISPLAY 'Error writing transaction'
                   MOVE 9999 TO LS-ERROR-CODE
           END-WRITE
           
           CLOSE TRANSACTION-FILE.
       
       END PROGRAM TRANSACTION-MANAGER.
