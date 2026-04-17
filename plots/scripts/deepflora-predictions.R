## Look at sp predictions

library(terra)
library(dplyr)

plantifs <- rast("data/big/initial_state_college_raw.tif")
naiptif <- rast("data-raw/m_4007710_se_18_1_20170509.tif")

# get top50 floral resource plants
top50 <- read.csv("data/results/per-sp-accuracy.csv") |>
  filter(model == "initial", subset=="floralres" & metric == "support") |>
  slice_max(n=50, order_by = value) |> pull(scientificName)

# define presence as > 0.5
plantifs.yn <- plantifs > 0.5

# sum of present species
plantifs.sum <- sum(plantifs.yn)

writeRaster(plantifs.sum, "data/sum.tif")

## Look at 50 of the top floral resource species

# match tif names to names from accuracy metrics
tif50 <- names(plantifs)[which(names(plantifs) %in% top50)]

# one is missing so find it
top50[which(!(top50 %in% names(plantifs)))]  # "Symphyotrichum novae angliae"

# it's because the name is missing a hyphen
tif50 <- append(tif50, "Symphyotrichum novae-angliae")

plantifs50 <- plantifs[[tif50]]

plantifs50.yn <- plantifs50 >0.5
plantifs50.sum <- sum(plantifs50.yn)

writeRaster(plantifs50.sum, "data/sum50.tif")


# individual plants

for(i in 1:10){
  writeRaster(plantifs50[[tif50[i]]],
              file.path("data",paste0(gsub(" ","_",tif50[i]),".tif")))
}

