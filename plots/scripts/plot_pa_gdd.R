# create animations
# https://dieghernan.github.io/tidyterra/articles/faqs.html#gganimate
library(tidyverse)
library(terra)
library(tidyterra)
library(rnaturalearth)
library(gganimate)

pa_gdd <- rast("data/pa_gdd2017.tif")
names(pa_gdd) <- paste("Week", as.numeric(names(pa_gdd)))

usne <- ne_states(country = "United States of America") |>
  filter(region %in% c("Northeast", "Midwest", "South"))

pa <- usne |> filter(name == "Pennsylvania")

pa_gdd_anim <- ggplot() +
  geom_spatraster(data = pa_gdd) +
  scale_fill_viridis_c(
    option = "inferno",
    na.value = "transparent"
  ) +
  transition_manual(lyr) +
  theme_bw() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  labs(
    title = "Accumulated growing degree days (2017): {current_frame}",
    fill = ""
  )


gganimate::animate(pa_gdd_anim, duration = 12, renderer = gifski_renderer())

gganimate::anim_save(filename = "plots/pa_gdd.gif")
