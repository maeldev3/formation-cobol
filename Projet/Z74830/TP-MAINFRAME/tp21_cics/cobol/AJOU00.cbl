      ******************************************************************
      * TP21 - CICS                                                   *
      * PROGRAMME   : AJOU00                                          *
      * ROLE        : Squelette de traitement pour l'option 1 - AJOUT *
      *               A completer avec EXEC CICS WRITE FILE(...)      *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. AJOU00.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-COMMAREA.
           05  WS-CA-CHOIX         PIC 9(01).

       01  WS-MESSAGE              PIC X(60)
               VALUE 'ECRAN AJOUT - A DEVELOPPER (EXEC CICS WRITE...)'.

       PROCEDURE DIVISION.

       000-MAIN.

           MOVE DFHCOMMAREA TO WS-COMMAREA

      *    TODO : SEND MAP('AJOUMAP') pour saisir les donnees
      *    TODO : RECEIVE MAP puis EXEC CICS WRITE FILE('FICHIER')
      *           FROM(enregistrement) RIDFLD(cle) RESP(WS-RESP)

           EXEC CICS SEND TEXT
                     FROM(WS-MESSAGE)
                     LENGTH(60)
                     ERASE
                     FREEKB
           END-EXEC.

           EXEC CICS XCTL PROGRAM('MENU00')
                     COMMAREA(WS-COMMAREA)
           END-EXEC.
