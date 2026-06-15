       IDENTIFICATION DIVISION.
       PROGRAM-ID. LIRECOP.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
               SELECT F-IN  ASSIGN TO "USER.CLIENT.IN"
                   ORGANIZATION IS LINE SEQUENTIAL.
           
               SELECT F-OUT ASSIGN TO "USER.CLIENT.OUT"
                   ORGANIZATION IS LINE SEQUENTIAL.
           
       DATA DIVISION.
       FILE SECTION.

       FD F-IN.
       01 ENR-IN PIC X(80).

       FD F-OUT.
       01 ENR-OUT PIC X(80).

       WORKING-STORAGE SECTION.
       01 FIN PIC X VALUE 'N'.

       PROCEDURE DIVISION.

           OPEN INPUT F-IN
           OPEN OUTPUT F-OUT

           PERFORM UNTIL FIN = 'O'
               READ F-IN
                   AT END
                       MOVE 'O' TO FIN
                   NOT AT END
                       DISPLAY ENR-IN
                       MOVE ENR-IN TO ENR-OUT
                       WRITE ENR-OUT
               END-READ
           END-PERFORM

           CLOSE F-IN
           CLOSE F-OUT

           STOP RUN.