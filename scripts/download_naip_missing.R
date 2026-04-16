# some downloads fail, which are saved in the retval tables.
# I compiled all the retval tables and then filter out non-zero returns (= failed)

failed <- read.csv("data-raw/results/failedreturns20260416.csv")

# save returns
returns <- c()

for(i in seq_len(nrow(failed))){
  naip.i <- failed$file[i]         # naip link
  output.i <- failed$output[i]     # destination file
  returns[i] <- download.file(naip.i, destfile = output.i, method="libcurl")
}
