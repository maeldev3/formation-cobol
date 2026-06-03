       IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDATOR.
       AUTHOR. SENIOR-DEV.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-VALIDATION-RESULT.
           05 WS-IS-VALID      PIC X(01) VALUE 'N'.
           05 WS-ERROR-DESC    PIC X(100).
       
       01  WS-TEMP-VARS.
           05 WS-INDEX         PIC 9(03).
           05 WS-CHAR          PIC X(01).
           05 WS-NUMERIC-CHECK PIC 9(12)V99.
       
       LINKAGE SECTION.
       01  LS-CARD-NUMBER      PIC X(19).
       01  LS-PIN-CODE         PIC X(04).
       01  LS-AMOUNT           PIC S9(12)V99.
       01  LS-VALID-FLAG       PIC X(01).
       01  LS-ERROR-MESSAGE    PIC X(100).
       
       PROCEDURE DIVISION USING LS-CARD-NUMBER 
                               LS-PIN-CODE 
                               LS-AMOUNT 
                               LS-VALID-FLAG 
                               LS-ERROR-MESSAGE.
       
       MAIN-PROCESS.
           MOVE 'Y' TO LS-VALID-FLAG
           MOVE SPACES TO LS-ERROR-MESSAGE
           
           PERFORM VALIDATE-CARD-NUMBER
           PERFORM VALIDATE-PIN
           PERFORM VALIDATE-AMOUNT
           
           GOBACK.
       
       VALIDATE-CARD-NUMBER.
           IF LS-CARD-NUMBER = SPACES OR LOW-VALUES
               MOVE 'N' TO LS-VALID-FLAG
               MOVE 'Card number cannot be empty' 
                 TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           PERFORM VARYING WS-INDEX FROM 1 BY 1
                     UNTIL WS-INDEX > 19
               MOVE LS-CARD-NUMBER(WS-INDEX:1) TO WS-CHAR
               IF WS-CHAR NOT = ' ' AND 
                  (WS-CHAR < '0' OR WS-CHAR > '9')
                  IF WS-CHAR NOT = ' '
                      MOVE 'N' TO LS-VALID-FLAG
                      MOVE 'Invalid card number format' 
                        TO LS-ERROR-MESSAGE
                      EXIT PERFORM
                  END-IF
               END-IF
           END-PERFORM.
       
       VALIDATE-PIN.
           IF LS-PIN-CODE = SPACES OR LOW-VALUES
               MOVE 'N' TO LS-VALID-FLAG
               MOVE 'PIN code cannot be empty' 
                 TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           PERFORM VARYING WS-INDEX FROM 1 BY 1
                     UNTIL WS-INDEX > 4
               MOVE LS-PIN-CODE(WS-INDEX:1) TO WS-CHAR
               IF WS-CHAR < '0' OR WS-CHAR > '9'
                   MOVE 'N' TO LS-VALID-FLAG
                   MOVE 'PIN must contain only digits' 
                     TO LS-ERROR-MESSAGE
                   EXIT PERFORM
               END-IF
           END-PERFORM.
       
       VALIDATE-AMOUNT.
           IF LS-AMOUNT <= 0
               MOVE 'N' TO LS-VALID-FLAG
               MOVE 'Amount must be greater than zero' 
                 TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           
           IF LS-AMOUNT > 99999999.99
               MOVE 'N' TO LS-VALID-FLAG
               MOVE 'Amount exceeds maximum limit' 
                 TO LS-ERROR-MESSAGE
           END-IF.
       
       END PROGRAM VALIDATOR.
