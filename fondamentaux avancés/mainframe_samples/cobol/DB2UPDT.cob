       IDENTIFICATION DIVISION.
       PROGRAM-ID. DB2UPDT.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INFILE ASSIGN TO INFILE.
       DATA DIVISION.
       FILE SECTION.
       FD INFILE RECORDING MODE F.
       01 IN-REC PIC X(80).
       WORKING-STORAGE SECTION.
       EXEC SQL INCLUDE SQLCA END-EXEC.
       01 WS-KEY   PIC X(10).
       01 WS-VALUE PIC X(70).
       01 WS-EOF   PIC X(1) VALUE 'N'.
       PROCEDURE DIVISION.
           OPEN INPUT INFILE
           PERFORM UNTIL WS-EOF = 'Y'
               READ INFILE INTO IN-REC
                 AT END MOVE 'Y' TO WS-EOF
                 NOT AT END
                   MOVE IN-REC(1:10) TO WS-KEY
                   MOVE IN-REC(11:70) TO WS-VALUE
                   EXEC SQL
                       UPDATE Z74830.MYTABLE
                       SET COLUMN1 = :WS-VALUE
                       WHERE KEYCOL = :WS-KEY
                   END-EXEC
                   IF SQLCODE NOT = 0
                       DISPLAY 'ERREUR MISE A JOUR, SQLCODE='
                               SQLCODE
                   END-IF
               END-READ
           END-PERFORM
           CLOSE INFILE
           GOBACK.
