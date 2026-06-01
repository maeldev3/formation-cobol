      *> COPYBOOK pour l'ATM
       01  WS-CARTE.
           05  WS-CARTE-ID         PIC 9(9).
           05  WS-NUMERO-CARTE     PIC X(16).
           05  WS-PIN              PIC X(4).
           05  WS-BLOQUEE          PIC 9.

       01  WS-COMPTE.
           05  WS-COMPTE-ID        PIC 9(9).
           05  WS-CARTE-ID-COMP    PIC 9(9).
           05  WS-SOLDE            PIC S9(13)V99.

       01  WS-TRANSACTION.
           05  WS-TRANS-ID         PIC 9(9).
           05  WS-CARTE-ID-TRANS   PIC 9(9).
           05  WS-TYPE-TRANS       PIC X(10).
           05  WS-MONTANT          PIC S9(13)V99.
           05  WS-DATE-TRANS       PIC X(19).

       01  WS-FLAGS.
           05  WS-AUTH-OK          PIC X.
               88  AUTH-SUCCESS    VALUE 'Y'.
           05  WS-TENTATIVES       PIC 9 VALUE 0.

       01  WS-MESSAGE              PIC X(80).
       01  WS-MONTANT-OP           PIC S9(13)V99.