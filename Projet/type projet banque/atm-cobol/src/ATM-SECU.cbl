      *================================================================*
      *  ATM-SECU.CBL - MODULE SÉCURITÉ ATM                           *
      *  Gestion avancée : PIN, blocage, audit                        *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ATM-SECU.
       AUTHOR. SYSTEME-BANCAIRE.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHIER-AUDIT ASSIGN TO "data/AUDIT.DAT"
               ORGANIZATION IS SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FS-AUDIT.

       DATA DIVISION.
       FILE SECTION.

       FD  FICHIER-AUDIT.
       01  ENREG-AUDIT.
           05  AUDIT-DATETIME      PIC X(19).
           05  AUDIT-CARTE         PIC X(19).
           05  AUDIT-EVENEMENT     PIC X(30).
           05  AUDIT-DETAIL        PIC X(50).
           05  AUDIT-IP            PIC X(15).

       WORKING-STORAGE SECTION.
       01  WS-FS-AUDIT             PIC XX VALUE SPACES.
       01  WS-ATM-ID               PIC X(8) VALUE "ATM-0001".
       01  WS-DATETIME             PIC X(19).

      *--- LINKAGE ENTRANT ---
       01  LK-CARTE-NUM            PIC X(19).
       01  LK-PIN-SAISI            PIC X(4).
       01  LK-PIN-STOCKE           PIC X(4).
       01  LK-TENTATIVES           PIC 9.
       01  LK-RESULTAT             PIC 9.
           88  SECU-OK             VALUE 1.
           88  SECU-ECHEC          VALUE 0.
           88  SECU-BLOQUE         VALUE 9.

       LINKAGE SECTION.
       01  LS-CARTE-NUM            PIC X(19).
       01  LS-PIN-SAISI            PIC X(4).
       01  LS-PIN-STOCKE           PIC X(4).
       01  LS-TENTATIVES           PIC 9.
       01  LS-RESULTAT             PIC 9.

       PROCEDURE DIVISION USING LS-CARTE-NUM
                                 LS-PIN-SAISI
                                 LS-PIN-STOCKE
                                 LS-TENTATIVES
                                 LS-RESULTAT.

       VERIFIER-PIN.
           MOVE LS-CARTE-NUM   TO LK-CARTE-NUM
           MOVE LS-PIN-SAISI   TO LK-PIN-SAISI
           MOVE LS-PIN-STOCKE  TO LK-PIN-STOCKE
           MOVE LS-TENTATIVES  TO LK-TENTATIVES

           IF LK-TENTATIVES >= 3
               MOVE 9 TO LK-RESULTAT
               PERFORM JOURNALISER-BLOCAGE
           ELSE
               IF LK-PIN-SAISI = LK-PIN-STOCKE
                   MOVE 1 TO LK-RESULTAT
                   PERFORM JOURNALISER-SUCCES
               ELSE
                   MOVE 0 TO LK-RESULTAT
                   PERFORM JOURNALISER-ECHEC
               END-IF
           END-IF

           MOVE LK-RESULTAT TO LS-RESULTAT
           STOP RUN.

       JOURNALISER-SUCCES.
           OPEN EXTEND FICHIER-AUDIT
           MOVE FUNCTION CURRENT-DATE TO AUDIT-DATETIME
           MOVE LK-CARTE-NUM TO AUDIT-CARTE
           MOVE "AUTHENTIFICATION_OK" TO AUDIT-EVENEMENT
           MOVE "PIN valide - accès accordé" TO AUDIT-DETAIL
           MOVE WS-ATM-ID TO AUDIT-IP
           WRITE ENREG-AUDIT
           CLOSE FICHIER-AUDIT.

       JOURNALISER-ECHEC.
           OPEN EXTEND FICHIER-AUDIT
           MOVE FUNCTION CURRENT-DATE TO AUDIT-DATETIME
           MOVE LK-CARTE-NUM TO AUDIT-CARTE
           MOVE "ECHEC_PIN" TO AUDIT-EVENEMENT
           STRING "Tentative " DELIMITED SIZE
                  LK-TENTATIVES DELIMITED SIZE
                  " échouée" DELIMITED SIZE
               INTO AUDIT-DETAIL
           MOVE WS-ATM-ID TO AUDIT-IP
           WRITE ENREG-AUDIT
           CLOSE FICHIER-AUDIT.

       JOURNALISER-BLOCAGE.
           OPEN EXTEND FICHIER-AUDIT
           MOVE FUNCTION CURRENT-DATE TO AUDIT-DATETIME
           MOVE LK-CARTE-NUM TO AUDIT-CARTE
           MOVE "CARTE_BLOQUEE" TO AUDIT-EVENEMENT
           MOVE "3 tentatives PIN échouées - blocage automatique"
               TO AUDIT-DETAIL
           MOVE WS-ATM-ID TO AUDIT-IP
           WRITE ENREG-AUDIT
           CLOSE FICHIER-AUDIT.
