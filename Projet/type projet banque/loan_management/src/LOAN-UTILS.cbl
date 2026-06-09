      *================================================================
      * LOAN-UTILS.CBL - Module utilitaires
      * Gestion Prets Bancaires - Fonctions communes
      *================================================================
       IDENTIFICATION DIVISION.
       PROGRAM-ID. LOAN-UTILS.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-DATE-INPUT           PIC X(10).
       01  WS-YEAR                 PIC 9(4).
       01  WS-MONTH                PIC 9(2).
       01  WS-DAY                  PIC 9(2).
       01  WS-DATE-WORK            PIC X(8).

      *--- Calcul puissance ---
       01  WS-BASE                 PIC S9(12)V9(8) COMP.
       01  WS-EXPONENT             PIC 9(4) COMP.
       01  WS-RESULT               PIC S9(12)V9(8) COMP.
       01  WS-IDX                  PIC 9(4) COMP.

       LINKAGE SECTION.
       01  LK-OPERATION            PIC X(20).
       01  LK-PARAM1               PIC S9(12)V9(8) COMP.
       01  LK-PARAM2               PIC S9(12)V9(8) COMP.
       01  LK-RESULT               PIC S9(12)V9(8) COMP.

       PROCEDURE DIVISION USING LK-OPERATION
                                 LK-PARAM1
                                 LK-PARAM2
                                 LK-RESULT.

       000-MAIN.
           EVALUATE LK-OPERATION
               WHEN "POWER"
                   PERFORM 100-COMPUTE-POWER
               WHEN OTHER
                   MOVE 0 TO LK-RESULT
           END-EVALUATE
           GOBACK.

       100-COMPUTE-POWER.
           MOVE LK-PARAM1 TO WS-BASE
           MOVE LK-PARAM2 TO WS-EXPONENT
           MOVE 1         TO WS-RESULT
           MOVE 0         TO WS-IDX
           PERFORM UNTIL WS-IDX >= WS-EXPONENT
               COMPUTE WS-RESULT = WS-RESULT * WS-BASE
               ADD 1 TO WS-IDX
           END-PERFORM
           MOVE WS-RESULT TO LK-RESULT.
