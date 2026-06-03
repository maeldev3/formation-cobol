      *>==============================================================*
      *> COPYBOOK: SCREENS.CPY
      *> PURPOSE:  Définitions des écrans et interfaces utilisateur
      *>==============================================================*
       
       01  SCREEN-WELCOME.
           05 BLANK SCREEN.
           05 LINE 03 COL 20 VALUE '===================================='.
           05 LINE 04 COL 20 VALUE '    BIENVENUE A L''ATM BANCAIRE     '.
           05 LINE 05 COL 20 VALUE '===================================='.
           05 LINE 07 COL 20 VALUE 'Veuillez insérer votre carte:'.
           05 LINE 07 COL 50 PIC X(19) USING CARD-INPUT 
              AUTO REQUIRED.
           05 LINE 09 COL 20 VALUE 'Code PIN:'.
           05 LINE 09 COL 35 PIC X(04) USING PIN-INPUT 
              AUTO SECURE REQUIRED.
           05 LINE 11 COL 20 VALUE '===================================='.
           05 LINE 23 COL 20 VALUE 'Appuyez sur ENTER pour continuer...'.
       
       01  SCREEN-MAIN-MENU.
           05 BLANK SCREEN.
           05 LINE 02 COL 25 VALUE '************************************'.
           05 LINE 03 COL 25 VALUE '*        ATM BANKING SYSTEM        *'.
           05 LINE 04 COL 25 VALUE '************************************'.
           05 LINE 06 COL 25 VALUE '1. RETRAIT D''ARGENT'.
           05 LINE 07 COL 25 VALUE '2. DEPOT D''ARGENT'.
           05 LINE 08 COL 25 VALUE '3. CONSULTATION SOLDE'.
           05 LINE 09 COL 25 VALUE '4. MINI RELEVE'.
           05 LINE 10 COL 25 VALUE '5. CHANGER LE PIN'.
           05 LINE 11 COL 25 VALUE '6. TRANSFERER FONDS'.
           05 LINE 12 COL 25 VALUE '7. HISTORIQUE COMPLET'.
           05 LINE 13 COL 25 VALUE '8. DECONNEXION'.
           05 LINE 15 COL 25 VALUE '------------------------------------'.
           05 LINE 16 COL 25 VALUE 'VOTRE CHOIX [1-8]: '.
           05 LINE 16 COL 45 PIC 9(01) USING MENU-CHOICE AUTO.
           05 LINE 23 COL 20 VALUE 'Client: '.
           05 LINE 23 COL 30 PIC X(30) FROM DISPLAY-NAME.
           05 LINE 23 COL 65 VALUE 'Solde: '.
           05 LINE 23 COL 72 PIC ZZZ,ZZZ,ZZ9.99 FROM DISPLAY-BALANCE.
       
       01  SCREEN-AMOUNT.
           05 BLANK SCREEN.
           05 LINE 10 COL 20 VALUE '===================================='.
           05 LINE 11 COL 20 VALUE '       OPERATION FINANCIERE        '.
           05 LINE 12 COL 20 VALUE '===================================='.
           05 LINE 14 COL 20 VALUE 'Montant a '.
           05 LINE 14 COL 31 PIC X(10) FROM OPERATION-TYPE.
           05 LINE 14 COL 42 VALUE ': $'.
           05 LINE 14 COL 45 PIC Z(8)9.99 USING TRANS-AMOUNT AUTO.
           05 LINE 16 COL 20 VALUE '===================================='.
           05 LINE 23 COL 20 VALUE 'Appuyez sur ENTER pour continuer...'.
       
       01  SCREEN-CONFIRMATION.
           05 BLANK SCREEN.
           05 LINE 12 COL 20 VALUE '------------------------------------'.
           05 LINE 13 COL 20 VALUE 'CONFIRMATION REQUISE'.
           05 LINE 14 COL 20 VALUE '------------------------------------'.
           05 LINE 16 COL 20 VALUE CONFIRM-MESSAGE.
           05 LINE 18 COL 20 VALUE 'Confirmez-vous cette operation? (O/N)'.
           05 LINE 18 COL 55 PIC X(01) USING CONFIRM-RESPONSE AUTO.
       
       01  SCREEN-MINI-STATEMENT.
           05 BLANK SCREEN.
           05 LINE 01 COL 20 VALUE '========== MINI RELEVE BANCAIRE =========='.
           05 LINE 03 COL 20 VALUE 'DATE: '.
           05 LINE 03 COL 26 PIC X(10) FROM STMT-DATE.
           05 LINE 03 COL 40 VALUE 'HEURE: '.
           05 LINE 03 COL 47 PIC X(08) FROM STMT-TIME.
           05 LINE 05 COL 20 VALUE 'CLIENT: '.
           05 LINE 05 COL 28 PIC X(30) FROM STMT-NAME.
           05 LINE 06 COL 20 VALUE 'CARTE:  '.
           05 LINE 06 COL 28 PIC X(19) FROM STMT-CARD.
           05 LINE 07 COL 20 VALUE 'STATUS: '.
           05 LINE 07 COL 28 PIC X(10) FROM STMT-STATUS.
           05 LINE 09 COL 20 VALUE '---------- DERNIERES TRANSACTIONS ----------'.
           05 LINE 11 COL 20 PIC X(60) FROM STMT-LINE-1.
           05 LINE 12 COL 20 PIC X(60) FROM STMT-LINE-2.
           05 LINE 13 COL 20 PIC X(60) FROM STMT-LINE-3.
           05 LINE 14 COL 20 PIC X(60) FROM STMT-LINE-4.
           05 LINE 15 COL 20 PIC X(60) FROM STMT-LINE-5.
           05 LINE 17 COL 20 VALUE 'SOLDE ACTUEL: $'.
           05 LINE 17 COL 34 PIC ZZZ,ZZZ,ZZ9.99 FROM STMT-BALANCE.
           05 LINE 20 COL 20 VALUE '==========================================='.
           05 LINE 23 COL 20 VALUE 'Appuyez sur ENTER pour continuer...'.
       
       01  SCREEN-ERROR.
           05 BLANK SCREEN.
           05 LINE 12 COL 20 VALUE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.
           05 LINE 13 COL 20 VALUE 'ERREUR SYSTEME'.
           05 LINE 14 COL 20 VALUE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'.
           05 LINE 16 COL 20 PIC X(60) FROM ERROR-MESSAGE.
           05 LINE 18 COL 20 VALUE 'Code erreur: '.
           05 LINE 18 COL 33 PIC 9(04) FROM ERROR-CODE.
           05 LINE 20 COL 20 VALUE 'Appuyez sur ENTER pour continuer...'.
