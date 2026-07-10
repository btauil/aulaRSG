#!/bin/bash
set -euo pipefail

# bash rnaseq_pipeline.sh <input_fastq.gz>

# Inputs
INPUT_FASTQ="${1:-}" # Definindo meu input

if [ -z "$INPUT_FASTQ" ]; then
    echo "Error: Nenhum input fastq entregue."
    echo "bash rnaseq_pipeline.sh <input_fastq.gz>"
    exit 1
fi

if [ ! -f "$INPUT_FASTQ" ]; then
    echo "Error: Arquivo input $INPUT_FASTQ não existe."
    exit 1
fi

# 1. FastQC
mkdir -p resultados/fastqc

echo "[1/3] Rodando FastQC..."
fastqc "$INPUT_FASTQ" --outdir=resultados/fastqc

# 2. Trimmomatic

# 3. Salmon