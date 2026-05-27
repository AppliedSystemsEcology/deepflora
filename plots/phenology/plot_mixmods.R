library(mixtools)
library(tidyverse)

source("R/mix_mods.R")

mixmods <- readRDS("data/flor_mixmods.rds")

mixmods.noerror <- mixmods[sapply(mixmods, FUN = \(x) class(x)[[1]][1]=="mixEM")]

mixdists <- lapply(mixmods.noerror, make_dist_mix, 50) %>% bind_rows(.id = "scientificName") %>%
  mutate(scientificName = fct_relevel(scientificName, names(mixmods)))
