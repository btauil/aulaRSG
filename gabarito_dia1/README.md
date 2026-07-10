# Gabarito Dia 1 - Exercícios do fastatool

Esta pasta contém as soluções para a atividade prática do Dia 1 (ferramenta `fastatool`) tanto em Python quanto em R.

## Conteúdo

```
/
├── python/
│   ├── fastatool.py       # Solução completa em Python
│   └── test_fastatool.py  # Solução de testes em Python
└── r/
    ├── fastatool.R        # Solução completa em R
    └── test_fastatool.R   # Solução de testes em R
```

## Como Testar as Soluções

### No Python:
```bash
cp python/fastatool.py ../../curso-dia1-git/exercises/python/
cd ../../curso-dia1-git/exercises/python/
pytest test_fastatool.py
```

### No R:
```bash
cp r/fastatool.R ../../curso-dia1-git/exercises/r/
cd ../../curso-dia1-git/exercises/r/
Rscript -e "testthat::test_file('test_fastatool.R')"
```
