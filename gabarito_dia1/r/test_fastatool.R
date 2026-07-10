library(testthat)
source("fastatool.R")

# =====================================================================
# EXERCÍCIO 1: Testes Completos Fornecidos (Onboarding)
# =====================================================================

test_that("read_fasta reads valid single-line FASTA", {
  tmp_file <- tempfile(fileext = ".fasta")
  writeLines(c(">seq1", "ATGC", ">seq2", "CGTA"), tmp_file)
  on.exit(unlink(tmp_file))
  
  records <- read_fasta(tmp_file)
  
  expect_equal(length(records), 2)
  expect_equal(records[[1]], list(id = "seq1", seq = "ATGC"))
  expect_equal(records[[2]], list(id = "seq2", seq = "CGTA"))
})

test_that("read_fasta reads valid multi-line FASTA", {
  tmp_file <- tempfile(fileext = ".fasta")
  writeLines(c("", ">seq1", "ATGC", "TTAA", "", ">seq2", "CG", "TA"), tmp_file)
  on.exit(unlink(tmp_file))
  
  records <- read_fasta(tmp_file)
  
  expect_equal(length(records), 2)
  expect_equal(records[[1]], list(id = "seq1", seq = "ATGCTTAA"))
  expect_equal(records[[2]], list(id = "seq2", seq = "CGTA"))
})

test_that("read_fasta throws error on invalid format", {
  tmp_file <- tempfile(fileext = ".fasta")
  writeLines(c("INVALID LINE", ">seq1", "ATGC"), tmp_file)
  on.exit(unlink(tmp_file))
  
  expect_error(read_fasta(tmp_file))
})


# =====================================================================
# EXERCÍCIO 2: Testes Parciais (Cálculo de GC) - RESOLVIDO
# =====================================================================

test_that("calc_gc calculates correctly on standard sequences", {
  expect_equal(calc_gc("ATGC"), 50.0)
  expect_equal(calc_gc("GGCC"), 100.0)
  expect_equal(calc_gc("AATT"), 0.0)
})

test_that("calc_gc handles case and ambiguous bases", {
  # 1. Garanta que calc_gc lida com minúsculas ("atgc" -> 50.0)
  expect_equal(calc_gc("atgc"), 50.0)
  
  # 2. Garanta que caracteres ambíguos (N, X) são desconsiderados no denominador
  expect_equal(calc_gc("ATGCNNN"), 50.0)
})


# =====================================================================
# EXERCÍCIO 3: Testes Parciais (Filtragem) - RESOLVIDO
# =====================================================================

test_that("filter_fasta filters by length", {
  records <- list(
    list(id = "seq1", seq = "ATGC"),       # len = 4
    list(id = "seq2", seq = "ATGCTTAA"),   # len = 8
    list(id = "seq3", seq = "A")           # len = 1
  )
  
  filtered <- filter_fasta(records, min_len = 4)
  expect_equal(length(filtered), 2)
  expect_equal(filtered[[1]]$id, "seq1")
  expect_equal(filtered[[2]]$id, "seq2")
})

test_that("filter_fasta filters by GC content and length", {
  records <- list(
    list(id = "high_gc", seq = "GCGC"),  # len = 4, GC = 100%
    list(id = "low_gc", seq = "ATAT"),   # len = 4, GC = 0%
    list(id = "mid_gc_long", seq = "ATGCATGC") # len = 8, GC = 50%
  )
  # Filtra por tamanho mínimo 4 e GC mínimo 40% (deve retornar high_gc e mid_gc_long)
  filtered <- filter_fasta(records, min_len = 4, min_gc = 40.0)
  expect_equal(length(filtered), 2)
  expect_equal(filtered[[1]]$id, "high_gc")
  expect_equal(filtered[[2]]$id, "mid_gc_long")
})


# =====================================================================
# EXERCÍCIO 4: Testes Parciais (Reverso Complementar) - RESOLVIDO
# =====================================================================

test_that("reverse_complement works on standard sequence", {
  expect_equal(reverse_complement("ATGC"), "GCAT")
})

test_that("reverse_complement preserves sequence case", {
  expect_equal(reverse_complement("atgc"), "gcat")
  expect_equal(reverse_complement("AtGc"), "gCaT")
})


# =====================================================================
# EXERCÍCIO 5: TDD Puro (CLI e MVP) - RESOLVIDO
# =====================================================================

test_that("CLI integration works correctly", {
  tmp_input <- tempfile(fileext = ".fasta")
  tmp_output <- tempfile(fileext = ".fasta")
  writeLines(c(">seq1", "ATGC", ">seq2", "ATGCNNN", ">seq3", "AT"), tmp_input)
  on.exit(unlink(c(tmp_input, tmp_output)))
  
  # Invoca o script via comando do sistema
  cmd <- sprintf("Rscript fastatool.R --input %s --output %s --min-len 4 --min-gc 40.0 --rev-comp", tmp_input, tmp_output)
  status <- system(cmd)
  
  expect_equal(status, 0)
  expect_true(file.exists(tmp_output))
  lines <- readLines(tmp_output)
  
  expect_true(any(grepl(">seq1", lines)))
  expect_true(any(grepl("GCAT", lines)))  # revcomp de ATGC
  
  expect_true(any(grepl(">seq2", lines)))
  expect_true(any(grepl("NNNGCAT", lines))) # revcomp de ATGCNNN
  
  expect_false(any(grepl(">seq3", lines))) # filtrado por len < 4
})
