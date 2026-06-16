       IDENTIFICATION DIVISION.
       PROGRAM-ID. READCLI.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENTS-FILE
               ASSIGN TO CLIENTS
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD CLIENTS-FILE
           RECORDING MODE F
           LABEL RECORDS STANDARD.
       01 CLIENTS-RECORD.
           05 CLIENT-NO      PIC X(10).
           05 CLIENT-NAME    PIC X(20).
           05 CLIENT-FNAME   PIC X(20).
           05 CLIENT-BALANCE PIC 9(7)V99.
       WORKING-STORAGE SECTION.
       01 WS-FILE-STATUS     PIC X(02) VALUE '00'.
           88 WS-FS-OK       VALUE '00'.
           88 WS-FS-EOF      VALUE '10'.
       01 WS-EOF             PIC X VALUE 'N'.
           88 WS-END-OF-FILE VALUE 'Y'.
       PROCEDURE DIVISION.
       MAIN.
           PERFORM INITIALIZE
           PERFORM OPEN-FILE
           IF WS-FS-OK
               PERFORM READ-FIRST
               IF WS-FS-OK
                   PERFORM CLOSE-FILE
                   MOVE 0 TO RETURN-CODE
               ELSE
                   PERFORM CLOSE-FILE
                   MOVE 4 TO RETURN-CODE
               END-IF
           ELSE
               MOVE 4 TO RETURN-CODE
           END-IF
           GOBACK.
       INITIALIZE.
           MOVE 'N' TO WS-EOF.
       OPEN-FILE.
           OPEN INPUT CLIENTS-FILE.
       READ-FIRST.
           READ CLIENTS-FILE.
       CLOSE-FILE.
           CLOSE CLIENTS-FILE.
