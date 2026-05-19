IDENTIFICATION DIVISION.
PROGRAM-ID. SQLDEMO.

DATA DIVISION.
WORKING-STORAGE SECTION.
*> En format libre, les commentaires commencent par *>
01  SQLCODE             PIC S9(9) COMP.

01  WS-EMP-ID           PIC 9(04) VALUE 1234.
01  WS-EMP-NOM          PIC X(30) VALUE "Jean Dupont".
01  WS-EMP-SALAIRE      PIC 9(05)V99 VALUE 2500.00.

PROCEDURE DIVISION.
0000-MAIN.
    DISPLAY "Simulation de recherche de l'employe..."

    MOVE 0 TO SQLCODE

    EVALUATE SQLCODE
        WHEN 0
            DISPLAY "Employe trouve !"
            DISPLAY "Nom : " WS-EMP-NOM
            DISPLAY "Salaire : " WS-EMP-SALAIRE
        WHEN 100
            DISPLAY "Erreur : Employe introuvable."
        WHEN OTHER
            DISPLAY "Erreur SQL critique : " SQLCODE
    END-EVALUATE.

    STOP RUN.