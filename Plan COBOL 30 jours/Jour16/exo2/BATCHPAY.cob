       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHPAY.
       AUTHOR. FORMATEUR.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FACTURES    ASSIGN TO 'FACTURES.DAT'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-FACT-STATUS.
           
           SELECT PAIEMENTS   ASSIGN TO 'PAIEMENTS.DAT'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-PAY-STATUS.
           
           SELECT RAPPORT     ASSIGN TO 'RAPPORT-PAIEMENT.TXT'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RAP-STATUS.
           
           SELECT REGLES      ASSIGN TO 'RULES.TXT'
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RUL-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD FACTURES.
       01 FACTURE-REC.
          05 FAC-ID          PIC 9(4).
          05 FILLER          PIC X(2).
          05 FAC-NOM         PIC X(20).
          05 FILLER          PIC X(2).
          05 FAC-MONTANT     PIC 9(7)V99.
          05 FILLER          PIC X(2).
          05 FAC-DATE        PIC 9(8).

       FD PAIEMENTS.
       01 PAIEMENT-REC.
          05 PAY-ID          PIC 9(4).
          05 FILLER          PIC X(2).
          05 PAY-NOM         PIC X(20).
          05 FILLER          PIC X(2).
          05 PAY-MONTANT     PIC 9(7)V99.
          05 FILLER          PIC X(2).
          05 PAY-DATE        PIC 9(8).
          05 FILLER          PIC X(2).
          05 PAY-STATUT      PIC X(10).

       FD RAPPORT.
       01 RAPPORT-LINE       PIC X(80).

       FD REGLES.
       01 REGLE-REC.
          05 REGLE-CODE      PIC X(15).
          05 FILLER          PIC X(2).
          05 REGLE-VALEUR    PIC X(20).

       WORKING-STORAGE SECTION.
      * Status fichiers
       01 WS-FACT-STATUS     PIC XX.
          88 WS-FACT-OK           VALUE '00'.
          88 WS-FACT-EOF          VALUE '10'.
       01 WS-PAY-STATUS      PIC XX.
       01 WS-RAP-STATUS      PIC XX.
       01 WS-RUL-STATUS      PIC XX.
       
      * Variables de contrôle
       01 WS-FINISHED        PIC X VALUE 'N'.
          88 WS-EOF                VALUE 'Y'.
       01 WS-RETURN-CODE     PIC 9(3) VALUE 0.
          88 WS-RC-OK             VALUE 0.
          88 WS-RC-INPUT-ERR      VALUE 4.
          88 WS-RC-NO-PAYMENT     VALUE 8.
       
      * Règles de paiement
       01 WS-MIN-MONTANT     PIC 9(7)V99 VALUE 0.
       01 WS-DATE-LIMITE     PIC 9(8) VALUE 0.
       01 WS-RULES-LOADED    PIC X VALUE 'N'.
          88 WS-RULES-OK          VALUE 'Y'.
       
      * Compteurs
       01 WS-FACTURE-COUNT    PIC 9(9) VALUE 0.
       01 WS-PAYMENT-COUNT    PIC 9(9) VALUE 0.
       01 WS-REJECT-COUNT     PIC 9(9) VALUE 0.
       01 WS-TOTAL-AMOUNT     PIC 9(11)V99 VALUE 0.
       
      * Lignes de rapport
       01 WS-HEADER-1.
          05 FILLER          PIC X(30) VALUE 'RAPPORT PAIEMENTS FOURNISSEURS'.
       
       01 WS-HEADER-2.
          05 FILLER          PIC X(10) VALUE 'DATE: '.
          05 WS-RAP-DATE     PIC 9(8).
          05 FILLER          PIC X(50).
       
       01 WS-HEADER-3.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 FILLER          PIC X(4) VALUE 'ID'.
          05 FILLER          PIC X(8) VALUE SPACES.
          05 FILLER          PIC X(20) VALUE 'NOM FOURNISSEUR'.
          05 FILLER          PIC X(6) VALUE SPACES.
          05 FILLER          PIC X(10) VALUE 'MONTANT'.
          05 FILLER          PIC X(6) VALUE SPACES.
          05 FILLER          PIC X(10) VALUE 'DATE'.
          05 FILLER          PIC X(6) VALUE SPACES.
          05 FILLER          PIC X(10) VALUE 'STATUT'.
       
       01 WS-DETAIL-LINE.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 DET-ID          PIC 9(4).
          05 FILLER          PIC X(8) VALUE SPACES.
          05 DET-NOM         PIC X(20).
          05 FILLER          PIC X(6) VALUE SPACES.
          05 DET-MONTANT     PIC Z(7)9.99.
          05 FILLER          PIC X(6) VALUE SPACES.
          05 DET-DATE        PIC 9(8).
          05 FILLER          PIC X(6) VALUE SPACES.
          05 DET-STATUT      PIC X(15).
       
       01 WS-SEPARATOR.
          05 FILLER          PIC X(80) VALUE ALL '-'.
       
       01 WS-TOTAL-LINE.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 FILLER          PIC X(30) VALUE 'NOMBRE FACTURES LUS :'.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 TOT-COUNT       PIC Z(9)9.
       
       01 WS-PAYMENT-LINE.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 FILLER          PIC X(30) VALUE 'NOMBRE PAIEMENTS EMIS :'.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 PAY-COUNT       PIC Z(9)9.
       
       01 WS-REJECT-LINE.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 FILLER          PIC X(30) VALUE 'NOMBRE FACTURES REJETEES :'.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 REJ-COUNT       PIC Z(9)9.
       
       01 WS-AMOUNT-LINE.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 FILLER          PIC X(30) VALUE 'MONTANT TOTAL PAYE :'.
          05 FILLER          PIC X(5) VALUE SPACES.
          05 TOT-AMOUNT      PIC Z(11)9.99.

       PROCEDURE DIVISION.
       MAIN.
           PERFORM 100-INITIALISATION
           PERFORM 200-CHARGER-REGLES
           PERFORM 300-TRAITER-FACTURES
           PERFORM 400-GENERER-RAPPORT
           PERFORM 500-FERMETURE
           PERFORM 600-CODE-RETOUR
           .
       
       100-INITIALISATION.
           OPEN INPUT FACTURES
           IF NOT WS-FACT-OK
               DISPLAY 'ERREUR OUVERTURE FACTURES : ' WS-FACT-STATUS
               MOVE 12 TO WS-RETURN-CODE
               PERFORM 500-FERMETURE
           END-IF
           
           OPEN OUTPUT PAIEMENTS
           IF NOT WS-PAY-OK
               DISPLAY 'ERREUR OUVERTURE PAIEMENTS : ' WS-PAY-STATUS
               MOVE 12 TO WS-RETURN-CODE
               PERFORM 500-FERMETURE
           END-IF
           
           OPEN OUTPUT RAPPORT
           IF NOT WS-RAP-OK
               DISPLAY 'ERREUR OUVERTURE RAPPORT : ' WS-RAP-STATUS
               MOVE 12 TO WS-RETURN-CODE
               PERFORM 500-FERMETURE
           END-IF
           
           ACCEPT WS-RAP-DATE FROM DATE YYYYMMDD
           .
       
       200-CHARGER-REGLES.
           OPEN INPUT REGLES
           IF NOT WS-RUL-OK
               DISPLAY 'ERREUR OUVERTURE REGLES : ' WS-RUL-STATUS
               DISPLAY 'UTILISATION VALEURS PAR DEFAUT'
               MOVE 500.00 TO WS-MIN-MONTANT
               MOVE 20241215 TO WS-DATE-LIMITE
               SET WS-RULES-OK TO TRUE
           ELSE
               PERFORM UNTIL WS-EOF
                   READ REGLES INTO REGLE-REC
                   AT END MOVE 'Y' TO WS-FINISHED
                   NOT AT END
                       EVALUATE REGLE-CODE
                           WHEN 'MIN_MONTANT'
                               MOVE FUNCTION NUMVAL(REGLE-VALEUR) 
                                 TO WS-MIN-MONTANT
                           WHEN 'DATE_LIMITE'
                               MOVE REGLE-VALEUR TO WS-DATE-LIMITE
                       END-EVALUATE
                   END-READ
               END-PERFORM
               MOVE 'N' TO WS-FINISHED
               SET WS-RULES-OK TO TRUE
               CLOSE REGLES
           END-IF
           
           DISPLAY 'REGLES CHARGEES :'
           DISPLAY '  MIN MONTANT = ' WS-MIN-MONTANT
           DISPLAY '  DATE LIMITE = ' WS-DATE-LIMITE
           .
       
       300-TRAITER-FACTURES.
           MOVE 'N' TO WS-FINISHED
           
           PERFORM UNTIL WS-EOF
               READ FACTURES INTO FACTURE-REC
               AT END MOVE 'Y' TO WS-FINISHED
               NOT AT END
                   ADD 1 TO WS-FACTURE-COUNT
                   
                   IF FAC-MONTANT >= WS-MIN-MONTANT 
                      AND FAC-DATE <= WS-DATE-LIMITE
                       PERFORM 310-EMETTRE-PAIEMENT
                   ELSE
                       PERFORM 320-REJETER-FACTURE
                   END-IF
               END-READ
           END-PERFORM
           .
       
       310-EMETTRE-PAIEMENT.
           MOVE FAC-ID        TO PAY-ID
           MOVE FAC-NOM       TO PAY-NOM
           MOVE FAC-MONTANT   TO PAY-MONTANT
           MOVE FAC-DATE      TO PAY-DATE
           MOVE 'PAYE'        TO PAY-STATUT
           
           WRITE PAIEMENT-REC
           ADD 1 TO WS-PAYMENT-COUNT
           ADD FAC-MONTANT TO WS-TOTAL-AMOUNT
           
           MOVE FAC-ID        TO DET-ID
           MOVE FAC-NOM       TO DET-NOM
           MOVE FAC-MONTANT   TO DET-MONTANT
           MOVE FAC-DATE      TO DET-DATE
           MOVE 'PAYE'        TO DET-STATUT
           WRITE RAPPORT-LINE FROM WS-DETAIL-LINE
           .
       
       320-REJETER-FACTURE.
           ADD 1 TO WS-REJECT-COUNT
           
           MOVE FAC-ID        TO DET-ID
           MOVE FAC-NOM       TO DET-NOM
           MOVE FAC-MONTANT   TO DET-MONTANT
           MOVE FAC-DATE      TO DET-DATE
           MOVE 'REJETE'      TO DET-STATUT
           WRITE RAPPORT-LINE FROM WS-DETAIL-LINE
           .
       
       400-GENERER-RAPPORT.
           WRITE RAPPORT-LINE FROM WS-HEADER-1
           WRITE RAPPORT-LINE FROM WS-HEADER-2
           WRITE RAPPORT-LINE FROM WS-SEPARATOR
           WRITE RAPPORT-LINE FROM WS-HEADER-3
           WRITE RAPPORT-LINE FROM WS-SEPARATOR
           
           MOVE WS-FACTURE-COUNT  TO TOT-COUNT
           MOVE WS-PAYMENT-COUNT  TO PAY-COUNT
           MOVE WS-REJECT-COUNT   TO REJ-COUNT
           MOVE WS-TOTAL-AMOUNT   TO TOT-AMOUNT
           
           WRITE RAPPORT-LINE FROM WS-SEPARATOR
           WRITE RAPPORT-LINE FROM WS-TOTAL-LINE
           WRITE RAPPORT-LINE FROM WS-PAYMENT-LINE
           WRITE RAPPORT-LINE FROM WS-REJECT-LINE
           WRITE RAPPORT-LINE FROM WS-AMOUNT-LINE
           WRITE RAPPORT-LINE FROM WS-SEPARATOR
           .
       
       500-FERMETURE.
           CLOSE FACTURES
           CLOSE PAIEMENTS
           CLOSE RAPPORT
           .
       
       600-CODE-RETOUR.
           IF WS-PAYMENT-COUNT = 0
               MOVE 8 TO WS-RETURN-CODE
               DISPLAY 'RC=8 : AUCUN PAIEMENT EMIS'
           ELSE
               MOVE 0 TO WS-RETURN-CODE
               DISPLAY 'RC=0 : SUCCES'
           END-IF
           
           MOVE WS-RETURN-CODE TO RETURN-CODE
           STOP RUN.