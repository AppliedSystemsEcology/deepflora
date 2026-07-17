library(mixtools)
library(tidyverse)

source("R/mix_mods.R")

plants_gdd <- readRDS("data/top100_gdd.rds")

# all plants
fromtop <- names(sort(table(plants_gdd$species), decreasing = TRUE))

mixmods <- list()
for(g in seq_along(fromtop)){
  sp.g <- plants_gdd %>%
    dplyr::filter(species == fromtop[g]) %>%
    dplyr::filter(!is.na(gdd))

  mixmods[[fromtop[g]]] <- fitmix(sp.g$gdd)  # TODO: catch errors/warnings

}

mixdists <- lapply(mixmods, make_dist_mix, 50) %>% bind_rows(.id = "species") %>%
  mutate(species = fct_relevel(species, names(mixmods)))

# facet plot
plants_mix <- plants_gdd %>% dplyr::filter(species %in% names(mixmods)) %>%
  mutate(species = fct_relevel(species, names(mixmods)))

# obs count
plants_obs_count <- table(plants_gdd$species)[names(mixmods)] %>% as.data.frame() %>%
  rename(species = Var1) %>%
  mutate(species = fct_relevel(species, names(mixmods)))

# reproductive conditions dataset
repstages <- unique(plants_gdd$reproductiveCondition)
repstage_flr <- c("flowers", "flowers|fruits or seeds", "flower buds", "flowers|flower buds", "flowers|fruits or seeds|flower buds", "fruits or seeds|flower buds")
flr_gdd <- plants_gdd |> dplyr::filter(reproductiveCondition %in% repstage_flr)

# phenovision dataset
phenovis <- read.csv("data/pheno_sp.csv") |> rename(species = scientific_name) |>
  mutate(trait = fct_recode(trait, `Phenovision fruit` = "fruit", `Phenovision flower` = "flower"))

# facet plot first 50

