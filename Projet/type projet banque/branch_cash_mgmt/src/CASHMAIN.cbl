       IDENTIFICATION DIVISION.
       PROGRAM-ID. CASHMAIN.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CASH-FILE ASSIGN TO "../data/cash.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT HIST-FILE ASSIGN TO "../data/history.dat"
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CASH-FILE.
       01  CASH-RECORD.
           05 CR-DATE           PIC X(10).
           05 CR-BALANCE        PIC 9(12)V99.
           05 CR-TIME           PIC X(19).
           05 CR-COUNT          PIC 9(6).

       FD  HIST-FILE.
       01  HIST-RECORD.
           05 HR-DATE           PIC X(10).
           05 HR-TIME           PIC X(08).
           05 HR-TYPE           PIC X(01).
           05 HR-AMOUNT         PIC 9(12)V99.
           05 HR-BALANCE        PIC 9(12)V99.

       WORKING-STORAGE SECTION.
       01 WS-MENU               PIC 9(01).
       01 WS-BALANCE            PIC 9(12)V99 VALUE 0.
       01 WS-COUNT              PIC 9(6) VALUE 0.
       01 WS-DATE               PIC X(10).
       01 WS-TIME               PIC X(08).
       01 WS-AMOUNT             PIC 9(12)V99.
       01 WS-CONFIRM            PIC X(01).
       01 WS-FS                 PIC X(02).
       01 WS-HIST-FS            PIC X(02).
       
      *> Variables pour controle especes
       01 WS-PHYSIQUE           PIC 9(12)V99.
       01 WS-DIFF               PIC S9(12)V99.
       01 WS-C500 PIC 9(6).
       01 WS-C200 PIC 9(6).
       01 WS-C100 PIC 9(6).
       01 WS-C50  PIC 9(6).
       01 WS-C20  PIC 9(6).
       01 WS-C10  PIC 9(6).
       01 WS-C5   PIC 9(6).
       01 WS-C1   PIC 9(6).
       
      *> Variables pour cloture
       01 WS-TOT-E PIC 9(12)V99.
       01 WS-TOT-S PIC 9(12)V99.
       01 WS-NB-TR PIC 9(6).

       PROCEDURE DIVISION.
       A000-DEBUT.
           MOVE FUNCTION CURRENT-DATE TO WS-DATE(1:10)
           MOVE FUNCTION CURRENT-DATE TO WS-TIME(1:8)
           PERFORM A010-LOAD
           
           PERFORM UNTIL WS-MENU = 0
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
               DISPLAY "CHOIX : "
               ACCEPT WS-MENU
               
               EVALUATE WS-MENU
                   WHEN 1 PERFORM A100-ENTRY
                   WHEN 2 PERFORM A200-WITHDRAWAL
                   WHEN 3 PERFORM A300-CONTROL
                   WHEN 4 PERFORM A400-CLOSURE
                   WHEN 5 PERFORM A500-SHOW
                   WHEN 0 DISPLAY "AU REVOIR"
                   WHEN OTHER DISPLAY "CHOIX INVALIDE"
               END-EVALUATE
           END-PERFORM
           STOP RUN.

       A010-LOAD.
           OPEN INPUT CASH-FILE
           IF WS-FS = "00"
               READ CASH-FILE
               IF WS-FS = "00"
                   MOVE CR-BALANCE TO WS-BALANCE
                   MOVE CR-COUNT TO WS-COUNT
                   DISPLAY "CAISSE CHARGEE: " WS-BALANCE
               END-IF
               CLOSE CASH-FILE
           ELSE
               DISPLAY "NOUVEAU FICHIER CAISSE CREE"
               MOVE 0 TO WS-BALANCE
               MOVE 0 TO WS-COUNT
               PERFORM A015-SAVE
           END-IF
           .

       A015-SAVE.
           OPEN OUTPUT CASH-FILE
           MOVE WS-DATE TO CR-DATE
           MOVE WS-BALANCE TO CR-BALANCE
           MOVE WS-TIME TO CR-TIME
           MOVE WS-COUNT TO CR-COUNT
           WRITE CASH-RECORD
           CLOSE CASH-FILE
           .

       A100-ENTRY.
           DISPLAY " "
           DISPLAY "========== ENTRES (DEPOTS) =========="
           DISPLAY "SOLDE: " WS-BALANCE
           DISPLAY "MONTANT: "
           ACCEPT WS-AMOUNT
           
           IF WS-AMOUNT <= 0
               DISPLAY "MONTANT INVALIDE"
               PERFORM A190-WAIT
               EXIT PERFORM
           END-IF
           
           DISPLAY "CONFIRMER DEPOT " WS-AMOUNT " ? (O/N)"
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
               ADD WS-AMOUNT TO WS-BALANCE
               ADD 1 TO WS-COUNT
               PERFORM A150-LOG-ENTRY
               PERFORM A015-SAVE
               DISPLAY "DEPOT EFFECTUE - NOUVEAU SOLDE: " WS-BALANCE
           ELSE
               DISPLAY "ANNULE"
           END-IF
           
           PERFORM A190-WAIT
           .

       A200-WITHDRAWAL.
           DISPLAY " "
           DISPLAY "========== SORTIES (RETRAITS) ========"
           DISPLAY "SOLDE: " WS-BALANCE
           DISPLAY "MONTANT: "
           ACCEPT WS-AMOUNT
           
           IF WS-AMOUNT <= 0
               DISPLAY "MONTANT INVALIDE"
               PERFORM A190-WAIT
               EXIT PERFORM
           END-IF
           
           IF WS-AMOUNT > WS-BALANCE
               DISPLAY "FONDS INSUFFISANTS"
               PERFORM A190-WAIT
               EXIT PERFORM
           END-IF
           
           DISPLAY "CONFIRMER RETRAIT " WS-AMOUNT " ? (O/N)"
           ACCEPT WS-CONFIRM
           
           IF WS-CONFIRM = 'O' OR WS-CONFIRM = 'o'
               SUBTRACT WS-AMOUNT FROM WS-BALANCE
               ADD 1 TO WS-COUNT
               PERFORM A250-LOG-WITHDRAWAL
               PERFORM A015-SAVE
               DISPLAY "RETRAIT EFFECTUE - NOUVEAU SOLDE: " WS-BALANCE
           ELSE
               DISPLAY "ANNULE"
           END-IF
           
           PERFORM A190-WAIT
           .

       A150-LOG-ENTRY.
           OPEN EXTEND HIST-FILE
           IF WS-HIST-FS = "00" OR WS-HIST-FS = "35"
               MOVE WS-DATE TO HR-DATE
               MOVE WS-TIME TO HR-TIME
               MOVE 'E' TO HR-TYPE
               MOVE WS-AMOUNT TO HR-AMOUNT
               MOVE WS-BALANCE TO HR-BALANCE
               WRITE HIST-RECORD
               CLOSE HIST-FILE
           END-IF
           .

       A250-LOG-WITHDRAWAL.
           OPEN EXTEND HIST-FILE
           IF WS-HIST-FS = "00" OR WS-HIST-FS = "35"
               MOVE WS-DATE TO HR-DATE
               MOVE WS-TIME TO HR-TIME
               MOVE 'S' TO HR-TYPE
               MOVE WS-AMOUNT TO HR-AMOUNT
               MOVE WS-BALANCE TO HR-BALANCE
               WRITE HIST-RECORD
               CLOSE HIST-FILE
           END-IF
           .

       A300-CONTROL.
           DISPLAY " "
           DISPLAY "========== CONTROLE ESPECES =========="
           DISPLAY "SOLDE COMPTABLE: " WS-BALANCE
           DISPLAY " "
           DISPLAY "COMPTAGE PHYSIQUE:"
           DISPLAY "-----------------"
           
           MOVE 0 TO WS-PHYSIQUE
           
           DISPLAY "BILLETS 500 EUR: " NO ADVANCING
           ACCEPT WS-C500
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C500 * 500)
           
           DISPLAY "BILLETS 200 EUR: " NO ADVANCING
           ACCEPT WS-C200
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C200 * 200)
           
           DISPLAY "BILLETS 100 EUR: " NO ADVANCING
           ACCEPT WS-C100
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C100 * 100)
           
           DISPLAY "BILLETS 50 EUR:  " NO ADVANCING
           ACCEPT WS-C50
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C50 * 50)
           
           DISPLAY "BILLETS 20 EUR:  " NO ADVANCING
           ACCEPT WS-C20
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C20 * 20)
           
           DISPLAY "BILLETS 10 EUR:  " NO ADVANCING
           ACCEPT WS-C10
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C10 * 10)
           
           DISPLAY "PIECES 5 EUR:    " NO ADVANCING
           ACCEPT WS-C5
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C5 * 5)
           
           DISPLAY "PIECES 1 EUR:    " NO ADVANCING
           ACCEPT WS-C1
           COMPUTE WS-PHYSIQUE = WS-PHYSIQUE + (WS-C1 * 1)
           
           DISPLAY " "
           DISPLAY "TOTAL PHYSIQUE: " WS-PHYSIQUE
           DISPLAY "SOLDE CAISSE:   " WS-BALANCE
           
           COMPUTE WS-DIFF = WS-PHYSIQUE - WS-BALANCE
           
           IF WS-DIFF = 0
               DISPLAY "CONTROLE OK - EQUILIBRE PARFAIT"
           ELSE
               DISPLAY "DIFFERENCE: " WS-DIFF " EUR"
               IF WS-DIFF > 0
                   DISPLAY "EXCEDENT EN CAISSE"
               ELSE
                   DISPLAY "MANQUE EN CAISSE"
               END-IF
           END-IF
           
           PERFORM A190-WAIT
           .

       A400-CLOSURE.
           DISPLAY " "
           DISPLAY "========== CLOTURE JOURNEE =========="
           DISPLAY "DATE: " WS-DATE
           
           MOVE 0 TO WS-TOT-E
           MOVE 0 TO WS-TOT-S
           MOVE 0 TO WS-NB-TR
           
           OPEN INPUT HIST-FILE
           IF WS-HIST-FS = "00"
               PERFORM UNTIL WS-HIST-FS NOT = "00"
                   READ HIST-FILE
                   IF WS-HIST-FS = "00"
                       IF HR-DATE = WS-DATE
                           ADD 1 TO WS-NB-TR
                           IF HR-TYPE = 'E'
                               ADD HR-AMOUNT TO WS-TOT-E
                           ELSE
                               ADD HR-AMOUNT TO WS-TOT-S
                           END-IF
                       END-IF
                   END-IF
               END-PERFORM
               CLOSE HIST-FILE
           END-IF
           
           DISPLAY " "
           DISPLAY "=== RAPPORT QUOTIDIEN ==="
           DISPLAY "TOTAL ENTRESS:   " WS-TOT-E
           DISPLAY "TOTAL SORTIES:   " WS-TOT-S
           DISPLAY "NB TRANSACTIONS: " WS-NB-TR
           DISPLAY "SOLDE FINAL:     " WS-BALANCE
           
           DISPLAY " "
           DISPLAY "REINITIALISATION..."
           MOVE 0 TO WS-BALANCE
           MOVE 0 TO WS-COUNT
           PERFORM A015-SAVE
           
           DISPLAY "CLOTURE TERMINEE - CAISSE A ZERO"
           PERFORM A190-WAIT
           .

       A500-SHOW.
           DISPLAY " "
           DISPLAY "========== SOLDE CAISSE =========="
           DISPLAY "DATE: " WS-DATE
           DISPLAY "HEURE: " WS-TIME
           DISPLAY "SOLDE: " WS-BALANCE
           DISPLAY "TRANSACTIONS: " WS-COUNT
           PERFORM A190-WAIT
           .

       A190-WAIT.
           DISPLAY " "
           DISPLAY "APPUYEZ ENTREE"
           ACCEPT WS-CONFIRM
           .

       END PROGRAM CASHMAIN.
