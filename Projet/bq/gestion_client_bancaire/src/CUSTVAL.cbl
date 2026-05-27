      *================================================================*
      * PROGRAM:    CUSTVAL                                            *
      * DESCRIPTION: Customer Data Validation Subprogram              *
      * CALLED BY:   BANKCUST                                          *
      *================================================================*
       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUSTVAL.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-WORK-EMAIL         PIC X(50).
       01  WS-AT-POSITION        PIC 9(3).
       01  WS-DOT-POSITION       PIC 9(3).

       LINKAGE SECTION.
       01  LK-VALIDATION-REQUEST.
           05  LK-TYPE           PIC X(10).
               88  VAL-EMAIL     VALUE "EMAIL".
               88  VAL-DATE      VALUE "DATE".
               88  VAL-PHONE     VALUE "PHONE".
               88  VAL-PROFIL    VALUE "PROFIL".
               88  VAL-SOLDE     VALUE "SOLDE".
           05  LK-DATA           PIC X(50).
           05  LK-NUMERIC-DATA   PIC S9(12)V99 COMP-3.
           05  LK-RESULT         PIC X(1).
               88  VAL-OK        VALUE "Y".
               88  VAL-FAIL      VALUE "N".
           05  LK-MESSAGE        PIC X(60).

       PROCEDURE DIVISION USING LK-VALIDATION-REQUEST.
       0000-MAIN.
           MOVE "Y"    TO LK-RESULT
           MOVE SPACES TO LK-MESSAGE

           EVALUATE TRUE
               WHEN VAL-EMAIL  PERFORM 1000-VAL-EMAIL
               WHEN VAL-DATE   PERFORM 2000-VAL-DATE
               WHEN VAL-PHONE  PERFORM 3000-VAL-PHONE
               WHEN VAL-PROFIL PERFORM 4000-VAL-PROFIL
               WHEN VAL-SOLDE  PERFORM 5000-VAL-SOLDE
               WHEN OTHER
                   MOVE "N" TO LK-RESULT
                   MOVE "TYPE VALIDATION INCONNU" TO LK-MESSAGE
           END-EVALUATE
           GOBACK.

       1000-VAL-EMAIL.
           MOVE FUNCTION TRIM(LK-DATA) TO WS-WORK-EMAIL
           MOVE FUNCTION FIND(WS-WORK-EMAIL "@")
               TO WS-AT-POSITION
           IF WS-AT-POSITION = 0
               MOVE "N" TO LK-RESULT
               MOVE "EMAIL: @ manquant" TO LK-MESSAGE
               GO TO 1000-EXIT
           END-IF
           IF WS-AT-POSITION = 1
               MOVE "N" TO LK-RESULT
               MOVE "EMAIL: nom utilisateur manquant" TO LK-MESSAGE
               GO TO 1000-EXIT
           END-IF
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-WORK-EMAIL)) < 6
               MOVE "N" TO LK-RESULT
               MOVE "EMAIL: trop court" TO LK-MESSAGE
           END-IF
           1000-EXIT.
           EXIT.

       2000-VAL-DATE.
           IF LK-DATA(1:8) NOT NUMERIC
               MOVE "N" TO LK-RESULT
               MOVE "DATE: format invalide (AAAAMMJJ)" TO LK-MESSAGE
               GO TO 2000-EXIT
           END-IF
           IF LK-DATA(5:2) < "01" OR LK-DATA(5:2) > "12"
               MOVE "N" TO LK-RESULT
               MOVE "DATE: mois invalide (01-12)" TO LK-MESSAGE
               GO TO 2000-EXIT
           END-IF
           IF LK-DATA(7:2) < "01" OR LK-DATA(7:2) > "31"
               MOVE "N" TO LK-RESULT
               MOVE "DATE: jour invalide (01-31)" TO LK-MESSAGE
           END-IF
           2000-EXIT.
           EXIT.

       3000-VAL-PHONE.
           IF LK-DATA = SPACES
               MOVE "N" TO LK-RESULT
               MOVE "TELEPHONE: obligatoire" TO LK-MESSAGE
               GO TO 3000-EXIT
           END-IF
           IF FUNCTION LENGTH(FUNCTION TRIM(LK-DATA)) < 8
               MOVE "N" TO LK-RESULT
               MOVE "TELEPHONE: trop court" TO LK-MESSAGE
           END-IF
           3000-EXIT.
           EXIT.

       4000-VAL-PROFIL.
           IF LK-DATA NOT = "STANDARD" AND
              LK-DATA NOT = "PREMIUM"  AND
              LK-DATA NOT = "CORPORATE"
               MOVE "N" TO LK-RESULT
               MOVE "PROFIL: STANDARD/PREMIUM/CORPORATE attendu"
                   TO LK-MESSAGE
           END-IF
           .

       5000-VAL-SOLDE.
           IF LK-NUMERIC-DATA < 0
               MOVE "N" TO LK-RESULT
               MOVE "SOLDE: ne peut pas etre negatif a l'ouverture"
                   TO LK-MESSAGE
           END-IF
           .
