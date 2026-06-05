       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-CHOICE PIC 9.

       PROCEDURE DIVISION.

       MENU-START.
           DISPLAY " ".
           DISPLAY "1. Add Product".
           DISPLAY "2. List Product".
           DISPLAY "3. Recherche".
           DISPLAY "4. Modification".
           DISPLAY "5. Supprimer".
           DISPLAY "6. Exit".
           DISPLAY "Choose option: ".
           ACCEPT WS-CHOICE.

           EVALUATE WS-CHOICE
           WHEN 1
                   CALL 'ADD_PRODUCT'
           WHEN 2
                   CALL 'LIST_PRODUCTS'
           WHEN 3
                   CALL 'SEARCH_PRODUCT'
           WHEN 4
                   CALL 'UPDATE_STOCK'
           WHEN 5
                   CALL 'DELETE_PRODUCT'        
           WHEN 6
                   DISPLAY "Goodbye!"
                   STOP RUN
           WHEN OTHER
                   DISPLAY "Invalid choice"
           END-EVALUATE.
           
           GO TO MENU-START.