      *>==============================================================*
      *> COPYBOOK: ATMVARS.CPY
      *> PURPOSE:  Variables globales et structures de données ATM
      *> AUTHOR:   SENIOR-DEV
      *> DATE:     2024
      *>==============================================================*
       
       01  WS-GLOBAL-FLAGS.
           05 WS-PROGRAM-STATUS        PIC X(2) VALUE '00'.
              88 WS-SUCCESS            VALUE '00'.
              88 WS-ERROR              VALUE '01'.
              88 WS-EXIT-PROGRAM       VALUE '99'.
           05 WS-SESSION-ACTIVE        PIC X(1) VALUE 'N'.
              88 WS-LOGGED-IN          VALUE 'Y'.
              88 WS-NOT-LOGGED         VALUE 'N'.
           05 WS-FILE-STATUS           PIC X(2) VALUE '00'.
           05 WS-RETRY-COUNT           PIC 9(2) VALUE 0.
           05 WS-MAX-RETRIES           PIC 9(2) VALUE 3.
       
       01  WS-CUSTOMER-MASTER.
           05 WS-CUST-CARD-NUM         PIC X(19).
           05 WS-CUST-PIN              PIC X(04).
           05 WS-CUST-BALANCE          PIC S9(12)V99.
           05 WS-CUST-NAME             PIC X(30).
           05 WS-CUST-STATUS           PIC X(01).
              88 WS-CUST-ACTIVE        VALUE 'A'.
              88 WS-CUST-BLOCKED       VALUE 'B'.
              88 WS-CUST-CLOSED        VALUE 'C'.
           05 WS-CUST-LAST-LOGIN       PIC X(26).
           05 WS-CUST-FAILED-ATTEMPTS  PIC 9(02).
       
       01  WS-TRANSACTION-DATA.
           05 WS-TRANS-TYPE            PIC X(02).
              88 WS-TRN-WITHDRAWAL     VALUE 'WD'.
              88 WS-TRN-DEPOSIT        VALUE 'DP'.
              88 WS-TRN-BALANCE        VALUE 'BL'.
              88 WS-TRN-MINI-STATEMENT VALUE 'MS'.
              88 WS-TRN-PIN-CHANGE     VALUE 'PC'.
           05 WS-TRANS-AMOUNT          PIC S9(12)V99.
           05 WS-TRANS-REF-NUM         PIC X(15).
           05 WS-TRANS-DESC            PIC X(40).
           05 WS-TRANS-TIMESTAMP       PIC X(26).
       
       01  WS-SYSTEM-INFO.
           05 WS-CURRENT-DATE.
              10 WS-CUR-DATE-YYYY      PIC 9(04).
              10 WS-CUR-DATE-MM        PIC 9(02).
              10 WS-CUR-DATE-DD        PIC 9(02).
           05 WS-CURRENT-TIME.
              10 WS-CUR-TIME-HH        PIC 9(02).
              10 WS-CUR-TIME-MM        PIC 9(02).
              10 WS-CUR-TIME-SS        PIC 9(02).
              10 WS-CUR-TIME-MS        PIC 9(02).
           05 WS-TERMINAL-ID           PIC X(10).
           05 WS-SESSION-ID            PIC X(32).
       
       01  WS-MESSAGE-AREA.
           05 WS-MSG-CODE              PIC 9(04).
           05 WS-MSG-TEXT              PIC X(80).
           05 WS-MSG-SEVERITY          PIC X(01).
              88 WS-MSG-INFO           VALUE 'I'.
              88 WS-MSG-WARNING        VALUE 'W'.
              88 WS-MSG-ERROR          VALUE 'E'.
              88 WS-MSG-FATAL          VALUE 'F'.
       
       01  WS-INPUT-VALIDATION.
           05 WS-VALID-AMOUNT          PIC X(01).
              88 WS-AMOUNT-VALID       VALUE 'Y'.
           05 WS-VALID-CARD-FORMAT     PIC X(01).
           05 WS-VALID-PIN-FORMAT      PIC X(01).
