      ******************************************************************
      * PROGRAMME   : FACTCRE                                         *
      * DESCRIPTION : CREATION DE FACTURES A PARTIR D'UN FICHIER DE   *
      *               TRANSACTIONS (ENTETE + LIGNES PRODUITS)         *
      *               CONTROLE CLIENT ET PRODUIT, CALCUL HT/TVA/TTC   *
      * ENTREE      : FACTRAN  (SEQUENTIEL - ENTETES ET LIGNES)       *
      * ENTREE      : CLIMAST  (INDEXE - CONSULTATION CLIENT)         *
      * ENTREE      : PRODMAST (INDEXE - CONSULTATION PRODUIT)        *
      * SORTIE      : FACTMAST (INDEXE - ENTETES FACTURES)            *
      * SORTIE      : FACTLIGN (INDEXE - LIGNES FACTURES)             *
      * SORTIE      : FACTRPT  (LISTING DES FACTURES CREEES)          *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. FACTCRE.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FACTURE-TRAN-FILE  ASSIGN TO FACTRAN
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT CLIENT-MASTER-FILE  ASSIGN TO CLIMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS CLI-ID
               FILE STATUS IS WS-CLIMAST-STATUS.

           SELECT PRODUIT-MASTER-FILE ASSIGN TO PRODMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS PRD-CODE
               FILE STATUS IS WS-PRODMAST-STATUS.

           SELECT FACTURE-HDR-FILE    ASSIGN TO FACTMAST
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FAC-NUMERO
               FILE STATUS IS WS-FACTMAST-STATUS.

           SELECT FACTURE-LGN-FILE    ASSIGN TO FACTLIGN
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS FLN-KEY
               FILE STATUS IS WS-FACTLIGN-STATUS.

           SELECT FACTURE-REPORT-FILE ASSIGN TO FACTRPT
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  FACTURE-TRAN-FILE
           RECORDING MODE IS F.
       01  FACTURE-TRAN-REC            PIC X(80).

       FD  CLIENT-MASTER-FILE
           RECORDING MODE IS F.
       COPY CLIENTRC.

       FD  PRODUIT-MASTER-FILE
           RECORDING MODE IS F.
       COPY PRODUITRC.

       FD  FACTURE-HDR-FILE
           RECORDING MODE IS F.
       COPY FACTHDRC.

       FD  FACTURE-LGN-FILE
           RECORDING MODE IS F.
       COPY FACTLNRC.

       FD  FACTURE-REPORT-FILE
           RECORDING MODE IS F.
       01  FACTURE-REPORT-REC          PIC X(132).

       WORKING-STORAGE SECTION.
       01  WS-CLIMAST-STATUS           PIC X(02).
       01  WS-PRODMAST-STATUS          PIC X(02).
       01  WS-FACTMAST-STATUS          PIC X(02).
       01  WS-FACTLIGN-STATUS          PIC X(02).

       01  WS-SWITCHES.
           05  WS-EOF-TRAN              PIC X(01) VALUE 'N'.
               88  TRAN-EOF                       VALUE 'Y'.
           05  WS-FACTURE-VALIDE        PIC X(01) VALUE 'Y'.
               88  FACTURE-OK                     VALUE 'Y'.
               88  FACTURE-KO                     VALUE 'N'.

       01  WS-COUNTERS.
           05  WS-CNT-FACTURES          PIC 9(05) VALUE ZEROES.
           05  WS-CNT-LIGNES            PIC 9(05) VALUE ZEROES.
           05  WS-CNT-REJETS            PIC 9(05) VALUE ZEROES.

       COPY FACTRNRC.

       01  WS-LIGNE-NUM                PIC 9(03) VALUE ZEROES.

       01  WS-DETAIL-LINE.
           05  WS-D-FACNUM             PIC X(10).
           05  WS-D-CLIID              PIC X(08).
           05  WS-D-HT                 PIC Z(5)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-TVA                PIC Z(5)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-TTC                PIC Z(5)9.99.
           05  FILLER                  PIC X(02) VALUE SPACES.
           05  WS-D-STATUT             PIC X(20).

       PROCEDURE DIVISION.
       0000-MAIN-PROCESS.
           PERFORM 1000-INITIALISATION
           PERFORM 2000-TRAITEMENT
               UNTIL TRAN-EOF
           PERFORM 3000-FINALISATION
           STOP RUN.

       1000-INITIALISATION.
           OPEN INPUT  FACTURE-TRAN-FILE
           OPEN INPUT  CLIENT-MASTER-FILE
           OPEN INPUT  PRODUIT-MASTER-FILE
           OPEN OUTPUT FACTURE-HDR-FILE
           OPEN OUTPUT FACTURE-LGN-FILE
           OPEN OUTPUT FACTURE-REPORT-FILE
           PERFORM 9100-READ-TRAN.

      * CHAQUE FACTURE COMMENCE PAR UNE LIGNE DE TYPE 'E' (ENTETE)
      * SUIVIE DE 1 A N LIGNES DE TYPE 'L' (DETAIL PRODUIT)
       2000-TRAITEMENT.
           IF FCT-TYPE-LIGNE = 'E'
               PERFORM 2100-TRAITER-ENTETE
           ELSE
               ADD 1 TO WS-CNT-REJETS
               MOVE 'TRANSACTION HORS SEQUENCE - LIGNE IGNOREE'
                   TO FACTURE-REPORT-REC
               WRITE FACTURE-REPORT-REC
               PERFORM 9100-READ-TRAN
           END-IF.

       2100-TRAITER-ENTETE.
           MOVE SPACES               TO FACTURE-HEADER
           MOVE FCT-FAC-NUMERO        TO FAC-NUMERO
           MOVE FCT-CLI-ID            TO FAC-CLI-ID
           MOVE FCT-DATE-EMISSION     TO FAC-DATE-EMISSION
           MOVE FCT-DATE-ECHEANCE     TO FAC-DATE-ECHEANCE
           MOVE ZEROES                TO FAC-MONTANT-HT
                                          FAC-MONTANT-TVA
                                          FAC-MONTANT-TTC
                                          FAC-MONTANT-PAYE
                                          FAC-MONTANT-SOLDE
           MOVE ZEROES                TO WS-LIGNE-NUM
           SET FACTURE-OK             TO TRUE

      * CONTROLE DE L'EXISTENCE DU CLIENT
           MOVE FAC-CLI-ID TO CLI-ID
           READ CLIENT-MASTER-FILE
               INVALID KEY
                   SET FACTURE-KO TO TRUE
                   MOVE 'CLIENT INCONNU' TO WS-D-STATUT
           END-READ

           IF FACTURE-OK
               PERFORM 9100-READ-TRAN
               PERFORM 2200-TRAITER-LIGNES
                   UNTIL FCT-TYPE-LIGNE NOT = 'L'
                       OR TRAN-EOF
               PERFORM 2300-ECRIRE-FACTURE
           ELSE
               ADD 1 TO WS-CNT-REJETS
               MOVE FAC-NUMERO TO WS-D-FACNUM
               MOVE FAC-CLI-ID TO WS-D-CLIID
               WRITE FACTURE-REPORT-REC FROM WS-DETAIL-LINE
      * ON CONSOMME LES LIGNES DETAIL ASSOCIEES A UNE ENTETE REJETEE
               PERFORM 9100-READ-TRAN
               PERFORM UNTIL FCT-TYPE-LIGNE NOT = 'L' OR TRAN-EOF
                   PERFORM 9100-READ-TRAN
               END-PERFORM
           END-IF.

       2200-TRAITER-LIGNES.
           MOVE FCD-PRD-CODE TO PRD-CODE
           READ PRODUIT-MASTER-FILE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE FAC-NUMERO  TO WS-D-FACNUM
                   MOVE FCD-PRD-CODE TO WS-D-CLIID
                   MOVE 'PRODUIT INCONNU - LIGNE IGNOREE'
                       TO WS-D-STATUT
                   WRITE FACTURE-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   PERFORM 2210-AJOUTER-LIGNE
           END-READ
           PERFORM 9100-READ-TRAN.

       2210-AJOUTER-LIGNE.
           ADD 1 TO WS-LIGNE-NUM
           MOVE SPACES                TO FACTURE-LIGNE
           MOVE FAC-NUMERO             TO FLN-FAC-NUMERO
           MOVE WS-LIGNE-NUM           TO FLN-NUM-LIGNE
           MOVE PRD-CODE               TO FLN-PRD-CODE
           MOVE PRD-LIBELLE            TO FLN-LIBELLE
           MOVE FCD-QUANTITE           TO FLN-QUANTITE
           MOVE PRD-PRIX-UNITAIRE      TO FLN-PRIX-UNITAIRE

           COMPUTE FLN-MONTANT-LIGNE ROUNDED =
               FLN-QUANTITE * FLN-PRIX-UNITAIRE

           WRITE FACTURE-LIGNE
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
               NOT INVALID KEY
                   ADD 1 TO WS-CNT-LIGNES
                   ADD FLN-MONTANT-LIGNE TO FAC-MONTANT-HT
                   COMPUTE FAC-MONTANT-TVA ROUNDED =
                       FAC-MONTANT-TVA +
                       (FLN-MONTANT-LIGNE * PRD-TAUX-TVA / 100)
           END-WRITE.

       2300-ECRIRE-FACTURE.
           COMPUTE FAC-MONTANT-TTC =
               FAC-MONTANT-HT + FAC-MONTANT-TVA
           MOVE FAC-MONTANT-TTC       TO FAC-MONTANT-SOLDE
           MOVE WS-LIGNE-NUM           TO FAC-NB-LIGNES
           SET FAC-OUVERTE             TO TRUE

           WRITE FACTURE-HEADER
               INVALID KEY
                   ADD 1 TO WS-CNT-REJETS
                   MOVE FAC-NUMERO TO WS-D-FACNUM
                   MOVE 'NUMERO DE FACTURE EN DOUBLE'
                       TO WS-D-STATUT
                   WRITE FACTURE-REPORT-REC FROM WS-DETAIL-LINE
               NOT INVALID KEY
                   ADD 1 TO WS-CNT-FACTURES
                   MOVE FAC-NUMERO     TO WS-D-FACNUM
                   MOVE FAC-CLI-ID     TO WS-D-CLIID
                   MOVE FAC-MONTANT-HT  TO WS-D-HT
                   MOVE FAC-MONTANT-TVA TO WS-D-TVA
                   MOVE FAC-MONTANT-TTC TO WS-D-TTC
                   MOVE 'FACTURE CREEE' TO WS-D-STATUT
                   WRITE FACTURE-REPORT-REC FROM WS-DETAIL-LINE
           END-WRITE.

       3000-FINALISATION.
           MOVE SPACES TO FACTURE-REPORT-REC
           WRITE FACTURE-REPORT-REC
           STRING 'TOTAL FACTURES CREEES : ' WS-CNT-FACTURES
               DELIMITED BY SIZE INTO FACTURE-REPORT-REC
           WRITE FACTURE-REPORT-REC
           STRING 'TOTAL LIGNES CREEES    : ' WS-CNT-LIGNES
               DELIMITED BY SIZE INTO FACTURE-REPORT-REC
           WRITE FACTURE-REPORT-REC
           STRING 'TOTAL REJETS           : ' WS-CNT-REJETS
               DELIMITED BY SIZE INTO FACTURE-REPORT-REC
           WRITE FACTURE-REPORT-REC
           CLOSE FACTURE-TRAN-FILE
                 CLIENT-MASTER-FILE
                 PRODUIT-MASTER-FILE
                 FACTURE-HDR-FILE
                 FACTURE-LGN-FILE
                 FACTURE-REPORT-FILE.

       9100-READ-TRAN.
           READ FACTURE-TRAN-FILE INTO FACTURE-TRANSACTION
               AT END
                   MOVE 'Y' TO WS-EOF-TRAN
           END-READ.
