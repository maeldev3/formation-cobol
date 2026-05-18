       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKDAY2.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-SOLDE       PIC 9(7)V99.
       01 WS-DEPOT       PIC 9(7)V99.
       01 WS-RETRAIT     PIC 9(7)V99.
       01 WS-NOUVEAU     PIC 9(8)V99.

       PROCEDURE DIVISION.

           DISPLAY "SOLDE : "
           ACCEPT WS-SOLDE

           DISPLAY "DEPOT : "
           ACCEPT WS-DEPOT

           DISPLAY "RETRAIT : "
           ACCEPT WS-RETRAIT

           COMPUTE WS-NOUVEAU =
               WS-SOLDE + WS-DEPOT - WS-RETRAIT

           DISPLAY "NOUVEAU SOLDE : "
           DISPLAY WS-NOUVEAU

           STOP RUN.