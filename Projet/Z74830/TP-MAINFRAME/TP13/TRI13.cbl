       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRI13.
       AUTHOR. Z74830.
      *****************************************************
      * TP13 - TRI EN MEMOIRE (BUBBLE SORT) - SANS DFSORT  *
      * LECTURE DU FICHIER CLIENTS                         *
      * TRI PAR ID, PAR NOM, PAR SALAIRE                   *
      *****************************************************
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLIENTS-FILE ASSIGN TO CLIENTS
               ORGANIZATION IS SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
       FD  CLIENTS-FILE
           RECORDING MODE IS F
           RECORD CONTAINS 34 CHARACTERS.
       01  CLIENT-REC.
           05  CLI-ID           PIC 9(5).
           05  CLI-NOM          PIC X(20).
           05  CLI-SALAIRE      PIC 9(7)V99.

       WORKING-STORAGE SECTION.
       01  WS-EOF               PIC X       VALUE 'N'.
       01  WS-COUNT             PIC 9(4)    VALUE 0.
       01  WS-I                 PIC 9(4).
       01  WS-J                 PIC 9(4).
       01  WS-LIMITE            PIC 9(4).

       01  WS-TEMP-ID           PIC 9(5).
       01  WS-TEMP-NOM          PIC X(20).
       01  WS-TEMP-SAL          PIC 9(7)V99.

       01  WS-TITRE.
           05  FILLER           PIC X(40)   VALUE
               '---- ID --- ------ NOM ------ -SALAIRE-'.

       01  WS-LIGNE.
           05  WL-ID            PIC ZZZZ9.
           05  FILLER           PIC X(3)    VALUE SPACES.
           05  WL-NOM           PIC X(20).
           05  FILLER           PIC X(3)    VALUE SPACES.
           05  WL-SAL           PIC ZZZZZZZ9.99.

       01  CLIENT-TABLE.
           05  CLIENT-ENTRY OCCURS 100 TIMES INDEXED BY IDX.
               10  T-ID         PIC 9(5).
               10  T-NOM        PIC X(20).
               10  T-SAL        PIC 9(7)V99.

       PROCEDURE DIVISION.

       0000-MAIN.
           PERFORM 1000-INIT
           PERFORM 2000-LIRE-CLIENTS
           PERFORM 4000-AFFICHER-ENTETE
               THRU 4099-FIN-ENTETE
           DISPLAY '*** ORDRE ORIGINAL (FICHIER) ***'
           PERFORM 4100-AFFICHER-TABLE

           PERFORM 3000-TRI-PAR-ID
           DISPLAY ' '
           DISPLAY '*** TRIE PAR ID ***'
           PERFORM 4100-AFFICHER-TABLE

           PERFORM 3100-TRI-PAR-NOM
           DISPLAY ' '
           DISPLAY '*** TRIE PAR NOM ***'
           PERFORM 4100-AFFICHER-TABLE

           PERFORM 3200-TRI-PAR-SALAIRE
           DISPLAY ' '
           DISPLAY '*** TRIE PAR SALAIRE ***'
           PERFORM 4100-AFFICHER-TABLE

           STOP RUN.

      *****************************************************
      * INITIALISATION                                     *
      *****************************************************
       1000-INIT.
           OPEN INPUT CLIENTS-FILE.

      *****************************************************
      * LECTURE DU FICHIER CLIENTS VERS LA TABLE           *
      *****************************************************
       2000-LIRE-CLIENTS.
           PERFORM UNTIL WS-EOF = 'Y'
               READ CLIENTS-FILE
                   AT END
                       MOVE 'Y' TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-COUNT
                       MOVE CLI-ID      TO T-ID(WS-COUNT)
                       MOVE CLI-NOM     TO T-NOM(WS-COUNT)
                       MOVE CLI-SALAIRE TO T-SAL(WS-COUNT)
               END-READ
           END-PERFORM
           CLOSE CLIENTS-FILE.

      *****************************************************
      * BUBBLE SORT PAR ID (ORDRE CROISSANT)               *
      *****************************************************
       3000-TRI-PAR-ID.
           COMPUTE WS-LIMITE = WS-COUNT - 1
           PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-LIMITE
               PERFORM VARYING WS-J FROM 1 BY 1
                       UNTIL WS-J > (WS-COUNT - WS-I)
                   IF T-ID(WS-J) > T-ID(WS-J + 1)
                       MOVE T-ID(WS-J)   TO WS-TEMP-ID
                       MOVE T-NOM(WS-J)  TO WS-TEMP-NOM
                       MOVE T-SAL(WS-J)  TO WS-TEMP-SAL

                       MOVE T-ID(WS-J + 1)  TO T-ID(WS-J)
                       MOVE T-NOM(WS-J + 1) TO T-NOM(WS-J)
                       MOVE T-SAL(WS-J + 1) TO T-SAL(WS-J)

                       MOVE WS-TEMP-ID  TO T-ID(WS-J + 1)
                       MOVE WS-TEMP-NOM TO T-NOM(WS-J + 1)
                       MOVE WS-TEMP-SAL TO T-SAL(WS-J + 1)
                   END-IF
               END-PERFORM
           END-PERFORM.

      *****************************************************
      * BUBBLE SORT PAR NOM (ORDRE ALPHABETIQUE)           *
      *****************************************************
       3100-TRI-PAR-NOM.
           COMPUTE WS-LIMITE = WS-COUNT - 1
           PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-LIMITE
               PERFORM VARYING WS-J FROM 1 BY 1
                       UNTIL WS-J > (WS-COUNT - WS-I)
                   IF T-NOM(WS-J) > T-NOM(WS-J + 1)
                       MOVE T-ID(WS-J)   TO WS-TEMP-ID
                       MOVE T-NOM(WS-J)  TO WS-TEMP-NOM
                       MOVE T-SAL(WS-J)  TO WS-TEMP-SAL

                       MOVE T-ID(WS-J + 1)  TO T-ID(WS-J)
                       MOVE T-NOM(WS-J + 1) TO T-NOM(WS-J)
                       MOVE T-SAL(WS-J + 1) TO T-SAL(WS-J)

                       MOVE WS-TEMP-ID  TO T-ID(WS-J + 1)
                       MOVE WS-TEMP-NOM TO T-NOM(WS-J + 1)
                       MOVE WS-TEMP-SAL TO T-SAL(WS-J + 1)
                   END-IF
               END-PERFORM
           END-PERFORM.

      *****************************************************
      * BUBBLE SORT PAR SALAIRE (ORDRE DECROISSANT)        *
      *****************************************************
       3200-TRI-PAR-SALAIRE.
           COMPUTE WS-LIMITE = WS-COUNT - 1
           PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-LIMITE
               PERFORM VARYING WS-J FROM 1 BY 1
                       UNTIL WS-J > (WS-COUNT - WS-I)
                   IF T-SAL(WS-J) < T-SAL(WS-J + 1)
                       MOVE T-ID(WS-J)   TO WS-TEMP-ID
                       MOVE T-NOM(WS-J)  TO WS-TEMP-NOM
                       MOVE T-SAL(WS-J)  TO WS-TEMP-SAL

                       MOVE T-ID(WS-J + 1)  TO T-ID(WS-J)
                       MOVE T-NOM(WS-J + 1) TO T-NOM(WS-J)
                       MOVE T-SAL(WS-J + 1) TO T-SAL(WS-J)

                       MOVE WS-TEMP-ID  TO T-ID(WS-J + 1)
                       MOVE WS-TEMP-NOM TO T-NOM(WS-J + 1)
                       MOVE WS-TEMP-SAL TO T-SAL(WS-J + 1)
                   END-IF
               END-PERFORM
           END-PERFORM.

      *****************************************************
      * AFFICHAGE DE L'ENTETE                              *
      *****************************************************
       4000-AFFICHER-ENTETE.
           DISPLAY WS-TITRE.
       4099-FIN-ENTETE.
           CONTINUE.

      *****************************************************
      * AFFICHAGE DU CONTENU DE LA TABLE                   *
      *****************************************************
       4100-AFFICHER-TABLE.
           PERFORM VARYING WS-I FROM 1 BY 1
                   UNTIL WS-I > WS-COUNT
               MOVE T-ID(WS-I)  TO WL-ID
               MOVE T-NOM(WS-I) TO WL-NOM
               MOVE T-SAL(WS-I) TO WL-SAL
               DISPLAY WS-LIGNE
           END-PERFORM.
