       IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-POSTES.
       AUTHOR. DEV.

      *> ==========================================
      *> LISTE DES POSTES
      *> ==========================================

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT RESULT-FILE
               ASSIGN TO "temp/result.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD           PIC X(300).

       FD RESULT-FILE.
       01 RESULT-RECORD        PIC X(300).

       WORKING-STORAGE SECTION.

       01 WS-COMMANDE          PIC X(300).
       01 WS-FIN               PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> GENERATION DE LA REQUETE SQL
      *> ==========================================

           OPEN OUTPUT SQL-FILE.
           MOVE
               "SELECT position_id, position_name FROM positions;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================================
      *> EXECUTION SQLITE
      *> ==========================================

           STRING
               "sqlite3 -separator ' | ' data/rh.db "
               "< temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.
           

      *> ==========================================
      *> AFFICHAGE RESULTAT
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "         LISTE DES POSTES".
           DISPLAY "====================================".

           OPEN INPUT RESULT-FILE.

           PERFORM UNTIL WS-FIN = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-FIN
                   NOT AT END
                       DISPLAY FUNCTION TRIM(RESULT-RECORD)
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.

           STOP RUN.