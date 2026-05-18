       IDENTIFICATION DIVISION.
       PROGRAM-ID. TVA.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-HT       PIC 9(6)V99.
       01 WS-TVA      PIC 9(6)V99.
       01 WS-TTC      PIC 9(7)V99.

       PROCEDURE DIVISION.

           DISPLAY "PRIX HT : "
           ACCEPT WS-HT

           COMPUTE WS-TVA = WS-HT * 0.20
           COMPUTE WS-TTC = WS-HT + WS-TVA

           DISPLAY "TVA : " WS-TVA
           DISPLAY "TTC : " WS-TTC

           STOP RUN.