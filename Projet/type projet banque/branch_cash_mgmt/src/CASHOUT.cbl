       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASHOUT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-AMOUNT-OUT         PIC 9(12)V99.
       01 WS-CONFIRM            PIC X(01).

       LINKAGE SECTION.
       01 LS-CURRENT-BAL        PIC 9(12)V99.
       01 LS-TRANS-COUNT        PIC 9(6).
       01 LS-DATE               PIC X(10).
       01 LS-TIME               PIC X(08).

       PROCEDURE DIVISION USING LS-CURRENT-BAL
                                LS-TRANS-COUNT
                                LS-DATE
                                LS-TIME.
       
       MAIN-PROCESS.
           DISPLAY "=============================="
           DISPLAY "      GESTION DES SORTIES     "
           DISPLAY "         (RETRAITS)           "
           DISPLAY "=============================="
           DISPLAY "SOLDE ACTUEL : " LS-CURRENT-BAL
           DISPLAY " "
           
           DISPLAY "ENTREZ LE MONTANT DU RETRAIT : "
           ACCEPT WS-AMOUNT-OUT
           
           IF WS-AMOUNT-OUT > 0
               IF WS-AMOUNT-OUT <= LS-CURRENT-BAL
                   DISPLAY "CONFIRMEZ-VOUS RETRAIT DE " 
                       WS-AMOUNT-OUT
                   DISPLAY "OUI (O) / NON (N) : "
                   ACCEPT WS-CONFIRM
                   IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
                       COMPUTE LS-CURRENT-BAL = 
                           LS-CURRENT-BAL - WS-AMOUNT-OUT
                       ADD 1 TO LS-TRANS-COUNT
                       PERFORM LOG-TRANSACTION
                       DISPLAY "RETRAIT EFFECTUE AVEC SUCCES"
                       DISPLAY "NOUVEAU SOLDE : " LS-CURRENT-BAL
                   ELSE
                       DISPLAY "OPERATION ANNULEE"
                   END-IF
               ELSE
                   DISPLAY "FONDS INSUFFISANTS"
                   DISPLAY "SOLDE DISPONIBLE : " LS-CURRENT-BAL
               END-IF
           ELSE
               DISPLAY "MONTANT INVALIDE"
           END-IF
           
           DISPLAY " "
           DISPLAY "APPUYEZ SUR ENTREE"
           ACCEPT WS-CONFIRM
           GOBACK.

       LOG-TRANSACTION.
           OPEN EXTEND HIST-FILE
           IF WS-HIST-STATUS = "00"
               MOVE LS-DATE TO HR-DATE
               MOVE LS-TIME TO HR-TIME
               MOVE 'S' TO HR-TYPE
               MOVE WS-AMOUNT-OUT TO HR-AMOUNT
               MOVE LS-CURRENT-BAL TO HR-BALANCE-AFT
               MOVE "T001" TO HR-TELLER-ID
               WRITE HIST-RECORD
               CLOSE HIST-FILE
           END-IF
           .

       COPY COMMON.
       
       END PROGRAM CASHOUT.
