      ******************************************************************
      * COPYBOOK    : PAIEMTRC                                        *
      * DESCRIPTION : ENREGISTREMENT FICHIER PAIEMENTS                *
      * LONGUEUR    : 60 OCTETS                                       *
      ******************************************************************
       01  PAIEMENT-RECORD.
           05  PAI-NUMERO              PIC X(08).
           05  PAI-FAC-NUMERO          PIC X(08).
           05  PAI-CLI-ID              PIC X(06).
           05  PAI-DATE-PAIEMENT       PIC X(08).
           05  PAI-MONTANT             PIC S9(7)V99 COMP-3.
           05  PAI-MODE-REGLEMENT      PIC X(02).
               88  PAI-VIREMENT               VALUE 'VI'.
               88  PAI-CHEQUE                 VALUE 'CH'.
               88  PAI-ESPECES                VALUE 'ES'.
               88  PAI-CARTE                  VALUE 'CB'.
           05  PAI-REFERENCE           PIC X(15).
           05  PAI-FILLER              PIC X(04).
