      ******************************************************************
      * PROGRAMME    : HELLOBANK                                       *
      * AUTEUR       : Z74830                                          *
      * NIVEAU       : DEBUTANT                                        *
      * OBJET        : PROGRAMME BATCH COBOL DE GESTION DE COMPTES     *
      *                BANCAIRES SIMPLES (DEPOTS / RETRAITS)           *
      *                                                                *
      * ENTREES      : - CLIENTI : FICHIER DES CLIENTS (TRIE PAR ID)   *
      *                - TRANSI  : FICHIER DES TRANSACTIONS (TRIE)     *
      * SORTIE       : - REPORTO : RAPPORT DES MOUVEMENTS ET SOLDES    *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLOBANK.
       AUTHOR. Z74830.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENT-FILE  ASSIGN TO CLIENTI
               ORGANIZATION IS SEQUENTIAL.
           SELECT TRANS-FILE   ASSIGN TO TRANSI
               ORGANIZATION IS SEQUENTIAL.
           SELECT REPORT-FILE  ASSIGN TO REPORTO
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
      *----------------------------------------------------------------
      * FICHIER CLIENTS - ENREGISTREMENT DE 80 CARACTERES
      *----------------------------------------------------------------
       FD  CLIENT-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.
       01  CLIENT-REC.
           05  CL-ACCOUNT-ID       PIC 9(05).
           05  CL-NAME             PIC X(20).
           05  CL-BALANCE          PIC 9(7)V99.
           05  FILLER               PIC X(46).

      *----------------------------------------------------------------
      * FICHIER TRANSACTIONS - ENREGISTREMENT DE 80 CARACTERES
      *----------------------------------------------------------------
       FD  TRANS-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.
       01  TRANS-REC.
           05  TR-ACCOUNT-ID       PIC 9(05).
           05  TR-TYPE              PIC X(01).
           05  TR-AMOUNT            PIC 9(7)V99.
           05  FILLER               PIC X(65).

      *----------------------------------------------------------------
      * FICHIER RAPPORT EN SORTIE - ENREGISTREMENT DE 132 CARACTERES
      *----------------------------------------------------------------
       FD  REPORT-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 132 CHARACTERS.
       01  REPORT-REC               PIC X(132).

       WORKING-STORAGE SECTION.
      *----------------------------------------------------------------
      * INDICATEURS DE FIN DE FICHIER
      *----------------------------------------------------------------
       01  WS-EOF-CLIENT            PIC X       VALUE 'N'.
       01  WS-EOF-TRANS             PIC X       VALUE 'N'.

      *----------------------------------------------------------------
      * ZONES DE TRAVAIL POUR LE CALCUL DES SOLDES
      *----------------------------------------------------------------
       01  WS-CURRENT-BALANCE       PIC S9(7)V99 VALUE 0.
       01  WS-DEPOSITS-TOT          PIC S9(7)V99 VALUE 0.
       01  WS-WITHDRAWALS-TOT       PIC S9(7)V99 VALUE 0.
       01  WS-GRAND-TOTAL           PIC S9(9)V99 VALUE 0.
       01  WS-NB-CLIENTS            PIC 9(5)     VALUE 0.

      *----------------------------------------------------------------
      * LIGNES DU RAPPORT
      *----------------------------------------------------------------
       01  WS-HEADER-1.
           05  FILLER          PIC X(40) VALUE
               '   HELLOBANK - RAPPORT DE COMPTES'.
           05  FILLER          PIC X(92) VALUE SPACES.

       01  WS-HEADER-2.
           05  FILLER          PIC X(05) VALUE 'ID'.
           05  FILLER          PIC X(20) VALUE 'NOM CLIENT'.
           05  FILLER          PIC X(15) VALUE 'SOLDE INITIAL'.
           05  FILLER          PIC X(15) VALUE 'DEPOTS'.
           05  FILLER          PIC X(15) VALUE 'RETRAITS'.
           05  FILLER          PIC X(15) VALUE 'SOLDE FINAL'.
           05  FILLER          PIC X(47) VALUE SPACES.

       01  WS-DETAIL-LINE.
           05  DL-ACCOUNT-ID        PIC 9(05).
           05  FILLER               PIC X(01) VALUE SPACE.
           05  DL-NAME              PIC X(20).
           05  DL-INIT-BAL          PIC ---,---,--9.99.
           05  FILLER               PIC X(02) VALUE SPACE.
           05  DL-DEPOSITS          PIC ---,---,--9.99.
           05  FILLER               PIC X(02) VALUE SPACE.
           05  DL-WITHDRAWALS       PIC ---,---,--9.99.
           05  FILLER               PIC X(02) VALUE SPACE.
           05  DL-FINAL-BAL         PIC ---,---,--9.99.
           05  FILLER               PIC X(20) VALUE SPACES.

       01  WS-TOTAL-LINE.
           05  FILLER          PIC X(20) VALUE
               'NOMBRE DE CLIENTS : '.
           05  TL-NB-CLIENTS   PIC ZZZZ9.
           05  FILLER          PIC X(10) VALUE SPACES.
           05  FILLER          PIC X(20) VALUE
               'TOTAL DES SOLDES :  '.
           05  TL-GRAND-TOTAL  PIC -----,---,--9.99.
           05  FILLER          PIC X(47) VALUE SPACES.

       PROCEDURE DIVISION.
      *----------------------------------------------------------------
      * PARAGRAPHE PRINCIPAL
      *----------------------------------------------------------------
       0000-MAIN-PARA.
           DISPLAY 'HELLOBANK - DEBUT DU TRAITEMENT - USER Z74830'.

           OPEN INPUT  CLIENT-FILE
                       TRANS-FILE
           OPEN OUTPUT REPORT-FILE

           PERFORM 1000-WRITE-HEADERS

           PERFORM 2000-READ-TRANS

           PERFORM UNTIL WS-EOF-CLIENT = 'Y'
               READ CLIENT-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF-CLIENT
                   NOT AT END
                       PERFORM 3000-PROCESS-CLIENT
               END-READ
           END-PERFORM

           PERFORM 4000-WRITE-TOTALS

           CLOSE CLIENT-FILE
                 TRANS-FILE
                 REPORT-FILE

           DISPLAY 'HELLOBANK - FIN DU TRAITEMENT - RETOUR CODE 0'.

           STOP RUN.

      *----------------------------------------------------------------
      * ECRITURE DES ENTETES DU RAPPORT
      *----------------------------------------------------------------
       1000-WRITE-HEADERS.
           WRITE REPORT-REC FROM WS-HEADER-1.
           MOVE SPACES TO REPORT-REC.
           WRITE REPORT-REC.
           WRITE REPORT-REC FROM WS-HEADER-2.
           MOVE SPACES TO REPORT-REC.
           WRITE REPORT-REC.

      *----------------------------------------------------------------
      * LECTURE D'UNE TRANSACTION (AVEC GESTION DE FIN DE FICHIER)
      *----------------------------------------------------------------
       2000-READ-TRANS.
           READ TRANS-FILE
               AT END
                   MOVE 'Y' TO WS-EOF-TRANS
                   MOVE 99999 TO TR-ACCOUNT-ID
               NOT AT END
                   CONTINUE
           END-READ.

      *----------------------------------------------------------------
      * TRAITEMENT D'UN CLIENT ET DE SES TRANSACTIONS ASSOCIEES
      *----------------------------------------------------------------
       3000-PROCESS-CLIENT.
           MOVE CL-BALANCE        TO WS-CURRENT-BALANCE
           MOVE 0                 TO WS-DEPOSITS-TOT
           MOVE 0                 TO WS-WITHDRAWALS-TOT

           PERFORM UNTIL WS-EOF-TRANS = 'Y'
                   OR TR-ACCOUNT-ID NOT = CL-ACCOUNT-ID

               EVALUATE TR-TYPE
                   WHEN 'D'
                       ADD TR-AMOUNT TO WS-CURRENT-BALANCE
                       ADD TR-AMOUNT TO WS-DEPOSITS-TOT
                   WHEN 'W'
                       SUBTRACT TR-AMOUNT FROM WS-CURRENT-BALANCE
                       ADD TR-AMOUNT TO WS-WITHDRAWALS-TOT
                   WHEN OTHER
                       DISPLAY 'TYPE TRANSACTION INVALIDE : ' TR-TYPE
               END-EVALUATE

               PERFORM 2000-READ-TRANS
           END-PERFORM

           ADD WS-CURRENT-BALANCE TO WS-GRAND-TOTAL
           ADD 1                  TO WS-NB-CLIENTS

           MOVE CL-ACCOUNT-ID     TO DL-ACCOUNT-ID
           MOVE CL-NAME           TO DL-NAME
           MOVE CL-BALANCE        TO DL-INIT-BAL
           MOVE WS-DEPOSITS-TOT   TO DL-DEPOSITS
           MOVE WS-WITHDRAWALS-TOT TO DL-WITHDRAWALS
           MOVE WS-CURRENT-BALANCE TO DL-FINAL-BAL

           WRITE REPORT-REC FROM WS-DETAIL-LINE.

      *----------------------------------------------------------------
      * ECRITURE DES TOTAUX EN FIN DE RAPPORT
      *----------------------------------------------------------------
       4000-WRITE-TOTALS.
           MOVE SPACES         TO REPORT-REC
           WRITE REPORT-REC.

           MOVE WS-NB-CLIENTS    TO TL-NB-CLIENTS
           MOVE WS-GRAND-TOTAL   TO TL-GRAND-TOTAL
           WRITE REPORT-REC FROM WS-TOTAL-LINE.
