       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD_PRODUCT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRODUCT-FILE ASSIGN TO "data/products.dat"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD PRODUCT-FILE.
       COPY "copybooks/product.cpy".

       WORKING-STORAGE SECTION.

       01 WS-LAST-ID     PIC 9(6) VALUE 0.
       01 WS-EOF         PIC X VALUE "N".

       01 WS-NAME        PIC X(30).
       01 WS-PRICE       PIC 9(6)V99.
       01 WS-STOCK       PIC 9(5).

       01 WS-DATE.
           05 WS-YEAR    PIC 9(4).
           05 WS-MONTH   PIC 9(2).
           05 WS-DAY     PIC 9(2).

       PROCEDURE DIVISION.

       MAIN-PARA.

           ACCEPT WS-DATE FROM DATE YYYYMMDD

           OPEN INPUT PRODUCT-FILE

           PERFORM UNTIL WS-EOF = "Y"
               READ PRODUCT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       MOVE PRODUCT-ID TO WS-LAST-ID
               END-READ
           END-PERFORM

           CLOSE PRODUCT-FILE

           ADD 1 TO WS-LAST-ID

           DISPLAY "Product Name: "
           ACCEPT WS-NAME

           DISPLAY "Price: "
           ACCEPT WS-PRICE

           DISPLAY "Stock Quantity: "
           ACCEPT WS-STOCK

           OPEN EXTEND PRODUCT-FILE

           MOVE WS-LAST-ID TO PRODUCT-ID
           MOVE WS-NAME    TO PRODUCT-NAME
           MOVE WS-PRICE   TO PRODUCT-PRICE
           MOVE WS-STOCK   TO PRODUCT-STOCK

           STRING
              WS-YEAR "-" WS-MONTH "-" WS-DAY
              DELIMITED BY SIZE
              INTO PRODUCT-DATE
           END-STRING

           WRITE PRODUCT-RECORD

           CLOSE PRODUCT-FILE

           DISPLAY "=============================="
           DISPLAY " PRODUCT ADDED SUCCESSFULLY "
           DISPLAY " ID   : " PRODUCT-ID
           DISPLAY " NAME : " PRODUCT-NAME
           DISPLAY " PRICE: " PRODUCT-PRICE
           DISPLAY " STOCK: " PRODUCT-STOCK
           DISPLAY " DATE : " PRODUCT-DATE
           DISPLAY "=============================="

           EXIT PROGRAM.