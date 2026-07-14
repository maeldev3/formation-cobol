      *****************************************************
      * COPYBOOK CLICOPY
      * Structure hôte (host variables) correspondant à la
      * table DB2 CLIENTS. Utilisé dans les EXEC SQL du
      * programme CLI0200.
      *****************************************************
       01  DCLCLIENTS.
           05  CLI-ID           PIC S9(9)    COMP.
           05  CLI-NOM          PIC X(20).
           05  CLI-PRENOM       PIC X(20).
           05  CLI-SALAIRE      PIC S9(7)V99 COMP-3.
           05  CLI-DATE-NAIS    PIC X(10).
