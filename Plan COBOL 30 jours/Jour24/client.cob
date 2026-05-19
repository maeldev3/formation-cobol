       IDENTIFICATION DIVISION.
       PROGRAM-ID. DEPOT.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 HV-NUMERO        PIC X(10).
       01 HV-MONTANT       PIC 9(7)V99.
       01 HV-NEW-SOLDE     PIC 9(7)V99.
       
       EXEC SQL
           INCLUDE SQLCA
       END-EXEC.
       
       PROCEDURE DIVISION.
           DISPLAY 'Numéro de compte: '
           ACCEPT HV-NUMERO
           DISPLAY 'Montant à déposer: '
           ACCEPT HV-MONTANT
           
      *> Vérifier existence et lire solde actuel
           EXEC SQL
               SELECT SOLDE INTO :HV-NEW-SOLDE
               FROM COMPTE
               WHERE NUMERO = :HV-NUMERO
           END-EXEC
           
           IF SQLCODE = 0
      *> Mettre à jour
               COMPUTE HV-NEW-SOLDE = 
                   HV-NEW-SOLDE + HV-MONTANT
                   
               EXEC SQL
                   UPDATE COMPTE
                   SET SOLDE = :HV-NEW-SOLDE
                   WHERE NUMERO = :HV-NUMERO
               END-EXEC
               
               EXEC SQL
                   COMMIT
               END-EXEC
               
               DISPLAY 'Nouveau solde: ' HV-NEW-SOLDE
               DISPLAY SQLERRD(3) ' ligne(s) modifiée(s)'
           ELSE
               DISPLAY 'Compte inexistant'
           END-IF
           
           STOP RUN.