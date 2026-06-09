       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCUL-INTERETS.
       AUTHOR. SENIOR-COBOL-DEV.
      *> Calcule et applique les intérêts annuels sur le compte épargne

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT SESSION-FILE ASSIGN TO "SESSION.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT SQL-FILE ASSIGN TO "/tmp/SQL_TMP.SQL"
               ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TEMP-FILE ASSIGN TO "/tmp/TEMP.DAT"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  SESSION-FILE.
       01  SESSION-RECORD         PIC X(20).
       FD  SQL-FILE.
       01  SQL-RECORD             PIC X(300).
       FD  TEMP-FILE.
       01  TEMP-RECORD            PIC X(200).

       WORKING-STORAGE SECTION.
       COPY 'epargne_copy.cpy'.
       01  WS-CLIENT-IDX          PIC 9(9).
       01  WS-SOLDE-ACT           PIC S9(13)V99.
       01  WS-TAUX                PIC 9(3)V99.
       01  WS-INTERETS-CALCULES   PIC S9(13)V99.
       01  WS-COMMANDE            PIC X(500).

       PROCEDURE DIVISION.
       DEBUT.
           OPEN INPUT SESSION-FILE.
           READ SESSION-FILE INTO SESSION-RECORD
               AT END 
                   DISPLAY "Session invalide. Authentifiez-vous."
                   STOP RUN
           END-READ.
           CLOSE SESSION-FILE.
           MOVE FUNCTION NUMVAL(SESSION-RECORD) TO WS-CLIENT-IDX.

           DISPLAY " "
           DISPLAY "╔══════════════════════════════════════════════════╗"
           DISPLAY "║              CALCUL DES INTÉRÊTS                 ║"
           DISPLAY "╚══════════════════════════════════════════════════╝"

      *> Récupérer le solde et le taux actuel
           OPEN OUTPUT SQL-FILE.
           STRING
               "SELECT solde, taux_interet FROM comptes_epargne "
               "WHERE client_id = " WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /tmp/TEMP.DAT 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           OPEN INPUT TEMP-FILE.
           READ TEMP-FILE INTO TEMP-RECORD
               AT END 
                   DISPLAY "Erreur lecture données compte."
                   STOP RUN
               NOT AT END
                   UNSTRING TEMP-RECORD DELIMITED BY "|"
                       INTO WS-SOLDE-ACT, WS-TAUX
           END-READ.
           CLOSE TEMP-FILE.

      *> Calcul des intérêts : solde * taux / 100
           COMPUTE WS-INTERETS-CALCULES = 
               WS-SOLDE-ACT * WS-TAUX / 100.

           DISPLAY "Solde actuel  : " WS-SOLDE-ACT " EUR"
           DISPLAY "Taux annuel   : " WS-TAUX " %"
           DISPLAY "Intérêts bruts: " WS-INTERETS-CALCULES " EUR"

      *> Appliquer les intérêts (créditer le compte)
           OPEN OUTPUT SQL-FILE.
           STRING
               "UPDATE comptes_epargne SET solde = solde + "
               WS-INTERETS-CALCULES " WHERE client_id = " WS-CLIENT-IDX ";"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /dev/null 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

      *> Enregistrer la transaction des intérêts
           OPEN OUTPUT SQL-FILE.
           STRING
               "INSERT INTO transactions (client_id, type_trans, montant) "
               "VALUES (" WS-CLIENT-IDX ", 'INTERETS', "
               WS-INTERETS-CALCULES ");"
               DELIMITED BY SIZE INTO SQL-RECORD
           END-STRING.
           WRITE SQL-RECORD.
           CLOSE SQL-FILE.
           STRING "sqlite3 data/epargne.db < /tmp/SQL_TMP.SQL > /dev/null 2>&1"
               DELIMITED BY SIZE INTO WS-COMMANDE
           END-STRING.
           CALL "SYSTEM" USING WS-COMMANDE.

           COMPUTE WS-SOLDE-ACT = WS-SOLDE-ACT + WS-INTERETS-CALCULES
           DISPLAY " "
           DISPLAY "✓ Intérêts ajoutés."
           DISPLAY "  Nouveau solde : " WS-SOLDE-ACT " EUR"
           STOP RUN.
