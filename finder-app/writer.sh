#!/bin/bash
# writer.sh - Assignment 1 (AESD / CU Boulder)
# Uso: writer.sh <writefile> <writestr>
#   writefile : ruta completa del archivo (incluye nombre) a crear
#   writestr  : texto que se escribira en el archivo
# Crea el archivo (y los directorios intermedios) sobrescribiendo si existe.

# 1) Verificar que se pasaron EXACTAMENTE dos argumentos.
if [ $# -ne 2 ]; then
    echo "Error: se requieren 2 argumentos: writefile y writestr"
    exit 1
fi

writefile=$1
writestr=$2

# 2) Crear los directorios intermedios si no existen (mkdir -p).
#    dirname extrae la parte de directorio de la ruta completa.
mkdir -p "$(dirname "$writefile")"

# 3) Escribir el contenido (sobrescribe el archivo si ya existe).
echo "$writestr" > "$writefile"

# 4) Si no se pudo crear el archivo, salir con error 1.
if [ $? -ne 0 ]; then
    echo "Error: no se pudo crear el archivo '$writefile'"
    exit 1
fi
