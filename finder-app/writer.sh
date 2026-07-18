#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Error: Se requieren 2 argumentos: <ruta-archivo> <string>"
    exit 1
fi

writefile="$1"
writestr="$2"

mkdir -p "$(dirname "$writefile")"

if ! echo "$writestr" > "$writefile"; then
    echo "Error: No se pudo crear el archivo '$writefile'"
    exit 1
fi
