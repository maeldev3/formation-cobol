       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-SYSTEM.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT ACCOUNT-FILE ASSIGN TO "data/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD ACCOUNT-FILE.
       01 ACCOUNT-RECORD                PIC X(100).

       WORKING-STORAGE SECTION.

       01 WS-EOF                        PIC X VALUE 'N'.
       01 WS-FOUND                      PIC X VALUE 'N'.

       01 WS-INPUT-ID                   PIC X(10).
       01 WS-INPUT-PIN                  PIC X(10).

       01 WS-ID                         PIC X(10).
       01 WS-PIN                        PIC X(10).
       01 WS-NAME                       PIC X(30).

       01 WS-BALANCE                    PIC 9(8).

       01 WS-DEPOSIT                    PIC 9(8).
       01 WS-WITHDRAW                   PIC 9(8).

       01 WS-CHOICE                     PIC 9.

       01 WS-BALANCE-DISPLAY            PIC ZZZ,ZZZ,ZZ9.

       PROCEDURE DIVISION.

       MAIN-PROGRAM.

           DISPLAY "================================="
           DISPLAY "        ATM BANKING SYSTEM      "
           DISPLAY "================================="

           DISPLAY "Inserer ID Carte : "
           ACCEPT WS-INPUT-ID

           DISPLAY "Entrer PIN : "
           ACCEPT WS-INPUT-PIN

           OPEN INPUT ACCOUNT-FILE

           PERFORM UNTIL WS-EOF = 'Y'

               READ ACCOUNT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF

                   NOT AT END

                       UNSTRING ACCOUNT-RECORD
                           DELIMITED BY "|"
                           INTO
                               WS-ID
                               WS-PIN
                               WS-NAME
                               WS-BALANCE

                       IF WS-ID = WS-INPUT-ID
                          AND WS-PIN = WS-INPUT-PIN

                           MOVE 'Y' TO WS-FOUND

                           DISPLAY " "
                           DISPLAY "Connexion reussie"
                           DISPLAY "Bienvenue : " WS-NAME

                           PERFORM MENU-SYSTEM

                           MOVE 'Y' TO WS-EOF

                       END-IF

               END-READ

           END-PERFORM

           CLOSE ACCOUNT-FILE

           IF WS-FOUND = 'N'
               DISPLAY "Carte ou PIN invalide."
           END-IF

           STOP RUN.

       MENU-SYSTEM.

           PERFORM UNTIL WS-CHOICE = 4

               DISPLAY " "
               DISPLAY "===== MENU ATM ====="
               DISPLAY "1 - Retrait"
               DISPLAY "2 - Depot"
               DISPLAY "3 - Mini Releve"
               DISPLAY "4 - Quitter"
               DISPLAY "Choix : "

               ACCEPT WS-CHOICE

               EVALUATE WS-CHOICE

                   WHEN 1
                       PERFORM WITHDRAW-MONEY

                   WHEN 2
                       PERFORM DEPOSIT-MONEY

                   WHEN 3
                       PERFORM SHOW-BALANCE

                   WHEN 4
                       DISPLAY "Merci d'utiliser notre ATM."

                   WHEN OTHER
                       DISPLAY "Choix invalide"

               END-EVALUATE

           END-PERFORM.

       WITHDRAW-MONEY.

           DISPLAY "Montant retrait : "
           ACCEPT WS-WITHDRAW

           IF WS-WITHDRAW <= 0
               DISPLAY "Montant invalide"

           ELSE
               IF WS-WITHDRAW > WS-BALANCE
                   DISPLAY "Solde insuffisant"
               ELSE
                   SUBTRACT WS-WITHDRAW FROM WS-BALANCE
                   DISPLAY "Retrait effectue."
                   MOVE WS-BALANCE TO WS-BALANCE-DISPLAY
                   DISPLAY "Nouveau solde : " WS-BALANCE-DISPLAY
               END-IF
           END-IF.

       DEPOSIT-MONEY.

           DISPLAY "Montant depot : "
           ACCEPT WS-DEPOSIT

           IF WS-DEPOSIT <= 0
               DISPLAY "Montant invalide"
           ELSE
               ADD WS-DEPOSIT TO WS-BALANCE
               DISPLAY "Depot effectue."
               MOVE WS-BALANCE TO WS-BALANCE-DISPLAY
               DISPLAY "Nouveau solde : " WS-BALANCE-DISPLAY
           END-IF.

       SHOW-BALANCE.

           MOVE WS-BALANCE TO WS-BALANCE-DISPLAY
           DISPLAY " "
           DISPLAY "===== MINI RELEVE ====="
           DISPLAY "Client : " WS-NAME
           DISPLAY "Solde actuel : " WS-BALANCE-DISPLAY.

