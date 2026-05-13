library(mixtools)
library(tidyverse)

source("R/mix_mods.R")

plants_gdd <- readRDS("data/pa_floral_gdd.rds") |> sf::st_drop_geometry()

# top 50
top50 <- names(sort(table(plants_gdd$scientificName), decreasing = TRUE))[1:50]

mixmods50 <- list()
for(g in seq_along(top50)){
  sp.g <- plants_gdd %>%
    dplyr::filter(scientificName == top50[g]) %>%
    dplyr::filter(!is.na(gdd))

  mixmods50[[top50[g]]] <- fitmix(sp.g$gdd)

}

mixdists50 <- lapply(mixmods50, make_dist_mix, 50) %>% bind_rows(.id = "scientificName")

# facet plot
plants_top50 <- plants_gdd %>% dplyr::filter(scientificName %in% top50)

mix_plot <- ggplot(plants_top50, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists50, mapping = aes(x = x, y = y, color = dist)) +
  facet_wrap(~ scientificName, scales = "free_y", ncol = 5) +
  scale_color_manual(values = c("red3","turquoise4"))+
  egg::theme_article() +
  theme(legend.position = "none")

ggsave("plots/mixture_top50.png", mix_plot, width = 12, height = 16, bg = "white", dpi = 300)
