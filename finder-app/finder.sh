#!/bin/bash
# finder.sh - Assignment 1 (AESD / CU Boulder)
# Uso: finder.sh <filesdir> <searchstr>
#   filesdir  : directorio donde buscar
#   searchstr : texto a buscar en los archivos
# Imprime: "The number of files are X and the number of matching lines are Y"

# 1) Verificar que se pasaron EXACTAMENTE dos argumentos.
#    (Se piden dos: directorio y cadena a buscar.)
if [ $# -ne 2 ]; then
    echo "Error: se requieren 2 argumentos: filesdir y searchstr"
    exit 1
fi

filesdir=$1
searchstr=$2

# 2) Verificar que filesdir sea un directorio existente.
if [ ! -d "$filesdir" ]; then
    echo "Error: '$filesdir' no es un directorio en el sistema de archivos"
    exit 1
fi

# 3) Contar archivos (recursivo, solo archivos regulares) y lineas que contienen searchstr.
#    find ... -type f: todos los archivos bajo filesdir y subdirectorios.
#    grep -r: recorre recursivamente; cada linea que coincide = 1 linea.
numfiles=$(find "$filesdir" -type f | wc -l)
numlines=$(grep -r "$searchstr" "$filesdir" | wc -l)

# 4) Imprimir el resultado en el formato EXACTO esperado.
echo "The number of files are $numfiles and the number of matching lines are $numlines"
