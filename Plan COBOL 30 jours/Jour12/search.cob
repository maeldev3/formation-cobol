       IDENTIFICATION DIVISION.
       PROGRAM-ID. SEARCHCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT CLIENT-FILE
               ASSIGN TO "data/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD CLIENT-FILE.
       01 CLIENT-REC.
          05 CL-ID      PIC 9(5).
          05 CL-NAME    PIC X(15).
          05 CL-CITY    PIC X(15).

       WORKING-STORAGE SECTION.

       01 WS-EOF       PIC X VALUE "N".
       01 WS-SEARCH-ID PIC 9(5).
       01 WS-FOUND     PIC X VALUE "N".

       PROCEDURE DIVISION.

       000-MAIN.

           DISPLAY "ENTER CLIENT ID: "
           ACCEPT WS-SEARCH-ID

           OPEN INPUT CLIENT-FILE

           PERFORM UNTIL WS-EOF = "Y" OR WS-FOUND = "Y"

               READ CLIENT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END

                       IF CL-ID = WS-SEARCH-ID
                           DISPLAY "CLIENT FOUND"
                           DISPLAY "NAME : " CL-NAME
                           DISPLAY "CITY : " CL-CITY
                           MOVE "Y" TO WS-FOUND
                       END-IF

               END-READ

           END-PERFORM

           CLOSE CLIENT-FILE

           IF WS-FOUND = "N"
               DISPLAY "CLIENT NOT FOUND"
           END-IF

           STOP RUN.