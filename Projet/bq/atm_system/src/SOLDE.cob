       IDENTIFICATION DIVISION.
       PROGRAM-ID. SOLDE.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).
       WORKING-STORAGE SECTION.
       COPY 'atm_copy.cpy'.
       01  WS-CARTE-IDX           PIC 9(9).  *> variable locale pour éviter conflit
       01  WS-SOLDE-VAL           PIC S9(13)V99.
       01  WS-COMMANDE            PIC X(500).

       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT SESSION-FILE.
           READ SESSION-FILE INTO SESSION-RECORD
               AT END 
                   DISPLAY "Aucune session active. Veuillez vous authentifier."
                   STOP RUN
           END-READ.
           CLOSE SESSION-FILE.
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CARTE-IDX.

           STRING
               "sqlite3 data/atm.db 'SELECT solde FROM comptes "
               "WHERE carte_id = " WS-CARTE-IDX ";' > TEMP.DAT"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END MOVE 0 TO WS-SOLDE-VAL
               NOT AT END MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-SOLDE-VAL
           END-READ.
           CLOSE TEMP-FILE.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║                  VOTRE SOLDE                     ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "  Solde actuel : " WS-SOLDE-VAL " EUR"
           DISPLAY " "
           STOP RUN.