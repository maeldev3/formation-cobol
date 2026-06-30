      ******************************************************************
      * COPYBOOK    : CLITRNRC                                        *
      * DESCRIPTION : ENREGISTREMENT TRANSACTION MISE A JOUR CLIENT   *
      * CODE-ACTION : A=AJOUT  M=MODIFICATION  S=SUPPRESSION          *
      ******************************************************************
       01  CLIENT-TRANSACTION.
           05  CLT-CODE-ACTION         PIC X(01).
           05  CLT-ID                  PIC X(06).
           05  CLT-NOM                 PIC X(25).
           05  CLT-PRENOM              PIC X(20).
           05  CLT-RUE                 PIC X(25).
           05  CLT-VILLE               PIC X(15).
           05  CLT-CODE-POSTAL         PIC X(05).
           05  CLT-TELEPHONE           PIC X(15).
           05  CLT-EMAIL               PIC X(30).
