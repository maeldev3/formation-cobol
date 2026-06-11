       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS        PIC X(02).
       01 WS-HIST-STATUS        PIC X(02).
       01 WS-CONFIRM            PIC X(01).
       01 WS-DATE               PIC X(10).
       01 WS-TIME               PIC X(08).
       01 WS-AMOUNT             PIC 9(12)V99.
       01 WS-IDX                PIC 9(2).
       01 WS-BILL-COUNT         PIC 9(6) OCCURS 8.
       01 WS-BILL-VALUES.
           05 WS-VAL-500        PIC 9(4) VALUE 500.
           05 WS-VAL-200        PIC 9(4) VALUE 200.
           05 WS-VAL-100        PIC 9(4) VALUE 100.
           05 WS-VAL-50         PIC 9(4) VALUE 50.
           05 WS-VAL-20         PIC 9(4) VALUE 20.
           05 WS-VAL-10         PIC 9(4) VALUE 10.
           05 WS-VAL-5          PIC 9(4) VALUE 5.
           05 WS-VAL-1          PIC 9(4) VALUE 1.
       01 WS-TOTAL-PHYSIQUE     PIC 9(12)V99.
       01 WS-DIFF               PIC S9(12)V99.
       01 WS-TOTAL-ENTRY        PIC 9(12)V99.
       01 WS-TOTAL-EXIT         PIC 9(12)V99.
       01 WS-COUNT-TRANS        PIC 9(6).
       01 WS-TEMP-AMOUNT        PIC 9(12)V99.
       01 WS-TEMP-TYPE          PIC X(01).
