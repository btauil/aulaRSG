#!/usr/bin/env Rscript
# fastatool.R - Ferramenta de manipulação de arquivos FASTA em R (Gabarito Instructor).

read_fasta <- function(path) {
  lines <- readLines(path, warn = FALSE)
  
  # Verifica primeira linha não vazia
  non_empty_lines <- lines[trimws(lines) != ""]
  if (length(non_empty_lines) > 0 && !startsWith(trimws(non_empty_lines[1]), ">")) {
    stop("Arquivo FASTA inválido: não inicia com '>'")
  }
  
  records <- list()
  current_id <- NULL
  current_seq <- character()
  
  for (line in lines) {
    line <- trimws(line)
    if (nchar(line) == 0) next
    
    if (startsWith(line, ">")) {
      if (!is.null(current_id)) {
        records[[length(records) + 1]] <- list(id = current_id, seq = paste0(current_seq, collapse = ""))
      }
      current_id <- substring(line, 2)
      current_seq <- character()
    } else {
      current_seq <- c(current_seq, line)
    }
  }
  if (!is.null(current_id)) {
    records[[length(records) + 1]] <- list(id = current_id, seq = paste0(current_seq, collapse = ""))
  }
  return(records)
}

calc_gc <- function(seq) {
  seq_upper <- toupper(seq)
  chars <- strsplit(seq_upper, "")[[1]]
  valid_bases <- chars[chars %in% c("A", "T", "C", "G")]
  if (length(valid_bases) == 0) {
    return(0.0)
  }
  gc_count <- sum(valid_bases %in% c("G", "C"))
  return((gc_count / length(valid_bases)) * 100.0)
}

filter_fasta <- function(records, min_len = 0, min_gc = 0.0) {
  filtered <- list()
  for (r in records) {
    if (nchar(r$seq) >= min_len && calc_gc(r$seq) >= min_gc) {
      filtered[[length(filtered) + 1]] <- r
    }
  }
  return(filtered)
}

reverse_complement <- function(seq) {
  comp_map <- c(
    'A'='T', 'T'='A', 'C'='G', 'G'='C',
    'a'='t', 't'='a', 'c'='g', 'g'='c'
  )
  chars <- strsplit(seq, "")[[1]]
  complemented <- sapply(chars, function(base) {
    if (base %in% names(comp_map)) {
      comp_map[[base]]
    } else {
      base
    }
  })
  reversed <- rev(complemented)
  return(paste0(reversed, collapse = ""))
}

write_fasta <- function(records, path) {
  lines <- c()
  for (r in records) {
    lines <- c(lines, paste0(">", r$id), r$seq)
  }
  writeLines(lines, path)
}

main <- function() {
  args <- commandArgs(trailingOnly = TRUE)
  
  # Parse simples de argumentos sem depender de pacotes adicionais
  input_file <- NULL
  output_file <- NULL
  min_len <- 0
  min_gc <- 0.0
  rev_comp <- FALSE
  
  i <- 1
  while (i <= length(args)) {
    arg <- args[i]
    if (arg == "--input" && i < length(args)) {
      input_file <- args[i+1]
      i <- i + 2
    } else if (arg == "--output" && i < length(args)) {
      output_file <- args[i+1]
      i <- i + 2
    } else if (arg == "--min-len" && i < length(args)) {
      min_len <- as.integer(args[i+1])
      i <- i + 2
    } else if (arg == "--min-gc" && i < length(args)) {
      min_gc <- as.double(args[i+1])
      i <- i + 2
    } else if (arg == "--rev-comp") {
      rev_comp <- TRUE
      i <- i + 1
    } else {
      i <- i + 1
    }
  }
  
  if (is.null(input_file) || is.null(output_file)) {
    stop("Uso correto: Rscript fastatool.R --input <arquivo> --output <arquivo> [--min-len <int>] [--min-gc <double>] [--rev-comp]")
  }
  
  records <- read_fasta(input_file)
  filtered <- filter_fasta(records, min_len = min_len, min_gc = min_gc)
  
  if (rev_comp) {
    filtered <- lapply(filtered, function(r) {
      r$seq <- reverse_complement(r$seq)
      return(r)
    })
  }
  
  write_fasta(filtered, output_file)
  cat(sprintf("Sucesso! %d registros gravados em %s\n", length(filtered), output_file))
}

if (!interactive()) {
  main()
}
