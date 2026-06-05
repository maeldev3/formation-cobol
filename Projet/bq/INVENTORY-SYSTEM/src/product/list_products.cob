       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIST_PRODUCTS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PRODUCT-FILE ASSIGN TO "data/products.dat"
           ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD PRODUCT-FILE.
       01 PRODUCT-RECORD.
          05 PRODUCT-ID        PIC 9(6).
          05 FILLER            PIC X VALUE SPACE.
          05 PRODUCT-NAME      PIC X(30).
          05 FILLER            PIC X VALUE SPACE.
          05 PRODUCT-PRICE     PIC 9(6)V99.
          05 FILLER            PIC X VALUE SPACE.
          05 PRODUCT-STOCK     PIC 9(5).
          05 FILLER            PIC X VALUE SPACE.
          05 PRODUCT-DATE      PIC X(10).

       WORKING-STORAGE SECTION.
       01 WS-EOF PIC X VALUE "N".

       PROCEDURE DIVISION.

           OPEN INPUT PRODUCT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ PRODUCT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       DISPLAY "ID    : " PRODUCT-ID
                       DISPLAY "NAME  : " PRODUCT-NAME
                       DISPLAY "PRICE : " PRODUCT-PRICE
                       DISPLAY "STOCK : " PRODUCT-STOCK
                       DISPLAY "-------------------"
               END-READ

           END-PERFORM

           CLOSE PRODUCT-FILE

           GOBACK.