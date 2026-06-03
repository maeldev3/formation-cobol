       IDENTIFICATION DIVISION.
       PROGRAM-ID. ERROR-HANDLER.
       AUTHOR. SENIOR-DEV.
       
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ERROR-LOG ASSIGN TO "logs/error.log"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  ERROR-LOG.
       01  ERROR-LOG-REC.
           05 ERR-TIMESTAMP    PIC X(26).
           05 ERR-CODE         PIC 9(04).
           05 ERR-SEVERITY     PIC X(01).
           05 ERR-MODULE       PIC X(30).
           05 ERR-MESSAGE      PIC X(200).
       
       WORKING-STORAGE SECTION.
       01  WS-ERROR-INFO.
           05 WS-ERR-TIMESTAMP PIC X(26).
           05 WS-ERR-CODE      PIC 9(04).
           05 WS-ERR-SEVERITY  PIC X(01).
           05 WS-ERR-MODULE    PIC X(30).
           05 WS-ERR-MESSAGE   PIC X(200).
       
       01  WS-FILE-STATUS      PIC X(02).
       
       LINKAGE SECTION.
       01  LS-ERROR-CODE       PIC 9(04).
       01  LS-ERROR-MESSAGE    PIC X(200).
       01  LS-MODULE-NAME      PIC X(30).
       01  LS-SEVERITY         PIC X(01).
       
       PROCEDURE DIVISION USING LS-ERROR-CODE 
                               LS-ERROR-MESSAGE 
                               LS-MODULE-NAME 
                               LS-SEVERITY.
       
       MAIN-PROCESS.
           MOVE LS-ERROR-CODE TO WS-ERR-CODE
           MOVE LS-ERROR-MESSAGE TO WS-ERR-MESSAGE
           MOVE LS-MODULE-NAME TO WS-ERR-MODULE
           MOVE LS-SEVERITY TO WS-ERR-SEVERITY
           
           PERFORM GET-TIMESTAMP
           PERFORM WRITE-ERROR-LOG
           PERFORM DISPLAY-ERROR-USER
           
           GOBACK.
       
       GET-TIMESTAMP.
           ACCEPT WS-ERR-TIMESTAMP FROM DATE YYYYMMDD
           STRING 
               WS-ERR-TIMESTAMP(1:4) DELIMITED BY SIZE
               '-' DELIMITED BY SIZE
               WS-ERR-TIMESTAMP(5:2) DELIMITED BY SIZE
               '-' DELIMITED BY SIZE
               WS-ERR-TIMESTAMP(7:2) DELIMITED BY SIZE
               ' ' DELIMITED BY SIZE
               WS-ERR-TIMESTAMP(9:2) DELIMITED BY SIZE
               ':' DELIMITED BY SIZE
               WS-ERR-TIMESTAMP(11:2) DELIMITED BY SIZE
               ':' DELIMITED BY SIZE
               WS-ERR-TIMESTAMP(13:2) DELIMITED BY SIZE
           INTO WS-ERR-TIMESTAMP
           END-STRING.
       
       WRITE-ERROR-LOG.
           OPEN EXTEND ERROR-LOG
           IF FILE-STATUS NOT = '00'
               DISPLAY 'ERROR: Cannot open error log'
               EXIT PARAGRAPH
           END-IF
           
           MOVE WS-ERR-TIMESTAMP TO ERR-TIMESTAMP
           MOVE WS-ERR-CODE TO ERR-CODE
           MOVE WS-ERR-SEVERITY TO ERR-SEVERITY
           MOVE WS-ERR-MODULE TO ERR-MODULE
           MOVE WS-ERR-MESSAGE TO ERR-MESSAGE
           
           WRITE ERROR-LOG-REC
           CLOSE ERROR-LOG.
       
       DISPLAY-ERROR-USER.
           DISPLAY 'ERROR ' WS-ERR-CODE ': ' 
                   FUNCTION TRIM(WS-ERR-MESSAGE).
       
       END PROGRAM ERROR-HANDLER.
