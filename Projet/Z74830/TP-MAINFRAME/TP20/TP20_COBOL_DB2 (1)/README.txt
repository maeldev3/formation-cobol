TP20 - COBOL + DB2 - Package complet
========================================

Contenu du package
-------------------
1. DDLCLI.sql        DDL : CREATE DATABASE, TABLESPACE, TABLE
                      CLIENTS, INDEX unique sur CLI_ID
2. DCLCLIENTS.cpy     Copybook "DCLGEN" : DECLARE TABLE + variables
                      hote COBOL correspondantes
3. TRANSREC2.cpy      Copybook enregistrement transaction en entree
                      (meme principe que TP19 : A/M/D/C/L)
4. CLIDB2.cbl         Programme COBOL-DB2 :
                        A -> INSERT
                        M -> UPDATE
                        D -> DELETE
                        C -> SELECT (une ligne, cle exacte)
                        L -> DECLARE CURSOR / OPEN / FETCH / CLOSE
5. RUNDDL.jcl         JCL pour executer le DDL via DSNTEP2
6. CLIDB2.jcl         JCL complet : Precompile (DSNHPC) + Compile
                      (IGYCRCTL) + Link-edition (IEWL) + BIND
                      (package + plan) + Execution (IKJEFT01/DSN)

IMPORTANT - Points a adapter selon la plateforme Z Xplore
-------------------------------------------------------------
Ce package suit la structure standard d'un batch COBOL-DB2 sur
z/OS. Certains noms sont forcement generiques car ils dependent
du sous-systeme DB2 installe sur la plateforme d'entrainement.
A demander/verifier aupres du support Z Xplore ou de la doc du
cours, puis a remplacer partout ou ils apparaissent :

   DB2A               -> nom reel du sous-systeme DB2 (SSID)
   DB2A.SDSNLOAD       -> bibliotheque de charge DB2 du site
   DB2A.SDSNEXIT       -> bibliotheque d'exit DB2 (si utilisee)
   IGY.SIGYCOMP         -> bibliotheque du compilateur COBOL
   CLIDB2P              -> nom du PLAN (a la discretion du site,
                            respecter les conventions imposees)
   Z74830               -> collection utilisee pour le BIND PACKAGE

Etapes a suivre
-----------------
1) Uploader DCLCLIENTS.cpy et TRANSREC2.cpy dans
   Z74830.COBOL.COPYLIB (membres DCLCLIENTS et TRANSREC2).

2) Uploader CLIDB2.cbl dans Z74830.COBOL.SOURCE (membre CLIDB2).

3) Uploader DDLCLI.sql dans Z74830.DB2.SOURCE (membre DDLCLI),
   puis soumettre RUNDDL.jcl pour creer la base, le tablespace,
   la table Z74830.CLIENTS et son index.

4) Creer au prealable (une seule fois) les datasets necessaires
   au JCL CLIDB2.jcl s'ils n'existent pas encore :
      Z74830.DBRMLIB     (PDS, DBRMs issus de la precompilation)
      Z74830.LOAD         (PDS, module charge - deja utilise
                             dans vos precedents TP)

5) Adapter les noms marques ci-dessus dans CLIDB2.jcl, puis le
   soumettre. Il enchaine automatiquement :
      PC   -> precompilation SQL (genere le DBRM + le source
              COBOL "nettoye" des EXEC SQL)
      COB  -> compilation Enterprise COBOL
      LKED -> edition de liens avec le module d'interface DB2
              (DSNELI)
      BIND -> BIND PACKAGE puis BIND PLAN
      GO   -> execution du programme sous DSN, avec le meme
              jeu de transactions de test que le TP19 (TRANSIN)
              et un rapport en sortie (REPTOUT)

Jeu de transactions de test inclus (dans GO.TRANSIN)
---------------------------------------------------------
   A 00010  INSERT client RANDRIA JEAN
   A 00020  INSERT client RAKOTO MARIE
   A 00030  INSERT client RASOA PAUL
   M 00010  UPDATE du client 00010
   C 00020  SELECT du client 00020
   D 00030  DELETE du client 00030
   A 00010  INSERT en double -> SQLCODE -803 attendu
   M 00099  UPDATE d'un client inexistant -> SQLCODE 100 attendu
   L 00001  Parcours CURSOR de tous les clients a partir de 00001

Points cles COBOL-DB2 demontres
-----------------------------------
- EXEC SQL INCLUDE SQLCA / DCLCLIENTS
- INSERT avec gestion du SQLCODE -803 (cle dupliquee)
- UPDATE / DELETE avec gestion du SQLCODE 100 (non trouve)
- SELECT ... INTO (lecture d'une seule ligne)
- DECLARE CURSOR (place avant le premier OPEN) puis
  OPEN / FETCH (boucle) / CLOSE pour parcourir plusieurs lignes
- Controle systematique de SQLCODE apres chaque instruction SQL
  (bonne pratique preferee a WHENEVER SQLERROR pour un TP
  pedagogique, car chaque cas d'erreur est traite explicitement)
