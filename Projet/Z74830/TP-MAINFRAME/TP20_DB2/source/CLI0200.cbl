       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLI0200.
      *****************************************************
      * TP20 - COBOL + DB2
      * Démonstration complète : SELECT / INSERT / UPDATE /
      *                          DELETE / CURSOR
      *****************************************************
       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *---------------------------------------------------
      * SQLCA : obligatoire dans tout programme COBOL-DB2
      * Contient SQLCODE, SQLERRD, SQLSTATE, etc.
      *---------------------------------------------------
           EXEC SQL INCLUDE SQLCA END-EXEC.

      *---------------------------------------------------
      * Structure hôte correspondant à la table CLIENTS
      *---------------------------------------------------
           COPY CLICOPY.

      *---------------------------------------------------
      * Variables de travail
      *---------------------------------------------------
       01  WS-SEUIL-SALAIRE     PIC S9(7)V99 COMP-3 VALUE 20000.00.
       01  WS-EOF-CURSOR        PIC X(01) VALUE 'N'.
           88  FIN-CURSOR                 VALUE 'O'.
       01  WS-NB-LIGNES         PIC 9(04) VALUE 0.

      *---------------------------------------------------
      * Déclaration du curseur (portée : tout le programme)
      *---------------------------------------------------
           EXEC SQL
               DECLARE CLI_CURSOR CURSOR FOR
               SELECT CLI_ID, CLI_NOM, CLI_PRENOM,
                      CLI_SALAIRE, CLI_DATE_NAIS
               FROM   CLIENTS
               WHERE  CLI_SALAIRE > :WS-SEUIL-SALAIRE
               ORDER BY CLI_ID
           END-EXEC.

       PROCEDURE DIVISION.

       MAIN-PROGRAM.
           PERFORM INIT-PROGRAM
           PERFORM SELECT-UN-CLIENT
           PERFORM INSERT-CLIENT
           PERFORM UPDATE-CLIENT
           PERFORM PARCOURS-CURSOR
           PERFORM DELETE-CLIENT
           PERFORM FIN-PROGRAM
           STOP RUN.

       INIT-PROGRAM.
           DISPLAY '=========================================='
           DISPLAY ' TP20 - DEMARRAGE PROGRAMME CLI0200 (DB2) '
           DISPLAY '=========================================='.

      *---------------------------------------------------
      * 1. SELECT simple (recherche par clé primaire)
      *---------------------------------------------------
       SELECT-UN-CLIENT.
           MOVE 100 TO CLI-ID

           EXEC SQL
               SELECT CLI_NOM, CLI_PRENOM, CLI_SALAIRE
               INTO   :CLI-NOM, :CLI-PRENOM, :CLI-SALAIRE
               FROM   CLIENTS
               WHERE  CLI_ID = :CLI-ID
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY '>> SELECT OK : ' CLI-NOM ' ' CLI-PRENOM
               WHEN 100
                   DISPLAY '>> AUCUN CLIENT AVEC CET ID'
               WHEN OTHER
                   DISPLAY '>> ERREUR SELECT - SQLCODE : ' SQLCODE
           END-EVALUATE.

      *---------------------------------------------------
      * 2. INSERT d'un nouveau client
      *---------------------------------------------------
       INSERT-CLIENT.
           MOVE 999           TO CLI-ID
           MOVE 'DUPONT'       TO CLI-NOM
           MOVE 'JEAN'         TO CLI-PRENOM
           MOVE 25000.00       TO CLI-SALAIRE
           MOVE '1990-05-14'   TO CLI-DATE-NAIS

           EXEC SQL
               INSERT INTO CLIENTS
                   (CLI_ID, CLI_NOM, CLI_PRENOM,
                    CLI_SALAIRE, CLI_DATE_NAIS)
               VALUES
                   (:CLI-ID, :CLI-NOM, :CLI-PRENOM,
                    :CLI-SALAIRE, :CLI-DATE-NAIS)
           END-EXEC

           IF SQLCODE = 0
               DISPLAY '>> INSERT OK - CLIENT ' CLI-ID
               EXEC SQL COMMIT END-EXEC
           ELSE
               DISPLAY '>> ERREUR INSERT - SQLCODE : ' SQLCODE
               EXEC SQL ROLLBACK END-EXEC
           END-IF.

      *---------------------------------------------------
      * 3. UPDATE d'un client existant
      *---------------------------------------------------
       UPDATE-CLIENT.
           MOVE 999 TO CLI-ID

           EXEC SQL
               UPDATE CLIENTS
               SET    CLI_SALAIRE = CLI_SALAIRE + 1000.00
               WHERE  CLI_ID = :CLI-ID
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY '>> UPDATE OK - LIGNES MODIFIEES : '
                            SQLERRD(3)
                   EXEC SQL COMMIT END-EXEC
               WHEN OTHER
                   DISPLAY '>> ERREUR UPDATE - SQLCODE : ' SQLCODE
                   EXEC SQL ROLLBACK END-EXEC
           END-EVALUATE.

      *---------------------------------------------------
      * 4. Parcours de plusieurs lignes via CURSOR
      *---------------------------------------------------
       PARCOURS-CURSOR.
           DISPLAY '>> LISTE DES CLIENTS (SALAIRE > 20000) :'

           EXEC SQL
               OPEN CLI_CURSOR
           END-EXEC

           IF SQLCODE NOT = 0
               DISPLAY '>> ERREUR OPEN CURSOR - SQLCODE : ' SQLCODE
           ELSE
               PERFORM UNTIL FIN-CURSOR
                   EXEC SQL
                       FETCH CLI_CURSOR
                       INTO :CLI-ID, :CLI-NOM, :CLI-PRENOM,
                            :CLI-SALAIRE, :CLI-DATE-NAIS
                   END-EXEC

                   EVALUATE SQLCODE
                       WHEN 0
                           ADD 1 TO WS-NB-LIGNES
                           DISPLAY CLI-ID ' - ' CLI-NOM
                                   ' - ' CLI-SALAIRE
                       WHEN 100
                           SET FIN-CURSOR TO TRUE
                       WHEN OTHER
                           DISPLAY '>> ERREUR FETCH - SQLCODE : '
                                    SQLCODE
                           SET FIN-CURSOR TO TRUE
                   END-EVALUATE
               END-PERFORM

               EXEC SQL
                   CLOSE CLI_CURSOR
               END-EXEC

               DISPLAY '>> TOTAL LIGNES LUES : ' WS-NB-LIGNES
           END-IF.

      *---------------------------------------------------
      * 5. DELETE d'un client
      *---------------------------------------------------
       DELETE-CLIENT.
           MOVE 999 TO CLI-ID

           EXEC SQL
               DELETE FROM CLIENTS
               WHERE  CLI_ID = :CLI-ID
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY '>> DELETE OK - CLIENT ' CLI-ID
                   EXEC SQL COMMIT END-EXEC
               WHEN 100
                   DISPLAY '>> AUCUNE LIGNE A SUPPRIMER'
               WHEN OTHER
                   DISPLAY '>> ERREUR DELETE - SQLCODE : ' SQLCODE
                   EXEC SQL ROLLBACK END-EXEC
           END-EVALUATE.

       FIN-PROGRAM.
           DISPLAY '=========================================='
           DISPLAY ' FIN PROGRAMME CLI0200                    '
           DISPLAY '=========================================='.
