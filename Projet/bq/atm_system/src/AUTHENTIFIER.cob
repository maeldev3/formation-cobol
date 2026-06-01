       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTHENTIFIER.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       WORKING-STORAGE SECTION.
       COPY 'atm_copy.cpy'.
       01  WS-CARTE-NUM           PIC X(16).
       01  WS-PIN-ENTREE          PIC X(4).
       01  WS-COMMANDE            PIC X(500).
       01  WS-CARTE-ID-VAL        PIC 9(9).
       01  WS-RETOUR              PIC 9(3).
       01  WS-EOF                 PIC X.

       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║                AUTHENTIFICATION                  ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Numero de carte (16 chiffres) : " WITH NO ADVANCING
           ACCEPT WS-CARTE-NUM
           DISPLAY "Code PIN (4 chiffres) : " WITH NO ADVANCING
           ACCEPT WS-PIN-ENTREE

      *> Vérifier dans la base
           STRING
               "sqlite3 data/atm.db 'SELECT carte_id FROM cartes "
               "WHERE numero_carte = '" WS-CARTE-NUM "' AND pin = '" 
               WS-PIN-ENTREE "' AND bloquee = 0;' > TEMP.DAT"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE RETURNING WS-RETOUR.

           MOVE 0 TO WS-CARTE-ID-VAL.
           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END MOVE 'Y' TO WS-EOF
               NOT AT END
                   MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-CARTE-ID-VAL
           END-READ.
           CLOSE TEMP-FILE.

           IF WS-CARTE-ID-VAL > 0
               OPEN OUTPUT SESSION-FILE
               MOVE WS-CARTE-ID-VAL TO SESSION-RECORD
               WRITE SESSION-RECORD
               CLOSE SESSION-FILE
               DISPLAY " "
               DISPLAY "✓ Authentification reussie. Bienvenue !"
           ELSE
               DISPLAY " "
               DISPLAY "✗ Carte ou PIN incorrect, ou carte bloquee."
           END-IF.
           STOP RUN.