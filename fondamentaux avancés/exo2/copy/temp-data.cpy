       01 WS-DONNEES.
           05 WS-CHOIX             PIC 9.
           05 WS-TEMP-ENTREE       PIC S9(4)V99.
           05 WS-TEMP-SORTIE       PIC S9(4)V99.

       01 WS-STATUT.
           05 WS-FIN               PIC X VALUE 'N'.
               88 CONTINUER        VALUE 'N'.
               88 ARRETER          VALUE 'O'.