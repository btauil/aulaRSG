#!/bin/bash
set -euo pipefail

# Baixa dados reais de Saccharomyces cerevisiae e monta o índice do Salmon.
#
# Este script roda dentro do container da pipeline. Todos os arquivos de saída são escritos
# em ./data, o volume montado do docker e persistem depois que o container terminar.
#
# rode com:
# bash fetch_data.sh 

REF_URL="https://ftp.ensembl.org/pub/release-110/fasta/saccharomyces_cerevisiae/cdna/Saccharomyces_cerevisiae.R64-1-1.cdna.all.fa.gz"
READS_URL="ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR797/SRR797058/SRR797058_1.fastq.gz"

mkdir -p data/ref

echo "[1/3] Fazendo o download do transcriptoma de referência de Saccharomyces cerevisiae..."
curl -sL "$REF_URL" -o data/ref/S_cerevisia.cdna.all.fa.gz

echo "[2/3] Montando o index Salmon..."
docker run --rm -v "$(pwd):/work" -w /work rnaseq:1.0 salmon index -t data/ref/S_cerevisia.cdna.all.fa.gz -i data/sc_index

echo "[3/3] Download + subamostragem de reads SRR787058..."
curl -sL "$READS_URL" | zcat | head -n 160000 | gzip > data/SRR797058_subamostra.fastq.gz

echo "Concluido. Dados podem ser encontrados em ./data."