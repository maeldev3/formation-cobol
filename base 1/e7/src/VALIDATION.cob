       IDENTIFICATION DIVISION.
       PROGRAM-ID. VALIDATION.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-RETOUR        PIC 9.
       
       LINKAGE SECTION.
       01 LS-AGE          PIC 9(3).
       01 LS-VALIDE       PIC 9.
       
       PROCEDURE DIVISION USING LS-AGE, LS-VALIDE.
           IF LS-AGE >= 18
               MOVE 1 TO LS-VALIDE
           ELSE
               MOVE 0 TO LS-VALIDE
           END-IF.
           
           GOBACK.