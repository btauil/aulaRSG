set -uo pipefail

# testes para o pipeline
# docker run --rm -v "$(pwd):/work" -w /work rnaseq:1.0 bash test_rnaseq_pipeline.sh 

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PIPELINE="$SCRIPT_DIR/rnaseq_pipeline.sh"


pass=0; fail=0
ok() { printf '  \033[32mPASS\033[0m %s\n' "$1"; pass=$((pass + 1)); }
no() { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=$((fail + 1)); }


make_fastq() {
 printf '%s\n' \
   '@SEQ_ID' \
   'GATTTGGGGTTCAAAGCAGTATCGATCAAATAGTAAATCCATTTGTTCAACTCACAGTTT' \
   '+' \
   "!''*((((***+))%%%++)(%%%%).1***-+*''))**55CCF>>>>>>CCCCCCC65" \
   | gzip > "$1"
}


echo "== rnaseq_pipeline.sh smoke tests =="


# 1) Sem argumento -> exit não pode ser 0
if bash "$PIPELINE" >/dev/null 2>&1; then
 no "no argument should fail"
else
 ok "no argument exits non-zero"
fi


# 2) Faltou input -> exit não pode ser 0
if bash "$PIPELINE" /nonexistent/reads.fastq.gz >/dev/null 2>&1; then
 no "missing file should fail"
else
 ok "missing input file exits non-zero"
fi


# 3) Input valido -> exit 0 e checa os outputs esperados
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
make_fastq "$WORK/sample.fastq.gz"
( cd "$WORK" && bash "$PIPELINE" sample.fastq.gz ) >"$WORK/run.log" 2>&1
rc=$?


if [ "$rc" -eq 0 ]; then
 ok "valid input exits 0"
else
 no "valid input exits 0 (rc=$rc)"; sed 's/^/      | /' "$WORK/run.log"
fi


if ls "$WORK"/resultados/fastqc/*_fastqc.html >/dev/null 2>&1; then
 ok "FastQC report produced"
else
 no "FastQC report produced"
fi


if ls "$WORK"/resultados/trimmed/*_trimmed.fastq.gz >/dev/null 2>&1; then
 ok "trimmed FASTQ produced"
else
 no "trimmed FASTQ produced"
fi


echo "== $pass passed, $fail failed =="
[ "$fail" -eq 0 ]
