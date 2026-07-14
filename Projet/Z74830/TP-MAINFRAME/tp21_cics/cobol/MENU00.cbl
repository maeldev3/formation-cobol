      ******************************************************************
      * TP21 - CICS                                                   *
      * PROGRAMME   : MENU00                                          *
      * TRANSACTION : MENU                                            *
      * ROLE        : Affiche l'ecran menu et aiguille vers le bon    *
      *               programme (Ajout / Modif / Suppr / Recherche)   *
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. MENU00.
       AUTHOR. TP21.

       ENVIRONMENT DIVISION.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-VARIABLES.
           05  WS-CHOIX-NUM        PIC 9(01).
           05  WS-MESSAGE          PIC X(79) VALUE SPACES.
           05  WS-PGM-CIBLE        PIC X(08).

       01  WS-COMMAREA.
           05  WS-CA-CHOIX         PIC 9(01).

      * Copie de la carte symbolique generee a partir du mapset BMS
       COPY MENUMAP.

      * Zone standard pour recuperer la reponse d'une commande CICS
       01  WS-RESP                 PIC S9(8) COMP.

       PROCEDURE DIVISION.

       000-MAIN.

           IF EIBCALEN = 0
               PERFORM 100-INIT-ECRAN
           ELSE
               MOVE DFHCOMMAREA TO WS-COMMAREA
               PERFORM 200-RECEVOIR-CHOIX
           END-IF.

           EXEC CICS RETURN
               TRANSID('MENU')
               COMMAREA(WS-COMMAREA)
           END-EXEC.

       100-INIT-ECRAN.

           MOVE SPACES         TO MENUMAPO
           MOVE -1              TO CHOIXL OF MENUMAPO
           MOVE FUNCTION CURRENT-DATE(1:8) TO DATEO OF MENUMAPO

           EXEC CICS SEND MAP('MENUMAP')
                     MAPSET('MENUSET')
                     ERASE
                     FREEKB
           END-EXEC.

       200-RECEVOIR-CHOIX.

           EXEC CICS HANDLE CONDITION
               MAPFAIL(300-ERREUR-SAISIE)
           END-EXEC.

           EXEC CICS RECEIVE MAP('MENUMAP')
                     MAPSET('MENUSET')
                     INTO(MENUMAPI)
                     RESP(WS-RESP)
           END-EXEC.

           EVALUATE EIBAID
               WHEN DFHPF3
                   PERFORM 900-FIN-TRANSACTION
               WHEN DFHENTER
                   MOVE CHOIXI OF MENUMAPI TO WS-CHOIX-NUM
                   PERFORM 400-AIGUILLAGE
               WHEN OTHER
                   MOVE 'TOUCHE NON AUTORISEE - UTILISEZ ENTER OU PF3'
                        TO WS-MESSAGE
                   PERFORM 500-RENVOI-MESSAGE
           END-EVALUATE.

       300-ERREUR-SAISIE.

           MOVE 'VEUILLEZ SAISIR UN CHOIX VALIDE (0 A 4)'
                TO WS-MESSAGE
           PERFORM 500-RENVOI-MESSAGE.

       400-AIGUILLAGE.

           EVALUATE WS-CHOIX-NUM
               WHEN 0
                   PERFORM 900-FIN-TRANSACTION
               WHEN 1
                   MOVE 'AJOU' TO WS-PGM-CIBLE
                   PERFORM 600-TRANSFERT
               WHEN 2
                   MOVE 'MODI' TO WS-PGM-CIBLE
                   PERFORM 600-TRANSFERT
               WHEN 3
                   MOVE 'SUPP' TO WS-PGM-CIBLE
                   PERFORM 600-TRANSFERT
               WHEN 4
                   MOVE 'RECH' TO WS-PGM-CIBLE
                   PERFORM 600-TRANSFERT
               WHEN OTHER
                   MOVE 'CHOIX INVALIDE - SAISISSEZ UNE VALEUR DE 0 A 4'
                        TO WS-MESSAGE
                   PERFORM 500-RENVOI-MESSAGE
           END-EVALUATE.

       500-RENVOI-MESSAGE.

           MOVE SPACES          TO MENUMAPO
           MOVE WS-MESSAGE      TO MSGO OF MENUMAPO
           MOVE -1              TO CHOIXL OF MENUMAPO

           EXEC CICS SEND MAP('MENUMAP')
                     MAPSET('MENUSET')
                     DATAONLY
                     CURSOR
                     FREEKB
           END-EXEC.

       600-TRANSFERT.

           MOVE WS-CHOIX-NUM TO WS-CA-CHOIX

           EXEC CICS XCTL PROGRAM(WS-PGM-CIBLE)
                     COMMAREA(WS-COMMAREA)
           END-EXEC.

       900-FIN-TRANSACTION.

           EXEC CICS SEND TEXT
                     FROM('FIN DE LA TRANSACTION MENU - AU REVOIR')
                     LENGTH(40)
                     ERASE
                     FREEKB
           END-EXEC.

           EXEC CICS RETURN
           END-EXEC.
