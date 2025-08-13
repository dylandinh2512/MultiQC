# calc_duplex_metrics.R  (no packages required)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript calc_duplex_metrics.R <input_rinfo.txt(.gz)> <output.csv> [sample_id]")
}

in_path  <- args[1]
out_path <- args[2]
sample_id <- if (length(args) >= 3) args[3] else {
  # derive a sample id from the input filename
  bn <- basename(in_path)
  sub("\\.txt(\\.gz)?$", "", bn, ignore.case = TRUE)
}

# Try to read a few lines to sanity‑check the input (tab‑separated expected).
# Handles .gz via a connection; if plain .txt, uses file().
is_gz <- grepl("\\.gz$", in_path, ignore.case = TRUE)
con <- if (is_gz) gzfile(in_path, open = "rt") else file(in_path, open = "rt")
on.exit(try(close(con), silent = TRUE), add = TRUE)

# If your rinfo is TSV, sep = "\t" is correct. Adjust if needed.
invisible(try(utils::read.table(con, header = TRUE, sep = "\t", nrows = 10,
                                quote = "", comment.char = "", check.names = FALSE), silent = TRUE))

# TODO: replace these placeholders with real calculations later
efficiency   <- 0.80
dropout_rate <- 0.05

metrics <- data.frame(
  sample = sample_id,
  metric = c("duplex_efficiency", "duplex_dropout_rate"),
  value  = c(efficiency, dropout_rate),
  stringsAsFactors = FALSE
)

dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
utils::write.csv(metrics, out_path, row.names = FALSE, quote = FALSE)
cat("Wrote CSV:", out_path, "\n")
