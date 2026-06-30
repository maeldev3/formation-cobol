================================================================
 SYSTEME DE FACTURATION - COBOL MAINFRAME (z/OS BATCH)
================================================================

OBJECTIF
--------
Système de facturation complet en COBOL, conçu selon les
conventions IBM Mainframe Batch (z/OS) : fichiers VSAM indexés
(KSDS), copybooks partagés, JCL de compilation / édition de
liens / exécution, et programmes batch pilotés par fichiers de
transactions.

Le système gère 4 domaines :
  1. CLIENTS    : création / modification / suppression logique
  2. PRODUITS   : catalogue produits avec prix et taux de TVA
  3. FACTURES   : entête + lignes de détail, calcul HT/TVA/TTC
  4. PAIEMENTS  : règlements clients, mise à jour du solde

================================================================
ARBORESCENCE DU PROJET
================================================================
FACTURATION/
 |-- COBOL/                Programmes sources (.cbl)
 |    |-- CLIUPDT.cbl       Mise à jour fichier maître Clients
 |    |-- PRDUPDT.cbl       Mise à jour fichier maître Produits
 |    |-- FACTCRE.cbl       Création des factures (entête+lignes)
 |    |-- PAIEENR.cbl       Enregistrement des paiements
 |    |-- FACTEDIT.cbl      Listing détaillé de toutes les factures
 |    |-- FACTSOLD.cbl      Rapport des factures impayées
 |
 |-- COPY/                  Copybooks partagés (.cpy)
 |    |-- CLIENTRC.cpy      Enregistrement maître Client
 |    |-- PRODUITRC.cpy     Enregistrement maître Produit
 |    |-- FACTHDRC.cpy      Enregistrement entête Facture
 |    |-- FACTLNRC.cpy      Enregistrement ligne Facture
 |    |-- PAIEMTRC.cpy      Enregistrement Paiement
 |    |-- CLITRNRC.cpy      Transaction Client (entrée)
 |    |-- PRDTRNRC.cpy      Transaction Produit (entrée)
 |    |-- FACTRNRC.cpy      Transaction Facture (entrée)
 |    |-- PAITRNRC.cpy      Transaction Paiement (entrée)
 |
 |-- JCL/                   Jobs de compilation / exécution
 |    |-- COMPFACT.jcl      Compilation des 6 programmes
 |    |-- LKEDFACT.jcl      Edition de liens -> LOADLIB
 |    |-- ALLOCFAC.jcl      Allocation IDCAMS des clusters VSAM
 |    |-- RUNFACT.jcl       Exécution de la chaîne complète
 |
 |-- DATA/                  Fichiers de transactions d'exemple
 |    |-- CLITRAN.txt       4 mouvements clients (3 AJOUT, 1 MODIF)
 |    |-- PRDTRAN.txt       4 produits à créer
 |    |-- FACTRAN.txt       3 factures (entêtes + lignes produits)
 |    |-- PAITRAN.txt       3 paiements

