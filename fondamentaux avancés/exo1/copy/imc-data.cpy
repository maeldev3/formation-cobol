       01 WS-DONNEES.
           05 WS-POIDS              PIC 9(3).
           05 WS-TAILLE             PIC 9(2)V99.
           05 WS-IMC                PIC 99V99.
           05 WS-CATEGORIE          PIC X(20).

       01 WS-STATUT.
           05 WS-ERREUR             PIC X VALUE 'N'.
               88 DONNEE-VALIDE     VALUE 'N'.
               88 DONNEE-INVALIDE   VALUE 'O'.

       01 WS-MESSAGE                PIC X(50).