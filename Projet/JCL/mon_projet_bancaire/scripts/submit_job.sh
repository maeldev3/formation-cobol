#!/bin/bash
if [ -z "$1" ]; then echo "Usage: $0 fichier.jcl"; exit 1; fi
zowe zos-jobs submit local-file "$1" --host 204.90.115.200 --port 10443 --user Z75013 --password XAW74XAZ --reject-unauthorized false --wait-for-output --view-all-spool-content
