       IDENTIFICATION DIVISION.
       PROGRAM-ID. SAVINGS-MANAGEMENT.
       AUTHOR.     COLLABORATEUR-AI.
       DATE-WRITTEN. 2026-06-01.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FILE-ACCOUNTS ASSIGN TO "data/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT FILE-HISTORY ASSIGN TO "data/history.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FILE-ACCOUNTS.
       01  REG-ACCOUNT.
           05 ACC-ID          PIC X(5).
           05 ACC-OWNER       PIC X(20).
           05 ACC-BALANCE     PIC 9(6)V99.
           05 ACC-RATE        PIC 9(2)V99.

       FD  FILE-HISTORY.
       01  REG-HISTORY.
           05 HIST-ACC-ID     PIC X(5).
           05 HIST-DATE       PIC X(10).
           05 HIST-TYPE       PIC X(10).
           05 HIST-AMOUNT     PIC 9(6)V99.

       WORKING-STORAGE SECTION.
       01  WS-SWITCHES.
           05 WS-EOF          PIC X     VALUE 'N'.
              88 EOF-REACHED            VALUE 'Y'.
       
       01  WS-VARIABLES.
           05 WS-CHOICE       PIC X.
           05 WS-INTEREST     PIC 9(6)V99.
           05 WS-NEW-BALANCE  PIC 9(6)V99.
           05 WS-YIELD        PIC 9(6)V99.
           05 WS-YEARS        PIC 9(2).
           05 WS-COUNTER      PIC 9(2).

       01  WS-DISPLAY-FIELDS.
           05 DISP-BALANCE    PIC ZZZ,ZZ9.99.
           05 DISP-RATE       PIC Z9.99.
           05 DISP-INTEREST   PIC ZZZ,ZZ9.99.
           05 DISP-YIELD      PIC ZZZ,ZZ9.99.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM UNTIL WS-CHOICE = '4'
               DISPLAY "--------------------------------------------"
               DISPLAY "    SAVINGS ACCOUNT MANAGEMENT SYSTEM       "
               DISPLAY "--------------------------------------------"
               DISPLAY "1. Simuler un calcul d'interet simple"
               DISPLAY "2. Simuler un rendement compose (Avenir)"
               DISPLAY "3. Afficher l'historique de demonstration"
               DISPLAY "4. Quitter"
               DISPLAY "Choix (1-4) : " WITH NO ADVANCING
               ACCEPT WS-CHOICE
               
               EVALUATE WS-CHOICE
                   WHEN '1'
                       PERFORM CALCULATE-SIMPLE-INTEREST
                   WHEN '2'
                       PERFORM CALCULATE-COMPOUND-YIELD
                   WHEN '3'
                       PERFORM SHOW-DEMO-HISTORY
                   WHEN '4'
                       DISPLAY "Fermeture du systeme. Au revoir !"
                   WHEN OTHER
                       DISPLAY "Option invalide, veuillez reessayer."
               END-EVALUATE
           END-PERFORM.
           STOP RUN.

       CALCULATE-SIMPLE-INTEREST.
           DISPLAY "--- CALCUL D'INTERETS SIMPLES ---".
           DISPLAY "Entrez le solde actuel : " WITH NO ADVANCING.
           ACCEPT ACC-BALANCE.
           DISPLAY "Entrez le taux d'interet (ex: 0400 pour 4.00%) : " 
                   WITH NO ADVANCING.
           ACCEPT ACC-RATE.
           
           COMPUTE WS-INTEREST ROUNDED = ACC-BALANCE * (ACC-RATE / 100).
           COMPUTE WS-NEW-BALANCE = ACC-BALANCE + WS-INTEREST.
           
           MOVE ACC-BALANCE TO DISP-BALANCE.
           MOVE ACC-RATE TO DISP-RATE.
           MOVE WS-INTEREST TO DISP-INTEREST.
           
           DISPLAY "Solde initial : " DISP-BALANCE "$".
           DISPLAY "Taux annuel   : " DISP-RATE "%".
           DISPLAY "Interet genere: " DISP-INTEREST "$".
           MOVE WS-NEW-BALANCE TO DISP-BALANCE.
           DISPLAY "Nouveau Solde : " DISP-BALANCE "$".
           DISPLAY " ".

       CALCULATE-COMPOUND-YIELD.
           DISPLAY "--- SIMULATION DE RENDEMENT COMPOSE ---".
           DISPLAY "Entrez le capital initial : " WITH NO ADVANCING.
           ACCEPT ACC-BALANCE.
           DISPLAY "Entrez le taux d'interet (%) (ex: 0400 pour 4.00%) : " 
                   WITH NO ADVANCING.
           ACCEPT ACC-RATE.
           DISPLAY "Nombre d'annees du placement : " WITH NO ADVANCING.
           ACCEPT WS-YEARS.
           
           MOVE ACC-BALANCE TO WS-YIELD.
           
           PERFORM VARYING WS-COUNTER FROM 1 BY 1 UNTIL WS-COUNTER > WS-YEARS
               COMPUTE WS-INTEREST ROUNDED = WS-YIELD * (ACC-RATE / 100)
               ADD WS-INTEREST TO WS-YIELD
           END-PERFORM.
           
           MOVE WS-YIELD TO DISP-YIELD.
           DISPLAY "Projection estimee apres " WS-YEARS " annees : " 
                   DISP-YIELD "$".
           DISPLAY " ".

       SHOW-DEMO-HISTORY.
           DISPLAY "--- HISTORIQUE DES TRANSACTIONS (DEMO) ---".
           DISPLAY "ID    | DATE       | TYPE       | MONTANT".
           DISPLAY "--------------------------------------------".
           DISPLAY "0001  | 2026-01-15 | DEPOT      | 001500.00".
           DISPLAY "0001  | 2026-02-01 | INTERET    | 000052.50".
           DISPLAY "0002  | 2026-03-10 | RETRAIT    | 000200.00".
           DISPLAY "--------------------------------------------".
           DISPLAY " ".
