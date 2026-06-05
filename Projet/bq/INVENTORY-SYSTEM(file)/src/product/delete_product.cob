       IDENTIFICATION DIVISION.
       PROGRAM-ID. DELETE_PRODUCT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRODUCT-FILE ASSIGN TO "data/products.dat"
                  ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "data/temp.dat"
                  ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD PRODUCT-FILE.
       COPY "copybooks/product.cpy".

       FD TEMP-FILE.
       01 TEMP-REC.
           05 T-ID        PIC 9(6).
           05 T-NAME      PIC X(30).
           05 T-PRICE     PIC 9(6)V99.
           05 T-STOCK     PIC 9(5).
           05 T-DATE      PIC X(10).

       WORKING-STORAGE SECTION.
       01 WS-SEARCH-ID   PIC 9(6).
       01 WS-EOF         PIC X VALUE "N".
       01 WS-FOUND       PIC X VALUE "N".
       01 WS-CONFIRM     PIC X.

       PROCEDURE DIVISION.

       MAIN-PARA.

           DISPLAY "Enter Product ID to delete: "
           ACCEPT WS-SEARCH-ID

           OPEN INPUT PRODUCT-FILE
           OPEN OUTPUT TEMP-FILE

           PERFORM UNTIL WS-EOF = "Y"
               READ PRODUCT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       IF PRODUCT-ID OF PRODUCT-RECORD = WS-SEARCH-ID
                           MOVE "Y" TO WS-FOUND
                           PERFORM DISPLAY-PRODUCT
                           DISPLAY "Confirm deletion (O/N): "
                           ACCEPT WS-CONFIRM
                           IF WS-CONFIRM = "O" OR "o"
                               DISPLAY "Product deleted (skipped)"
                           ELSE
                               MOVE PRODUCT-ID   OF PRODUCT-RECORD
                                 TO T-ID
                               MOVE PRODUCT-NAME OF PRODUCT-RECORD
                                 TO T-NAME
                               MOVE PRODUCT-PRICE OF PRODUCT-RECORD
                                 TO T-PRICE
                               MOVE PRODUCT-STOCK OF PRODUCT-RECORD
                                 TO T-STOCK
                               MOVE PRODUCT-DATE OF PRODUCT-RECORD
                                 TO T-DATE
                               WRITE TEMP-REC
                           END-IF
                       ELSE
                           MOVE PRODUCT-ID   OF PRODUCT-RECORD
                             TO T-ID
                           MOVE PRODUCT-NAME OF PRODUCT-RECORD
                             TO T-NAME
                           MOVE PRODUCT-PRICE OF PRODUCT-RECORD
                             TO T-PRICE
                           MOVE PRODUCT-STOCK OF PRODUCT-RECORD
                             TO T-STOCK
                           MOVE PRODUCT-DATE OF PRODUCT-RECORD
                             TO T-DATE
                           WRITE TEMP-REC
                       END-IF
               END-READ
           END-PERFORM

           CLOSE PRODUCT-FILE
           CLOSE TEMP-FILE

           CALL "SYSTEM" USING "rm -f data/products.dat"
           CALL "SYSTEM" USING "mv data/temp.dat data/products.dat"

           IF WS-FOUND = "Y" AND (WS-CONFIRM = "O" OR "o")
               DISPLAY "=============================="
               DISPLAY "     PRODUCT DELETED          "
               DISPLAY "=============================="
           ELSE
               IF WS-FOUND = "Y"
                   DISPLAY "Deletion cancelled"
               ELSE
                   DISPLAY "=============================="
                   DISPLAY "     PRODUCT NOT FOUND       "
                   DISPLAY "=============================="
               END-IF
           END-IF

           EXIT PROGRAM.

       DISPLAY-PRODUCT.
           DISPLAY "=============================="
           DISPLAY "         PRODUCT FOUND        "
           DISPLAY "=============================="
           DISPLAY "ID    : " PRODUCT-ID OF PRODUCT-RECORD
           DISPLAY "NAME  : " PRODUCT-NAME OF PRODUCT-RECORD
           DISPLAY "PRICE : " PRODUCT-PRICE OF PRODUCT-RECORD
           DISPLAY "STOCK : " PRODUCT-STOCK OF PRODUCT-RECORD
           DISPLAY "DATE  : " PRODUCT-DATE OF PRODUCT-RECORD
           DISPLAY "==============================".