library(terra)

plants <- read.csv("data-raw/rare-plants.csv")
raredir <- "data-raw/big/rare"

rarefiles <- list.files(raredir)

pa_plants <- names(rast(file.path(raredir,rarefiles[1])))

plants_in_pa <- unique(plants$species[plants$species %in% pa_plants])

for(i in 10:11){
  plant.i <- plants_in_pa[i]
  raretiles.i <- lapply(file.path(raredir, rarefiles), terra::rast, lyrs=plant.i)

  raresprc.i <- terra::sprc(raretiles.i)
  terra::merge(raresprc.i,
               filename = file.path("data/rare",paste0(gsub(" ", "_", plant.i),".tif")),
               overwrite = TRUE)
}

# use ny model
plant.use_ny <- plants$species[!(plants$species %in% pa_plants)]
raredir.use_ny <- "data-raw/big/rare_useny"
rarefiles.use_ny <- list.files(raredir.use_ny)

raretiles.use_ny <- lapply(file.path("data-raw/big/rare_useny",rarefiles.use_ny), terra::rast, lyrs=plant.use_ny)
raresprc.use_ny <- terra::sprc(raretiles.use_ny)
terra::merge(raresprc.use_ny, filename = file.path("data/rare",paste0(gsub(" ", "_", plant.use_ny),"_useNYmod.tif")))
