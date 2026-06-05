       IDENTIFICATION DIVISION.
       PROGRAM-ID. DASHBOARD-RH.
       AUTHOR. DEV.

      *> ==========================================
      *> TABLEAU DE BORD RH
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

       01 WS-NB-EMPLOYES       PIC X(50) VALUE SPACES.
       01 WS-NB-DEPARTEMENTS   PIC X(50) VALUE SPACES.
       01 WS-NB-POSTES         PIC X(50) VALUE SPACES.
       01 WS-NB-PRESENCES      PIC X(50) VALUE SPACES.
       01 WS-NB-CONGES         PIC X(50) VALUE SPACES.
       01 WS-MASSE-SALARIALE   PIC X(50) VALUE SPACES.

       PROCEDURE DIVISION.

       DEBUT.

      *> ==========================================
      *> NOMBRE EMPLOYES
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE
               "SELECT COUNT(*) FROM employees;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-NB-EMPLOYES
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> NOMBRE DEPARTEMENTS
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE
               "SELECT COUNT(*) FROM departments;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-NB-DEPARTEMENTS
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> NOMBRE POSTES
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE
               "SELECT COUNT(*) FROM positions;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-NB-POSTES
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> PRESENCES
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

           MOVE
               "SELECT COUNT(*) FROM attendance;"
               TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-NB-PRESENCES
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> CONGES EN ATTENTE
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

          MOVE "SELECT COUNT(*) FROM leaves WHERE status='PENDING';"
                TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-NB-CONGES
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> MASSE SALARIALE
      *> ==========================================

           OPEN OUTPUT SQL-FILE.

         MOVE "SELECT IFNULL(SUM(net_salary),0) FROM payroll;"
                TO SQL-RECORD.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END CONTINUE
               NOT AT END
                   MOVE FUNCTION TRIM(RESULT-RECORD)
                       TO WS-MASSE-SALARIALE
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> AFFICHAGE DASHBOARD
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY
           "==========================================".

           DISPLAY
           "          TABLEAU DE BORD RH".

           DISPLAY
           "==========================================".

           DISPLAY
           "Employes            : "
           FUNCTION TRIM(WS-NB-EMPLOYES).

           DISPLAY
           "Departements        : "
           FUNCTION TRIM(WS-NB-DEPARTEMENTS).

           DISPLAY
           "Postes              : "
           FUNCTION TRIM(WS-NB-POSTES).

           DISPLAY
           "Presences           : "
           FUNCTION TRIM(WS-NB-PRESENCES).

           DISPLAY
           "Conges en attente   : "
           FUNCTION TRIM(WS-NB-CONGES).

           DISPLAY
           "Masse salariale     : "
           FUNCTION TRIM(WS-MASSE-SALARIALE)
           " Ar".

           DISPLAY
           "==========================================".

           STOP RUN.