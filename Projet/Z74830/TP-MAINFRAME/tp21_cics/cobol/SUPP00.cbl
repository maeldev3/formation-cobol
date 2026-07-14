      ******************************************************************
      * TP21 - CICS                                                   *
      * PROGRAMME   : SUPP00                                          *
      * ROLE        : Squelette de traitement pour l'option 3 - SUPPR *
      *               A completer avec EXEC CICS DELETE FILE(...)     *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. SUPP00.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-COMMAREA.
           05  WS-CA-CHOIX         PIC 9(01).

       01  WS-MESSAGE              PIC X(60)
               VALUE 'ECRAN SUPPRESSION - A DEVELOPPER (DELETE FILE)'.

       PROCEDURE DIVISION.

       000-MAIN.

           MOVE DFHCOMMAREA TO WS-COMMAREA

      *    TODO : SEND MAP('SUPPMAP') pour saisir la cle a supprimer
      *    TODO : EXEC CICS DELETE FILE('FICHIER') RIDFLD(cle)
      *           RESP(WS-RESP)

           EXEC CICS SEND TEXT
                     FROM(WS-MESSAGE)
                     LENGTH(60)
                     ERASE
                     FREEKB
           END-EXEC.

           EXEC CICS XCTL PROGRAM('MENU00')
                     COMMAREA(WS-COMMAREA)
           END-EXEC.
