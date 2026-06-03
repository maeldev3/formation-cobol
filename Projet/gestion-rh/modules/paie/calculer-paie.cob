       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCULER-PAIE.
       AUTHOR. DEV.

      *> ==========================================
      *> CALCUL DE PAIE
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
       01 SQL-RECORD              PIC X(500).

       FD RESULT-FILE.
       01 RESULT-RECORD           PIC X(500).

       WORKING-STORAGE SECTION.

       01 WS-EMPLOYEE-ID          PIC 9(9).
       01 WS-MOIS                 PIC X(10).

       01 WS-SALAIRE-BASE         PIC 9(9)V99 VALUE 0.
       01 WS-PRIME                PIC 9(9)V99 VALUE 0.
       01 WS-RETENUE              PIC 9(9)V99 VALUE 0.
       01 WS-SALAIRE-NET          PIC 9(9)V99 VALUE 0.

       01 WS-COMMANDE             PIC X(500).
       
      *> Variables pour conversion
       01 WS-EMPLOYEE-ID-ED       PIC Z(9)9.
       01 WS-PRIME-ED             PIC Z(9)9.99.
       01 WS-RETENUE-ED           PIC Z(9)9.99.
       01 WS-SALAIRE-NET-ED       PIC Z(9)9.99.

       PROCEDURE DIVISION.

       DEBUT.

           DISPLAY SPACE.
           DISPLAY "====================================".
           DISPLAY "         CALCUL DE PAIE".
           DISPLAY "====================================".

      *> ==========================================
      *> SAISIE
      *> ==========================================

           DISPLAY "ID Employe : " WITH NO ADVANCING.
           ACCEPT WS-EMPLOYEE-ID.

           DISPLAY "Mois (YYYY-MM) : " WITH NO ADVANCING.
           ACCEPT WS-MOIS.

           DISPLAY "Prime : " WITH NO ADVANCING.
           ACCEPT WS-PRIME.

           DISPLAY "Retenue : " WITH NO ADVANCING.
           ACCEPT WS-RETENUE.

      *> ==========================================
      *> RECUPERATION SALAIRE DE BASE
      *> ==========================================

      *> Convertir l'ID en format texte
           MOVE WS-EMPLOYEE-ID TO WS-EMPLOYEE-ID-ED.
           
           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "SELECT p.base_salary FROM employees e, positions p "
               "WHERE e.position_id = p.position_id "
               "AND e.employee_id = "
               FUNCTION TRIM(WS-EMPLOYEE-ID-ED)
               ";"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp > temp/result.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================================
      *> LECTURE SALAIRE
      *> ==========================================

           OPEN INPUT RESULT-FILE.

           READ RESULT-FILE
               AT END
                   DISPLAY "Employe introuvable."
                   CLOSE RESULT-FILE
                   STOP RUN
               NOT AT END
                   MOVE FUNCTION NUMVAL(RESULT-RECORD)
                       TO WS-SALAIRE-BASE
           END-READ.

           CLOSE RESULT-FILE.

      *> ==========================================
      *> CALCUL
      *> ==========================================

           COMPUTE WS-SALAIRE-NET =
               WS-SALAIRE-BASE
               + WS-PRIME
               - WS-RETENUE.

           DISPLAY SPACE.
           DISPLAY "Salaire Base : " WS-SALAIRE-BASE.
           DISPLAY "Prime        : " WS-PRIME.
           DISPLAY "Retenue      : " WS-RETENUE.
           DISPLAY "Salaire Net  : " WS-SALAIRE-NET.

      *> ==========================================
      *> INSERTION PAYROLL
      *> ==========================================

      *> Convertir les valeurs pour l'INSERT
           MOVE WS-PRIME TO WS-PRIME-ED.
           MOVE WS-RETENUE TO WS-RETENUE-ED.
           MOVE WS-SALAIRE-NET TO WS-SALAIRE-NET-ED.

           OPEN OUTPUT SQL-FILE.

           MOVE SPACES TO SQL-RECORD.

           STRING
               "INSERT INTO payroll (employee_id, payroll_month, "
               "basic_salary, bonus, deduction, net_salary) "
               "VALUES ("
               FUNCTION TRIM(WS-EMPLOYEE-ID-ED)
               ",'"
               FUNCTION TRIM(WS-MOIS)
               "',"
               FUNCTION TRIM(WS-SALAIRE-BASE)
               ","
               FUNCTION TRIM(WS-PRIME-ED)
               ","
               FUNCTION TRIM(WS-RETENUE-ED)
               ","
               FUNCTION TRIM(WS-SALAIRE-NET-ED)
               ");"
               DELIMITED BY SIZE
               INTO SQL-RECORD
           END-STRING.

           WRITE SQL-RECORD.

           CLOSE SQL-FILE.

           MOVE SPACES TO WS-COMMANDE.

           STRING
               "sqlite3 data/rh.db < temp/sql.tmp"
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING.

           CALL "SYSTEM" USING WS-COMMANDE.

      *> ==========================================
      *> FIN
      *> ==========================================

           DISPLAY SPACE.
           DISPLAY "[OK] PAIE ENREGISTREE.".

           STOP RUN.