      ******************************************************************
      * COPYBOOK    : PRODUITRC                                       *
      * DESCRIPTION : ENREGISTREMENT MAITRE PRODUIT                   *
      * LONGUEUR    : 80 OCTETS                                       *
      ******************************************************************
       01  PRODUIT-RECORD.
           05  PRD-CODE                PIC X(08).
           05  PRD-LIBELLE             PIC X(30).
           05  PRD-PRIX-UNITAIRE       PIC S9(5)V99 COMP-3.
           05  PRD-TAUX-TVA            PIC S9(2)V99 COMP-3.
           05  PRD-STOCK-DISPO         PIC S9(5)      COMP-3.
           05  PRD-CATEGORIE           PIC X(02).
           05  PRD-STATUT              PIC X(01).
               88  PRD-ACTIF                  VALUE 'A'.
               88  PRD-INACTIF                VALUE 'I'.
           05  PRD-FILLER              PIC X(14).
