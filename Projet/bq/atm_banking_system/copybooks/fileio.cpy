      *>==============================================================*
      *> COPYBOOK: FILEIO.CPY
      *> PURPOSE:  Structures de fichiers et constantes I/O
      *>==============================================================*
       
      *> Fichier clients
       FD  CUSTOMER-FILE
           LABEL RECORDS ARE STANDARD
           RECORD CONTAINS 120 CHARACTERS
           DATA RECORD IS CUSTOMER-RECORD.
       
       01  CUSTOMER-RECORD.
           05 CUST-CARD-NUM         PIC X(19).
           05 FILLER                PIC X(01).
           05 CUST-PIN              PIC X(04).
           05 FILLER                PIC X(01).
           05 CUST-BALANCE          PIC S9(12)V99.
           05 FILLER                PIC X(01).
           05 CUST-NAME             PIC X(30).
           05 FILLER                PIC X(01).
           05 CUST-STATUS           PIC X(01).
           05 FILLER                PIC X(01).
           05 CUST-LAST-LOGIN       PIC X(26).
           05 FILLER                PIC X(01).
           05 CUST-FAILED-ATTEMPTS  PIC 9(02).
       
      *> Fichier transactions avec index
       SELECT TRANSACTION-FILE ASSIGN TO "data/transactions.dat"
           ORGANIZATION IS INDEXED
           ACCESS MODE IS DYNAMIC
           RECORD KEY IS TRN-REF-NUM
           ALTERNATE RECORD KEY IS TRN-CARD-NUM
           ALTERNATE RECORD KEY IS TRN-TIMESTAMP.
       
       FD  TRANSACTION-FILE.
       01  TRANSACTION-RECORD.
           05 TRN-REF-NUM          PIC X(15).
           05 TRN-CARD-NUM         PIC X(19).
           05 TRN-TYPE             PIC X(02).
           05 TRN-AMOUNT           PIC S9(12)V99.
           05 TRN-BALANCE-AFTER    PIC S9(12)V99.
           05 TRN-TIMESTAMP        PIC X(26).
           05 TRN-DESCRIPTION      PIC X(40).
           05 TRN-TERMINAL-ID      PIC X(10).
           05 TRN-SESSION-ID       PIC X(32).
       
      *> Fichier log système
       SELECT SYSTEM-LOG ASSIGN TO "logs/system.log"
           ORGANIZATION IS LINE SEQUENTIAL.
       
       FD  SYSTEM-LOG.
       01  LOG-RECORD.
           05 LOG-TIMESTAMP        PIC X(26).
           05 LOG-LEVEL            PIC X(05).
           05 LOG-MODULE           PIC X(20).
           05 LOG-MESSAGE          PIC X(100).
