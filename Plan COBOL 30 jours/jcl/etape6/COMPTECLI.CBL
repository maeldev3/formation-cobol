       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMPTECLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT F-CLIENT ASSIGN TO "CLIENT.IN"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD F-CLIENT.
       01 CLIENT-LIGNE PIC X(80).

       WORKING-STORAGE SECTION.

       01 FIN-FICHIER PIC X VALUE 'N'.
       01 NB-CLIENTS  PIC 9(4) VALUE ZERO.

       PROCEDURE DIVISION.

           OPEN INPUT F-CLIENT

           PERFORM UNTIL FIN-FICHIER = 'O'

               READ F-CLIENT
                   AT END
                       MOVE 'O' TO FIN-FICHIER
                   NOT AT END
                       DISPLAY "CLIENT : " CLIENT-LIGNE
                       ADD 1 TO NB-CLIENTS
               END-READ

           END-PERFORM

           CLOSE F-CLIENT

           DISPLAY "-------------------"
           DISPLAY "TOTAL CLIENTS : " NB-CLIENTS

           STOP RUN.