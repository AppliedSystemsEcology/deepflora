subset_labels <- c(
  "full" = "All",
  "floralres" = "Bee flowers"
)

state_labels <- c(
  "pa" = "PA",
  "ny" = "NY"
)

model_labels <- c(
  "db" = "Deepbiosph.",
  "bioclim" = "Bioclim MLP",
  "tresnet" = "TResNet",
  "maxent" = "Maxent",
  "rf" = "Rand. Forest"
)

# Map your metric column values to display labels
metric_labels <- c(
  "calibrated_PRC_AUC" = "calibrated~AUC[PRC]",
  "calibrated_ROC_AUC" = "calibrated~AUC[ROC]",
  "f1_score"           = "F1~score",
  "PRC_AUC"            = "AUC[PRC]",
  "precision_score"    = "Precision~score",
  "recall_score"       = "Recall~score",
  "ROC_AUC"            = "AUC[ROC]",
  "species_top1"       = "Top~'1'[spp]",
  "species_top100"     = "Top~'100'[spp]",
  "species_top30"      = "Top~'30'[spp]",
  "species_top5"       = "Top~'5'[spp]",
  "zero_one_accuracy"  = "Presence~accuracy"
)

# Desired panel order
metric_order <- c(
  "zero_one_accuracy", "calibrated_PRC_AUC", "calibrated_ROC_AUC",
  "PRC_AUC", "ROC_AUC",  "precision_score",   "recall_score", "f1_score",
  "species_top1", "species_top5","species_top30","species_top100")

# plotting function
plot_state_subset <- function(panel.metric, data, data.medians, stat.results){

  outplot <- ggplot(data %>% dplyr::filter(metric == panel.metric),
                    aes(x = model, y = value, fill = model, color = model)) +
    geom_violin(alpha = 0.35, trim = TRUE, scale = "width", linewidth = 0.3) +
    geom_jitter(width = 0.08, size = 0.6, alpha = 0.25, shape = 16) +
    geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0,
                 color = "black", linewidth = 0.4) +
    geom_text(
      data = data.medians %>% dplyr::filter(metric == panel.metric),
      aes(x = model, y = med, label = med),
      inherit.aes = FALSE,
      size = 2.2, fontface = "bold", vjust = -0.5
    ) +
    # Use precomputed stats instead of computing inside geom_signif
    ggpubr::stat_pvalue_manual(
      stat.results %>% dplyr::filter(metric == panel.metric),
      label = "empty",
      tip.length    = 0.08,
      step.increase = 0,
      size          = 2.5,
      step.group.by = "metric",
      hide.ns       = FALSE             # set TRUE to drop NS. brackets
    ) +
    ggpubr::stat_pvalue_manual(
      stat.results %>% dplyr::filter(metric == panel.metric),
      vjust = -0.5, size = 3,
      x = "group2",
      label         = "p.adj.signif",   # uses the *** / NS. symbols
    ) +
    # scale_fill_manual(values  = model_colors) +
    # scale_color_manual(values = model_colors) +
    scale_y_continuous(limits = c(0, 1.25),   # extra headroom for brackets
                       breaks = c(0, 0.25, 0.50, 0.75, 1.00)) +
    scale_x_discrete(labels = model_labels) +
    facet_grid(state ~ subset,
               labeller = as_labeller(c(subset_labels, state_labels))
    ) +
    labs(title = parse(text = metric_labels[panel.metric])) +
    theme_bw(base_size = 9) +
    theme(
      legend.position    = "none",
      axis.text.x        = element_text(angle = 45, hjust = 1, size = 7),
      axis.text.y        = element_text(size = 7),
      axis.title         = element_blank(),
      strip.background   = element_blank(),
      strip.text         = element_text(size = 8, face = "bold"),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank()
    )
}

# plotting function
plot_state_spatcv <- function(panel.metric, data, data.medians, stat.results){

  outplot <- ggplot(data %>% dplyr::filter(metric == panel.metric),
                    aes(x = model.code, y = value, fill = model.code, color = model.code)) +

    geom_violin(alpha = 0.35, trim = TRUE, scale = "width", linewidth = 0.3) +
    geom_jitter(width = 0.08, size = 0.8, shape = 16) +
    geom_boxplot(width = 0.15, outlier.shape = NA, alpha = 0,linewidth = 0.4) +
    # geom_point(data=data %>% dplyr::filter(metric == panel.metric), color = "grey15", pch=1, size=2) +
    geom_text(
      data = data.medians %>% dplyr::filter(metric == panel.metric),
      aes(x = model.code, y = med, label = med),
      inherit.aes = FALSE,
      size = 2.2, fontface = "bold", vjust = -0.5
    ) +
    # Use precomputed stats instead of computing inside geom_signif
    # ggpubr::stat_pvalue_manual(
    #   stat.results %>% dplyr::filter(metric == panel.metric),
    #   label = "empty",
    #   tip.length    = 0.08,
    #   step.increase = 0,
    #   size          = 2.5,
    #   step.group.by = "metric",
    #   hide.ns       = FALSE             # set TRUE to drop NS. brackets
    # ) +
    ggpubr::stat_pvalue_manual(
      stat.results %>% dplyr::filter(metric == panel.metric),
      vjust = -0.5, size = 3,
      x = "group2",
      label         = "p.adj.signif",   # uses the *** / NS. symbols
    ) +
    # scale_fill_manual(values  = model_colors) +
    # scale_color_manual(values = model_colors) +
    scale_y_continuous(limits = c(0, 1.25),   # extra headroom for brackets
                       breaks = c(0, 0.25, 0.50, 0.75, 1.00)) +
    scale_x_discrete(labels = model_labels) +
    facet_wrap( ~ state, ncol = length(levels(data$state)),
               labeller = as_labeller(c(state_labels, metric_labels))
    ) +
    labs(title = parse(text = metric_labels[panel.metric])) +
    theme_bw(base_size = 9) +
    theme(
      legend.position    = "none",
      axis.text.x        = element_text(angle = 45, hjust = 1, size = 7),
      axis.text.y        = element_text(size = 7),
      axis.title         = element_blank(),
      strip.background   = element_blank(),
      strip.text         = element_text(size = 8, face = "bold"),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank()
    )
}
