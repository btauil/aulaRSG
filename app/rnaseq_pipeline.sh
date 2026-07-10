#!/bin/bash
set -euo pipefail

# bash rnaseq_pipeline.sh <input_fastq.gz>

# Inputs
INPUT_FASTQ="${1:-}" # Definindo meu input
INPUT_INDEX="${2:-}" # input pasta de index salmon

if [ -z "$INPUT_FASTQ" ]; then
    echo "Error: Nenhum input fastq entregue."
    echo "bash rnaseq_pipeline.sh <input_fastq.gz>"
    exit 1
fi

if [ -z "$INPUT_INDEX" ]; then
    echo "Error: Nenhum diretorio de indice entregue."
    echo "bash rnaseq_pipeline.sh <input_fastq.gz> <input_indice/>"
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
RESULTS_TRIMMOMATIC="resultados/trimmomatic"
mkdir -p "$RESULTS_TRIMMOMATIC"

TRIMMED_FASTQ="$RESULTS_TRIMMOMATIC/$(basename "$INPUT_FASTQ" .fastq.gz)_trimmed.fastq.gz"
echo "[2/3] Rodando o Trimmomatic..."
trimmomatic SE -phred33 "$INPUT_FASTQ" "$TRIMMED_FASTQ" LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# 3. Salmon
RESULTS_SALMON="resultados/salmon"
mkdir -p "$RESULTS_SALMON"

echo "[3/3] Rodando o Salmon..."

salmon quant -i $INPUT_INDEX -l A -r "$TRIMMED_FASTQ" -o "$RESULTS_SALMON/quant_output"

echo "================================="
echo "Pipeline RNAseq concluida!"
echo "================================="