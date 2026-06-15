       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIRECLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-IN ASSIGN TO "CLIENT.TXT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.

       FD FICHIER-IN.

       01 ENREG-IN PIC X(80).

       WORKING-STORAGE SECTION.

       01 FIN-FICHIER PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT FICHIER-IN

           PERFORM UNTIL FIN-FICHIER = 'O'

               READ FICHIER-IN
                   AT END
                       MOVE 'O' TO FIN-FICHIER
                   NOT AT END
                       DISPLAY ENREG-IN
               END-READ

           END-PERFORM

           CLOSE FICHIER-IN

           STOP RUN.