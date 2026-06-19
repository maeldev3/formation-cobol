       IDENTIFICATION DIVISION.
       PROGRAM-ID. DB2CURSOR.
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
       01 WS-EMPNO    PIC X(6).
       01 WS-LASTNAME PIC X(20).
       01 WS-FIRSTNME PIC X(12).
       01 WS-END-FLAG PIC X(1) VALUE 'N'.
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           EXEC SQL
               DECLARE EMP-CURSOR CURSOR FOR
               SELECT EMPNO, LASTNAME, FIRSTNME
               FROM Z74830.EMPLOYEE
               ORDER BY EMPNO
           END-EXEC
           EXEC SQL
               OPEN EMP-CURSOR
           END-EXEC
           PERFORM UNTIL WS-END-FLAG = 'Y'
               EXEC SQL
                   FETCH EMP-CURSOR
                   INTO :WS-EMPNO, :WS-LASTNAME, :WS-FIRSTNME
               END-EXEC
               IF SQLCODE = 0
                   DISPLAY 'EMPNO: ' WS-EMPNO
                          ' NOM: ' WS-LASTNAME
                          ' PRENOM: ' WS-FIRSTNME
               ELSE
                   MOVE 'Y' TO WS-END-FLAG
               END-IF
           END-PERFORM
           EXEC SQL
               CLOSE EMP-CURSOR
           END-EXEC
           GOBACK.
