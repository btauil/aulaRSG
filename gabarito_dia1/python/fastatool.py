#!/usr/bin/env python3
"""
fastatool.py - Ferramenta de manipulação de arquivos FASTA.
Atividade prática do Dia 1 - Engenharia de Software e Git (Gabarito Instructor).
"""

import sys
import argparse


def read_fasta(path: str) -> list:
    """
    Lê um arquivo FASTA e retorna uma lista de dicionários.
    Cada dicionário tem o formato: {"id": "nome_da_sequencia", "seq": "SEQUENCIA"}
    Lida com sequências multi-linha e ignora linhas em branco.
    Lança ValueError se o arquivo não começar com ">".
    """
    records = []
    current_id = None
    current_seq = []
    
    with open(path, "r") as f:
        # Verifica a primeira linha não vazia
        first_char = ""
        for line in f:
            stripped = line.strip()
            if stripped:
                first_char = stripped[0]
                break
        if first_char and first_char != ">":
            raise ValueError("Arquivo FASTA inválido: não inicia com '>'")
            
        f.seek(0)
        
        for line in f:
            line = line.strip()
            if not line:
                continue
            if line.startswith(">"):
                if current_id is not None:
                    records.append({"id": current_id, "seq": "".join(current_seq)})
                current_id = line[1:]
                current_seq = []
            else:
                current_seq.append(line)
                
        if current_id is not None:
            records.append({"id": current_id, "seq": "".join(current_seq)})
            
    return records


def calc_gc(seq: str) -> float:
    """
    Calcula a porcentagem de conteúdo GC de uma sequência de DNA.
    Insensível a maiúsculas/minúsculas. Descarta caracteres não padrão (N, X, etc.)
    no denominador do cálculo. Se não houver bases válidas, retorna 0.0.
    """
    seq = seq.upper()
    valid_bases = [b for b in seq if b in "ATCG"]
    if not valid_bases:
        return 0.0
    gc_count = sum(1 for b in valid_bases if b in "GC")
    return (gc_count / len(valid_bases)) * 100.0


def filter_fasta(records: list, min_len: int = 0, min_gc: float = 0.0) -> list:
    """
    Filtra os registros de sequência por comprimento mínimo e conteúdo GC mínimo.
    """
    filtered = []
    for r in records:
        if len(r["seq"]) >= min_len and calc_gc(r["seq"]) >= min_gc:
            filtered.append(r)
    return filtered


def reverse_complement(seq: str) -> str:
    """
    Retorna o reverso complementar de uma fita de DNA simples. Preserva maiúsculas/minúsculas.
    """
    comp_map = {
        'A': 'T', 'T': 'A', 'C': 'G', 'G': 'C',
        'a': 't', 't': 'a', 'c': 'g', 'g': 'c'
    }
    complemented = [comp_map.get(base, base) for base in seq]
    return "".join(reversed(complemented))


def write_fasta(records: list, path: str) -> None:
    """
    Grava os registros FASTA em arquivo especificado.
    """
    with open(path, "w") as f:
        for r in records:
            f.write(f">{r['id']}\n{r['seq']}\n")


def main():
    parser = argparse.ArgumentParser(description="Ferramenta CLI para manipulação de arquivos FASTA.")
    parser.add_argument("--input", required=True, help="Arquivo FASTA de entrada")
    parser.add_argument("--output", required=True, help="Arquivo FASTA de saída")
    parser.add_argument("--min-len", type=int, default=0, help="Comprimento mínimo (default: 0)")
    parser.add_argument("--min-gc", type=float, default=0.0, help="GC mínimo em % (default: 0.0)")
    parser.add_argument("--rev-comp", action="store_true", help="Aplica reverso complementar")
    args = parser.parse_args()
    
    try:
        records = read_fasta(args.input)
    except Exception as e:
        print(f"Erro: {e}", file=sys.stderr)
        sys.exit(1)
        
    filtered = filter_fasta(records, min_len=args.min_len, min_gc=args.min_gc)
    
    if args.rev_comp:
        for r in filtered:
            r["seq"] = reverse_complement(r["seq"])
            
    write_fasta(filtered, args.output)
    print(f"Sucesso! {len(filtered)} registros gravados em {args.output}")


if __name__ == "__main__":
    main()
