#!/usr/bin/env bash
# ==============================================================================
# DevOps Assessment Script - Requirement 5b
# Crea 10 archivos con la fecha actual y los imprime en consola
# ==============================================================================
set -euo pipefail

OUTPUT_DIR="./output-files"
mkdir -p "$OUTPUT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

echo "=========================================================="
echo "Iniciando generación de 10 archivos con timestamp: $TIMESTAMP"
echo "=========================================================="

for i in $(seq 1 10); do
  FILE_NAME="archivo_${i}_${TIMESTAMP}.txt"
  FILE_PATH="${OUTPUT_DIR}/${FILE_NAME}"
  echo "Archivo #${i} generado exitosamente el $(date '+%Y-%m-%d %H:%M:%S')" > "$FILE_PATH"
  echo "[CREADO] $FILE_NAME"
done

echo ""
echo "=========================================================="
echo "Imprimiendo contenido de los 10 archivos en consola:"
echo "=========================================================="

for i in $(seq 1 10); do
  FILE_NAME="archivo_${i}_${TIMESTAMP}.txt"
  FILE_PATH="${OUTPUT_DIR}/${FILE_NAME}"
  echo ""
  echo "--- Contenido de $FILE_NAME ---"
  cat "$FILE_PATH"
done

echo ""
echo "[COMPLETADO] Proceso finalizado con éxito."

