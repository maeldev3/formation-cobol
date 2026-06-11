       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASHCTRL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-IDX               PIC 9(2).
       01 WS-TOTAL-PHYSIQUE    PIC 9(12)V99.
       01 WS-DIFF              PIC S9(12)V99.
       01 WS-CONFIRM           PIC X(01).

       LINKAGE SECTION.
       01 LS-CURRENT-BAL       PIC 9(12)V99.

       PROCEDURE DIVISION USING LS-CURRENT-BAL.
       
       MAIN-PROCESS.
           DISPLAY "=============================="
           DISPLAY "      CONTROLE DES ESPECES    "
           DISPLAY "=============================="
           DISPLAY "SOLDE COMPTABLE : " LS-CURRENT-BAL
           DISPLAY " "
           DISPLAY "COMPTAGE PHYSIQUE DES BILLETS"
           DISPLAY "-----------------------------"
           
           MOVE 0 TO WS-TOTAL-PHYSIQUE
           
           PERFORM VARYING WS-IDX FROM 1 BY 1 
                   UNTIL WS-IDX > 8
               DISPLAY "NOMBRE DE BILLETS DE " 
                   WS-VAL(WS-IDX) " EUROS : "
               ACCEPT WS-BILL-COUNT(WS-IDX)
               COMPUTE WS-TOTAL-PHYSIQUE = 
                   WS-TOTAL-PHYSIQUE + 
                   (WS-BILL-COUNT(WS-IDX) * WS-VAL(WS-IDX))
           END-PERFORM
           
           DISPLAY " "
           DISPLAY "TOTAL PHYSIQUE COUNTE : " WS-TOTAL-PHYSIQUE
           
           COMPUTE WS-DIFF = 
               WS-TOTAL-PHYSIQUE - LS-CURRENT-BAL
           
           IF WS-DIFF = 0
               DISPLAY "CONTROLE OK - AUCUNE DIFFERENCE"
               DISPLAY "CAISSE PARFAITEMENT EQUILIBREE"
           ELSE
               DISPLAY "ALERTE : DIFFERENCE DETECTEE"
               DISPLAY "ECART : " WS-DIFF
               IF WS-DIFF > 0
                   DISPLAY "EXCEDENT EN CAISSE"
               ELSE
                   DISPLAY "MANQUE EN CAISSE"
               END-IF
           END-IF
           
           DISPLAY " "
           DISPLAY "APPUYEZ SUR ENTREE"
           ACCEPT WS-CONFIRM
           GOBACK.

       COPY COMMON.
       
       END PROGRAM CASHCTRL.
