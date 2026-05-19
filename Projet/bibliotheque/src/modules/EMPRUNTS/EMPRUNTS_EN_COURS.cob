       IDENTIFICATION DIVISION.
       PROGRAM-ID. EMPRUNTS-EN-COURS.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-COMPTEUR       PIC 99 VALUE 3.
       
       PROCEDURE DIVISION.
           DISPLAY " "
           DISPLAY "=== EMPRUNTS EN COURS ==="
           DISPLAY "ID     ADHERENT     LIVRE                    DATE EMPRUNT"
           DISPLAY "---------------------------------------------------------"
           DISPLAY "E00001 A00001       Le Petit Prince          2025-01-10"
           DISPLAY "E00002 A00002       1984                     2025-01-15"
           DISPLAY "E00003 A00001       Les Miserables           2025-01-20"
           DISPLAY "---------------------------------------------------------"
           DISPLAY "TOTAL EMPRUNTS: " WS-COMPTEUR
           
           STOP RUN.
