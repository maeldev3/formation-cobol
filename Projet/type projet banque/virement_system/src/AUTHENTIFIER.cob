       IDENTIFICATION DIVISION.
       PROGRAM-ID. AUTHENTIFIER.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SQL-FILE ASSIGN TO "SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
       DATA DIVISION.
       FILE SECTION.
       FD  SQL-FILE.
       01  SQL-RECORD             PIC X(200).
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       WORKING-STORAGE SECTION.
       COPY 'virement_copy.cpy'.
       01  WS-LOGIN-ENTREE        PIC X(20).
       01  WS-PIN-ENTREE          PIC X(4).
       01  WS-COMMANDE            PIC X(500).
       01  WS-CLIENT-ID-VAL       PIC 9(9).

       PROCEDURE DIVISION.
       DEBUT.
           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║                AUTHENTIFICATION                  ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"
           DISPLAY "Login : " WITH NO ADVANCING
           ACCEPT WS-LOGIN-ENTREE
           DISPLAY "PIN (4 chiffres) : " WITH NO ADVANCING
           ACCEPT WS-PIN-ENTREE

      *> Écrire la requête SQL dans un fichier
           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT client_id FROM clients WHERE login = '"
               FUNCTION TRIM(WS-LOGIN-ENTREE)
               "' AND pin = '" WS-PIN-ENTREE "';"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

      *> Exécuter la requête et rediriger la sortie
           STRING
               "sqlite3 data/banque.db < SQL_TMP.SQL > TEMP.DAT"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           MOVE 0 TO WS-CLIENT-ID-VAL.
           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION NUMVAL(TEMP-RECORD) TO WS-CLIENT-ID-VAL
           END-READ.
           CLOSE TEMP-FILE.

           IF WS-CLIENT-ID-VAL > 0
               OPEN OUTPUT SESSION-FILE
               MOVE WS-CLIENT-ID-VAL TO SESSION-RECORD
               WRITE SESSION-RECORD
               CLOSE SESSION-FILE
               DISPLAY " "
               DISPLAY "✓ Authentification réussie. Bienvenue, "
                       FUNCTION TRIM(WS-LOGIN-ENTREE) " !"
           ELSE
               DISPLAY " "
               DISPLAY "✗ Login ou PIN incorrect."
           END-IF.
           STOP RUN.