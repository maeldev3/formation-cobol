       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATE_STOCK.

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
       01 WS-NEW-NAME    PIC X(30).
       01 WS-NEW-PRICE   PIC 9(6)V99.
       01 WS-NEW-STOCK   PIC 9(5).
       01 WS-EOF         PIC X VALUE "N".
       01 WS-FOUND       PIC X VALUE "N".
       01 WS-CHOICE      PIC 9.
       01 WS-DELETE      PIC X VALUE "N".   *> Indicateur de suppression
       01 WS-CONFIRM     PIC X.
       01 WS-CURRENT-DATE.
           05 WS-YEAR    PIC 9(4).
           05 WS-MONTH   PIC 9(2).
           05 WS-DAY     PIC 9(2).

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
                       IF PRODUCT-ID OF PRODUCT-RECORD = WS-SEARCH-ID
                           MOVE "Y" TO WS-FOUND
                           PERFORM DISPLAY-PRODUCT
                           PERFORM UPDATE-MENU
                           IF WS-DELETE = "Y"
                               DISPLAY "Product will be deleted"
                           ELSE
                               MOVE WS-NEW-NAME  TO PRODUCT-NAME
                                                    OF PRODUCT-RECORD
                               MOVE WS-NEW-PRICE TO PRODUCT-PRICE
                                                    OF PRODUCT-RECORD
                               MOVE WS-NEW-STOCK TO PRODUCT-STOCK
                                                    OF PRODUCT-RECORD
                               ACCEPT WS-CURRENT-DATE FROM DATE YYYYMMDD
                               STRING
                                   WS-YEAR "-" WS-MONTH "-" WS-DAY
                                   DELIMITED BY SIZE
                                   INTO PRODUCT-DATE OF PRODUCT-RECORD
                               END-STRING
                           END-IF
                       END-IF
                       *> Écriture dans le fichier temporaire
                       IF NOT (PRODUCT-ID OF PRODUCT-RECORD =
                               WS-SEARCH-ID AND WS-DELETE = "Y")
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

           IF WS-FOUND = "Y"
               IF WS-DELETE = "Y"
                   DISPLAY "=============================="
                   DISPLAY "     PRODUCT DELETED          "
                   DISPLAY "=============================="
               ELSE
                   DISPLAY "=============================="
                   DISPLAY "    UPDATE SUCCESSFUL        "
                   DISPLAY "=============================="
               END-IF
           ELSE
               DISPLAY "=============================="
               DISPLAY "     PRODUCT NOT FOUND       "
               DISPLAY "=============================="
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

       UPDATE-MENU.
           MOVE PRODUCT-NAME OF PRODUCT-RECORD TO WS-NEW-NAME
           MOVE PRODUCT-PRICE OF PRODUCT-RECORD TO WS-NEW-PRICE
           MOVE PRODUCT-STOCK OF PRODUCT-RECORD TO WS-NEW-STOCK
           MOVE "N" TO WS-DELETE
           DISPLAY "What do you want to do ?"
           DISPLAY "1. Modify Name"
           DISPLAY "2. Modify Price"
           DISPLAY "3. Modify Stock"
           DISPLAY "4. Modify ALL fields"
           DISPLAY "5. DELETE this product"
           ACCEPT WS-CHOICE
           EVALUATE WS-CHOICE
               WHEN 1
                   DISPLAY "New name : "
                   ACCEPT WS-NEW-NAME
               WHEN 2
                   DISPLAY "New price : "
                   ACCEPT WS-NEW-PRICE
               WHEN 3
                   DISPLAY "New stock : "
                   ACCEPT WS-NEW-STOCK
               WHEN 4
                   DISPLAY "New name : "
                   ACCEPT WS-NEW-NAME
                   DISPLAY "New price : "
                   ACCEPT WS-NEW-PRICE
                   DISPLAY "New stock : "
                   ACCEPT WS-NEW-STOCK
               WHEN 5
                   DISPLAY "Confirm deletion (O/N): "
                   ACCEPT WS-CONFIRM
                   IF WS-CONFIRM = "O" OR "o"
                       MOVE "Y" TO WS-DELETE
                   ELSE
                       DISPLAY "Deletion cancelled"
                   END-IF
               WHEN OTHER
                   DISPLAY "Invalid choice, only stock updated"
                   ACCEPT WS-NEW-STOCK
           END-EVALUATE.