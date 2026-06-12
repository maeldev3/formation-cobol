       IDENTIFICATION DIVISION.
       PROGRAM-ID.  GESTCMPT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       EXEC SQL INCLUDE SQLCA          END-EXEC.
       EXEC SQL INCLUDE COMTAB         END-EXEC.

       01  WS-MESSAGE.
           05  WS-MSG1                 PIC X(40).

       01  WS-DB2-REC.
           05  DB2-NUM                 PIC X(6).
           05  DB2-NOM                 PIC X(30).
           05  DB2-SOL                 PIC S9(9)V99.

       01  WS-INDICATEURS.
           05  IND-COMNUM              PIC S9(4) COMP.
           05  IND-COMNOM              PIC S9(4) COMP.
           05  IND-COMSOL              PIC S9(4) COMP.

       COPY ACCTMAP.

       LINKAGE SECTION.
       01  DFHCOMMAREA                 PIC X(1).

       PROCEDURE DIVISION.
       MAIN-PROCESSING.
           IF EIBCALEN = 0
               MOVE LOW-VALUES TO ACCTMAPO
               MOVE 'Saisir le numero de compte (ex: 100001)' TO MESSAGEO
               EXEC CICS SEND MAP('ACCTMAP')
                             MAPSET('ACCTMAP')
                             FROM(ACCTMAP)
                             ERASE
               END-EXEC
               EXEC CICS RETURN TRANSID(EIBTRNID)
               END-EXEC
           ELSE
               EXEC CICS RECEIVE MAP('ACCTMAP')
                             MAPSET('ACCTMAP')
                             INTO(ACCTMAP)
               END-EXEC
               PERFORM 0200-RECUPERER-DB2
               PERFORM 0300-METTRE-A-JOUR-ECRAN
               EXEC CICS SEND MAP('ACCTMAP')
                             MAPSET('ACCTMAP')
                             FROM(ACCTMAP)
                             DATAONLY
               END-EXEC
               EXEC CICS RETURN TRANSID(EIBTRNID)
               END-EXEC
           END-IF.
       0100-RETOUR.
           EXEC CICS RETURN
           END-EXEC.

       0200-RECUPERER-DB2.
           MOVE ACINUMI TO DB2-NUM.
           EXEC SQL
               SELECT COMNUM, COMNOM, COMSOL
               INTO   :DB2-NUM :IND-COMNUM,
                      :DB2-NOM :IND-COMNOM,
                      :DB2-SOL :IND-COMSOL
               FROM   COMTAB
               WHERE  COMNUM = :DB2-NUM
           END-EXEC.

       0300-METTRE-A-JOUR-ECRAN.
           IF SQLCODE = 0
               MOVE DB2-NUM TO ACINUMO
               MOVE DB2-NOM TO ACINOMO
               MOVE DB2-SOL TO ACISOLO
               MOVE SPACE   TO MESSAGEO
           ELSE
               MOVE SPACE   TO ACINOMO
               MOVE SPACE   TO ACISOLO
               MOVE 'COMPTE NON TROUVE' TO MESSAGEO
           END-IF.
