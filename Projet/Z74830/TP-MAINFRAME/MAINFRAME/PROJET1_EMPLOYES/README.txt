================================================================
 PROJET 1 : GESTION DES EMPLOYES (LECTURE DE FICHIER)
 NIVEAU DEBUTANT - COBOL MAINFRAME (z/OS)
================================================================

OBJECTIF PEDAGOGIQUE
---------------------
Ce projet est volontairement très simple : un seul programme
COBOL qui lit un fichier d'employés ligne par ligne et affiche
chaque employé, puis un récapitulatif (nombre d'employés, masse
salariale totale, salaire moyen).

C'est l'exercice de base pour comprendre :
  - la structure d'un programme COBOL (4 DIVISIONS)
  - la lecture séquentielle d'un fichier (OPEN / READ / CLOSE)
  - la boucle PERFORM ... UNTIL
  - les totaux/compteurs (ADD, COMPUTE)
  - l'affichage avec DISPLAY

================================================================
CONTENU DU ZIP
================================================================
COBOL/EMPLOYE.cbl     Le programme, à titre de référence/lecture
                       (vous n'avez PAS besoin de le copier nulle
                       part, il est déjà inclus dans le JCL)

JCL/EMPTEST.jcl        LE SEUL FICHIER A SOUMETTRE. Il contient
                       TOUT : le code source COBOL, la
                       compilation, l'édition de liens, et les
                       données d'employés, en un seul job.

DATA/EMPDATA.txt       Les mêmes données, si vous voulez les
                       réutiliser plus tard dans un vrai fichier
                       sur le mainframe.

================================================================
COMMENT LANCER LE PROJET (LE PLUS SIMPLE POSSIBLE)
================================================================
1. Ouvrez le fichier JCL/EMPTEST.jcl dans VSCode (connecté à
   votre profil mainframe).

2. Adaptez UNIQUEMENT la première ligne :
       //Z74830F  JOB (ACCT),'TEST EMPLOYES',CLASS=A,...
   Remplacez Z74830F par VOTRE identifiant Z suivi d'une lettre
   libre (par exemple Z99994A).

3. Soumettez le job (clic droit > Submit Job, ou la commande
   habituelle que vous utilisez pour vos autres défis).

4. Regardez le résultat dans le SPOOL / job log. Vous devriez
   voir, dans la sortie du step GO, la liste des 5 employés
   suivie du récapitulatif.

AUCUNE CREATION DE DATASET (PDS, VSAM...) N'EST NECESSAIRE.
Tout est "instream" : le code et les données voyagent avec le
JCL lui-même.

================================================================
POURQUOI CETTE APPROCHE (IGYWCLG) ?
================================================================
Plutôt que d'enchaîner 3 jobs séparés (compilation, édition de
liens, exécution) avec des bibliothèques (STEPLIB) qu'il faut
connaître à l'avance - ce qui a posé problème précédemment avec
le nom IGY.SIGYCOMP introuvable sur votre système - ce JCL
utilise une PROCEDURE CATALOGUEE nommée IGYWCLG.

Une procédure cataloguée est un JCL "modèle" déjà écrit et
enregistré par les administrateurs système. Elle connaît déjà
le bon nom de bibliothèque compilateur pour CE système précis,
vous n'avez donc rien à deviner.

IGYWCLG fait 3 choses dans l'ordre :
  COBOL  : compile le programme (équivalent du step COMPCLI
           de vos précédents JCL)
  LKED   : édite les liens (équivalent de LKEDFACT.jcl)
  GO     : exécute le programme tout de suite après

SI LE JOB ECHOUE AVEC UNE ERREUR DU TYPE
"PROCEDURE IGYWCLG NOT FOUND" OU SIMILAIRE :
   Cela veut dire que cette procédure ne s'appelle pas IGYWCLG
   sur votre système Z Xplore. Essayez de remplacer la ligne :
       //STEP1    EXEC IGYWCLG
   par l'une de ces variantes (à tester dans l'ordre) :
       //STEP1    EXEC IGYWC
       //STEP1    EXEC COBUCLG
       //STEP1    EXEC COBUCG
   Ou bien : si l'un de vos précédents défis "Fundamentals"
   contenait un JCL fourni par Z Xplore qui compilait du COBOL
   avec succès, regardez le nom de procédure (EXEC ...) qu'il
   utilisait, et réutilisez exactement ce nom ici.

================================================================
COMPRENDRE LE PROGRAMME (EMPLOYE.cbl)
================================================================
STRUCTURE DU FICHIER D'ENTREE (EMPFILE) - 58 caractères/ligne :
   Colonnes  1- 5  : Matricule        (ex: E0001)
   Colonnes  6-25  : Nom               (20 caractères)
   Colonnes 26-40  : Prénom            (15 caractères)
   Colonnes 41-50  : Service           (10 caractères)
   Colonnes 51-58  : Salaire           (8 chiffres = 6 entiers
                                         + 2 décimales, sans
                                         virgule ni point dans
                                         le fichier)
   Exemple : un salaire de 3500.00 EUR s'écrit "00350000"
             (3500.00 * 100 = 350000, sur 8 positions)

DEROULEMENT DU PROGRAMME :
   1. OPEN INPUT  : ouverture du fichier en lecture
   2. Boucle de lecture (PERFORM ... UNTIL fin de fichier) :
        - lecture d'un enregistrement (READ)
        - affichage de ses 5 champs (DISPLAY)
        - mise à jour du compteur et du total des salaires
   3. CLOSE        : fermeture du fichier
   4. Affichage du récapitulatif (nombre, total, moyenne)

================================================================
POUR ALLER PLUS LOIN (UNE FOIS QUE CA FONCTIONNE)
================================================================
Une fois que ce premier projet tourne sans erreur, des
évolutions naturelles et simples seraient :
  - Ajouter un filtre (n'afficher que les employés d'un service
    donné, avec IF EMP-SERVICE = '...')
  - Trouver le salaire le plus haut et le plus bas (variables
    WS-SALAIRE-MAX / WS-SALAIRE-MIN, comparaisons dans la
    boucle)
  - Compter les employés PAR service (plusieurs compteurs, ou
    une table avec OCCURS)
  - Écrire les résultats dans un fichier de sortie au lieu de
    simplement les DISPLAY (ajout d'un FD de sortie + WRITE)

Dites-moi quand celui-ci fonctionne, je vous prépare la suite
progressivement (un concept ajouté à la fois).
