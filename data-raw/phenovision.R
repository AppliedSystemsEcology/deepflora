library(tidyverse)
library(arrow)
library(duckdb)

big_sample <- data.table::fread("data-raw/big/annotations_all_w_headers_9cf8ad8.csv", nrows = 5)

dir.create("data-raw/big/phenovision")

csv_ds <- open_csv_dataset("data-raw/big/annotations_all_w_headers_9cf8ad8.csv")
write_dataset(csv_ds, "data-raw/big/phenovision", format = "parquet")

phenovis <- open_dataset("data-raw/big/phenovision")

names(phenovis)