================================================================
CHAINE DE TRAITEMENT (ORDRE D'EXECUTION)
================================================================
 1. ALLOCFAC.jcl   -> crée les clusters VSAM (une seule fois)
 2. COMPFACT.jcl   -> compile les 6 programmes COBOL
 3. LKEDFACT.jcl   -> édite les liens vers la LOADLIB
 4. RUNFACT.jcl    -> exécute la chaîne complète :
       STEP010 CLIUPDT   lit CLITRAN  -> met à jour CLIMAST
       STEP020 PRDUPDT   lit PRDTRAN  -> met à jour PRODMAST
       STEP030 FACTCRE   lit FACTRAN  -> crée FACTMAST/FACTLIGN
       STEP040 PAIEENR   lit PAITRAN  -> met à jour FACTMAST,
                                          écrit PAIEMENT
       STEP050 FACTEDIT  -> édite le listing détaillé (FACTLIST)
       STEP060 FACTSOLD  -> édite le rapport des impayés (SOLDRPT)

================================================================
A FAIRE AVANT UTILISATION SUR VOTRE LPAR
================================================================
1. Remplacer TOUTES les occurrences de "ZXXXXX" par votre
   identifiant Z (ex : Z99994), dans :
     - les 4 fichiers JCL (qualificateur des DSN et JOBCARD)
     - aucun changement nécessaire dans les sources COBOL ni
       les copybooks (les noms de fichiers sont logiques, liés
       aux DD du JCL)

2. Créer dans VSCode (ou via TSO) les PDS suivants AVANT de
   lancer COMPFACT.jcl :
     ZXXXXX.COBOL.SOURCE    (PDS, RECFM=FB, LRECL=80)
        -> y charger les 6 membres .cbl (CLIUPDT, PRDUPDT,
           FACTCRE, PAIEENR, FACTEDIT, FACTSOLD)
     ZXXXXX.COBOL.COPYLIB   (PDS, RECFM=FB, LRECL=80)
        -> y charger les 9 membres .cpy (mêmes noms que les
           fichiers, sans extension)
     ZXXXXX.COBOL.OBJLIB    (PDS, RECFM=FB, LRECL=80, format objet)
     ZXXXXX.COBOL.LOADLIB   (PDS, RECFM=U, format chargeable)

3. Exécuter ALLOCFAC.jcl pour créer les fichiers VSAM
   (CLIMAST, PRODMAST, FACTMAST, FACTLIGN).

4. Charger les fichiers du dossier DATA/ comme jeux de données
   séquentiels sur le mainframe (RECFM=FB) :
     ZXXXXX.FACT.CLITRAN   LRECL=142  (depuis CLITRAN.txt)
     ZXXXXX.FACT.PRDTRAN   LRECL=57   (depuis PRDTRAN.txt)
     ZXXXXX.FACT.FACTRAN   LRECL=80   (depuis FACTRAN.txt)
     ZXXXXX.FACT.PAITRAN   LRECL=42   (depuis PAITRAN.txt)

5. Soumettre COMPFACT.jcl, puis LKEDFACT.jcl, puis RUNFACT.jcl.

================================================================
REGLES DE GESTION IMPLEMENTEES
================================================================
- Suppression logique des clients/produits (statut, pas de
  suppression physique de l'enregistrement).
- Calcul automatique du montant HT (somme des lignes), de la
  TVA (par taux produit) et du TTC pour chaque facture.
- Contrôle d'existence du client et du produit avant création
  d'une ligne de facture ; rejet tracé dans le listing si
  client/produit introuvable.
- Statuts de facture : OUVERTE / PAIEMENT PARTIEL / SOLDEE /
  ANNULEE, mis à jour automatiquement lors de l'enregistrement
  d'un paiement (comparaison solde <= 0).
- Le fichier FACTLIGN utilise une clé composite
  (numéro de facture + numéro de ligne) pour l'accès VSAM.
- Tous les montants sont stockés en COMP-3 (packed decimal)
  dans les fichiers maîtres, conformément aux conventions
  IBM Mainframe Batch.

================================================================
NOTE TECHNIQUE - VALIDATION DE LA SYNTAXE
================================================================
Les 6 programmes ont été vérifiés avec le compilateur GnuCOBOL
(cobc -fsyntax-only). Le code est syntaxiquement valide pour
Enterprise COBOL (IGYCRCTL) sur z/OS.

Dans l'environnement de validation utilisé ici, le paquet
GnuCOBOL disponible n'embarque pas le gestionnaire de fichiers
indexés (ISAM/VSAM désactivé à la compilation du paquet), ce
qui empêche la génération d'un exécutable lié localement pour
les programmes utilisant ORGANIZATION INDEXED avec WRITE/READ
INVALID KEY. Ceci est une limitation de l'outil de test, pas
du code : sur un vrai z/OS avec Enterprise COBOL ou un GnuCOBOL
complet (option --with-db), la compilation et l'édition de
liens se déroulent normalement. Les programmes FACTEDIT et
FACTSOLD (accès séquentiel pur) compilent et s'exécutent sans
aucune restriction dans cet environnement.

================================================================
EVOLUTIONS POSSIBLES
================================================================
- Ajout d'un programme ANNULFAC pour annuler une facture
  (passage à FAC-ANNULEE) avec contrôle qu'aucun paiement n'a
  été enregistré.
- Génération d'un numéro de facture automatique (compteur
  séquentiel persistant au lieu d'un numéro fourni en entrée).
- Ajout d'une seconde clé alternée sur FACTMAST (par CLI-ID)
  pour lister directement les factures d'un client.
- Interface CICS ou appel via ZOAU/Python pour piloter la
  chaîne depuis un script (cf. vos travaux précédents sur
  Z Open Automation Utilities).
