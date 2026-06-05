#!/bin/bash
cobc -x -o inventory INVENTORY-DB-SYSTEM/src/main.cob \
     INVENTORY-DB-SYSTEM/src/menu.cob \
     INVENTORY-DB-SYSTEM/src/category/*.cob \
     INVENTORY-DB-SYSTEM/src/supplier/*.cob \
     INVENTORY-DB-SYSTEM/src/product/*.cob \
     INVENTORY-DB-SYSTEM/src/stock/*.cob \
     INVENTORY-DB-SYSTEM/src/user/*.cob