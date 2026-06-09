# get central PA solidago
library(terra)
library(geodata)
library(tidyverse)

padf <- rast("data-raw/big/pa_2017_merge_block_mosaic.tif")

# get solidago sp
dfsp <- names(padf)
solidagos <- dfsp[grepl("Solidago*", dfsp)]

# get support info
accuracy <- read.csv("data/results/per-sp-accuracy.csv") |>
  filter(metric == "support" & scientificName %in% solidagos & model == "initial" & subset == "full")

# plots
pdf(file = "plots/solidagos.pdf", width = 11, height = 8.5)
for(i in seq_along(solidagos)){
  supportval <- accuracy |> filter(scientificName == solidagos[i]) |> pull(value)
  supportval <- if(length(supportval)==0){"not available"}else{supportval}

  print(
    ggplot() +
      geom_spatraster(data = padf_centre[[solidagos[i]]]) +
      geom_spatvector(data = near_centre, fill = NA, lwd = 0.5) +
      annotate("text",-Inf, Inf, hjust = -0.1, vjust = 2, label = paste("Support:", supportval)) +
      scale_fill_whitebox_c(
        palette = "viridi",
        na.value = "transparent"
      ) +
      labs(title = solidagos[i], fill = "Probability") +
      theme_bw() + theme(plot.margin = margin(0.5,0.5,0.5,0.5, unit = "in"))
  )

}
dev.off()

# make colorized geotifs of three Solidago sp
Sr <- padf_centre[["Solidago rugosa"]]
Sa <- padf_centre[["Solidago altissima"]]
Sj <- padf_centre[["Solidago juncea"]]

# save geotifs
terra::writeRaster(Sr, "data/big/Solidago_rugosa.tif", overwrite = TRUE)
terra::writeRaster(Sa, "data/big/Solidago_altissima.tif", overwrite = TRUE)
terra::writeRaster(Sj, "data/big/Solidago_juncea.tif", overwrite = TRUE)

# make integer
Sr_i <- terra::classify(Sr, 256, datatype = "INT1U")
Sa_i <- terra::classify(Sa, 256, datatype = "INT1U")
Sj_i <- terra::classify(Sj, 256, datatype = "INT1U")

vircoltab <- data.frame(val=0:255,col=hcl.colors(256, palette = "viridis"))

coltab(Sr_i) <- vircoltab
coltab(Sa_i) <- vircoltab
coltab(Sj_i) <- vircoltab

Sr_i_rgb <- colorize(Sr_i, to = "rgb")
Sa_i_rgb <- colorize(Sa_i, to = "rgb")
Sj_i_rgb <- colorize(Sj_i, to = "rgb")

# save rgb
terra::writeRaster(Sr_i_rgb, "data/big/Solidago_rugosa_rgb.tif")
terra::writeRaster(Sa_i_rgb, "data/big/Solidago_altissima_rgb.tif")
terra::writeRaster(Sj_i_rgb, "data/big/Solidago_juncea_rgb.tif")
