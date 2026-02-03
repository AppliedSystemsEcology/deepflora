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
