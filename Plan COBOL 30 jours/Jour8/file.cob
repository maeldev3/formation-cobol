       IDENTIFICATION DIVISION.
       PROGRAM-ID. READCLI.

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
          05 CL-ID        PIC 9(5).
          05 CL-NAME      PIC X(20).
          05 CL-CITY      PIC X(15).

       WORKING-STORAGE SECTION.

       01 WS-EOF        PIC X VALUE "N".

       PROCEDURE DIVISION.

       000-MAIN.

           OPEN INPUT CLIENT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ CLIENT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       DISPLAY "ID   : " CL-ID
                       DISPLAY "NAME : " CL-NAME
                       DISPLAY "CITY : " CL-CITY
                       DISPLAY "-------------------"
               END-READ

           END-PERFORM

           CLOSE CLIENT-FILE

           STOP RUN.