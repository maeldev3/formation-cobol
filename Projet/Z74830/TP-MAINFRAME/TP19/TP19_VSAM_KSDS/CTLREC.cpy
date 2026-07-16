      *---------------------------------------------------------*
      * COPYBOOK   : CTLREC                                     *
      * OBJET      : CARTE DE CONTROLE PILOTANT LE PROGRAMME    *
      * LONGUEUR   : 80 OCTETS (CONFORME DD * INSTREAM FB 80)   *
      *                                                         *
      * CTL-ACTION :                                            *
      *   W = WRITE     (AJOUT D'UN CLIENT)                     *
      *   R = READ      (CONSULTATION PAR CLE)                  *
      *   U = REWRITE   (MODIFICATION VILLE + SOLDE)             *
      *   D = DELETE    (SUPPRESSION PAR CLE)                   *
      *   S = START     (POSITIONNEMENT + LECTURE SEQ. SUIVANTE)*
      *---------------------------------------------------------*
       01  CTL-RECORD.
           05  CTL-ACTION          PIC X(1).
           05  CTL-CLI-ID          PIC 9(9).
           05  CTL-NOM             PIC X(20).
           05  CTL-PRENOM          PIC X(20).
           05  CTL-VILLE           PIC X(20).
           05  CTL-SOLDE           PIC 9(7).
           05  CTL-NBR             PIC 9(3).
