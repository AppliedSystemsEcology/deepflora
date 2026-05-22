library(tidyverse)
source("R/accuracy_utils.R")
metricsdir <- "data-raw/results"
# unzip("data-raw/results/acc_metrics.zip",exdir = metricsdir, junkpaths = TRUE)
metricfiles <- list.files(metricsdir, full.names = TRUE)
beeplants <- readRDS("data/beeplants.rds")

overall <- lapply(metricfiles[grep("overall_results", metricfiles)], read.csv)
names(overall) <- strsplit(basename(metricfiles[grep("overall_results", metricfiles)]), "_") |> sapply(\(x) paste(unlist(x)[1:2],collapse="_"))

perobs <- lapply(metricfiles[grep("observations", metricfiles)], read.csv)
names(perobs) <- strsplit(basename(metricfiles[grep("observations", metricfiles)]), "_") |> sapply(\(x) paste(unlist(x)[1:2],collapse="_"))

persp <- lapply(metricfiles[grep("species", metricfiles)], read.csv)
persp.nameparts <- strsplit(sub("\\.csv$", "", basename(metricfiles[grep("species", metricfiles)])), "_")

names(persp) <- sapply(persp.nameparts, \(x) paste(head(x, 1), dplyr::nth(x, 2), tail(x, 1), sep="_"))

test <- read.csv("data-raw/results/db_ny_2017_per_species_results_band0.csv") |> tail(20)

make_persp_long <- function(x) {
  x |> as.data.frame() |>
    dplyr::select(-dset_name, -model, -loss, -exp_id, -pretrained, -date, -batch_size, -epoch, -thres, -band) |>
    pivot_longer(!matches("metric"))
    # column_to_rownames("metric") |>
    # t() |>
    # rownames_to_column("scientificName") |>
    # mutate(scientificName = gsub("\\."," ",scientificName)) %>%
    # separate_wider_delim(scientificName, delim=" ",
    #                      names=c("genus","sp"),
    #                      too_few = "align_start",
    #                      too_many = "merge",
    #                      cols_remove = FALSE)
}

for(g in seq_along(persp)){
  test <- make_persp_long(persp[[g]])
}

metricfiles[grep("species", metricfiles)][g]

persp[[2]]$Medeola.virginiana
persp[[2]]$Reynoutria.japonica

persp.l <- lapply(persp, make_persp_long)

# all bee floral resource sp (Grozinger + Fowler)
# persp.fr <- persp.l %>%
#   filter(genus %in% beeplants$genus$genus |
#            scientificName %in% beeplants$species$scientificName)

# all PA bee floral resource sp (Grozinger list)
persp.fr <- lapply(persp.l, \(x){
  filter(x, genus %in% beeplants$genus$genus |
           scientificName %in% (beeplants$species %>%
                                  dplyr::filter(source == "Grozinger") %>%
                                  pull(scientificName)))
})

# plotting df
plot_persp <- list(full=bind_rows(persp.l, .id = "model"), floralres=bind_rows(persp.fr, .id = "model")) |>
  bind_rows(.id = "subset") |> dplyr::filter(support >= 1) |>
  pivot_longer(species_top1:support, names_to = "metric") |>
  mutate(model = str_remove(model, "_[^.]*$"))

dir.create("data/results/")
write.csv(plot_persp, "data/results/per-sp-accuracy.csv", row.names = FALSE)


## overall results
overall.red <- lapply(overall, \(x) dplyr::select(x, where(~!all(is.na(.x)))))  # select only columns where not NaN
overall_df <- bind_rows(overall.red, .id = "model")

write.csv(overall_df, "data/results/overall-accuracy.csv", row.names = FALSE)
