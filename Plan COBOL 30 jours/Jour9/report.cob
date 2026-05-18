       IDENTIFICATION DIVISION.
       PROGRAM-ID. REPORTCLI.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT CLIENT-FILE
               ASSIGN TO "data/clients.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REPORT-FILE
               ASSIGN TO "reports/report.txt"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD CLIENT-FILE.
       01 CLIENT-REC.
          05 CL-ID     PIC 9(5).
          05 CL-NAME   PIC X(20).
          05 CL-CITY   PIC X(15).

       FD REPORT-FILE.
       01 REPORT-LINE  PIC X(80).

       WORKING-STORAGE SECTION.

       01 WS-EOF      PIC X VALUE "N".

       PROCEDURE DIVISION.

       000-MAIN.

           OPEN INPUT CLIENT-FILE
           OPEN OUTPUT REPORT-FILE
           MOVE "=== CLIENT REPORT ===" TO REPORT-LINE
           WRITE REPORT-LINE.

          

           PERFORM UNTIL WS-EOF = "Y"
              
               READ CLIENT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       PERFORM 200-WRITE-REPORT
               END-READ

           END-PERFORM

           CLOSE CLIENT-FILE
           CLOSE REPORT-FILE

           STOP RUN.
  

       200-WRITE-REPORT.

           STRING
               "ID: " CL-ID
               " NAME: " CL-NAME
               " CITY: " CL-CITY
               
               DELIMITED BY SIZE
               INTO REPORT-LINE
           END-STRING

           WRITE REPORT-LINE.