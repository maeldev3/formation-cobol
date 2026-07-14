      *****************************************************
      * TRANSREC2.CPY
      * Enregistrement transaction (fichier sequentiel FB 80)
      * Code transaction :
      *   A = Insert (INSERT)     M = Modification (UPDATE)
      *   D = Suppression (DELETE) C = Consultation (SELECT)
      *   L = Liste (CURSOR) a partir de TRANS-ID
      *****************************************************
       01  TRANS-RECORD.
           05  TRANS-CODE          PIC X(01).
               88  TRANS-INSERT             VALUE 'A'.
               88  TRANS-MODIF               VALUE 'M'.
               88  TRANS-SUPPR               VALUE 'D'.
               88  TRANS-CONSULT             VALUE 'C'.
               88  TRANS-LISTE               VALUE 'L'.
           05  TRANS-ID            PIC 9(05).
           05  TRANS-NOM           PIC X(20).
           05  TRANS-PRENOM        PIC X(20).
           05  TRANS-ADRESSE       PIC X(30).
           05  FILLER              PIC X(04).
