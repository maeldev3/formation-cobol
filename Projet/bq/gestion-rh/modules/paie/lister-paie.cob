      *IDENTIFICATION DIVISION.
      *PROGRAM-ID. LISTER-PAIE.
      *AUTHOR. DEV.
      *
      **> ==========================================
      **> LISTE DES EMPLOYES AVEC SALAIRE
      **> ==========================================
      *
      *ENVIRONMENT DIVISION.
      *INPUT-OUTPUT SECTION.
      *FILE-CONTROL.
      *
      *    SELECT SQL-FILE
      *        ASSIGN TO "temp/sql.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      *    SELECT RESULT-FILE
      *        ASSIGN TO "temp/result.tmp"
      *        ORGANIZATION IS LINE SEQUENTIAL.
      *
      *DATA DIVISION.
      *
      *FILE SECTION.
      *
      *FD SQL-FILE.
      *01 SQL-RECORD           PIC X(500).
      *
      *FD RESULT-FILE.
      *01 RESULT-RECORD        PIC X(500).
      *
      *WORKING-STORAGE SECTION.
      *
      *01 WS-COMMANDE          PIC X(500).
      *01 WS-END               PIC X VALUE "N".
      *
      *PROCEDURE DIVISION.
      *
      *DEBUT.
      *
      **> ==========================
      **> CONSTRUCTION DE LA REQUÊTE SQL
      **> ==========================
      *
      *    OPEN OUTPUT SQL-FILE.
      *
      **> Utilisation de STRING pour construire la requête SQL
      *    STRING
      *        "SELECT e.employee_id || ' | ' || "
      *        "e.first_name || ' ' || e.last_name || ' | ' || "
      *        "p.position_name || ' | ' || "
      *        "p.base_salary "
      *        "FROM employees e, positions p "
      *        "WHERE e.position_id = p.position_id;"
      *        DELIMITED BY SIZE
      *        INTO SQL-RECORD
      *    END-STRING.
      *
      *    WRITE SQL-RECORD.
      *
      *    CLOSE SQL-FILE.
      *
      **> ==========================
      **> EXÉCUTION SQLITE
      **> ==========================
      *
      *    STRING
      *        "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
      *        DELIMITED BY SIZE
      *        INTO WS-COMMANDE
      *    END-STRING.
      *
      *    CALL "SYSTEM" USING WS-COMMANDE.
      *
      **> ==========================
      **> AFFICHAGE DU RÉSULTAT
      **> ==========================
      *
      *    DISPLAY SPACE.
      *    DISPLAY "====================================".
      *    DISPLAY "            PAIE EMPLOYES".
      *    DISPLAY "====================================".
      *
      *    OPEN INPUT RESULT-FILE.
      *
      *    MOVE "N" TO WS-END.
      *
      *    PERFORM UNTIL WS-END = "Y"
      *
      *        READ RESULT-FILE
      *            AT END
      *                MOVE "Y" TO WS-END
      *            NOT AT END
      *                DISPLAY FUNCTION TRIM(RESULT-RECORD)
      *        END-READ
      *
      *    END-PERFORM.
      *
      *    CLOSE RESULT-FILE.
      *
      *    STOP RUN.


             IDENTIFICATION DIVISION.
       PROGRAM-ID. LISTER-PAIE.
       AUTHOR. DEV.

      *> ==========================================
      *> LISTE DES PAIES
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
       01 SQL-RECORD           PIC X(500).

       FD RESULT-FILE.
       01 RESULT-RECORD        PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-COMMANDE          PIC X(500).
       01 WS-END               PIC X VALUE "N".

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> CREATION DE LA REQUETE SQL
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "SELECT "
               "e.employee_id || ' | ' || "
               "e.first_name || ' ' || e.last_name || ' | ' || "
               "p.payroll_month || ' | ' || "
               "p.basic_salary || ' | ' || "
               "p.bonus || ' | ' || "
               "p.deduction || ' | ' || "
               "p.net_salary "
               "FROM payroll p, employees e "
               "WHERE p.employee_id = e.employee_id;"
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
      *> AFFICHAGE
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY
           "========================================================".

           DISPLAY
           "                  LISTE DES PAIES".

           DISPLAY
           "========================================================".

           DISPLAY
           "ID | EMPLOYE | MOIS | BASE | PRIME | RETENUE | NET".

           DISPLAY
           "--------------------------------------------------------".

           OPEN INPUT RESULT-FILE.

           MOVE "N" TO WS-END.

           PERFORM UNTIL WS-END = "Y"

               READ RESULT-FILE
                   AT END
                       MOVE "Y" TO WS-END
                   NOT AT END
                       DISPLAY FUNCTION TRIM(RESULT-RECORD)
               END-READ

           END-PERFORM.

           CLOSE RESULT-FILE.

           DISPLAY SPACE.
           DISPLAY "[OK] LISTE TERMINEE".

           STOP RUN.