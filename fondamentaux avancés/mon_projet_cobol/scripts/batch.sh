#!/bin/bash
# Script batch pour exécuter toutes les étapes du projet

set -e

cd "$(dirname "$0")/.." || exit

echo "=== Étape 1 : Allocation des datasets ==="
zowe zos-jobs submit local-file jcl/ALLOC.jcl
sleep 2
JOBID=$(zowe zos-jobs list jobs --owner=Z74830 | grep ALLOCC | tail -1 | awk '{print $1}')
echo "Job d'allocation soumis : $JOBID"
echo "Attente de la fin du job..."
while true; do
    STATUS=$(zowe zos-jobs view job-status-by-jobid "$JOBID" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if [ "$STATUS" = "OUTPUT" ]; then
        break
    fi
    sleep 2
done
echo "Job d'allocation terminé."

echo "=== Étape 2 : Création du fichier d'entrée ==="
zowe zos-jobs submit local-file jcl/CREATEINPUT.jcl
sleep 2
JOBID2=$(zowe zos-jobs list jobs --owner=Z74830 | grep CREINP | tail -1 | awk '{print $1}')
echo "Job de création soumis : $JOBID2"
while true; do
    STATUS=$(zowe zos-jobs view job-status-by-jobid "$JOBID2" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if [ "$STATUS" = "OUTPUT" ]; then
        break
    fi
    sleep 2
done
echo "Fichier d'entrée créé."

echo "=== Étape 3 : Upload des sources COBOL ==="
for f in src/*.cob; do
    member=$(basename "$f" .cob)
    zowe zos-files upload file-to-data-set "$f" "Z74830.HELLOBNK.COBOL($member)"
done

echo "=== Étape 4 : Compilation et exécution HELLOBNK ==="
zowe zos-jobs submit local-file jcl/HELLOBNK.jcl
sleep 2
JOBID3=$(zowe zos-jobs list jobs --owner=Z74830 | grep Z74830C | tail -1 | awk '{print $1}')
echo "Job HELLOBNK soumis : $JOBID3"
while true; do
    STATUS=$(zowe zos-jobs view job-status-by-jobid "$JOBID3" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if [ "$STATUS" = "OUTPUT" ]; then
        break
    fi
    sleep 2
done
echo "Résultat HELLOBNK :"
zowe zos-jobs view spool-file-by-id "$JOBID3" 103 || zowe zos-jobs view all-spool-content "$JOBID3"

echo "=== Étape 5 : Compilation et exécution SEQPROC ==="
zowe zos-jobs submit local-file jcl/SEQPROC.jcl
sleep 2
JOBID4=$(zowe zos-jobs list jobs --owner=Z74830 | grep Z74830C | tail -1 | awk '{print $1}')
echo "Job SEQPROC soumis : $JOBID4"
while true; do
    STATUS=$(zowe zos-jobs view job-status-by-jobid "$JOBID4" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if [ "$STATUS" = "OUTPUT" ]; then
        break
    fi
    sleep 2
done
echo "Résultat SEQPROC :"
zowe zos-jobs view spool-file-by-id "$JOBID4" 103 || zowe zos-jobs view all-spool-content "$JOBID4"

echo "=== Tous les jobs sont terminés. Voir les spools pour détails."
