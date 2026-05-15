       IDENTIFICATION DIVISION.
       PROGRAM-ID. NOTE.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-NOTE         PIC 99.
       01 WS-APPRECIATION PIC X(20).

       PROCEDURE DIVISION.
           DISPLAY "ENTREZ VOTRE NOTE (0-20) : "
           ACCEPT WS-NOTE

           IF WS-NOTE >= 10
               MOVE "ADMIS" TO WS-APPRECIATION
               DISPLAY "FELICITATIONS ! VOUS ETES " WS-APPRECIATION

               IF WS-NOTE >= 16
                   DISPLAY "MENTION TRES BIEN"
               ELSE
                   IF WS-NOTE >= 14
                       DISPLAY "MENTION BIEN"
                   ELSE
                       IF WS-NOTE >= 12
                           DISPLAY "MENTION ASSEZ BIEN"
                       END-IF
                   END-IF
               END-IF

           ELSE
               MOVE "NON ADMIS" TO WS-APPRECIATION
               DISPLAY "DESOLE, VOUS ETES " WS-APPRECIATION
           END-IF

           STOP RUN.