      ******************************************************************
      * COPYBOOK    : PRDTRNRC                                        *
      * DESCRIPTION : ENREGISTREMENT TRANSACTION MISE A JOUR PRODUIT  *
      * CODE-ACTION : A=AJOUT  M=MODIFICATION  S=SUPPRESSION          *
      ******************************************************************
       01  PRODUIT-TRANSACTION.
           05  PRT-CODE-ACTION         PIC X(01).
           05  PRT-CODE                PIC X(08).
           05  PRT-LIBELLE             PIC X(30).
           05  PRT-PRIX-UNITAIRE       PIC 9(5)V99.
           05  PRT-TAUX-TVA            PIC 9(2)V99.
           05  PRT-STOCK-DISPO         PIC 9(5).
           05  PRT-CATEGORIE           PIC X(02).
