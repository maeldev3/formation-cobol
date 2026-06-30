      ******************************************************************
      * COPYBOOK    : FACTLNRC                                        *
      * DESCRIPTION : ENREGISTREMENT DETAIL FACTURE - LIGNE PRODUIT   *
      * LONGUEUR    : 60 OCTETS                                       *
      * CLE         : FAC-NUMERO + FLN-NUM-LIGNE                      *
      ******************************************************************
       01  FACTURE-LIGNE.
           05  FLN-KEY.
               10  FLN-FAC-NUMERO      PIC X(08).
               10  FLN-NUM-LIGNE       PIC 9(03).
           05  FLN-PRD-CODE            PIC X(08).
           05  FLN-LIBELLE             PIC X(30).
           05  FLN-QUANTITE            PIC S9(5)    COMP-3.
           05  FLN-PRIX-UNITAIRE       PIC S9(5)V99 COMP-3.
           05  FLN-MONTANT-LIGNE       PIC S9(7)V99 COMP-3.
