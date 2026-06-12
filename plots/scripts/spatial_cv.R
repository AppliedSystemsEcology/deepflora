library(tidyverse)
library(DT)
library(rstatix)
library(ggsignif)

overall <- read.csv("data/results/overall-accuracy.csv")
source("R/plot_standards.R")

# spacing in brackets
# setspacing <- Vectorize(\(x) switch(as.character(x), bioclim = 1, tresnet = 1.1, maxent = 1.2, rf = 1.3))

df <- overall %>% filter(band.code != "band-1") %>%
  filter(metric %in% metric_order) %>%
  mutate(
    model.code  = factor(model.code, levels = names(model_labels)),
    state = factor(state, levels = names(state_labels)),
    metric = factor(metric, levels = metric_order)
  ) %>% droplevels()


stat_results_cv <- df %>%
  arrange(state, metric, band, model.code) %>%  # same species order for every model
  group_by(state, metric) %>%
  wilcox_test(
    value ~ model.code,
    ref.group   = "db",
    # paired      = TRUE,
    p.adjust.method = "BH"        # correct for multiple comparisons within metric
  ) %>%
  add_significance(
    p.col = "p.adj",
    cutpoints = c(0, 0.001, 0.01, 0.05, 1),
    symbols   = c("***", "**", "*", "NS.")
  ) %>%
  add_xy_position(
    x     = "model",
    dodge = 0.8,
    # step.increase = 0.07   # ggsignif needs y positions for bracket heights
    scales = "fixed"
  ) %>%
  dplyr::mutate(y.position = 1.1, empty = "")


medians <- df %>% filter(band > -1) %>%
  group_by(state, metric, model.code) %>%
  summarise(med = round(median(value, na.rm = TRUE), 3), .groups = "drop")
means <- df %>% filter(band > -1) %>%
  group_by(state, metric, model.code) %>%
  summarise(mean = round(mean(value, na.rm = TRUE), 3), .groups = "drop")

for(g in seq_along(metric_labels)){
  metric.g <- plot_state_spatcv(names(metric_labels)[g], df, medians, stat_results_cv)
  ggsave(paste0("plots/accuracy-metrics/spatcv/",names(metric_labels)[g],".png"),
         metric.g, height = 3, width =4, dpi=300,bg="white")
}

# p <- ggplot(df %>% dplyr::filter(band > -1),
#                 aes(x = model.code, y = value, fill = model.code, color = model.code)) +
#
#   geom_violin(alpha = 0.35, trim = TRUE, scale = "width", linewidth = 0.3) +
#   geom_jitter(width = 0.08, size = 0.8, shape = 16) +
#   geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0,linewidth = 0.4) +
#   geom_point(data=df %>% dplyr::filter(band == -1), color = "grey15", pch=1, size=2) +
#   geom_text(
#     data = medians,
#     aes(x = model.code, y = med, label = med),
#     inherit.aes = FALSE,
#     size = 2.2, fontface = "bold", vjust = -0.5
#   ) +
#   # Use precomputed stats instead of computing inside geom_signif
#   # ggpubr::stat_pvalue_manual(
#   #   stat_results_cv,
#   #   label = "empty",
#   #   tip.length    = 0.08,
#   #   step.increase = 0,
#   #   size          = 2.5,
#   #   step.group.by = "metric",
#   #   hide.ns       = FALSE             # set TRUE to drop NS. brackets
#   # ) +
#   ggpubr::stat_pvalue_manual(
#     stat_results_cv,
#     vjust = -0.5, size = 3,
#     x = "group2",
#     label         = "p.adj.signif",   # uses the *** / NS. symbols
#   ) +
#   # scale_fill_manual(values  = model_colors) +
#   # scale_color_manual(values = model_colors) +
#   scale_y_continuous(limits = c(0, 1.25),   # extra headroom for brackets
#                      breaks = c(0, 0.25, 0.50, 0.75, 1.00)) +
#   scale_x_discrete(labels = model_labels) +
#   facet_grid(state ~ metric,
#              labeller = as_labeller(c(state_labels, metric_labels))
#   ) +
#
#   theme_bw(base_size = 9) +
#   theme(
#     legend.position    = "none",
#     axis.text.x        = element_text(angle = 45, hjust = 1, size = 7),
#     axis.text.y        = element_text(size = 7),
#     axis.title         = element_blank(),
#     strip.background   = element_blank(),
#     strip.text         = element_text(size = 8, face = "bold"),
#     panel.grid.minor   = element_blank(),
#     panel.grid.major.x = element_blank()
#   )


# ggsave("plots/accuracy-metrics/spatcv/compare_spatial_cv_full.png", p, height = 8, width =6, dpi=300,bg="white")
