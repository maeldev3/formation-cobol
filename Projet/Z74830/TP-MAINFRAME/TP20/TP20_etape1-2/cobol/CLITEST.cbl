      *****************************************************
      * ETAPE 2 - CLITEST
      * Petit programme de test : un seul SELECT, pour
      * valider la chaine precompile/compile/link/bind/run
      * avant d'ajouter INSERT, UPDATE, DELETE, CURSOR.
      *****************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CLITEST.
       AUTHOR. Z74830.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE DCLCLIENTS END-EXEC.

       PROCEDURE DIVISION.

       MAIN-PROGRAM.
           PERFORM CONSULTER-CLIENT
           STOP RUN.

       CONSULTER-CLIENT.
           MOVE 10 TO CLI-ID

           EXEC SQL
               SELECT CLI_ID, CLI_NOM, CLI_PRENOM, CLI_ADRESSE,
                      CLI_VILLE, CLI_SOLDE, CLI_STATUT
                 INTO :CLI-ID, :CLI-NOM, :CLI-PRENOM, :CLI-ADRESSE,
                      :CLI-VILLE, :CLI-SOLDE, :CLI-STATUT
                 FROM Z74830.CLIENTS
                WHERE CLI_ID = :CLI-ID
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   DISPLAY 'CLIENT TROUVE : ' CLI-NOM
               WHEN 100
                   DISPLAY 'CLIENT INEXISTANT (SQLCODE 100)'
               WHEN OTHER
                   DISPLAY 'ERREUR SQL : ' SQLCODE
           END-EVALUATE.
