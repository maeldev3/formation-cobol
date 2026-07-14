TP20 - COBOL + DB2 - Suivi d'avancement
==========================================

Structure du dossier
---------------------
TP20/
  ddl/          -> scripts SQL (creation base/table)
  copybooks/    -> .cpy partages (DCLGEN, structures)
  cobol/        -> sources .cbl
  jcl/          -> JCL (execution DDL, compile/link/bind/run)
  README.txt    -> ce fichier

Avancement
-----------
[FAIT]  Etape 1 - Creation de la table CLIENTS
          ddl/DDLCLI.sql
          jcl/RUNDDL.jcl  (execution via DSNTEP2)

[FAIT]  Etape 2 - SELECT (lecture d'un client)
          copybooks/DCLCLIENTS.cpy  (DCLGEN + variables hote)
          cobol/CLITEST.cbl         (programme de test, 1 SELECT)
          jcl/CLITEST.jcl           (precompile/compile/link/bind/run)

[A VENIR]
   Etape 3 - INSERT
   Etape 4 - UPDATE
   Etape 5 - DELETE
   Etape 6 - CURSOR (parcours de plusieurs lignes)
   Etape 7 - Programme final regroupant tout (CLIDB2.cbl)
             + JCL final avec jeu de transactions de test

A ADAPTER selon la plateforme Z Xplore (dans les JCL de jcl/)
-------------------------------------------------------------
   DB2A               -> nom reel du sous-systeme DB2 (SSID)
   DB2A.SDSNLOAD       -> bibliotheque de charge DB2 du site
   IGY.SIGYCOMP         -> bibliotheque du compilateur COBOL
   CLITESTP             -> nom du PLAN (etape 2)
   Z74830               -> collection utilisee pour le BIND PACKAGE

Datasets a creer une seule fois sur la plateforme (s'ils
n'existent pas deja)
-----------------------------------------------------------
   Z74830.DB2.SOURCE     (PDS, scripts SQL)
   Z74830.COBOL.SOURCE   (PDS, deja utilise dans TP19)
   Z74830.COBOL.COPYLIB  (PDS, deja utilise dans TP19)
   Z74830.DBRMLIB        (PDS, DBRMs issus de la precompilation)
   Z74830.LOAD           (PDS, deja utilise dans TP19)

Etape suivante
---------------
Une fois que RUNDDL.jcl a tourne sans erreur et que CLITEST.jcl
confirme bien "CLIENT INEXISTANT (SQLCODE 100)" (la table est
vide au depart), on passe a l'etape 3 : ajout de l'INSERT dans
un nouveau membre cobol/CLIGEST.cbl qui remplacera progressivement
CLITEST.cbl.
