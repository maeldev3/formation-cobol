       IDENTIFICATION DIVISION.
       PROGRAM-ID. UPDATECLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT IN-FILE
               ASSIGN TO "data/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT OUT-FILE
               ASSIGN TO "data/clients_new.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD IN-FILE.
       01 IN-REC.
          05 IN-ID     PIC 9(5).
          05 IN-NAME   PIC X(20).
          05 IN-BAL    PIC 9(7)V99.

       FD OUT-FILE.
       01 OUT-REC.
          05 OUT-ID     PIC 9(5).
          05 OUT-NAME   PIC X(20).
          05 OUT-BAL    PIC 9(7)V99.

       WORKING-STORAGE SECTION.

       01 WS-EOF        PIC X VALUE "N".
       01 WS-AMOUNT     PIC 9(7)V99 VALUE 50000.

       PROCEDURE DIVISION.

       000-MAIN.

           OPEN INPUT IN-FILE
           OPEN OUTPUT OUT-FILE

           PERFORM UNTIL WS-EOF = "Y"

               READ IN-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       PERFORM 200-PROCESS
               END-READ

           END-PERFORM

           CLOSE IN-FILE
           CLOSE OUT-FILE

           STOP RUN.

       200-PROCESS.

           IF IN-ID = 00001
               ADD WS-AMOUNT TO IN-BAL
           END-IF

           MOVE IN-ID   TO OUT-ID
           MOVE IN-NAME TO OUT-NAME
           MOVE IN-BAL  TO OUT-BAL

           WRITE OUT-REC.