      ******************************************************************
      * COPYBOOK    : FACTHDRC                                        *
      * DESCRIPTION : ENREGISTREMENT MAITRE FACTURE - ENTETE          *
      * LONGUEUR    : 80 OCTETS                                       *
      ******************************************************************
       01  FACTURE-HEADER.
           05  FAC-NUMERO              PIC X(08).
           05  FAC-CLI-ID              PIC X(06).
           05  FAC-DATE-EMISSION       PIC X(08).
           05  FAC-DATE-ECHEANCE       PIC X(08).
           05  FAC-MONTANT-HT          PIC S9(7)V99 COMP-3.
           05  FAC-MONTANT-TVA         PIC S9(7)V99 COMP-3.
           05  FAC-MONTANT-TTC         PIC S9(7)V99 COMP-3.
           05  FAC-MONTANT-PAYE        PIC S9(7)V99 COMP-3.
           05  FAC-MONTANT-SOLDE       PIC S9(7)V99 COMP-3.
           05  FAC-STATUT              PIC X(01).
               88  FAC-OUVERTE                VALUE 'O'.
               88  FAC-PAYEE-PARTIEL          VALUE 'P'.
               88  FAC-SOLDEE                 VALUE 'S'.
               88  FAC-ANNULEE                VALUE 'A'.
           05  FAC-NB-LIGNES           PIC S9(3)    COMP-3.
           05  FAC-FILLER              PIC X(09).
