
model_labels <- c(
  "db" = "Deepbiosph.",
  "initial" = "Deepbiosph.",
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
