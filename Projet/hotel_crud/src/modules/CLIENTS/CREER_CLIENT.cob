       IDENTIFICATION DIVISION.
       PROGRAM-ID. CREER-CLIENT.
       AUTHOR. EQUIPE-DEV.
       DATE-WRITTEN. 22/05/2025.
       DATE-COMPILED.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-ZOS.
       OBJECT-COMPUTER. IBM-ZOS.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LOG-ERREUR ASSIGN TO "CREER-CLIENT.LOG"
               ORGANIZATION IS LINE SEQUENTIAL.
       
       DATA DIVISION.
       FILE SECTION.
       FD  LOG-ERREUR.
       01  LOG-LIGNE             PIC X(132).
       
       WORKING-STORAGE SECTION.
       *> Constantes
       01  WS-SQLITE-CMD         PIC X(20) VALUE "sqlite3".
       01  WS-DB-PATH            PIC X(30) VALUE "data/input/hotel.db".
       01  WS-INSERT-SQL         PIC X(50) VALUE 
           "INSERT INTO CLIENTS VALUES (".
       
       *> Variables client
       01  WS-CLIENT.
           05 WS-ID              PIC X(6).
           05 WS-NOM             PIC X(20).
           05 WS-PRENOM          PIC X(15).
           05 WS-EMAIL           PIC X(30).
           05 WS-TEL             PIC X(12).
           05 WS-ADRESSE         PIC X(40).
           05 WS-VILLE           PIC X(20).
           05 WS-CP              PIC X(5).
           05 WS-DATE-INS        PIC X(10).
           05 WS-STATUT          PIC X(8) VALUE "ACTIF".
       
       *> Contrôles et validation
       01  WS-RETOUR             PIC 9(2).
           88 WS-SUCCES          VALUE 0.
           88 WS-ERREUR          VALUE 1 THRU 99.
       
       01  WS-COMMANDE           PIC X(1024).
       01  WS-INDEX              PIC 9(4).
       
       *> Messages
       01  WS-MSG-ERREUR         PIC X(80).
       01  WS-MSG-SUCCES         PIC X(80).
       
       *> Flag de contrôle
       01  WS-VALIDE             PIC X(1) VALUE 'O'.
           88 WS-DONNEES-VALIDES VALUE 'O'.
           88 WS-DONNEES-INVALIDES VALUE 'N'.
       
       PROCEDURE DIVISION.
       
       MAIN.
      *> Initialisation
           PERFORM INIT
           
      *> Saisie utilisateur avec validation
           PERFORM SAISIE-CLIENT
           
      *> Validation des données
           IF WS-DONNEES-VALIDES
               PERFORM ENREGISTRER-CLIENT
               PERFORM AFFICHER-SUCCES
           ELSE
               PERFORM GERER-ERREUR
           END-IF
           
      *> Fin du programme
           PERFORM FIN
           .
       
       INIT.
           MOVE FUNCTION CURRENT-DATE TO WS-DATE-INS
           MOVE SPACES TO WS-MSG-ERREUR, WS-MSG-SUCCES
           MOVE 'O' TO WS-VALIDE
           .
       
       SAISIE-CLIENT.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║              CREER UN NOUVEAU CLIENT               ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY " "
           
      *> ID Client avec contrôle de format
           PERFORM VARYING WS-INDEX FROM 1 BY 1
             UNTIL WS-INDEX > 3
               DISPLAY "ID Client (ex: C00001) : " 
                 WITH NO ADVANCING
               ACCEPT WS-ID
               IF WS-ID NOT = SPACES
                   EXIT PERFORM
               ELSE
                   DISPLAY "  ⚠ ID obligatoire !"
               END-IF
           END-PERFORM
           
           DISPLAY "NOM : " WITH NO ADVANCING
           ACCEPT WS-NOM
           DISPLAY "PRENOM : " WITH NO ADVANCING
           ACCEPT WS-PRENOM
           
      *> Validation email (présence de @)
           DISPLAY "EMAIL : " WITH NO ADVANCING
           ACCEPT WS-EMAIL
           IF WS-EMAIL NOT CONTAINS "@"
               MOVE 'N' TO WS-VALIDE
               MOVE "Email invalide (doit contenir @)" 
                 TO WS-MSG-ERREUR
           END-IF
           
           DISPLAY "TELEPHONE : " WITH NO ADVANCING
           ACCEPT WS-TEL
           DISPLAY "ADRESSE : " WITH NO ADVANCING
           ACCEPT WS-ADRESSE
           DISPLAY "VILLE : " WITH NO ADVANCING
           ACCEPT WS-VILLE
           DISPLAY "CODE POSTAL : " WITH NO ADVANCING
           ACCEPT WS-CP
           .
       
       ENREGISTRER-CLIENT.
      *> Construction de la commande SQL sans injection possible
           STRING 
               WS-SQLITE-CMD DELIMITED BY SPACE
               " " DELIMITED BY SIZE
               WS-DB-PATH DELIMITED BY SPACE
               " \"" DELIMITED BY SIZE
               WS-INSERT-SQL DELIMITED BY SIZE
               "'" DELIMITED BY SIZE
               FUNCTION TRIM(WS-ID) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-NOM) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-PRENOM) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-EMAIL) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-TEL) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-ADRESSE) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-VILLE) DELIMITED BY SIZE
               "', '" DELIMITED BY SIZE
               FUNCTION TRIM(WS-CP) DELIMITED BY SIZE
               "', date('now'), 'ACTIF');\"" 
               DELIMITED BY SIZE
               INTO WS-COMMANDE
           END-STRING
           
      *> Exécution avec gestion d'erreur
           CALL "SYSTEM" USING WS-COMMANDE 
               RETURNING WS-RETOUR
           
           IF NOT WS-SUCCES
               MOVE 'N' TO WS-VALIDE
               MOVE "Erreur SQLite: commande non executee" 
                 TO WS-MSG-ERREUR
               PERFORM LOG-ERREUR
           END-IF
           .
       
       AFFICHER-SUCCES.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║                    SUCCES !                        ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "✓ CLIENT CREE AVEC SUCCES !"
           DISPLAY "  ID: " WS-ID
           DISPLAY "  Nom: " 
               FUNCTION TRIM(WS-NOM) " " FUNCTION TRIM(WS-PRENOM)
           DISPLAY "  Email: " FUNCTION TRIM(WS-EMAIL)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           .
       
       GERER-ERREUR.
           DISPLAY " "
           DISPLAY "╔════════════════════════════════════════════════════╗"
           DISPLAY "║                    ERREUR !                        ║"
           DISPLAY "╚════════════════════════════════════════════════════╝"
           DISPLAY "✗ " FUNCTION TRIM(WS-MSG-ERREUR)
           DISPLAY "╚════════════════════════════════════════════════════╝"
           .
       
       LOG-ERREUR.
           OPEN EXTEND LOG-ERREUR
           STRING 
               FUNCTION CURRENT-DATE " - " 
               FUNCTION TRIM(WS-MSG-ERREUR) " - ID: "
               FUNCTION TRIM(WS-ID)
               INTO LOG-LIGNE
           END-STRING
           WRITE LOG-LIGNE
           CLOSE LOG-ERREUR
           .
       
       FIN.
           STOP RUN.



           

      *IDENTIFICATION DIVISION.
      *PROGRAM-ID. CREER-CLIENT.
      *
      *DATA DIVISION.
      *WORKING-STORAGE SECTION.
      *01 WS-ID         PIC X(6).
      *01 WS-NOM        PIC X(20).
      *01 WS-PRENOM     PIC X(15).
      *01 WS-EMAIL      PIC X(30).
      *01 WS-TEL        PIC X(12).
      *01 WS-ADRESSE    PIC X(40).
      *01 WS-VILLE      PIC X(20).
      *01 WS-CP         PIC X(5).
      *01 WS-COMMANDE   PIC X(500).
      *
      *PROCEDURE DIVISION.
      *DEBUT.
      *    DISPLAY " "
      *    DISPLAY "╔════════════════════════════════════════════════════╗"
      *    DISPLAY "║              CREER UN NOUVEAU CLIENT               ║"
      *    DISPLAY "╚════════════════════════════════════════════════════╝"
      *    DISPLAY " "
      *    DISPLAY "ID Client (C00001) : " WITH NO ADVANCING
      *    ACCEPT WS-ID
      *    DISPLAY "NOM : " WITH NO ADVANCING
      *    ACCEPT WS-NOM
      *    DISPLAY "PRENOM : " WITH NO ADVANCING
      *    ACCEPT WS-PRENOM
      *    DISPLAY "EMAIL : " WITH NO ADVANCING
      *    ACCEPT WS-EMAIL
      *    DISPLAY "TELEPHONE : " WITH NO ADVANCING
      *    ACCEPT WS-TEL
      *    DISPLAY "ADRESSE : " WITH NO ADVANCING
      *    ACCEPT WS-ADRESSE
      *    DISPLAY "VILLE : " WITH NO ADVANCING
      *    ACCEPT WS-VILLE
      *    DISPLAY "CODE POSTAL : " WITH NO ADVANCING
      *    ACCEPT WS-CP
      *    
      *    STRING "sqlite3 data/input/hotel.db \"INSERT INTO CLIENTS VALUES ('"
      *        FUNCTION TRIM(WS-ID) "', '"
      *        FUNCTION TRIM(WS-NOM) "', '"
      *        FUNCTION TRIM(WS-PRENOM) "', '"
      *        FUNCTION TRIM(WS-EMAIL) "', '"
      *        FUNCTION TRIM(WS-TEL) "', '"
      *        FUNCTION TRIM(WS-ADRESSE) "', '"
      *        FUNCTION TRIM(WS-VILLE) "', '"
      *        FUNCTION TRIM(WS-CP) "', date('now'), 'ACTIF');\""
      *        INTO WS-COMMANDE
      *    END-STRING
      *    CALL "SYSTEM" USING WS-COMMANDE
      *    
      *    DISPLAY " "
      *    DISPLAY "✓ CLIENT CREE AVEC SUCCES !"
      *    DISPLAY "  ID: " WS-ID
      *    DISPLAY "  Nom: " FUNCTION TRIM(WS-NOM) " " FUNCTION TRIM(WS-PRENOM)
      *    DISPLAY "╚════════════════════════════════════════════════════╝"
      *    STOP RUN.
