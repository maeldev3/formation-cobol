      ******************************************************************
      * TP21 - CICS                                                   *
      * PROGRAMME   : MODI00                                          *
      * ROLE        : Squelette de traitement pour l'option 2 - MODIF *
      *               A completer avec EXEC CICS READ UPDATE / REWRITE*
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MODI00.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-COMMAREA.
           05  WS-CA-CHOIX         PIC 9(01).

       01  WS-MESSAGE              PIC X(60)
               VALUE 'ECRAN MODIF - A DEVELOPPER (READ UPDATE/REWRITE)'.

       PROCEDURE DIVISION.

       000-MAIN.

           MOVE DFHCOMMAREA TO WS-COMMAREA

      *    TODO : SEND MAP('MODIMAP') pour saisir la cle a modifier
      *    TODO : EXEC CICS READ FILE('FICHIER') RIDFLD(cle) UPDATE
      *    TODO : EXEC CICS REWRITE FILE('FICHIER') FROM(enreg-modifie)

           EXEC CICS SEND TEXT
                     FROM(WS-MESSAGE)
                     LENGTH(60)
                     ERASE
                     FREEKB
           END-EXEC.

           EXEC CICS XCTL PROGRAM('MENU00')
                     COMMAREA(WS-COMMAREA)
           END-EXEC.
