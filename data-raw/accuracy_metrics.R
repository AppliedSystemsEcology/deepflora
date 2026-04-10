library(tidyverse)
metricsdir <- "data-raw/results/accuracy_metrics/"
# unzip("data-raw/results/acc_metrics.zip",exdir = metricsdir, junkpaths = TRUE)
metricfiles <- list.files(metricsdir, full.names = TRUE)
beeplants <- readRDS("data/beeplants.rds")

overall <- lapply(metricfiles[grep("overall_results", metricfiles)], read.csv)
names(overall) <- strsplit(basename(metricfiles[grep("overall_results", metricfiles)]), "_") |> sapply(\(x) paste(unlist(x)[1:2],collapse="_"))

perobs <- lapply(metricfiles[grep("observations", metricfiles)], read.csv)
names(perobs) <- strsplit(basename(metricfiles[grep("observations", metricfiles)]), "_") |> sapply(\(x) paste(unlist(x)[1:2],collapse="_"))

persp <- lapply(metricfiles[grep("species", metricfiles)], read.csv)
names(persp) <- strsplit(basename(metricfiles[grep("species", metricfiles)]), "_") |> sapply(\(x) paste(unlist(x)[1:2],collapse="_"))

make_persp_long <- function(x) {
  x |>
    dplyr::select(-dset_name, -model, -loss, -exp_id, -pretrained, -date, -batch_size, -epoch, -thres, -band) |>
    column_to_rownames("metric") |>
    t() |> as.data.frame() |>
    rownames_to_column("scientificName") |>
    mutate(scientificName = gsub("\\."," ",scientificName)) %>%
    separate_wider_delim(scientificName, delim=" ",
                         names=c("genus","sp"),
                         too_few = "align_start",
                         too_many = "merge",
                         cols_remove = FALSE)
}

persp.l <- lapply(persp[c("bioclim_unif", "initial_db", "maxent_unif", "rf_unif", "tresnet_unif")], make_persp_long)

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
