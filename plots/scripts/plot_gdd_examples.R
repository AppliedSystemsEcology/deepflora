library(tidyverse)

plants_gdd <- readRDS("data/pa_floral_gdd.rds")

# Cercis canadensis
C_canadensis <- plants_gdd %>% filter(species == "Cercis canadensis")

ggplot(C_canadensis, aes(gdd)) + geom_histogram()

# Solidago
Solidago <- plants_gdd %>% filter(genus == "Solidago")

ggplot(Solidago, aes(gdd)) + geom_histogram() + facet_wrap(~species)
