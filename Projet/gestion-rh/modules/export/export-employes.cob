       IDENTIFICATION DIVISION.
       PROGRAM-ID. EXPORT-EMPLOYES.
       AUTHOR. DEV.

      *> ==========================================
      *> EXPORT DES EMPLOYES AU FORMAT CSV
      *> Fichier généré :
      *> exports/employes.csv
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

           SELECT CSV-FILE
               ASSIGN TO "exports/employes.csv"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD SQL-FILE.
       01 SQL-RECORD          PIC X(500).

       FD RESULT-FILE.
       01 RESULT-RECORD       PIC X(500).

       FD CSV-FILE.
       01 CSV-RECORD          PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-COMMANDE         PIC X(500).
       01 WS-END              PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> CONSTRUCTION DE LA REQUETE SQL
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "SELECT e.employee_id || ',' || "
               "e.first_name || ',' || "
               "e.last_name || ',' || "
               "d.department_name || ',' || "
               "p.position_name "
               "FROM employees e, departments d, positions p "
               "WHERE e.department_id = d.department_id "
               "AND e.position_id = p.position_id;"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

      *> ==========================================
      *> EXECUTION SQLITE
      *> ==========================================

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================================
      *> CREATION DU FICHIER CSV
      *> ==========================================

           MOVE "N" TO WS-END.

           OPEN INPUT RESULT-FILE.
           OPEN OUTPUT CSV-FILE.

      *> Entête CSV

           MOVE SPACES TO CSV-RECORD.

           MOVE
               "ID,PRENOM,NOM,DEPARTEMENT,POSTE"
               TO CSV-RECORD.

           WRITE CSV-RECORD.

      *> Copie des données

           PERFORM UNTIL WS-END = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-END
                   NOT AT END
                       MOVE SPACES TO CSV-RECORD
                       MOVE FUNCTION TRIM(RESULT-RECORD)
                           TO CSV-RECORD
                       WRITE CSV-RECORD
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.
           CLOSE CSV-FILE.

      *> ==========================================
      *> FIN
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "[OK] exports/employes.csv genere".

           STOP RUN.