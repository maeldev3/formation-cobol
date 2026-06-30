      ******************************************************************
      * COPYBOOK    : CLIENTRC                                        *
      * DESCRIPTION : ENREGISTREMENT MAITRE CLIENT                    *
      * LONGUEUR    : 100 OCTETS                                      *
      ******************************************************************
       01  CLIENT-RECORD.
           05  CLI-ID                  PIC X(06).
           05  CLI-NOM                 PIC X(25).
           05  CLI-PRENOM              PIC X(20).
           05  CLI-ADRESSE.
               10  CLI-RUE             PIC X(25).
               10  CLI-VILLE           PIC X(15).
               10  CLI-CODE-POSTAL     PIC X(05).
           05  CLI-TELEPHONE           PIC X(15).
           05  CLI-EMAIL               PIC X(30).
           05  CLI-SOLDE-COMPTE        PIC S9(7)V99 COMP-3.
           05  CLI-DATE-CREATION       PIC X(08).
           05  CLI-STATUT              PIC X(01).
               88  CLI-ACTIF                  VALUE 'A'.
               88  CLI-INACTIF                VALUE 'I'.
               88  CLI-SUPPRIME               VALUE 'S'.
           05  CLI-FILLER              PIC X(05).
