#!/bin/bash

echo "Compiling COBOL project..."

mkdir -p bin

cobc -x \
src/main.cob \
src/menu.cob \
src/product/add_product.cob \
-o bin/app

if [ $? -eq 0 ]; then
    echo "Compilation SUCCESS"
else
    echo "Compilation FAILED"
fi