mix_plot_50 <- ggplot(plants_mix %>% dplyr::filter(species %in% names(mixmods)[1:50]), aes(gdd)) +
  geom_histogram(aes(fill = "All iNat"), binwidth = 50) +
  geom_histogram(data = phenovis %>% dplyr::filter(species %in% names(mixmods)[1:50]) %>%
                   mutate(species = fct_relevel(species, names(mixmods))),
                 aes(fill = trait),
                 binwidth = 50, position = "stack", alpha = 0.6) +
  geom_histogram(data = flr_gdd %>% dplyr::filter(species %in% names(mixmods)[1:50]) %>%
                   mutate(species = fct_relevel(species, names(mixmods))),
                 aes(fill = "Annotated iNat"), color = "black", binwidth = 50) +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists %>% dplyr::filter(species %in% names(mixmods)[1:50]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(species %in% names(mixmods)[1:50]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ species, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    name = NULL,
    values = c(
      "All iNat" = "gray",
      "Phenovision flower" = "orange",
      "Phenovision fruit" = "purple",
      "Annotated iNat" = NA
    )
  ) +
  scale_color_manual(
    name = "Mix mod distr.",
    values = c(
      "1" = "red3",
      "2" = "turquoise4",
      "3" = "burlywood4"
      )
    ) +
  egg::theme_article() +
  theme(legend.position = "top")

# next 50
mix_plot_100 <- ggplot(plants_mix %>% dplyr::filter(species %in% names(mixmods)[51:100]), aes(gdd)) +
  geom_histogram(aes(fill = "All iNat"), binwidth = 50) +
  geom_histogram(data = phenovis %>% dplyr::filter(species %in% names(mixmods)[51:100]) %>%
                   mutate(species = fct_relevel(species, names(mixmods))),
                 aes(fill = trait),
                 binwidth = 50, position = "stack", alpha = 0.6) +
  geom_histogram(data = flr_gdd %>% dplyr::filter(species %in% names(mixmods)[51:100]) %>%
                   mutate(species = fct_relevel(species, names(mixmods))),
                 aes(fill = "Annotated iNat"), color = "black", binwidth = 50) +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists %>% dplyr::filter(species %in% names(mixmods)[51:100]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(species %in% names(mixmods)[51:100]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ species, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    name = NULL,
    values = c(
      "All iNat" = "gray",
      "Phenovision flower" = "orange",
      "Phenovision fruit" = "purple",
      "Annotated iNat" = NA
    )
  ) +
  scale_color_manual(
    name = "Mix mod distr.",
    values = c(
      "1" = "red3",
      "2" = "turquoise4",
      "3" = "burlywood4"
    )
  ) +
  egg::theme_article() +
  theme(legend.position = "top")

ggsave("plots/mixture_NE0-50v2.png", mix_plot_50, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)
ggsave("plots/mixture_NE50-100v2.png", mix_plot_100, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)


# THINNING

plants_gdd.thin <- plants_gdd %>% sf::st_drop_geometry() %>%
  group_by(species, year, week, prismid, gdd) %>%
  summarize(n=n(), .groups = "drop")

fromtop.thin <- names(sort(table(plants_gdd.thin$species), decreasing = TRUE))

mixmods.thin <- list()
for(g in seq_along(fromtop.thin)){
  sp.g <- plants_gdd.thin %>%
    dplyr::filter(species == fromtop.thin[g]) %>%
    dplyr::filter(!is.na(gdd))

  mixmods.thin[[fromtop.thin[g]]] <- fitmix(sp.g$gdd)  # TODO: catch errors/warnings

}

mixdists.thin <- lapply(mixmods.thin, make_dist_mix, 50) %>% bind_rows(.id = "species") %>%
  mutate(species = fct_relevel(species, names(mixmods.thin)))

# facet plot
plants_mix.thin <- plants_gdd.thin %>% dplyr::filter(species %in% names(mixmods.thin)) %>%
  mutate(species = fct_relevel(species, names(mixmods.thin)))

# obs count
plants_obs_count.thin <- table(plants_gdd.thin$species)[names(mixmods.thin)] %>% as.data.frame() %>%
  rename(species = Var1) %>%
  mutate(species = fct_relevel(species, names(mixmods.thin)))

# reproductive conditions dataset thinned
flr_gdd.thin <- flr_gdd %>% sf::st_drop_geometry() %>%
  group_by(species, year, week, prismid, gdd) %>%
  summarize(flowering = TRUE, n.flr=n(), .groups = "drop")

# phenovision dataset thinned
phenovis.thin <- phenovis %>%
  group_by(species, year, week, trait, prismid, gdd) %>%
  summarize(n=n(), .groups = "drop")

# thinned facet plot first 50

mix_plot_50.thin <- ggplot(plants_mix.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]), aes(gdd)) +
  geom_histogram(aes(fill = "All iNat"), binwidth = 50) +
  geom_histogram(data = phenovis.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]) %>%
                   mutate(species = fct_relevel(species, names(mixmods.thin))),
                 aes(fill = trait),
                 binwidth = 50, position = "stack", alpha = 0.6) +
  geom_histogram(data = flr_gdd.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]) %>%
                   mutate(species = fct_relevel(species, names(mixmods.thin))),
                 aes(fill = "Annotated iNat"), color = "black", binwidth = 50) +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ species, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    name = NULL,
    values = c(
      "All iNat" = "gray",
      "Phenovision flower" = "orange",
      "Phenovision fruit" = "purple",
      "Annotated iNat" = NA
    )
  ) +
  scale_color_manual(
    name = "Mix mod distr.",
    values = c(
      "1" = "red3",
      "2" = "turquoise4",
      "3" = "burlywood4"
    )
  ) +
  egg::theme_article() +
  theme(legend.position = "top")

