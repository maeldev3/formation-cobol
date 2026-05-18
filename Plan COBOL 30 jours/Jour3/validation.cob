       IDENTIFICATION DIVISION.
       PROGRAM-ID. RETRAIT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-SOLDE   PIC 9(7)V99.
       01 WS-MONTANT PIC 9(7)V99.

       PROCEDURE DIVISION.

           DISPLAY "SOLDE : "
           ACCEPT WS-SOLDE

           DISPLAY "RETRAIT : "
           ACCEPT WS-MONTANT

           IF WS-MONTANT > WS-SOLDE
               DISPLAY "REFUS"
           ELSE
               DISPLAY "ACCEPTE"
           END-IF

           STOP RUN.