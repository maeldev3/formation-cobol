      ******************************************************************
      * COPYBOOK    : PAITRNRC                                        *
      * DESCRIPTION : ENREGISTREMENT TRANSACTION ENREGISTREMENT PAIE  *
      ******************************************************************
       01  PAIEMENT-TRANSACTION.
           05  PTR-FAC-NUMERO          PIC X(08).
           05  PTR-DATE-PAIEMENT       PIC X(08).
           05  PTR-MONTANT             PIC 9(7)V99.
           05  PTR-MODE-REGLEMENT      PIC X(02).
           05  PTR-REFERENCE           PIC X(15).
