       IDENTIFICATION DIVISION.
       PROGRAM-ID. DB2CLIENT.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

       01 WS-ID     PIC 9(5).
       01 WS-NOM    PIC X(20).
       01 WS-SOLDE  PIC 9(9)V99.

       01 I         PIC 9 VALUE 1.

       PROCEDURE DIVISION.

       MAIN.

           DISPLAY "=== SIMULATION CLIENTS ===".

           PERFORM VARYING I FROM 1 BY 1 UNTIL I > 3

               IF I = 1
                   MOVE 1 TO WS-ID
                   MOVE "ALI" TO WS-NOM
                   MOVE 1500 TO WS-SOLDE
               END-IF

               IF I = 2
                   MOVE 2 TO WS-ID
                   MOVE "SARA" TO WS-NOM
                   MOVE 800 TO WS-SOLDE
               END-IF

               IF I = 3
                   MOVE 3 TO WS-ID
                   MOVE "JOHN" TO WS-NOM
                   MOVE 2500 TO WS-SOLDE
               END-IF

               DISPLAY "----------------"
               DISPLAY "ID    : " WS-ID
               DISPLAY "NOM   : " WS-NOM
               DISPLAY "SOLDE : " WS-SOLDE

           END-PERFORM.

           STOP RUN.