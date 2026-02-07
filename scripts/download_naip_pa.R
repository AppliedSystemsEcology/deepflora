# script to download the PA naip imagery (2017) to heather's shared data allocation

source("scripts/azure_from_index.R")

scratch_dir <- "/storage/group/hlc30/default/data/deepflora/SCRATCH/"
index_html <- "https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_100cm_2017/index.html"

# vector of links to index.html files for PA NAIP directories
state_index_links <- azure_from_index(index_html)
state_outdir <- basename(dirname(index_html))

# logging
zz <- file("all.Rout", open="wt")
sink(zz, type="message", append = TRUE)
sink(zz, type = "output", append = TRUE)

# loop over each index file
for (i in seq_along(state_index_links)){
  index.i <- state_index_links[i]
  # build output directory path and create if it doesn't exist
  # based on naip server file structure because that's what deepbiosphere wants
  outputdir.i <- file.path(scratch_dir,state_outdir,basename(dirname(index.i)))
  if(!dir.exists(outputdir.i)){dir.create(outputdir.i, recursive = TRUE)}
  # get the data files in index.i
  files.i <- azure_from_index(index.i)
  cat("trying", basename(files.i),"\n")
  # build output filepaths
  outputfiles.i <- file.path(outputdir.i,basename(files.i))
  # check for existing files
  exist.outputfiles <- file.exists(outputfiles.i)
  # update list for files to download and destinations
  files.i <- files.i[!exist.outputfiles]
  outputfiles.i <- outputfiles.i[!exist.outputfiles]
  # download to file structure
  tryCatch(
    download.file(files.i,
                  destfile = outputfiles.i,
                  method="libcurl"),
    error = function(e) message(e)
  )
}
sink(type="message")
sink(type = "output")
