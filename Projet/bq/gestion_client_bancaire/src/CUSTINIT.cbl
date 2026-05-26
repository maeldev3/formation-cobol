      *================================================================*
      * PROGRAM:    CUSTINIT                                           *
      * DESCRIPTION: Initialize Customer Database with sample data    *
      * AUTHOR:      Senior COBOL Developer                           *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTINIT.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CUSTOMER-FILE
               ASSIGN TO "data/CUSTFILE.dat"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS CUST-ID
               ALTERNATE RECORD KEY IS CUST-NOM
                   WITH DUPLICATES
               FILE STATUS IS WS-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CUSTOMER-FILE
           RECORD CONTAINS 300 CHARACTERS.

       01  CUSTOMER-RECORD.
           05  CUST-ID              PIC 9(8).
           05  CUST-NOM             PIC X(30).
           05  CUST-PRENOM          PIC X(25).
           05  CUST-DATE-NAIS       PIC 9(8).
           05  CUST-CNI             PIC X(15).
           05  CUST-TELEPHONE       PIC X(15).
           05  CUST-EMAIL           PIC X(50).
           05  CUST-ADRESSE.
               10  CUST-RUE         PIC X(50).
               10  CUST-VILLE       PIC X(30).
               10  CUST-CODE-POST   PIC X(10).
               10  CUST-PAYS        PIC X(20).
           05  CUST-PROFIL          PIC X(10).
           05  CUST-SOLDE           PIC S9(12)V99 COMP-3.
           05  CUST-DATE-OUVERTURE  PIC 9(8).
           05  CUST-DATE-MAJ        PIC 9(8).
           05  CUST-STATUT          PIC X(1).
           05  CUST-NB-COMPTES      PIC 9(3).
           05  FILLER               PIC X(10).

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS           PIC X(2).
       01  WS-COUNTER               PIC 9(4) VALUE ZEROS.

       PROCEDURE DIVISION.
       0000-MAIN.
           DISPLAY "INITIALISATION BASE DONNEES CLIENTS..."
           OPEN OUTPUT CUSTOMER-FILE
           IF WS-FILE-STATUS NOT = "00"
               DISPLAY "ERREUR CREATION FICHIER: " WS-FILE-STATUS
               STOP RUN
           END-IF

           PERFORM 1000-LOAD-SAMPLE-DATA

           CLOSE CUSTOMER-FILE
           DISPLAY WS-COUNTER " CLIENT(S) CHARGES."
           DISPLAY "INITIALISATION TERMINEE."
           STOP RUN.

       1000-LOAD-SAMPLE-DATA.
           PERFORM 1100-WRITE-CLIENT

           INITIALIZE CUSTOMER-RECORD
           MOVE 00000001          TO CUST-ID
           MOVE "RAKOTO"          TO CUST-NOM
           MOVE "Jean-Baptiste"   TO CUST-PRENOM
           MOVE 19850315          TO CUST-DATE-NAIS
           MOVE "MG-2024-001"     TO CUST-CNI
           MOVE "+261320001001"   TO CUST-TELEPHONE
           MOVE "jb.rakoto@mail.mg" TO CUST-EMAIL
           MOVE "12 Rue Indepen." TO CUST-RUE
           MOVE "Antananarivo"    TO CUST-VILLE
           MOVE "101"             TO CUST-CODE-POST
           MOVE "Madagascar"      TO CUST-PAYS
           MOVE "PREMIUM"         TO CUST-PROFIL
           MOVE +5000000.00       TO CUST-SOLDE
           MOVE 20220101          TO CUST-DATE-OUVERTURE
           MOVE 20250101          TO CUST-DATE-MAJ
           MOVE "A"               TO CUST-STATUT
           MOVE 2                 TO CUST-NB-COMPTES
           PERFORM 1100-WRITE-CLIENT

           INITIALIZE CUSTOMER-RECORD
           MOVE 00000002          TO CUST-ID
           MOVE "RATSIMBA"        TO CUST-NOM
           MOVE "Marie Claire"    TO CUST-PRENOM
           MOVE 19901122          TO CUST-DATE-NAIS
           MOVE "MG-2024-002"     TO CUST-CNI
           MOVE "+261340002002"   TO CUST-TELEPHONE
           MOVE "m.ratsimba@corp.mg" TO CUST-EMAIL
           MOVE "45 Av. de la Rep" TO CUST-RUE
           MOVE "Toamasina"       TO CUST-VILLE
           MOVE "501"             TO CUST-CODE-POST
           MOVE "Madagascar"      TO CUST-PAYS
           MOVE "CORPORATE"       TO CUST-PROFIL
           MOVE +150000000.00     TO CUST-SOLDE
           MOVE 20180601          TO CUST-DATE-OUVERTURE
           MOVE 20250101          TO CUST-DATE-MAJ
           MOVE "A"               TO CUST-STATUT
           MOVE 5                 TO CUST-NB-COMPTES
           PERFORM 1100-WRITE-CLIENT

           INITIALIZE CUSTOMER-RECORD
           MOVE 00000003          TO CUST-ID
           MOVE "ANDRIAMAHEFA"    TO CUST-NOM
           MOVE "Paul Emile"      TO CUST-PRENOM
           MOVE 19751005          TO CUST-DATE-NAIS
           MOVE "MG-2024-003"     TO CUST-CNI
           MOVE "+261320003003"   TO CUST-TELEPHONE
           MOVE "p.andriamahefa@mail.com" TO CUST-EMAIL
           MOVE "7 Rue du Commerce" TO CUST-RUE
           MOVE "Fianarantsoa"    TO CUST-VILLE
           MOVE "301"             TO CUST-CODE-POST
           MOVE "Madagascar"      TO CUST-PAYS
           MOVE "STANDARD"        TO CUST-PROFIL
           MOVE +250000.00        TO CUST-SOLDE
           MOVE 20230301          TO CUST-DATE-OUVERTURE
           MOVE 20250101          TO CUST-DATE-MAJ
           MOVE "A"               TO CUST-STATUT
           MOVE 1                 TO CUST-NB-COMPTES
           PERFORM 1100-WRITE-CLIENT

           INITIALIZE CUSTOMER-RECORD
           MOVE 00000004          TO CUST-ID
           MOVE "RAKOTONDRABE"    TO CUST-NOM
           MOVE "Sophie"          TO CUST-PRENOM
           MOVE 19880620          TO CUST-DATE-NAIS
           MOVE "MG-2024-004"     TO CUST-CNI
           MOVE "+261340004004"   TO CUST-TELEPHONE
           MOVE "sophie.r@web.mg" TO CUST-EMAIL
           MOVE "23 Bd du Lac"    TO CUST-RUE
           MOVE "Antananarivo"    TO CUST-VILLE
           MOVE "101"             TO CUST-CODE-POST
           MOVE "Madagascar"      TO CUST-PAYS
           MOVE "STANDARD"        TO CUST-PROFIL
           MOVE +85000.00         TO CUST-SOLDE
           MOVE 20240101          TO CUST-DATE-OUVERTURE
           MOVE 20250101          TO CUST-DATE-MAJ
           MOVE "I"               TO CUST-STATUT
           MOVE 1                 TO CUST-NB-COMPTES
           PERFORM 1100-WRITE-CLIENT

           INITIALIZE CUSTOMER-RECORD
           MOVE 00000005          TO CUST-ID
           MOVE "RANDRIA"         TO CUST-NOM
           MOVE "Hery"            TO CUST-PRENOM
           MOVE 19920408          TO CUST-DATE-NAIS
           MOVE "MG-2024-005"     TO CUST-CNI
           MOVE "+261320005005"   TO CUST-TELEPHONE
           MOVE "hery.randria@net.mg" TO CUST-EMAIL
           MOVE "15 Rue Pasteur"  TO CUST-RUE
           MOVE "Mahajanga"       TO CUST-VILLE
           MOVE "401"             TO CUST-CODE-POST
           MOVE "Madagascar"      TO CUST-PAYS
           MOVE "PREMIUM"         TO CUST-PROFIL
           MOVE +2500000.00       TO CUST-SOLDE
           MOVE 20210901          TO CUST-DATE-OUVERTURE
           MOVE 20250101          TO CUST-DATE-MAJ
           MOVE "B"               TO CUST-STATUT
           MOVE 3                 TO CUST-NB-COMPTES
           PERFORM 1100-WRITE-CLIENT
           .

       1100-WRITE-CLIENT.
           IF CUST-ID NOT = ZEROS
               WRITE CUSTOMER-RECORD
               IF WS-FILE-STATUS = "00"
                   ADD 1 TO WS-COUNTER
               ELSE
                   DISPLAY "ERREUR ECRITURE ID " CUST-ID
                       ": " WS-FILE-STATUS
               END-IF
           END-IF
           .
