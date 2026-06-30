      ******************************************************************
      * PROGRAMME   : FACTEDIT                                        *
      * DESCRIPTION : EDITION DU LISTING DETAILLE DE TOUTES LES       *
      *               FACTURES (ENTETE + LIGNES PRODUITS)             *
      * ENTREE      : FACTMAST (INDEXE - LECTURE SEQUENTIELLE)        *
      * ENTREE      : FACTLIGN (INDEXE - LECTURE PAR CLE START/NEXT)  *
      * ENTREE      : CLIMAST  (INDEXE - CONSULTATION CLIENT)         *
      * SORTIE      : FACTLIST (LISTING DETAILLE)                     *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTEDIT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FACTURE-HDR-FILE  ASSIGN TO FACTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS FAC-NUMERO
               FILE STATUS IS WS-FACTMAST-STATUS.

           SELECT FACTURE-LGN-FILE  ASSIGN TO FACTLIGN
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FLN-KEY
               FILE STATUS IS WS-FACTLIGN-STATUS.

           SELECT CLIENT-MASTER-FILE ASSIGN TO CLIMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CLI-ID
               FILE STATUS IS WS-CLIMAST-STATUS.

           SELECT FACTURE-LISTING-FILE ASSIGN TO FACTLIST
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FACTURE-HDR-FILE
           RECORDING MODE IS F.
       COPY FACTHDRC.

       FD  FACTURE-LGN-FILE
           RECORDING MODE IS F.
       COPY FACTLNRC.

       FD  CLIENT-MASTER-FILE
           RECORDING MODE IS F.
       COPY CLIENTRC.

       FD  FACTURE-LISTING-FILE
           RECORDING MODE IS F.
       01  FACTURE-LISTING-REC         PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-FACTMAST-STATUS          PIC X(02).
       01  WS-FACTLIGN-STATUS          PIC X(02).
       01  WS-CLIMAST-STATUS           PIC X(02).

       01  WS-SWITCHES.
           05  WS-EOF-FACTURE           PIC X(01) VALUE 'N'.
               88  FACTURE-EOF                    VALUE 'Y'.
           05  WS-EOF-LIGNE             PIC X(01) VALUE 'N'.
               88  LIGNE-EOF                      VALUE 'Y'.

       01  WS-TOTAUX.
           05  WS-TOT-HT                PIC S9(9)V99 COMP-3
                                                    VALUE ZEROES.
           05  WS-TOT-TVA               PIC S9(9)V99 COMP-3
                                                    VALUE ZEROES.
           05  WS-TOT-TTC               PIC S9(9)V99 COMP-3
                                                    VALUE ZEROES.
           05  WS-CNT-FACTURES          PIC 9(05)  VALUE ZEROES.

       01  WS-HEADER-LINE-1.
           05  FILLER  PIC X(50) VALUE
               'LISTING DETAILLE DES FACTURES'.

       01  WS-FAC-LINE.
           05  FILLER  PIC X(10) VALUE 'FACTURE : '.
           05  WS-FH-NUMERO            PIC X(08).
           05  FILLER  PIC X(05) VALUE ' CLI:'.
           05  WS-FH-CLIID             PIC X(06).
           05  FILLER  PIC X(02) VALUE '  '.
           05  WS-FH-NOM               PIC X(30).
           05  FILLER  PIC X(08) VALUE ' STATUT:'.
           05  WS-FH-STATUT            PIC X(12).

       01  WS-LGN-LINE.
           05  FILLER  PIC X(06) VALUE SPACES.
           05  FILLER  PIC X(05) VALUE 'LGN '.
           05  WS-FL-NUM               PIC ZZ9.
           05  FILLER  PIC X(02) VALUE '  '.
           05  WS-FL-PRODCODE          PIC X(08).
           05  FILLER  PIC X(01) VALUE ' '.
           05  WS-FL-LIBELLE           PIC X(30).
           05  FILLER  PIC X(02) VALUE '  '.
           05  WS-FL-QTE               PIC ZZZZ9.
           05  FILLER  PIC X(01) VALUE ' '.
           05  WS-FL-PU                PIC Z(4)9.99.
           05  FILLER  PIC X(01) VALUE ' '.
           05  WS-FL-MONTANT           PIC Z(5)9.99.

       01  WS-TOT-LINE.
           05  FILLER  PIC X(12) VALUE '  TOTAL HT :'.
           05  WS-TT-HT                PIC Z(6)9.99.
           05  FILLER  PIC X(08) VALUE '  TVA :'.
           05  WS-TT-TVA               PIC Z(6)9.99.
           05  FILLER  PIC X(08) VALUE '  TTC :'.
           05  WS-TT-TTC               PIC Z(6)9.99.

       01  WS-GRAND-TOTAL-LINE.
           05  FILLER  PIC X(25) VALUE 'NOMBRE TOTAL FACTURES : '.
           05  WS-GT-CNT               PIC ZZZZ9.
           05  FILLER  PIC X(20) VALUE '   MONTANT TTC : '.
           05  WS-GT-TTC               PIC Z(8)9.99.

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL FACTURE-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           OPEN INPUT  FACTURE-HDR-FILE
           OPEN INPUT  FACTURE-LGN-FILE
           OPEN INPUT  CLIENT-MASTER-FILE
           OPEN OUTPUT FACTURE-LISTING-FILE
           WRITE FACTURE-LISTING-REC FROM WS-HEADER-LINE-1
           MOVE SPACES TO FACTURE-LISTING-REC
           WRITE FACTURE-LISTING-REC
           PERFORM 9100-READ-FACTURE.

       2000-TRAITEMENT.
           ADD 1 TO WS-CNT-FACTURES
           ADD FAC-MONTANT-HT  TO WS-TOT-HT
           ADD FAC-MONTANT-TVA TO WS-TOT-TVA
           ADD FAC-MONTANT-TTC TO WS-TOT-TTC

           MOVE FAC-CLI-ID TO CLI-ID
           READ CLIENT-MASTER-FILE
               INVALID KEY
                   MOVE 'CLIENT INCONNU' TO WS-FH-NOM
               NOT INVALID KEY
                   STRING CLI-PRENOM DELIMITED BY '  '
                          ' ' DELIMITED BY SIZE
                          CLI-NOM    DELIMITED BY '  '
                          INTO WS-FH-NOM
           END-READ

           MOVE FAC-NUMERO TO WS-FH-NUMERO
           MOVE FAC-CLI-ID TO WS-FH-CLIID
           EVALUATE TRUE
               WHEN FAC-OUVERTE
                   MOVE 'OUVERTE'       TO WS-FH-STATUT
               WHEN FAC-PAYEE-PARTIEL
                   MOVE 'PAIEMENT PART' TO WS-FH-STATUT
               WHEN FAC-SOLDEE
                   MOVE 'SOLDEE'        TO WS-FH-STATUT
               WHEN FAC-ANNULEE
                   MOVE 'ANNULEE'       TO WS-FH-STATUT
           END-EVALUATE
           WRITE FACTURE-LISTING-REC FROM WS-FAC-LINE

           PERFORM 2100-EDITER-LIGNES

           MOVE FAC-MONTANT-HT  TO WS-TT-HT
           MOVE FAC-MONTANT-TVA TO WS-TT-TVA
           MOVE FAC-MONTANT-TTC TO WS-TT-TTC
           WRITE FACTURE-LISTING-REC FROM WS-TOT-LINE
           MOVE SPACES TO FACTURE-LISTING-REC
           WRITE FACTURE-LISTING-REC

           PERFORM 9100-READ-FACTURE.

       2100-EDITER-LIGNES.
           MOVE FAC-NUMERO     TO FLN-FAC-NUMERO
           MOVE ZEROES          TO FLN-NUM-LIGNE
           MOVE 'N'              TO WS-EOF-LIGNE

           START FACTURE-LGN-FILE KEY IS NOT LESS THAN FLN-KEY
               INVALID KEY
                   MOVE 'Y' TO WS-EOF-LIGNE
           END-START

           PERFORM UNTIL LIGNE-EOF
               READ FACTURE-LGN-FILE NEXT RECORD
                   AT END
                       MOVE 'Y' TO WS-EOF-LIGNE
               END-READ
               IF NOT LIGNE-EOF
                   IF FLN-FAC-NUMERO NOT = FAC-NUMERO
                       MOVE 'Y' TO WS-EOF-LIGNE
                   ELSE
                       MOVE FLN-NUM-LIGNE     TO WS-FL-NUM
                       MOVE FLN-PRD-CODE      TO WS-FL-PRODCODE
                       MOVE FLN-LIBELLE       TO WS-FL-LIBELLE
                       MOVE FLN-QUANTITE      TO WS-FL-QTE
                       MOVE FLN-PRIX-UNITAIRE TO WS-FL-PU
                       MOVE FLN-MONTANT-LIGNE TO WS-FL-MONTANT
                       WRITE FACTURE-LISTING-REC FROM WS-LGN-LINE
                   END-IF
               END-IF
           END-PERFORM.

       3000-FINALISATION.
           MOVE SPACES TO FACTURE-LISTING-REC
           WRITE FACTURE-LISTING-REC
           MOVE WS-CNT-FACTURES TO WS-GT-CNT
           MOVE WS-TOT-TTC      TO WS-GT-TTC
           WRITE FACTURE-LISTING-REC FROM WS-GRAND-TOTAL-LINE
           CLOSE FACTURE-HDR-FILE
                 FACTURE-LGN-FILE
                 CLIENT-MASTER-FILE
                 FACTURE-LISTING-FILE.

       9100-READ-FACTURE.
           READ FACTURE-HDR-FILE NEXT RECORD
               AT END
                   MOVE 'Y' TO WS-EOF-FACTURE
           END-READ.
