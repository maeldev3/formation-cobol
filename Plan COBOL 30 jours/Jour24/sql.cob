IDENTIFICATION DIVISION.
PROGRAM-ID. SELECT-COMPTE.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> Zone de communication SQL (Simulée pour cobc)
01  SQLCODE             PIC S9(9) COMP VALUE 0.

*> Variables d'accueil (Host Variables) pour le SQL
01  WS-NUM-COMPTE       PIC X(11) VALUE "FR761234567".
01  WS-TITULAIRE        PIC X(30).
01  WS-SOLDE            PIC S9(7)V99.
01  WS-STATUT           PIC X(10).

PROCEDURE DIVISION.
0000-MAIN.
    DISPLAY "--- BANQUE COBOL : CONSULTATION ---"
    DISPLAY "Lecture du compte : " WS-NUM-COMPTE

    *> En temps normal, le précompilateur traduirait ce bloc :
    *> EXEC SQL
    *>     SELECT TITULAIRE, SOLDE, STATUT
    *>     INTO  :WS-TITULAIRE, :WS-SOLDE, :WS-STATUT
    *>     FROM   COMPTE_BANCAIRE
    *>     WHERE  NUMERO_COMPTE = :WS-NUM-COMPTE
    *> END-EXEC.

    *> --- SIMULATION DU RETOUR DE LA BASE DE DONNEES ---
    *> On simule une lecture réussie (SQLCODE = 0)
    MOVE 0 TO SQLCODE
    MOVE "Olivier Dupont" TO WS-TITULAIRE
    MOVE 1550.75 TO WS-SOLDE
    MOVE "ACTIF" TO WS-STATUT
    *> --------------------------------------------------

    *> Traitement du résultat SQL
    EVALUATE SQLCODE
        WHEN 0
            DISPLAY "Compte trouve avec succes !"
            DISPLAY "Titulaire : " WS-TITULAIRE
            DISPLAY "Solde     : " WS-SOLDE " EUR"
            DISPLAY "Statut    : " WS-STATUT
            
            *> Petite logique métier bancaire
            IF WS-SOLDE < 0
                DISPLAY "ATTENTION : Le compte est à découvert !"
            ELSE
                DISPLAY "Situation financière : Saine."
            END-IF

        WHEN 100
            DISPLAY "ERREUR : Compte " WS-NUM-COMPTE " introuvable."

        WHEN OTHER
            DISPLAY "ERREUR CRITIQUE SQL : " SQLCODE
    END-EVALUATE.

    STOP RUN.