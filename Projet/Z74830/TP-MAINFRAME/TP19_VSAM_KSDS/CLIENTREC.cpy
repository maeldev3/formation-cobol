      *---------------------------------------------------------*
      * COPYBOOK   : CLIENTREC                                  *
      * OBJET      : LAYOUT ENREGISTREMENT VSAM KSDS CLIENTS    *
      * LONGUEUR   : 136 OCTETS                                 *
      * CLE        : CLI-ID (9 OCTETS, POSITION 1)               *
      *---------------------------------------------------------*
       01  CLIENT-RECORD.
           05  CLI-ID              PIC 9(9).
           05  CLI-NOM             PIC X(20).
           05  CLI-PRENOM          PIC X(20).
           05  CLI-ADRESSE         PIC X(30).
           05  CLI-VILLE           PIC X(20).
           05  CLI-TELEPHONE       PIC X(14).
           05  CLI-SOLDE           PIC S9(7)V99 COMP-3.
           05  CLI-DATE-MAJ        PIC X(8).
           05  FILLER              PIC X(10).
