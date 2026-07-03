       IDENTIFICATION DIVISION.
       PROGRAM-ID. REPORTCL.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.
           SELECT INFILE ASSIGN TO CLIENTS.

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

       WORKING-STORAGE SECTION.

       01 EOF-FLAG       PIC X VALUE 'N'.
       01 NB-CLI         PIC 9(4) VALUE ZERO.
       01 TOT-SAL        PIC 9(7) VALUE ZERO.
       01 MOY-SAL        PIC 9(7) VALUE ZERO.
       01 MAX-SAL        PIC 9(5) VALUE ZERO.
       01 MIN-SAL        PIC 9(5) VALUE 99999.

       PROCEDURE DIVISION.

           OPEN INPUT INFILE.

           PERFORM UNTIL EOF-FLAG = 'Y'

               READ INFILE
                   AT END
                       MOVE 'Y' TO EOF-FLAG

                   NOT AT END

                       ADD 1 TO NB-CLI
                       ADD CLI-SAL TO TOT-SAL

                       IF CLI-SAL > MAX-SAL
                           MOVE CLI-SAL TO MAX-SAL
                       END-IF

                       IF CLI-SAL < MIN-SAL
                           MOVE CLI-SAL TO MIN-SAL
                       END-IF

                       DISPLAY "CLIENT : "
                               CLI-ID SPACE
                               CLI-NOM SPACE
                               CLI-SAL

               END-READ

           END-PERFORM

           IF NB-CLI > 0
               DIVIDE TOT-SAL BY NB-CLI
                   GIVING MOY-SAL
           END-IF

           DISPLAY " "
           DISPLAY "NOMBRE CLIENTS : " NB-CLI
           DISPLAY "TOTAL SALAIRES : " TOT-SAL
           DISPLAY "SALAIRE MOYEN  : " MOY-SAL
           DISPLAY "SALAIRE MAX    : " MAX-SAL
           DISPLAY "SALAIRE MIN    : " MIN-SAL

           CLOSE INFILE.

           DISPLAY "RAPPORT TERMINE".

           STOP RUN.
