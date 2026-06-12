       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPDB2.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       01 WS-EMPID   PIC X(10).
       01 WS-NOM     PIC X(30).
       01 WS-POSTE   PIC X(20).
       01 WS-SALAIRE PIC 9(9)V99.

       01 WS-MSG     PIC X(80).

       EXEC SQL
            INCLUDE EMPMAP
       END-EXEC.

       PROCEDURE DIVISION.

       MAIN.

      *---------------------------------------
      * RECEVOIR DONNEES DE L'ECRAN CICS
      *---------------------------------------
           EXEC CICS RECEIVE MAP('EMPSC')
                MAPSET('EMPMAP')
           END-EXEC.

           MOVE EMPIDI TO WS-EMPID
           MOVE EMPNOMI TO WS-NOM
           MOVE EMPJOBI TO WS-POSTE

      *---------------------------------------
      * INSERT DB2
      *---------------------------------------
           EXEC SQL
                INSERT INTO EMPLOYE
                (EMPID, NOM, POSTE, SALAIRE)
                VALUES (:WS-EMPID, :WS-NOM, :WS-POSTE, 1000)
           END-EXEC.

           IF SQLCODE = 0
              MOVE 'INSERT OK' TO WS-MSG
           ELSE
              MOVE 'ERREUR DB2 INSERT' TO WS-MSG
           END-IF.

      *---------------------------------------
      * AFFICHER MESSAGE CICS
      *---------------------------------------
           EXEC CICS
                SEND TEXT
                FROM(WS-MSG)
                LENGTH(80)
                ERASE
           END-EXEC.

           EXEC CICS RETURN END-EXEC.

           GOBACK.