# next 50
mix_plot_100.thin <- ggplot(plants_mix.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]), aes(gdd)) +
  geom_histogram(aes(fill = "All iNat"), binwidth = 50) +
  geom_histogram(data = phenovis.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]) %>%
                   mutate(species = fct_relevel(species, names(mixmods.thin))),
                 aes(fill = trait),
                 binwidth = 50, position = "stack", alpha = 0.6) +
  geom_histogram(data = flr_gdd.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]) %>%
                   mutate(species = fct_relevel(species, names(mixmods.thin))),
                 aes(fill = "Annotated iNat"), color = "black", binwidth = 50) +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  geom_line(data = mixdists.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]),
            mapping = aes(x = x, y = y, color = dist)) +
  geom_text(
    data = plants_obs_count %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]),
    mapping = aes(x = Inf, y = Inf, label = Freq),
    hjust   = 1.1,
    vjust   = 1.2) +
  facet_wrap(~ species, scales = "free_y", ncol = 2) +
  scale_fill_manual(
    name = NULL,
    values = c(
      "All iNat" = "gray",
      "Phenovision flower" = "orange",
      "Phenovision fruit" = "purple",
      "Annotated iNat" = NA
    )
  ) +
  scale_color_manual(
    name = "Mix mod distr.",
    values = c(
      "1" = "red3",
      "2" = "turquoise4",
      "3" = "burlywood4"
    )
  ) +
  egg::theme_article() +
  theme(legend.position = "top")

# mix_plot_50.thin <- ggplot(plants_mix.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]), aes(gdd)) +
#   geom_histogram(binwidth = 50, fill = "yellowgreen") +
#   geom_histogram(data = flr_gdd %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]) %>%
#                    mutate(species = fct_relevel(species, names(mixmods.thin))),
#                  binwidth = 50, fill = "tan1") +
#   geom_histogram(data = flr_gdd.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]) %>%
#                    mutate(species = fct_relevel(species, names(mixmods.thin))),
#                  binwidth = 50, fill = "blue") +
#   labs(x=NULL, y="Count") + xlim(c(0,3400)) +
#   geom_line(data = mixdists.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]),
#             mapping = aes(x = x, y = y, color = dist)) +
#   geom_text(
#     data = plants_obs_count.thin %>% dplyr::filter(species %in% names(mixmods.thin)[1:50]),
#     mapping = aes(x = Inf, y = Inf, label = Freq),
#     hjust   = 1.1,
#     vjust   = 1.2) +
#   facet_wrap(~ species, scales = "free_y", ncol = 2) +
#   scale_color_manual(values = c("red3","turquoise4","burlywood4"))+
#   egg::theme_article() +
#   theme(legend.position = "none")
#
# # next 50
# mix_plot_100.thin <- ggplot(plants_mix.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]), aes(gdd)) +
#   geom_histogram(binwidth = 50, fill = "yellowgreen") +
#   geom_histogram(data = flr_gdd %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]) %>%
#                    mutate(species = fct_relevel(species, names(mixmods.thin))),
#                  binwidth = 50, fill = "tan1") +
#   geom_histogram(data = flr_gdd.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]) %>%
#                    mutate(species = fct_relevel(species, names(mixmods.thin))),
#                  binwidth = 50, fill = "blue") +
#   labs(x=NULL, y="Count") + xlim(c(0,3400)) +
#   geom_line(data = mixdists.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]),
#             mapping = aes(x = x, y = y, color = dist)) +
#   geom_text(
#     data = plants_obs_count.thin %>% dplyr::filter(species %in% names(mixmods.thin)[51:100]),
#     mapping = aes(x = Inf, y = Inf, label = Freq),
#     hjust   = 1.1,
#     vjust   = 1.2) +
#   facet_wrap(~ species, scales = "free_y", ncol = 2) +
#   scale_color_manual(values = c("red3","turquoise4","burlywood4"))+
#   egg::theme_article() +
#   theme(legend.position = "none")

ggsave("plots/mixture_NE0-50_thinnedv2.png", mix_plot_50.thin, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)
ggsave("plots/mixture_NE50-100_thinnedv2.png", mix_plot_100.thin, width = 8, height = 48, bg = "white", dpi = 300, limitsize = FALSE)


# write out data
saveRDS(mixmods, "data/results/mixmods_flr100.rds")
saveRDS(plants_gdd.thin %>% left_join(flr_gdd.thin) %>%
          mutate(flowering = replace_values(flowering, NA ~ FALSE),
                 n.flr = replace_values(n.flr, NA ~ 0)), "data/top100_gdd_thin.rds")
saveRDS(mixmods.thin, "data/results/mixmods_flr100_thin.rds")
