      ******************************************************************
      * COPYBOOK    : FACTRNRC                                        *
      * DESCRIPTION : ENREGISTREMENT TRANSACTION CREATION FACTURE     *
      * TYPE 'E'    : LIGNE ENTETE  (1 PAR FACTURE)                   *
      * TYPE 'L'    : LIGNE DETAIL  (N PAR FACTURE, SUIT L'ENTETE)    *
      ******************************************************************
       01  FACTURE-TRANSACTION.
           05  FCT-TYPE-LIGNE          PIC X(01).
           05  FCT-DONNEES             PIC X(79).
           05  FCT-ENTETE  REDEFINES FCT-DONNEES.
               10  FCT-FAC-NUMERO      PIC X(08).
               10  FCT-CLI-ID          PIC X(06).
               10  FCT-DATE-EMISSION   PIC X(08).
               10  FCT-DATE-ECHEANCE   PIC X(08).
               10  FCT-FILLER          PIC X(49).
           05  FCT-DETAIL  REDEFINES FCT-DONNEES.
               10  FCD-FAC-NUMERO      PIC X(08).
               10  FCD-PRD-CODE        PIC X(08).
               10  FCD-QUANTITE        PIC 9(5).
               10  FCD-FILLER          PIC X(58).
