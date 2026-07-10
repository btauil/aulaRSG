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

# 2. Trimmomatic

# 3. Salmon