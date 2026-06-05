       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXPORT-PAIE.
       AUTHOR. DEV.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT SQL-FILE
               ASSIGN TO "temp/sql.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT RESULT-FILE
               ASSIGN TO "temp/result.tmp"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT CSV-FILE
               ASSIGN TO "exports/paie.csv"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD      PIC X(500).

       FD RESULT-FILE.
       01 RESULT-RECORD   PIC X(500).

       FD CSV-FILE.
       01 CSV-RECORD      PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-COMMANDE PIC X(500).
       01 WS-END      PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

           OPEN OUTPUT SQL-FILE.

           STRING
               "SELECT payroll_id || ',' || "
               "employee_id || ',' || "
               "payroll_month || ',' || "
               "basic_salary || ',' || "
               "bonus || ',' || "
               "deduction || ',' || "
               "net_salary "
               "FROM payroll;"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.
           CLOSE SQL-FILE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.
           OPEN OUTPUT CSV-FILE.

           MOVE
             "ID,EMPLOYE,MOIS,BASE,BONUS,RETENUE,NET"
             TO CSV-RECORD.

           WRITE CSV-RECORD.

           PERFORM UNTIL WS-END = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-END
                   NOT AT END
                       MOVE RESULT-RECORD TO CSV-RECORD
                       WRITE CSV-RECORD
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.
           CLOSE CSV-FILE.

           DISPLAY "[OK] exports/paie.csv genere".

           STOP RUN.