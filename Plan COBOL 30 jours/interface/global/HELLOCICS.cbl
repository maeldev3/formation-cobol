       IDENTIFICATION DIVISION.
       PROGRAM-ID. HELLOCICS.

       ENVIRONMENT DIVISION.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-NAME        PIC X(20).
       01 WS-MESSAGE     PIC X(50).

       COPY DFHAID.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       LINKAGE SECTION.
       01 DFHCOMMAREA.
          05 CA-NAME     PIC X(20).

       PROCEDURE DIVISION.

       MAIN-PARA.

           EXEC CICS RECEIVE
                INTO(WS-NAME)
                LENGTH(LENGTH OF WS-NAME)
           END-EXEC.

           IF WS-NAME = SPACES
              MOVE 'Nom vide !!!' TO WS-MESSAGE
           ELSE
              STRING 'Bonjour ' DELIMITED BY SIZE
                     WS-NAME DELIMITED BY SPACE
                     INTO WS-MESSAGE
              END-STRING
           END-IF.

           EXEC CICS SEND
                FROM(WS-MESSAGE)
                LENGTH(LENGTH OF WS-MESSAGE)
                ERASE
           END-EXEC.

           EXEC CICS RETURN END-EXEC.