import os
import sys
import pytest
from fastatool import read_fasta, calc_gc, filter_fasta, reverse_complement, write_fasta

# =====================================================================
# EXERCÍCIO 1: Testes Completos Fornecidos (Onboarding)
# =====================================================================

def test_read_fasta_valid_single_line(tmp_path):
    fasta_content = ">seq1\nATGC\n>seq2\nCGTA\n"
    fasta_file = tmp_path / "test_simple.fasta"
    fasta_file.write_text(fasta_content)
    
    records = read_fasta(str(fasta_file))
    
    assert len(records) == 2
    assert records[0] == {"id": "seq1", "seq": "ATGC"}
    assert records[1] == {"id": "seq2", "seq": "CGTA"}


def test_read_fasta_valid_multi_line(tmp_path):
    fasta_content = "\n>seq1\nATGC\nTTAA\n\n>seq2\nCG\nTA\n"
    fasta_file = tmp_path / "test_multi.fasta"
    fasta_file.write_text(fasta_content)
    
    records = read_fasta(str(fasta_file))
    
    assert len(records) == 2
    assert records[0] == {"id": "seq1", "seq": "ATGCTTAA"}
    assert records[1] == {"id": "seq2", "seq": "CGTA"}


def test_read_fasta_invalid_format(tmp_path):
    bad_content = "INVALID LINE\n>seq1\nATGC\n"
    bad_file = tmp_path / "bad.fasta"
    bad_file.write_text(bad_content)
    
    with pytest.raises(ValueError):
        read_fasta(str(bad_file))


# =====================================================================
# EXERCÍCIO 2: Testes Parciais (Cálculo de GC) - RESOLVIDO
# =====================================================================

def test_calc_gc_standard():
    assert calc_gc("ATGC") == 50.0
    assert calc_gc("GGCC") == 100.0
    assert calc_gc("AATT") == 0.0


def test_calc_gc_case_and_ambiguous():
    # 1. Garanta que calc_gc lida com minúsculas
    assert calc_gc("atgc") == 50.0
    
    # 2. Garanta que caracteres ambíguos (N) são desconsiderados no denominador
    assert calc_gc("ATGCNNN") == 50.0


# =====================================================================
# EXERCÍCIO 3: Testes Parciais (Filtragem) - RESOLVIDO
# =====================================================================

def test_filter_fasta_by_length():
    records = [
        {"id": "seq1", "seq": "ATGC"},        # len = 4
        {"id": "seq2", "seq": "ATGCTTAA"},    # len = 8
        {"id": "seq3", "seq": "A"},           # len = 1
    ]
    filtered = filter_fasta(records, min_len=4)
    assert len(filtered) == 2
    assert filtered[0]["id"] == "seq1"
    assert filtered[1]["id"] == "seq2"


def test_filter_fasta_by_gc_and_length():
    records = [
        {"id": "high_gc", "seq": "GCGC"},  # len = 4, GC = 100%
        {"id": "low_gc", "seq": "ATAT"},   # len = 4, GC = 0%
        {"id": "mid_gc_long", "seq": "ATGCATGC"}, # len = 8, GC = 50%
    ]
    # Filtra por tamanho mínimo 4 e GC mínimo 40% (deve retornar high_gc e mid_gc_long)
    filtered = filter_fasta(records, min_len=4, min_gc=40.0)
    assert len(filtered) == 2
    assert filtered[0]["id"] == "high_gc"
    assert filtered[1]["id"] == "mid_gc_long"


# =====================================================================
# EXERCÍCIO 4: Testes Parciais (Reverso Complementar) - RESOLVIDO
# =====================================================================

def test_reverse_complement_basic():
    assert reverse_complement("ATGC") == "GCAT"


def test_reverse_complement_case_preservation():
    # Garante preservação de caixa
    assert reverse_complement("atgc") == "gcat"
    assert reverse_complement("AtGc") == "gCaT"


# =====================================================================
# EXERCÍCIO 5: TDD Puro (CLI e MVP) - RESOLVIDO
# =====================================================================

def test_cli_integration(tmp_path):
    from fastatool import main
    
    # Prepara arquivos temporários de entrada e saída
    input_fasta = tmp_path / "input.fasta"
    input_fasta.write_text(">seq1\nATGC\n>seq2\nATGCNNN\n>seq3\nAT\n")
    output_fasta = tmp_path / "output.fasta"
    
    # Mock sys.argv para simular execução de terminal
    orig_argv = sys.argv
    try:
        sys.argv = [
            "fastatool.py",
            "--input", str(input_fasta),
            "--output", str(output_fasta),
            "--min-len", "4",
            "--min-gc", "40.0",
            "--rev-comp"
        ]
        
        main()
        
        # Validações
        assert output_fasta.exists()
        content = output_fasta.read_text()
        
        assert ">seq1" in content
        assert "GCAT" in content  # rev-comp de ATGC
        
        assert ">seq2" in content
        assert "NNNGCAT" in content  # rev-comp de ATGCNNN (N preservado)
        
        assert "seq3" not in content  # filtrado por len < 4
        
    finally:
        sys.argv = orig_argv
