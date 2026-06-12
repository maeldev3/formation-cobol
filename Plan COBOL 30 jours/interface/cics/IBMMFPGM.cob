       IDENTIFICATION DIVISION.
       PROGRAM-ID. IBMMFPGM.
       
       DATA DIVISION.
       FILE SECTION.
       
       WORKING-STORAGE SECTION.
       01 WS-DISP-MESSAGE PIC X(40).
       01 WS-DISP-LENGTH  PIC S9(4) COMP.
       
       PROCEDURE DIVISION.
       0000-MAIN-PARA.
           MOVE 'WELCOME TO IBMMAINFRAMER COMMUNITY' TO WS-DISP-MESSAGE
           MOVE '+34' TO WS-DISP-LENGTH
       
             EXEC CICS SEND TEXT
             FROM (WS-MESSAGE)
             LENGHT(WS-LENGTH)
               END-EXEC
       
             EXEC CICS
           RETURN
           END-EXEC.