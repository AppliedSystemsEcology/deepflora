# script to download the PA naip imagery (2017) to heather's shared data allocation

source("scripts/azure_from_index.r")

scratch_dir <- "/storage/group/hlc30/default/data/deepflora/SCRATCH/"
index_html <- "https://naipeuwest.blob.core.windows.net/naip/v002/pa/2017/pa_100cm_2017/index.html"

# vector of links to index.html files for PA NAIP directories
state_index_links <- azure_from_index(index_html)
state_outdir <- basename(dirname(index_html))

# loop over each index file
for (i in seq_along(state_index_links)){
  index.i <- state_index_links[i]
  # build output directory path and create if it doesn't exist
  # based on naip server file structure because that's what deepbiosphere wants
  outputdir.i <- file.path(scratch_dir,state_outdir,basename(dirname(index.i)))
  if(!dir.exists(outputdir.i)){dir.create(outputdir.i, recursive = TRUE)}
  # get the data files in index.i
  files.i <- azure_from_index(index.i)
  # build output filepaths
  outputfiles.i <- file.path(outputdir.i,basename(files.i))
  # download to file structure
  download.file(files.i,
                destfile = outputfiles.i,
                method="libcurl")
}
