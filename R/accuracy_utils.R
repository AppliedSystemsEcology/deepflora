readcsv_back <- function(filename, rows.from.bottom){
  header <- names(read.csv(filename))
  nL <- R.utils::countLines(filename)

  readin <- read.csv(filename, header = FALSE, skip = nL - rows.from.bottom) |>
    setNames(header)

  readin
}
