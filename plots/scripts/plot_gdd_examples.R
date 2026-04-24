library(tidyverse)
library(mixtools)
# https://dozenoaks.twelvetreeslab.co.uk/2019/06/mixture-models/

make_dists <- function(mean, sd, lambda, n, binwidth, ...) {
  stat_function(
    fun = function(x) {
      (dnorm(x, mean = mean, sd = sd)) * n * binwidth * lambda
      },
    ...
    )
  }

plants_gdd <- readRDS("data/pa_floral_gdd.rds") |> sf::st_drop_geometry()

# Cercis canadensis
C_canadensis <- plants_gdd %>% filter(species == "Cercis canadensis")

Cc_mix <- normalmixEM(C_canadensis$gdd, k=3)

Cc_plot_wk <- ggplot(C_canadensis, aes(as.numeric(week))) +
  geom_histogram(binwidth = 1, fill = "palegreen3") +
  labs(x=NULL, y="Count") + xlim(c(0,52)) +
  egg::theme_article()

Cc_plot_gdd <- ggplot(C_canadensis, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()

Cc_plot <- ggplot(C_canadensis, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  mapply(
    make_dists,
    mean = Cc_mix[["mu"]], #mean
    sd = Cc_mix[["sigma"]], #standard deviation
    lambda = Cc_mix[["lambda"]], #amplitude
    n = length(C_canadensis$gdd), #sample size
    binwidth = 50, #binwidth used for histogram
    color = c("red3","turquoise4","burlywood4"),
    lwd = 1
  ) + labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()


ggsave("plots/phen_Cc_wk.png", Cc_plot_wk, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_Cc_gdd.png", Cc_plot_gdd, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_Cc_mix.png", Cc_plot, height = 2, width = 3.5, units = "in", bg="white")

# Solidago
S_rugosa <- plants_gdd %>% filter(species == "Solidago rugosa")

Sr_mix <- normalmixEM(S_rugosa$gdd)

Sr_plot_wk <- ggplot(S_rugosa, aes(as.numeric(week))) +
  geom_histogram(binwidth = 1, fill = "palegreen3") +
  labs(x=NULL, y="Count") + xlim(c(0,52)) +
  egg::theme_article()

Sr_plot_gdd <- ggplot(S_rugosa, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()

Sr_plot <- ggplot(S_rugosa, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  mapply(
    make_dists,
    mean = Sr_mix[["mu"]], #mean
    sd = Sr_mix[["sigma"]], #standard deviation
    lambda = Sr_mix[["lambda"]], #amplitude
    n = length(S_rugosa$gdd), #sample size
    binwidth = 50, #binwidth used for histogram
    color = c("red3","turquoise4"),
    lwd = 1
  ) + labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()

ggsave("plots/phen_Sr_wk.png", Sr_plot_wk, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_Sr_gdd.png", Sr_plot_gdd, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_Sr_mix.png", Sr_plot, height = 2, width = 3.5, units = "in", bg="white")

# Asclepias tuberosa
A_tuberosa <- plants_gdd %>% filter(species == "Asclepias tuberosa")
At_mix <- normalmixEM(A_tuberosa$gdd)

At_plot_wk <- ggplot(A_tuberosa, aes(as.numeric(week))) +
  geom_histogram(binwidth = 1, fill = "palegreen3") +
  labs(x=NULL, y="Count") + xlim(c(0,52)) +
  egg::theme_article()

At_plot_gdd <- ggplot(A_tuberosa, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()

At_plot <- ggplot(A_tuberosa, aes(gdd)) +
  geom_histogram(binwidth = 50, fill = "tan1") +
  mapply(
    make_dists,
    mean = At_mix[["mu"]], #mean
    sd = At_mix[["sigma"]], #standard deviation
    lambda = At_mix[["lambda"]], #amplitude
    n = length(A_tuberosa$gdd), #sample size
    binwidth = 50, #binwidth used for histogram
    color = c("red3","turquoise4"),
    lwd = 1
  ) + labs(x=NULL, y="Count") + xlim(c(0,3400)) +
  egg::theme_article()

ggsave("plots/phen_At_wk.png", At_plot_wk, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_At_gdd.png", At_plot_gdd, height = 2, width = 3.5, units = "in", bg="white")
ggsave("plots/phen_At_mix.png", At_plot, height = 2, width = 3.5, units = "in", bg="white")

# curves together

plot_flr <- ggplot() +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = Sr_mix[["mu"]][2], sd = Sr_mix[["sigma"]][2])
    }, n=1000, geom = "area", fill = "goldenrod", alpha = 0.5
  ) +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = Cc_mix[["mu"]][2], sd = Cc_mix[["sigma"]][2])
    }, n=1000, geom = "area", fill = "violetred", alpha = 0.5
  ) +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = At_mix[["mu"]][1], sd = At_mix[["sigma"]][1])
    }, n=1000, geom = "area", fill = "darkorange", alpha = 0.5
  ) +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = Sr_mix[["mu"]][2], sd = Sr_mix[["sigma"]][2])
    }, n=1000, color = "goldenrod",
  ) +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = Cc_mix[["mu"]][2], sd = Cc_mix[["sigma"]][2])
    }, n=1000, color = "violetred",
  ) +
  stat_function(
    fun = function(x) {
      dnorm(x, mean = At_mix[["mu"]][1], sd = At_mix[["sigma"]][1])
    }, n=1000, color = "darkorange",
  ) +
  xlim(c(0,3400)) + labs(x="Growing degree day", y="Probability density") +
  egg::theme_article()

ggsave("plots/phen_allflr.png", plot_flr, height = 3, width = 4, units = "in", bg="white")
