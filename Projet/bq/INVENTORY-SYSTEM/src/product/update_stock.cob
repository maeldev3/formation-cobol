       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATE_STOCK.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT PRODUCT-FILE ASSIGN TO "data/products.dat".
           SELECT TEMP-FILE ASSIGN TO "data/temp.dat".

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
       01 WS-NEW-STOCK   PIC 9(5).
       01 WS-EOF         PIC X VALUE "N".
       01 WS-FOUND       PIC X VALUE "N".

       PROCEDURE DIVISION.

       MAIN-PARA.

           DISPLAY "Enter Product ID: "
           ACCEPT WS-SEARCH-ID

           OPEN INPUT PRODUCT-FILE
           OPEN OUTPUT TEMP-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ PRODUCT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END

                       IF PRODUCT-ID = WS-SEARCH-ID THEN

                           MOVE "Y" TO WS-FOUND

                           DISPLAY "PRODUCT FOUND"
                           DISPLAY "NAME  : " PRODUCT-NAME
                           DISPLAY "STOCK: " PRODUCT-STOCK

                           DISPLAY "NEW STOCK: "
                           ACCEPT WS-NEW-STOCK

                           MOVE WS-NEW-STOCK TO PRODUCT-STOCK

                       END-IF

                       MOVE PRODUCT-ID    TO T-ID
                       MOVE PRODUCT-NAME  TO T-NAME
                       MOVE PRODUCT-PRICE TO T-PRICE
                       MOVE PRODUCT-STOCK TO T-STOCK
                       MOVE PRODUCT-DATE  TO T-DATE

                       WRITE TEMP-REC

               END-READ

           END-PERFORM

           CLOSE PRODUCT-FILE
           CLOSE TEMP-FILE

           CALL "SYSTEM" USING "rm data/products.dat".
           CALL "SYSTEM" USING "mv data/temp.dat data/products.dat".

           IF WS-FOUND = "Y"
               DISPLAY "UPDATE SUCCESSFUL"
           ELSE
               DISPLAY "PRODUCT NOT FOUND"
           END-IF

           EXIT PROGRAM.