# this function is specifically for downloading the naip imagery from the azure servers
# these servers have a structure where the index.html file lists links (to data or nested data structure)
# this function takes a link to an index.html and returns the links listed as a vector of strings.
# depending on what's listed, the next step could be to download the return value (if its a link to a dataset)
# or to run the function again on the return (if it's a link to another index.html)

azure_from_index <- function(index){
  index.contents <- readLines(index)
  contains.address <- grep("href='[^']*'",index.contents, value = TRUE)

  download.address <- strsplit(contains.address,"'") |>
    lapply("[",2)   # take second element

  download.address <- grep("^index.html$|^../index.html$", download.address, invert = TRUE, value = TRUE)  # return everything but index

  paste0(dirname(index),"/",download.address)
}

download_from_index <- function(index, outpath){
  # build output directory path and create if it doesn't exist
  # based on naip server file structure because that's what deepbiosphere wants
  outputdir <- file.path(outpath,basename(dirname(index)))
  if(!dir.exists(outputdir)){dir.create(outputdir, recursive = TRUE)}

  # get the data files in index
  files <- azure_from_index(index)
  cat("trying", basename(index),"\n")

  # build output filepaths
  outputfiles <- file.path(outputdir,basename(files))

  # check for existing files
  exist.outputfiles <- file.exists(outputfiles)

  # update list for files to download and destinations
  files <- files[!exist.outputfiles]
  outputfiles <- outputfiles[!exist.outputfiles]

  # download to file structure
  download.return <- tryCatch(
    download.file(files, destfile = outputfiles, method="libcurl"),
    error = function(e) cat(message(e),"\n", print(files),"\n")
  )

  # create a return report
  returncodes <- attributes(download.return)$retvals

  data.frame(file = files, output = outputfiles, reval = returncodes)
}
