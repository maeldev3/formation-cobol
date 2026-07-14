      *****************************************************
      * TP20 - CLIDB2
      * Gestion de la table DB2 Z74830.CLIENTS a partir
      * d'un fichier transactions sequentiel.
      *
      * Fonctions demontrees : SELECT (simple), INSERT,
      *                        UPDATE, DELETE, DECLARE
      *                        CURSOR / OPEN / FETCH / CLOSE
      *****************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLIDB2.
       AUTHOR. Z74830.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TRANS-FILE ASSIGN TO TRANSIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-TRANS-STATUS.

           SELECT REPORT-FILE ASSIGN TO REPTOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-REPORT-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  TRANS-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 80 CHARACTERS.
       COPY TRANSREC2.

       FD  REPORT-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 132 CHARACTERS.
       01  REPORT-LINE                PIC X(132).

       WORKING-STORAGE SECTION.

           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE DCLCLIENTS END-EXEC.

       01  WS-TRANS-STATUS              PIC X(02) VALUE '00'.
       01  WS-REPORT-STATUS             PIC X(02) VALUE '00'.

       01  WS-EOF-TRANS                 PIC X(01) VALUE 'N'.
           88  FIN-TRANS                          VALUE 'O'.

       01  WS-EOF-CURSOR                PIC X(01) VALUE 'N'.
           88  FIN-CURSOR                          VALUE 'O'.

       01  WS-COMPTEURS.
           05  CTL-NB-LUS               PIC 9(05) VALUE ZERO.
           05  CTL-NB-INSERT            PIC 9(05) VALUE ZERO.
           05  CTL-NB-UPDATE            PIC 9(05) VALUE ZERO.
           05  CTL-NB-DELETE            PIC 9(05) VALUE ZERO.
           05  CTL-NB-SELECT            PIC 9(05) VALUE ZERO.
           05  CTL-NB-LISTES            PIC 9(05) VALUE ZERO.
           05  CTL-NB-LIGNES-CURSOR     PIC 9(05) VALUE ZERO.
           05  CTL-NB-ERREURS           PIC 9(05) VALUE ZERO.

       01  WS-SQLCODE-DISP              PIC -(6)9.

       01  WS-LIGNE-DETAIL.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-ID                    PIC 9(05).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-NOM                   PIC X(20).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-PRENOM                PIC X(20).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-VILLE                 PIC X(20).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-SOLDE                 PIC ---,---,--9.99.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WD-STATUT                PIC X(01).
           05  FILLER                   PIC X(20) VALUE SPACES.

       01  WS-LIGNE-MSG.
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WM-ID                    PIC 9(05).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WM-MESSAGE               PIC X(45).
           05  FILLER                   PIC X(02) VALUE SPACES.
           05  WM-SQLCODE-LBL           PIC X(09) VALUE 'SQLCODE='.
           05  WM-SQLCODE               PIC -(6)9.

       PROCEDURE DIVISION.

      *--------------------------------------------------*
      * DECLARATION DU CURSEUR (fonction LISTE)
      * Doit se trouver AVANT le premier OPEN dans le
      * source, l'instruction n'est pas executable en
      * elle-meme.
      *--------------------------------------------------*
           EXEC SQL
               DECLARE CUR-CLIENTS CURSOR FOR
                   SELECT CLI_ID, CLI_NOM, CLI_PRENOM,
                          CLI_ADRESSE, CLI_VILLE, CLI_SOLDE,
                          CLI_STATUT, CLI_DATE_MAJ
                     FROM Z74830.CLIENTS
                    WHERE CLI_ID >= :CLI-ID
                    ORDER BY CLI_ID
           END-EXEC.

       MAIN-PROGRAM.
           PERFORM OPEN-FILES
           PERFORM ENTETE-RAPPORT
           PERFORM TRAITER-TRANSACTIONS
               UNTIL FIN-TRANS
           PERFORM PIED-RAPPORT
           PERFORM CLOSE-FILES
           STOP RUN.

       OPEN-FILES.
           OPEN INPUT TRANS-FILE
           IF WS-TRANS-STATUS NOT = '00'
               DISPLAY 'ERREUR OUVERTURE TRANSIN : '
                   WS-TRANS-STATUS
               MOVE 'O' TO WS-EOF-TRANS
           END-IF

           OPEN OUTPUT REPORT-FILE

           IF NOT FIN-TRANS
               PERFORM LIRE-TRANS
           END-IF.

       CLOSE-FILES.
           CLOSE TRANS-FILE
           CLOSE REPORT-FILE.

       LIRE-TRANS.
           READ TRANS-FILE
               AT END
                   MOVE 'O' TO WS-EOF-TRANS
               NOT AT END
                   ADD 1 TO CTL-NB-LUS
           END-READ.

       TRAITER-TRANSACTIONS.
           EVALUATE TRUE
               WHEN TRANS-INSERT
                   PERFORM INSERER-CLIENT
               WHEN TRANS-MODIF
                   PERFORM MODIFIER-CLIENT
               WHEN TRANS-SUPPR
                   PERFORM SUPPRIMER-CLIENT
               WHEN TRANS-CONSULT
                   PERFORM CONSULTER-CLIENT
               WHEN TRANS-LISTE
                   PERFORM LISTER-CLIENTS-CURSOR
               WHEN OTHER
                   PERFORM CODE-INVALIDE
           END-EVALUATE
           PERFORM LIRE-TRANS.

      *--------------------------------------------------*
      * INSERT
      *--------------------------------------------------*
       INSERER-CLIENT.
           MOVE TRANS-ID       TO CLI-ID
           MOVE TRANS-NOM      TO CLI-NOM
           MOVE TRANS-PRENOM   TO CLI-PRENOM
           MOVE TRANS-ADRESSE  TO CLI-ADRESSE
           MOVE SPACES         TO CLI-VILLE
           MOVE ZERO           TO CLI-SOLDE
           MOVE 'A'            TO CLI-STATUT
           MOVE FUNCTION CURRENT-DATE (1:4) TO CLI-DATE-MAJ (1:4)
           MOVE '-'                          TO CLI-DATE-MAJ (5:1)
           MOVE FUNCTION CURRENT-DATE (5:2) TO CLI-DATE-MAJ (6:2)
           MOVE '-'                          TO CLI-DATE-MAJ (8:1)
           MOVE FUNCTION CURRENT-DATE (7:2) TO CLI-DATE-MAJ (9:2)

           EXEC SQL
               INSERT INTO Z74830.CLIENTS
                   ( CLI_ID, CLI_NOM, CLI_PRENOM, CLI_ADRESSE,
                     CLI_VILLE, CLI_SOLDE, CLI_STATUT,
                     CLI_DATE_MAJ )
               VALUES
                   ( :CLI-ID, :CLI-NOM, :CLI-PRENOM, :CLI-ADRESSE,
                     :CLI-VILLE, :CLI-SOLDE, :CLI-STATUT,
                     :CLI-DATE-MAJ )
           END-EXEC

           MOVE TRANS-ID TO WM-ID
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO CTL-NB-INSERT
                   MOVE 'CLIENT INSERE AVEC SUCCES' TO WM-MESSAGE
               WHEN -803
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'INSERT REFUSE - CLE DEJA EXISTANTE'
                       TO WM-MESSAGE
               WHEN OTHER
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'ERREUR SQL SUR INSERT' TO WM-MESSAGE
           END-EVALUATE
           PERFORM ECRIRE-MSG.

      *--------------------------------------------------*
      * UPDATE
      *--------------------------------------------------*
       MODIFIER-CLIENT.
           MOVE TRANS-ID      TO CLI-ID
           MOVE TRANS-NOM     TO CLI-NOM
           MOVE TRANS-PRENOM  TO CLI-PRENOM
           MOVE TRANS-ADRESSE TO CLI-ADRESSE

           EXEC SQL
               UPDATE Z74830.CLIENTS
                  SET CLI_NOM      = :CLI-NOM,
                      CLI_PRENOM   = :CLI-PRENOM,
                      CLI_ADRESSE  = :CLI-ADRESSE
                WHERE CLI_ID = :CLI-ID
           END-EXEC

           MOVE TRANS-ID TO WM-ID
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO CTL-NB-UPDATE
                   MOVE 'CLIENT MODIFIE AVEC SUCCES' TO WM-MESSAGE
               WHEN 100
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'UPDATE REFUSE - CLIENT INEXISTANT'
                       TO WM-MESSAGE
               WHEN OTHER
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'ERREUR SQL SUR UPDATE' TO WM-MESSAGE
           END-EVALUATE
           PERFORM ECRIRE-MSG.

      *--------------------------------------------------*
      * DELETE
      *--------------------------------------------------*
       SUPPRIMER-CLIENT.
           MOVE TRANS-ID TO CLI-ID

           EXEC SQL
               DELETE FROM Z74830.CLIENTS
                WHERE CLI_ID = :CLI-ID
           END-EXEC

           MOVE TRANS-ID TO WM-ID
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO CTL-NB-DELETE
                   MOVE 'CLIENT SUPPRIME AVEC SUCCES' TO WM-MESSAGE
               WHEN 100
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'DELETE REFUSE - CLIENT INEXISTANT'
                       TO WM-MESSAGE
               WHEN OTHER
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'ERREUR SQL SUR DELETE' TO WM-MESSAGE
           END-EVALUATE
           PERFORM ECRIRE-MSG.

      *--------------------------------------------------*
      * SELECT simple (une seule ligne, cle exacte)
      *--------------------------------------------------*
       CONSULTER-CLIENT.
           MOVE TRANS-ID TO CLI-ID

           EXEC SQL
               SELECT CLI_ID, CLI_NOM, CLI_PRENOM, CLI_ADRESSE,
                      CLI_VILLE, CLI_SOLDE, CLI_STATUT,
                      CLI_DATE_MAJ
                 INTO :CLI-ID, :CLI-NOM, :CLI-PRENOM, :CLI-ADRESSE,
                      :CLI-VILLE, :CLI-SOLDE, :CLI-STATUT,
                      :CLI-DATE-MAJ
                 FROM Z74830.CLIENTS
                WHERE CLI_ID = :CLI-ID
           END-EXEC

           MOVE TRANS-ID TO WM-ID
           EVALUATE SQLCODE
               WHEN 0
                   ADD 1 TO CTL-NB-SELECT
                   PERFORM ECRIRE-DETAIL
               WHEN 100
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'CONSULTATION REFUSEE - CLIENT INEXISTANT'
                       TO WM-MESSAGE
                   PERFORM ECRIRE-MSG
               WHEN OTHER
                   ADD 1 TO CTL-NB-ERREURS
                   MOVE 'ERREUR SQL SUR SELECT' TO WM-MESSAGE
                   PERFORM ECRIRE-MSG
           END-EVALUATE.

      *--------------------------------------------------*
      * CURSOR : liste de tous les clients a partir d'une
      * cle donnee (DECLARE fait en debut de PROCEDURE
      * DIVISION, ici uniquement OPEN / FETCH / CLOSE)
      *--------------------------------------------------*
       LISTER-CLIENTS-CURSOR.
           ADD 1 TO CTL-NB-LISTES
           MOVE TRANS-ID TO CLI-ID
           MOVE 'N' TO WS-EOF-CURSOR

           EXEC SQL
               OPEN CUR-CLIENTS
           END-EXEC

           IF SQLCODE NOT = 0
               ADD 1 TO CTL-NB-ERREURS
               MOVE TRANS-ID TO WM-ID
               MOVE 'ERREUR SQL SUR OPEN CURSOR' TO WM-MESSAGE
               PERFORM ECRIRE-MSG
               MOVE 'O' TO WS-EOF-CURSOR
           END-IF

           PERFORM UNTIL FIN-CURSOR
               EXEC SQL
                   FETCH CUR-CLIENTS
                     INTO :CLI-ID, :CLI-NOM, :CLI-PRENOM,
                          :CLI-ADRESSE, :CLI-VILLE, :CLI-SOLDE,
                          :CLI-STATUT, :CLI-DATE-MAJ
               END-EXEC

               EVALUATE SQLCODE
                   WHEN 0
                       ADD 1 TO CTL-NB-LIGNES-CURSOR
                       PERFORM ECRIRE-DETAIL
                   WHEN 100
                       MOVE 'O' TO WS-EOF-CURSOR
                   WHEN OTHER
                       ADD 1 TO CTL-NB-ERREURS
                       MOVE TRANS-ID TO WM-ID
                       MOVE 'ERREUR SQL SUR FETCH' TO WM-MESSAGE
                       PERFORM ECRIRE-MSG
                       MOVE 'O' TO WS-EOF-CURSOR
               END-EVALUATE
           END-PERFORM

           EXEC SQL
               CLOSE CUR-CLIENTS
           END-EXEC.

      *--------------------------------------------------*
       CODE-INVALIDE.
           ADD 1 TO CTL-NB-ERREURS
           MOVE TRANS-ID TO WM-ID
           MOVE 'CODE TRANSACTION INCONNU' TO WM-MESSAGE
           PERFORM ECRIRE-MSG.

      *--------------------------------------------------*
      * ROUTINES D'EDITION
      *--------------------------------------------------*
       ENTETE-RAPPORT.
           MOVE SPACES TO REPORT-LINE
           MOVE 'TP20 - RAPPORT DE GESTION DB2 CLIENTS'
               TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE SPACES TO REPORT-LINE
           MOVE ALL '-' TO REPORT-LINE (1:60)
           WRITE REPORT-LINE
           MOVE SPACES TO REPORT-LINE
           WRITE REPORT-LINE.

       ECRIRE-DETAIL.
           MOVE SPACES     TO REPORT-LINE
           MOVE CLI-ID     TO WD-ID
           MOVE CLI-NOM    TO WD-NOM
           MOVE CLI-PRENOM TO WD-PRENOM
           MOVE CLI-VILLE  TO WD-VILLE
           MOVE CLI-SOLDE  TO WD-SOLDE
           MOVE CLI-STATUT TO WD-STATUT
           MOVE WS-LIGNE-DETAIL TO REPORT-LINE
           WRITE REPORT-LINE.

       ECRIRE-MSG.
           MOVE SQLCODE TO WM-SQLCODE
           MOVE SPACES TO REPORT-LINE
           MOVE WS-LIGNE-MSG TO REPORT-LINE
           WRITE REPORT-LINE.

       PIED-RAPPORT.
           MOVE SPACES TO REPORT-LINE
           WRITE REPORT-LINE
           MOVE SPACES TO REPORT-LINE
           MOVE ALL '-' TO REPORT-LINE (1:60)
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'TRANSACTIONS LUES     : ' CTL-NB-LUS
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'INSERTIONS REUSSIES   : ' CTL-NB-INSERT
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'MODIFICATIONS REUSSIES: ' CTL-NB-UPDATE
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'SUPPRESSIONS REUSSIES : ' CTL-NB-DELETE
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'CONSULTATIONS (SELECT): ' CTL-NB-SELECT
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'LISTES (CURSOR)       : ' CTL-NB-LISTES
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'LIGNES LUES PAR CURSOR: ' CTL-NB-LIGNES-CURSOR
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE

           MOVE SPACES TO REPORT-LINE
           STRING 'ERREURS                : ' CTL-NB-ERREURS
               DELIMITED BY SIZE INTO REPORT-LINE
           WRITE REPORT-LINE.
