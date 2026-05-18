       IDENTIFICATION DIVISION.
       PROGRAM-ID. GESTION-DONNEES.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       *> =========================
       *> CLIENTS BANQUE
       *> =========================
       01  CLIENTS.
           05 CLIENT OCCURS 5 TIMES.
              10 CLI-ID        PIC 9(3).
              10 CLI-NOM       PIC X(20).
              10 CLI-SOLDE     PIC S9(8)V99.

       *> =========================
       *> PRODUITS
       *> =========================
       01  PRODUITS.
           05 PRODUIT OCCURS 10 TIMES.
              10 PROD-ID       PIC 9(3).
              10 PROD-NOM      PIC X(25).
              10 PROD-PRIX     PIC 9(6)V99.

       *> =========================
       *> EMPLOYES
       *> =========================
       01  EMPLOYES.
           05 EMPLOYE OCCURS 5 TIMES.
              10 EMP-ID        PIC 9(3).
              10 EMP-NOM       PIC X(20).
              10 EMP-SALAIRE   PIC 9(7)V99.

       *> =========================
       *> TRANSACTIONS
       *> =========================
       01  TRANSACTIONS.
           05 TRANS OCCURS 7 TIMES.
              10 TRANS-ID      PIC 9(3).
              10 TRANS-TYPE    PIC X(10).
              10 TRANS-MONTANT PIC 9(8)V99.

       *> INDEX
       01  I PIC 9 VALUE 0.

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           DISPLAY "INITIALISATION DES DONNEES BANCAIRES".

           *> Exemple client
           MOVE 1 TO CLI-ID (1)
           MOVE "Rakoto" TO CLI-NOM (1)
           MOVE 150000.50 TO CLI-SOLDE (1)

           MOVE 2 TO CLI-ID (2)
           MOVE "Rabe" TO CLI-NOM (2)
           MOVE 50000.00 TO CLI-SOLDE (2)

           *> Exemple produit
           MOVE 101 TO PROD-ID (1)
           MOVE "Ordinateur" TO PROD-NOM (1)
           MOVE 2500000.00 TO PROD-PRIX (1)

           *> Exemple employé
           MOVE 1 TO EMP-ID (1)
           MOVE "Jean" TO EMP-NOM (1)
           MOVE 800000.00 TO EMP-SALAIRE (1)

           *> Exemple transaction
           MOVE 1 TO TRANS-ID (1)
           MOVE "DEPOT" TO TRANS-TYPE (1)
           MOVE 100000.00 TO TRANS-MONTANT (1)

           DISPLAY "DONNEES CHARGEES AVEC SUCCES".

           STOP RUN.