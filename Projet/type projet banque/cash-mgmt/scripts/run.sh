#!/bin/bash
cd "$(dirname "$0")/.."
if [ ! -f bin/cash-main ]; then
    echo "Build requis..."
    ./scripts/build.sh
fi
if [ ! -f db/caisse.db ]; then
    echo "Initialisation de la base..."
    ./bin/cash-init
fi
./bin/cash-main
