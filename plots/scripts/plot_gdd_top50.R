library(mixtools)
library(tidyverse)

source("R/mix_mods.R")

plants_gdd <- readRDS("data/floral_gdd.rds") |> sf::st_drop_geometry()

# all plants
fromtop <- names(sort(table(plants_gdd$scientificName), decreasing = TRUE))

mixmods <- list()
for(g in seq_along(fromtop)){
  sp.g <- plants_gdd %>%
    dplyr::filter(scientificName == fromtop[g]) %>%
    dplyr::filter(!is.na(gdd))

  mixmods[[fromtop[g]]] <- fitmix(sp.g$gdd)

}

mixdists <- lapply(mixmods, make_dist_mix, 50) %>% bind_rows(.id = "scientificName") %>%
  mutate(scientificName = fct_relevel(scientificName, names(mixmods)))

# facet plot
plants_mix <- plants_gdd %>% dplyr::filter(scientificName %in% names(mixmods)) %>%
  mutate(scientificName = fct_relevel(scientificName, names(mixmods)))

# obs count
plants_obs_count <- table(plants_gdd$scientificName)[names(mixmods)] %>% as.data.frame() %>%
  rename(scientificName = Var1) %>%
  mutate(scientificName = fct_relevel(scientificName, names(mixmods)))

# facet plot first 50

mix_plot_50 <- ggplot(plants_mix %>% dplyr::filter(scientificName %in% names(mixmods)[1:50]), aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists %>% dplyr::filter(scientificName %in% names(mixmods)[1:50]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(scientificName %in% names(mixmods)[1:50]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ scientificName, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("red3","turquoise4","burlywood4"))+
  egg::theme_article() +
  theme(legend.position = "none")

# next 50
mix_plot_100 <- ggplot(plants_mix %>% dplyr::filter(scientificName %in% names(mixmods)[51:100]), aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists %>% dplyr::filter(scientificName %in% names(mixmods)[51:100]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(scientificName %in% names(mixmods)[51:100]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ scientificName, scales = "free_y", ncol = 2) +
  scale_color_manual(values = c("red3","turquoise4","burlywood4"))+
  egg::theme_article() +
  theme(legend.position = "none")

ggsave("plots/mixture_worked0-50v2.png", mix_plot_50, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)
ggsave("plots/mixture_worked50-100v2.png", mix_plot_100, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)
