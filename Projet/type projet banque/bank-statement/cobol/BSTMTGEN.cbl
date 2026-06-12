      ******************************************************************
      * PROGRAMME  : BSTMTGEN                                          *
      * DESCRIPTION: GENERATEUR DE RELEVES BANCAIRES                   *
      *              CICS/DB2/COBOL                                     *
      * TABLES     : BANKDB.CLIENTS, BANKDB.TRANSACTIONS               *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BSTMTGEN.
       AUTHOR.        BANK STATEMENT GENERATOR.
       DATE-WRITTEN.  2024-01-01.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-MAINFRAME.
       OBJECT-COMPUTER. IBM-MAINFRAME.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *----------------------------------------------------------------*
      * CODES RETOUR ET CONSTANTES                                      *
      *----------------------------------------------------------------*
       01  WS-CONSTANTS.
           05  WS-PGMNAME        PIC X(8)  VALUE 'BSTMTGEN'.
           05  WS-OK             PIC S9(4) COMP VALUE ZERO.
           05  WS-MAX-TRANS      PIC 9(4)       VALUE 0100.

       01  WS-FLAGS.
           05  WS-EOF-FLAG       PIC X(1)  VALUE 'N'.
               88  WS-EOF                  VALUE 'Y'.
           05  WS-FOUND-FLAG     PIC X(1)  VALUE 'N'.
               88  WS-CLIENT-FOUND         VALUE 'Y'.

       01  WS-COUNTERS.
           05  WS-TRANS-COUNT    PIC 9(4)  VALUE ZERO.
           05  WS-IDX            PIC 9(4)  VALUE ZERO.

      *----------------------------------------------------------------*
      * ZONE DE COMMUNICATION CICS                                      *
      *----------------------------------------------------------------*
       01  WS-COMMAREA.
           05  CA-NUM-COMPTE     PIC X(26).
           05  CA-DATE-DEBUT     PIC X(10).
           05  CA-DATE-FIN       PIC X(10).
           05  CA-RETURN-CODE    PIC X(4).
           05  CA-MSG-ERREUR     PIC X(50).

      *----------------------------------------------------------------*
      * VARIABLES DB2                                                   *
      *----------------------------------------------------------------*
       01  WS-DB2-VARS.
           05  WS-SQLCODE-SAVE   PIC S9(9) COMP.
           05  WS-SQLERRM        PIC X(70).

      *----------------------------------------------------------------*
      * HOST VARIABLES - TABLE CLIENTS                                  *
      *----------------------------------------------------------------*
       01  WS-CLIENT-REC.
           05  HV-CLIENT-ID      PIC X(10).
           05  HV-NOM            PIC X(40).
           05  HV-PRENOM         PIC X(40).
           05  HV-ADRESSE        PIC X(80).
           05  HV-VILLE          PIC X(30).
           05  HV-CODE-POSTAL    PIC X(5).
           05  HV-NUM-COMPTE     PIC X(26).
           05  HV-DATE-OUVERTURE PIC X(10).
           05  HV-STATUT         PIC X(1).

      *----------------------------------------------------------------*
      * HOST VARIABLES - TABLE TRANSACTIONS                             *
      *----------------------------------------------------------------*
       01  WS-TRANS-REC.
           05  HV-TRANS-ID       PIC X(12).
           05  HV-DATE-TRANS     PIC X(10).
           05  HV-HEURE-TRANS    PIC X(8).
           05  HV-TYPE-TRANS     PIC X(3).
           05  HV-MONTANT        PIC S9(13)V99 COMP-3.
           05  HV-SOLDE-APRES    PIC S9(13)V99 COMP-3.
           05  HV-LIBELLE        PIC X(50).
           05  HV-STATUT-TRANS   PIC X(1).

      *----------------------------------------------------------------*
      * TABLE DES TRANSACTIONS EN MEMOIRE                              *
      *----------------------------------------------------------------*
       01  WS-TRANS-TABLE.
           05  WS-TRANS-ENTRY    OCCURS 100 TIMES
                                 INDEXED BY WS-T-IDX.
               10  WT-TRANS-ID   PIC X(12).
               10  WT-DATE       PIC X(10).
               10  WT-HEURE      PIC X(8).
               10  WT-TYPE       PIC X(3).
               10  WT-MONTANT    PIC S9(13)V99 COMP-3.
               10  WT-SOLDE      PIC S9(13)V99 COMP-3.
               10  WT-LIBELLE    PIC X(50).

      *----------------------------------------------------------------*
      * CALCULS SOLDES                                                  *
      *----------------------------------------------------------------*
       01  WS-SOLDES.
           05  WS-SOLDE-INITIAL  PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-SOLDE-FINAL    PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-TOTAL-CREDIT   PIC S9(13)V99 COMP-3 VALUE ZERO.
           05  WS-TOTAL-DEBIT    PIC S9(13)V99 COMP-3 VALUE ZERO.

      *----------------------------------------------------------------*
      * ZONES D'AFFICHAGE                                               *
      *----------------------------------------------------------------*
       01  WS-DISPLAY-VARS.
           05  WS-MONTANT-DISP   PIC Z(11)9.99-.
           05  WS-SOLDE-DISP     PIC Z(11)9.99-.
           05  WS-CREDIT-DISP    PIC Z(11)9.99-.
           05  WS-DEBIT-DISP     PIC Z(11)9.99-.
           05  WS-DATE-DISP      PIC X(10).

      *----------------------------------------------------------------*
      * RELEVE BANCAIRE - STRUCTURE DE SORTIE                          *
      *----------------------------------------------------------------*
       01  WS-RELEVE-LINE        PIC X(80).

       01  WS-LINE-SEP.
           05  FILLER            PIC X(80)
               VALUE '================================================
      -              '==============='.

      *----------------------------------------------------------------*
      * SQLCA - COMMUNICATION AREA DB2                                  *
      *----------------------------------------------------------------*
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *----------------------------------------------------------------*
      * DECLARATIONS CURSEUR DB2                                        *
      *----------------------------------------------------------------*
           EXEC SQL DECLARE CUR-TRANSACTIONS CURSOR FOR
               SELECT  T.TRANS_ID,
                       CHAR(T.DATE_TRANS,ISO),
                       CHAR(T.HEURE_TRANS,ISO),
                       T.TYPE_TRANS,
                       T.MONTANT,
                       T.SOLDE_APRES,
                       T.LIBELLE
               FROM    BANKDB.TRANSACTIONS T
               WHERE   T.NUM_COMPTE  = :HV-NUM-COMPTE
               AND     T.DATE_TRANS BETWEEN
                       DATE(:CA-DATE-DEBUT) AND DATE(:CA-DATE-FIN)
               AND     T.STATUT_TRANS = 'V'
               ORDER BY T.DATE_TRANS ASC,
                        T.HEURE_TRANS ASC
           END-EXEC.

      ******************************************************************
       PROCEDURE DIVISION.
      ******************************************************************

       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-GET-CLIENT
           IF WS-CLIENT-FOUND
               PERFORM 3000-LOAD-TRANSACTIONS
               PERFORM 4000-CALC-SOLDES
               PERFORM 5000-PRINT-RELEVE
           END-IF
           PERFORM 9000-END
           STOP RUN.

      *----------------------------------------------------------------*
      * 1000 - INITIALISATION                                           *
      *----------------------------------------------------------------*
       1000-INIT.
           MOVE SPACES          TO CA-RETURN-CODE
           MOVE SPACES          TO CA-MSG-ERREUR
           MOVE ZERO            TO WS-TRANS-COUNT
           INITIALIZE WS-SOLDES
           MOVE 'N'             TO WS-EOF-FLAG
           MOVE 'N'             TO WS-FOUND-FLAG

      *    RECUPERER LE COMMAREA CICS
           EXEC CICS ADDRESS
               COMMAREA(WS-COMMAREA)
               RESP(WS-OK)
           END-EXEC

      *    VALEURS PAR DEFAUT SI PAS DE COMMAREA
           IF CA-NUM-COMPTE = SPACES
               MOVE 'FR7630001007941234567890185'
                                TO CA-NUM-COMPTE
           END-IF
           IF CA-DATE-DEBUT = SPACES
               MOVE '2024-01-01' TO CA-DATE-DEBUT
           END-IF
           IF CA-DATE-FIN = SPACES
               MOVE '2024-12-31' TO CA-DATE-FIN
           END-IF.

      *----------------------------------------------------------------*
      * 2000 - LECTURE CLIENT                                           *
      *----------------------------------------------------------------*
       2000-GET-CLIENT.
           MOVE CA-NUM-COMPTE TO HV-NUM-COMPTE

           EXEC SQL
               SELECT  CLIENT_ID,
                       NOM,
                       PRENOM,
                       ADRESSE,
                       VILLE,
                       CODE_POSTAL,
                       NUM_COMPTE,
                       CHAR(DATE_OUVERTURE,ISO),
                       STATUT
               INTO    :HV-CLIENT-ID,
                       :HV-NOM,
                       :HV-PRENOM,
                       :HV-ADRESSE,
                       :HV-VILLE,
                       :HV-CODE-POSTAL,
                       :HV-NUM-COMPTE,
                       :HV-DATE-OUVERTURE,
                       :HV-STATUT
               FROM    BANKDB.CLIENTS
               WHERE   NUM_COMPTE = :HV-NUM-COMPTE
               AND     STATUT     = 'A'
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   MOVE 'Y'     TO WS-FOUND-FLAG
               WHEN +100
                   MOVE 'NFND'  TO CA-RETURN-CODE
                   MOVE 'CLIENT INTROUVABLE OU INACTIF'
                                TO CA-MSG-ERREUR
               WHEN OTHER
                   MOVE WS-SQLCODE-SAVE TO SQLCODE
                   PERFORM 8000-SQL-ERROR
           END-EVALUATE.

      *----------------------------------------------------------------*
      * 3000 - CHARGEMENT DES TRANSACTIONS                              *
      *----------------------------------------------------------------*
       3000-LOAD-TRANSACTIONS.
           EXEC SQL OPEN CUR-TRANSACTIONS END-EXEC

           IF SQLCODE NOT = ZERO
               PERFORM 8000-SQL-ERROR
               STOP RUN
           END-IF

           PERFORM UNTIL WS-EOF
               EXEC SQL FETCH CUR-TRANSACTIONS
                   INTO :HV-TRANS-ID,
                        :HV-DATE-TRANS,
                        :HV-HEURE-TRANS,
                        :HV-TYPE-TRANS,
                        :HV-MONTANT,
                        :HV-SOLDE-APRES,
                        :HV-LIBELLE
               END-EXEC

               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO WS-TRANS-COUNT
                       SET WS-T-IDX TO WS-TRANS-COUNT
                       MOVE HV-TRANS-ID  TO WT-TRANS-ID(WS-T-IDX)
                       MOVE HV-DATE-TRANS TO WT-DATE(WS-T-IDX)
                       MOVE HV-HEURE-TRANS TO WT-HEURE(WS-T-IDX)
                       MOVE HV-TYPE-TRANS TO WT-TYPE(WS-T-IDX)
                       MOVE HV-MONTANT   TO WT-MONTANT(WS-T-IDX)
                       MOVE HV-SOLDE-APRES TO WT-SOLDE(WS-T-IDX)
                       MOVE HV-LIBELLE   TO WT-LIBELLE(WS-T-IDX)
                   WHEN +100
                       MOVE 'Y' TO WS-EOF-FLAG
                   WHEN OTHER
                       PERFORM 8000-SQL-ERROR
               END-EVALUATE
           END-PERFORM

           EXEC SQL CLOSE CUR-TRANSACTIONS END-EXEC.

      *----------------------------------------------------------------*
      * 4000 - CALCUL DES SOLDES                                        *
      *----------------------------------------------------------------*
       4000-CALC-SOLDES.
           IF WS-TRANS-COUNT > ZERO
               SET WS-T-IDX TO 1
               MOVE WT-SOLDE(WS-T-IDX) TO WS-SOLDE-INITIAL
               SUBTRACT WT-MONTANT(WS-T-IDX)
                   FROM WS-SOLDE-INITIAL
               SET WS-T-IDX TO WS-TRANS-COUNT
               MOVE WT-SOLDE(WS-T-IDX) TO WS-SOLDE-FINAL
           END-IF

           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-TRANS-COUNT
               SET WS-T-IDX TO WS-IDX
               EVALUATE WT-TYPE(WS-T-IDX)
                   WHEN 'CRE'
                   WHEN 'DEP'
                   WHEN 'VIR'
                       ADD WT-MONTANT(WS-T-IDX) TO WS-TOTAL-CREDIT
                   WHEN 'DEB'
                   WHEN 'RET'
                   WHEN 'FRA'
                       ADD WT-MONTANT(WS-T-IDX) TO WS-TOTAL-DEBIT
               END-EVALUATE
           END-PERFORM.

      *----------------------------------------------------------------*
      * 5000 - IMPRESSION DU RELEVE                                     *
      *----------------------------------------------------------------*
       5000-PRINT-RELEVE.
           PERFORM 5100-PRINT-HEADER
           PERFORM 5200-PRINT-TRANSACTIONS
           PERFORM 5300-PRINT-FOOTER.

       5100-PRINT-HEADER.
           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING 'RELEVE DE COMPTE BANCAIRE'
                  SPACES
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING 'CLIENT  : '
                  FUNCTION TRIM(HV-PRENOM)
                  ' '
                  FUNCTION TRIM(HV-NOM)
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING 'ADRESSE : '
                  FUNCTION TRIM(HV-ADRESSE)
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING '          '
                  FUNCTION TRIM(HV-CODE-POSTAL)
                  ' '
                  FUNCTION TRIM(HV-VILLE)
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING 'COMPTE  : '
                  HV-NUM-COMPTE
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           STRING 'PERIODE : '
                  CA-DATE-DEBUT
                  ' AU '
                  CA-DATE-FIN
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE SPACES      TO WS-RELEVE-LINE
           STRING 'DATE       '
                  'HEURE    '
                  'TYPE '
                  'LIBELLE                       '
                  '      MONTANT'
                  '       SOLDE'
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE SPACES      TO WS-RELEVE-LINE
           MOVE WS-SOLDE-INITIAL TO WS-SOLDE-DISP
           STRING 'SOLDE INITIAL                                    '
                  WS-SOLDE-DISP
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE.

       5200-PRINT-TRANSACTIONS.
           PERFORM VARYING WS-IDX FROM 1 BY 1
               UNTIL WS-IDX > WS-TRANS-COUNT
               SET WS-T-IDX TO WS-IDX
               MOVE WT-MONTANT(WS-T-IDX) TO WS-MONTANT-DISP
               MOVE WT-SOLDE(WS-T-IDX)   TO WS-SOLDE-DISP
               MOVE SPACES TO WS-RELEVE-LINE
               STRING WT-DATE(WS-T-IDX)
                      ' '
                      WT-HEURE(WS-T-IDX)(1:5)
                      ' '
                      WT-TYPE(WS-T-IDX)
                      ' '
                      WT-LIBELLE(WS-T-IDX)(1:30)
                      ' '
                      WS-MONTANT-DISP
                      ' '
                      WS-SOLDE-DISP
                      DELIMITED SIZE
                   INTO WS-RELEVE-LINE
               PERFORM 5900-SEND-LINE
           END-PERFORM.

       5300-PRINT-FOOTER.
           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-TOTAL-CREDIT TO WS-CREDIT-DISP
           MOVE SPACES          TO WS-RELEVE-LINE
           STRING 'TOTAL CREDITS : '
                  WS-CREDIT-DISP
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-TOTAL-DEBIT  TO WS-DEBIT-DISP
           MOVE SPACES          TO WS-RELEVE-LINE
           STRING 'TOTAL DEBITS  : '
                  WS-DEBIT-DISP
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-SOLDE-FINAL  TO WS-SOLDE-DISP
           MOVE SPACES          TO WS-RELEVE-LINE
           STRING 'SOLDE FINAL   : '
                  WS-SOLDE-DISP
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE WS-LINE-SEP TO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE

           MOVE SPACES      TO WS-RELEVE-LINE
           STRING 'NOMBRE DE TRANSACTIONS : '
                  WS-TRANS-COUNT
                  DELIMITED SIZE
               INTO WS-RELEVE-LINE
           PERFORM 5900-SEND-LINE.

       5900-SEND-LINE.
           EXEC CICS WRITEQ TS
               QUEUE('BSTMTQ  ')
               FROM(WS-RELEVE-LINE)
               LENGTH(80)
               RESP(WS-OK)
           END-EXEC.

      *----------------------------------------------------------------*
      * 8000 - GESTION ERREURS SQL                                      *
      *----------------------------------------------------------------*
       8000-SQL-ERROR.
           MOVE 'SQLE'       TO CA-RETURN-CODE
           MOVE SQLERRMC     TO WS-SQLERRM
           STRING 'SQL ERROR: '
                  SQLCODE
                  ' - '
                  WS-SQLERRM(1:30)
                  DELIMITED SIZE
               INTO CA-MSG-ERREUR
           EXEC CICS WRITEQ TS
               QUEUE('BSTMTEQ ')
               FROM(CA-MSG-ERREUR)
               LENGTH(50)
           END-EXEC.

      *----------------------------------------------------------------*
      * 9000 - FIN DE PROGRAMME                                         *
      *----------------------------------------------------------------*
       9000-END.
           EXEC CICS RETURN END-EXEC.
