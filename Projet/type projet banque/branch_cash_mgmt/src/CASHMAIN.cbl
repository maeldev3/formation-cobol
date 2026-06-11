       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASHMAIN.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CASH-FILE ASSIGN TO "../data/cash.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT HIST-FILE ASSIGN TO "../data/history.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CASH-FILE.
       01  CASH-RECORD.
           05 CR-DATE           PIC X(10).
           05 CR-BALANCE        PIC 9(12)V99.
           05 CR-LAST-UPDATE    PIC X(19).
           05 CR-TRANS-COUNT    PIC 9(6).

       FD  HIST-FILE.
       01  HIST-RECORD.
           05 HR-DATE           PIC X(10).
           05 HR-TIME           PIC X(08).
           05 HR-TYPE           PIC X(01).
           05 HR-AMOUNT         PIC 9(12)V99.
           05 HR-BALANCE-AFT    PIC 9(12)V99.
           05 HR-TELLER-ID      PIC X(04).

       WORKING-STORAGE SECTION.
       01 WS-MENU-CHOICE        PIC 9(01).
       01 WS-CURRENT-BAL        PIC 9(12)V99 VALUE 0.
       01 WS-TRANS-COUNT        PIC 9(6) VALUE 0.
       01 WS-DATE               PIC X(10).
       01 WS-TIME               PIC X(08).
       01 WS-CONFIRM            PIC X(01).
       01 WS-FILE-STATUS        PIC X(02).
       01 WS-AMOUNT             PIC 9(12)V99.
       01 WS-TOTAL-PHYSIQUE     PIC 9(12)V99.
       01 WS-DIFF               PIC S9(12)V99.
       01 WS-TOTAL-ENTRY        PIC 9(12)V99.
       01 WS-TOTAL-EXIT         PIC 9(12)V99.
       01 WS-COUNT-TRANS        PIC 9(6).
       
       01 WS-BILL-500           PIC 9(6).
       01 WS-BILL-200           PIC 9(6).
       01 WS-BILL-100           PIC 9(6).
       01 WS-BILL-50            PIC 9(6).
       01 WS-BILL-20            PIC 9(6).
       01 WS-BILL-10            PIC 9(6).
       01 WS-BILL-5             PIC 9(6).
       01 WS-BILL-1             PIC 9(6).

       PROCEDURE DIVISION.
       MAIN-PROCESS.
           MOVE FUNCTION CURRENT-DATE TO WS-DATE
           MOVE FUNCTION CURRENT-DATE TO WS-TIME
           PERFORM LOAD-CASH-DATA
           
           PERFORM UNTIL WS-MENU-CHOICE = 0
               DISPLAY " "
               DISPLAY "======================================"
               DISPLAY "   BRANCH CASH MANAGEMENT SYSTEM     "
               DISPLAY "======================================"
               DISPLAY "1. ENTRES (DEPOTS)"
               DISPLAY "2. SORTIES (RETRAITS)"
               DISPLAY "3. CONTROLE ESPECES"
               DISPLAY "4. CLOTURE JOURNEE"
               DISPLAY "5. AFFICHER SOLDE"
               DISPLAY "0. QUITTER"
               DISPLAY "======================================"
               DISPLAY "VOTRE CHOIX : "
               ACCEPT WS-MENU-CHOICE
               
               EVALUATE WS-MENU-CHOICE
                   WHEN 1
                       PERFORM PROCESS-ENTRY
                   WHEN 2
                       PERFORM PROCESS-WITHDRAWAL
                   WHEN 3
                       PERFORM CASH-CONTROL
                   WHEN 4
                       PERFORM DAY-CLOSURE
                   WHEN 5
                       PERFORM SHOW-BALANCE
                   WHEN 0
                       DISPLAY "FERMETURE DU SYSTEME"
                   WHEN OTHER
                       DISPLAY "CHOIX INVALIDE"
                       ACCEPT WS-CONFIRM
               END-EVALUATE
           END-PERFORM
           STOP RUN.

       LOAD-CASH-DATA.
           OPEN INPUT CASH-FILE
           IF WS-FILE-STATUS = "00"
               READ CASH-FILE INTO CASH-RECORD
               IF WS-FILE-STATUS = "00"
                   MOVE CR-BALANCE TO WS-CURRENT-BAL
                   MOVE CR-TRANS-COUNT TO WS-TRANS-COUNT
                   DISPLAY "CAISSE CHARGEE : " WS-CURRENT-BAL
               END-IF
               CLOSE CASH-FILE
           ELSE
               DISPLAY "CREATION NOUVEAU FICHIER CAISSE"
               MOVE 0 TO WS-CURRENT-BAL
               MOVE 0 TO WS-TRANS-COUNT
               PERFORM SAVE-CASH-DATA
           END-IF
           .

       SAVE-CASH-DATA.
           OPEN OUTPUT CASH-FILE
           MOVE WS-DATE TO CR-DATE
           MOVE WS-CURRENT-BAL TO CR-BALANCE
           MOVE WS-DATE TO CR-LAST-UPDATE
           MOVE WS-TRANS-COUNT TO CR-TRANS-COUNT
           WRITE CASH-RECORD
           CLOSE CASH-FILE
           .

       PROCESS-ENTRY.
           DISPLAY " "
           DISPLAY "======================================"
           DISPLAY "      GESTION DES ENTREES (DEPOTS)   "
           DISPLAY "======================================"
           DISPLAY "SOLDE ACTUEL : " WS-CURRENT-BAL
           DISPLAY "ENTREZ LE MONTANT : "
           ACCEPT WS-AMOUNT
           
           IF WS-AMOUNT > 0
               DISPLAY "CONFIRMER DEPOT DE " WS-AMOUNT
               DISPLAY "OUI (O) / NON (N) : "
               ACCEPT WS-CONFIRM
               IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
                   COMPUTE WS-CURRENT-BAL = 
                       WS-CURRENT-BAL + WS-AMOUNT
                   ADD 1 TO WS-TRANS-COUNT
                   PERFORM LOG-TRANSACTION-ENTRY
                   DISPLAY "DEPOT EFFECTUE"
                   DISPLAY "NOUVEAU SOLDE : " WS-CURRENT-BAL
                   PERFORM SAVE-CASH-DATA
               ELSE
                   DISPLAY "OPERATION ANNULEE"
               END-IF
           ELSE
               DISPLAY "MONTANT INVALIDE"
           END-IF
           DISPLAY "APPUYEZ SUR ENTREE POUR CONTINUER"
           ACCEPT WS-CONFIRM
           .

       PROCESS-WITHDRAWAL.
           DISPLAY " "
           DISPLAY "======================================"
           DISPLAY "     GESTION DES SORTIES (RETRAITS)  "
           DISPLAY "======================================"
           DISPLAY "SOLDE ACTUEL : " WS-CURRENT-BAL
           DISPLAY "ENTREZ LE MONTANT : "
           ACCEPT WS-AMOUNT
           
           IF WS-AMOUNT > 0
               IF WS-AMOUNT <= WS-CURRENT-BAL
                   DISPLAY "CONFIRMER RETRAIT DE " WS-AMOUNT
                   DISPLAY "OUI (O) / NON (N) : "
                   ACCEPT WS-CONFIRM
                   IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
                       COMPUTE WS-CURRENT-BAL = 
                           WS-CURRENT-BAL - WS-AMOUNT
                       ADD 1 TO WS-TRANS-COUNT
                       PERFORM LOG-TRANSACTION-WITHDRAWAL
                       DISPLAY "RETRAIT EFFECTUE"
                       DISPLAY "NOUVEAU SOLDE : " WS-CURRENT-BAL
                       PERFORM SAVE-CASH-DATA
                   ELSE
                       DISPLAY "OPERATION ANNULEE"
                   END-IF
               ELSE
                   DISPLAY "FONDS INSUFFISANTS"
                   DISPLAY "SOLDE DISPONIBLE : " WS-CURRENT-BAL
               END-IF
           ELSE
               DISPLAY "MONTANT INVALIDE"
           END-IF
           DISPLAY "APPUYEZ SUR ENTREE POUR CONTINUER"
           ACCEPT WS-CONFIRM
           .

       LOG-TRANSACTION-ENTRY.
           OPEN EXTEND HIST-FILE
           IF WS-FILE-STATUS = "00" OR WS-FILE-STATUS = "35"
               MOVE WS-DATE TO HR-DATE
               MOVE WS-TIME TO HR-TIME
               MOVE 'E' TO HR-TYPE
               MOVE WS-AMOUNT TO HR-AMOUNT
               MOVE WS-CURRENT-BAL TO HR-BALANCE-AFT
               MOVE "T001" TO HR-TELLER-ID
               WRITE HIST-RECORD
               CLOSE HIST-FILE
           END-IF
           .

       LOG-TRANSACTION-WITHDRAWAL.
           OPEN EXTEND HIST-FILE
           IF WS-FILE-STATUS = "00" OR WS-FILE-STATUS = "35"
               MOVE WS-DATE TO HR-DATE
               MOVE WS-TIME TO HR-TIME
               MOVE 'S' TO HR-TYPE
               MOVE WS-AMOUNT TO HR-AMOUNT
               MOVE WS-CURRENT-BAL TO HR-BALANCE-AFT
               MOVE "T001" TO HR-TELLER-ID
               WRITE HIST-RECORD
               CLOSE HIST-FILE
           END-IF
           .

       CASH-CONTROL.
           DISPLAY " "
           DISPLAY "======================================"
           DISPLAY "        CONTROLE DES ESPECES         "
           DISPLAY "======================================"
           DISPLAY "SOLDE COMPTABLE : " WS-CURRENT-BAL
           DISPLAY " "
           DISPLAY "COMPTAGE PHYSIQUE DES BILLETS :"
           DISPLAY "-------------------------------------"
           
           MOVE 0 TO WS-TOTAL-PHYSIQUE
           
           DISPLAY "NOMBRE DE BILLETS DE 500 EUR : "
           ACCEPT WS-BILL-500
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-500 * 500)
           
           DISPLAY "NOMBRE DE BILLETS DE 200 EUR : "
           ACCEPT WS-BILL-200
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-200 * 200)
           
           DISPLAY "NOMBRE DE BILLETS DE 100 EUR : "
           ACCEPT WS-BILL-100
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-100 * 100)
           
           DISPLAY "NOMBRE DE BILLETS DE 50 EUR : "
           ACCEPT WS-BILL-50
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-50 * 50)
           
           DISPLAY "NOMBRE DE BILLETS DE 20 EUR : "
           ACCEPT WS-BILL-20
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-20 * 20)
           
           DISPLAY "NOMBRE DE BILLETS DE 10 EUR : "
           ACCEPT WS-BILL-10
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-10 * 10)
           
           DISPLAY "NOMBRE DE PIECES DE 5 EUR : "
           ACCEPT WS-BILL-5
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-5 * 5)
           
           DISPLAY "NOMBRE DE PIECES DE 1 EUR : "
           ACCEPT WS-BILL-1
           COMPUTE WS-TOTAL-PHYSIQUE = WS-TOTAL-PHYSIQUE 
               + (WS-BILL-1 * 1)
           
           DISPLAY " "
           DISPLAY "TOTAL PHYSIQUE COMPTE : " WS-TOTAL-PHYSIQUE
           DISPLAY "SOLDE COMPTABLE      : " WS-CURRENT-BAL
           
           COMPUTE WS-DIFF = WS-TOTAL-PHYSIQUE - WS-CURRENT-BAL
           
           DISPLAY " "
           IF WS-DIFF = 0
               DISPLAY "CONTROLE OK - CAISSE PARFAITEMENT EQUILIBREE"
           ELSE
               DISPLAY "ALERTE : DIFFERENCE DETECTEE"
               DISPLAY "ECART DE : " WS-DIFF " EUROS"
               IF WS-DIFF > 0
                   DISPLAY "EXCEDENT EN CAISSE"
               ELSE
                   DISPLAY "MANQUE EN CAISSE"
               END-IF
           END-IF
           
           DISPLAY " "
           DISPLAY "APPUYEZ SUR ENTREE POUR CONTINUER"
           ACCEPT WS-CONFIRM
           .

       DAY-CLOSURE.
           DISPLAY " "
           DISPLAY "======================================"
           DISPLAY "        CLOTURE DE JOURNEE           "
           DISPLAY "======================================"
           DISPLAY "DATE : " WS-DATE
           DISPLAY " "
           
           MOVE 0 TO WS-TOTAL-ENTRY
           MOVE 0 TO WS-TOTAL-EXIT
           MOVE 0 TO WS-COUNT-TRANS
           
           OPEN INPUT HIST-FILE
           IF WS-FILE-STATUS = "00"
               PERFORM UNTIL WS-FILE-STATUS NOT = "00"
                   READ HIST-FILE INTO HIST-RECORD
                   IF WS-FILE-STATUS = "00"
                       IF HR-DATE = WS-DATE
                           ADD 1 TO WS-COUNT-TRANS
                           IF HR-TYPE = 'E'
                               COMPUTE WS-TOTAL-ENTRY = 
                                   WS-TOTAL-ENTRY + HR-AMOUNT
                           END-IF
                           IF HR-TYPE = 'S'
                               COMPUTE WS-TOTAL-EXIT = 
                                   WS-TOTAL-EXIT + HR-AMOUNT
                           END-IF
                       END-IF
                   END-IF
               END-PERFORM
               CLOSE HIST-FILE
           END-IF
           
           DISPLAY "=== RECAPITULATIF DE LA JOURNEE ==="
           DISPLAY "TOTAL DES ENTREES  : " WS-TOTAL-ENTRY
           DISPLAY "TOTAL DES SORTIES  : " WS-TOTAL-EXIT
           DISPLAY "NOMBRE TRANSACTIONS : " WS-COUNT-TRANS
           DISPLAY "SOLDE FINAL         : " WS-CURRENT-BAL
           
           DISPLAY " "
           DISPLAY "REINITIALISATION DE LA CAISSE..."
           
           OPEN OUTPUT CASH-FILE
           MOVE WS-DATE TO CR-DATE
           MOVE 0 TO CR-BALANCE
           MOVE WS-DATE TO CR-LAST-UPDATE
           MOVE 0 TO CR-TRANS-COUNT
           WRITE CASH-RECORD
           CLOSE CASH-FILE
           
           MOVE 0 TO WS-CURRENT-BAL
           MOVE 0 TO WS-TRANS-COUNT
           
           DISPLAY "CLOTURE DE JOURNEE EFFECTUEE"
           DISPLAY "CAISSE REINITIALISEE A 0 EURO"
           
           DISPLAY " "
           DISPLAY "APPUYEZ SUR ENTREE POUR CONTINUER"
           ACCEPT WS-CONFIRM
           .

       SHOW-BALANCE.
           DISPLAY " "
           DISPLAY "======================================"
           DISPLAY "           SOLDE ACTUEL              "
           DISPLAY "======================================"
           DISPLAY "DATE : " WS-DATE
           DISPLAY "HEURE : " WS-TIME
           DISPLAY "SOLDE CAISSE : " WS-CURRENT-BAL
           DISPLAY "NB TRANSACTIONS : " WS-TRANS-COUNT
           DISPLAY "======================================"
           DISPLAY "APPUYEZ SUR ENTREE POUR CONTINUER"
           ACCEPT WS-CONFIRM
           .

       END PROGRAM CASHMAIN.
