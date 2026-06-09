      *> COPYBOOK pour le système d'épargne
      *> Définit les structures de données communes

       01  WS-CLIENT.
           05  WS-CLIENT-ID       PIC 9(9).
           05  WS-NOM             PIC X(30).
           05  WS-PRENOM          PIC X(30).
           05  WS-LOGIN           PIC X(20).
           05  WS-PIN             PIC X(4).

       01  WS-COMPTE-EPARGNE.
           05  WS-COMPTE-ID       PIC 9(9).
           05  WS-CLIENT-ID-COMP  PIC 9(9).
           05  WS-SOLDE           PIC S9(13)V99.
           05  WS-TAUX            PIC 9(3)V99.
           05  WS-DATE-OUVERTURE  PIC X(10).

       01  WS-TRANSACTION.
           05  WS-TRANS-ID        PIC 9(9).
           05  WS-CLIENT-ID-TRANS PIC 9(9).
           05  WS-TYPE-TRANS      PIC X(15).
           05  WS-MONTANT         PIC S9(13)V99.
           05  WS-DATE-TRANS      PIC X(19).

      *> Variables de travail
       01  WS-AUTH-OK             PIC X.
           88  AUTH-SUCCESS       VALUE 'Y'.
       01  WS-EXIT-FLAG           PIC X VALUE 'N'.
           88  WS-EXIT-YES        VALUE 'Y'.
       01  WS-MENU-CHOICE         PIC 9.
       01  WS-MONTANT-OP          PIC S9(13)V99.
       01  WS-MESSAGE             PIC X(80).
       01  WS-TEMP-FILE           PIC X(20) VALUE '/tmp/TEMP.DAT'.
       01  WS-SESSION-FILE        PIC X(20) VALUE 'SESSION.DAT'.
       01  WS-SQL-FILE            PIC X(20) VALUE '/tmp/SQL_TMP.SQL'.
       01  WS-TAUX-ANNUEL         PIC 9(3)V99.
       01  WS-INTERETS            PIC S9(13)V99.
