       IDENTIFICATION DIVISION.
       PROGRAM-ID. SEARCH_PRODUCT.

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

       01 WS-SEARCH-ID   PIC 9(6).
       01 WS-EOF         PIC X VALUE "N".
       01 WS-FOUND       PIC X VALUE "N".

       PROCEDURE DIVISION.

       MAIN-PARA.

           DISPLAY "Enter Product ID to search: "
           ACCEPT WS-SEARCH-ID

           OPEN INPUT PRODUCT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ PRODUCT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END

                       IF PRODUCT-ID = WS-SEARCH-ID THEN
                           DISPLAY "======================="
                           DISPLAY " PRODUCT FOUND "
                           DISPLAY "======================="
                           DISPLAY "ID    : " PRODUCT-ID
                           DISPLAY "NAME  : " PRODUCT-NAME
                           DISPLAY "PRICE : " PRODUCT-PRICE
                           DISPLAY "STOCK : " PRODUCT-STOCK
                           DISPLAY "======================="
                           MOVE "Y" TO WS-FOUND
                           MOVE "Y" TO WS-EOF
                       END-IF

               END-READ

           END-PERFORM

           CLOSE PRODUCT-FILE

           IF WS-FOUND = "N"
               DISPLAY "Product not found!"
           END-IF

           EXIT PROGRAM.