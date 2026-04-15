#!/usr/bin/env Rscript

# script to download the naip imagery (2017) to heather's shared data allocation
# TOO BE USED WITH ARRAY ARGUMENT

# args = commandArgs(trailingOnly=TRUE)
# arraynum <- as.numeric(args[1])

arraynum <- as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

source("R/azure_from_index.R")

scratch_dir <- "/storage/group/hlc30/default/data/deepflora/SCRATCH"
# index_html <- "https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_100cm_2017/index.html"
index_html <- "https://naipeuwest.blob.core.windows.net/naip/v002/ny/2017/ny_100cm_2017/index.html"

# vector of links to index.html files for PA NAIP directories
state_index_links <- azure_from_index(index_html)
state_outdir <- basename(dirname(index_html))

# output path is scratch directory + the basename in azure
hpc_outpath <- file.path(scratch_dir, state_outdir)

# choose array index
index.array <- state_index_links[arraynum]

# run download for index number supplied to script
returndf <- download_from_index(index.array, hpc_outpath)

# write the return values to log any error messages from libcurl
filename <- paste0("retvals_",basename(dirname(index.array)),".csv")

write.csv(returndf, file.path(hpc_outpath,filename), row.names = FALSE)
