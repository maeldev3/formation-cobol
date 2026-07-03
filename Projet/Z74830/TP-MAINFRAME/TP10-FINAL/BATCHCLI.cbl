       IDENTIFICATION DIVISION.
       PROGRAM-ID. BATCHCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT INFILE
               ASSIGN TO CLIENTS.

           SELECT OUTFILE
               ASSIGN TO OUTFILE.

       DATA DIVISION.

       FILE SECTION.

       FD INFILE
           RECORD CONTAINS 80 CHARACTERS.

       01 INREC.
          05 CLI-ID      PIC X(3).
          05 FILLER      PIC X.
          05 CLI-NOM     PIC X(8).
          05 FILLER      PIC X(3).
          05 CLI-SAL     PIC 9(5).
          05 FILLER      PIC X(60).

       FD OUTFILE
           RECORD CONTAINS 80 CHARACTERS.

       01 OUTREC.
          05 O-ID        PIC X(3).
          05 FILLER      PIC X.
          05 O-NOM       PIC X(8).
          05 FILLER      PIC X(3).
          05 O-SAL       PIC 9(5).
          05 FILLER      PIC X(60).

       WORKING-STORAGE SECTION.

       01 EOF-FLAG       PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE
                OUTPUT OUTFILE

           PERFORM UNTIL EOF-FLAG = 'Y'

               READ INFILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG

                   NOT AT END

      * Mise à jour du client 003

                       IF CLI-ID = "003"
                           MOVE INREC TO OUTREC
                           MOVE 02000 TO O-SAL
                           WRITE OUTREC

      * Suppression du client 004

                       ELSE
                           IF CLI-ID NOT = "004"
                               MOVE INREC TO OUTREC
                               WRITE OUTREC
                           END-IF
                       END-IF

               END-READ

           END-PERFORM

      * Ajout d'un nouveau client

           MOVE "008"      TO O-ID
           MOVE "ROBERT  " TO O-NOM
           MOVE 07000      TO O-SAL
           WRITE OUTREC

           CLOSE INFILE
                 OUTFILE

           DISPLAY "TRAITEMENT BATCH TERMINE"

           STOP RUN.
