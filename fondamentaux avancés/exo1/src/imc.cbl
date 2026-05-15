       IDENTIFICATION DIVISION.
       PROGRAM-ID. IMC.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

           COPY "imc-const.cpy".
           COPY "imc-data.cpy".

       PROCEDURE DIVISION.

           PERFORM INITIALISATION
           PERFORM SAISIE-DONNEES
           PERFORM CALCUL-IMC
           PERFORM AFFICHAGE-RESULTAT

           STOP RUN.

           COPY "imc-proc.cpy".