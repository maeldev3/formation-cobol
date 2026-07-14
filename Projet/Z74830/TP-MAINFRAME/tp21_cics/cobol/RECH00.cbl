      ******************************************************************
      * TP21 - CICS                                                   *
      * PROGRAMME   : RECH00                                          *
      * ROLE        : Squelette de traitement pour l'option 4 - RECH  *
      *               A completer avec EXEC CICS READ FILE(...)       *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. RECH00.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-COMMAREA.
           05  WS-CA-CHOIX         PIC 9(01).

       01  WS-MESSAGE              PIC X(60)
               VALUE 'ECRAN RECHERCHE - A DEVELOPPER (READ FILE...)'.

       PROCEDURE DIVISION.

       000-MAIN.

           MOVE DFHCOMMAREA TO WS-COMMAREA

      *    TODO : SEND MAP('RECHMAP') pour saisir la cle recherchee
      *    TODO : EXEC CICS READ FILE('FICHIER') RIDFLD(cle)
      *           INTO(enregistrement) RESP(WS-RESP)
      *    TODO : SEND MAP('RECHMAP') DATAONLY pour afficher le resultat

           EXEC CICS SEND TEXT
                     FROM(WS-MESSAGE)
                     LENGTH(60)
                     ERASE
                     FREEKB
           END-EXEC.

           EXEC CICS XCTL PROGRAM('MENU00')
                     COMMAREA(WS-COMMAREA)
           END-EXEC.
