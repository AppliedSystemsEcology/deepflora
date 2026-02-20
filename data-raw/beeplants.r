library(tidyverse)
beeplants <- read.csv("data-raw/beeplants.csv")
beeplants_fowler <- read.csv("data-raw/beeplants_Fowler2016.csv")

beeplant_sep <- beeplants %>%
  separate_wider_delim(scientificName, delim=" ",
                       names=c("genus","sp"),
                       too_few = "align_start",
                       cols_remove = FALSE)

beeplant_genus <- beeplant_sep %>% filter(sp == "spp" | is.na(sp)) %>%
  filter(!duplicated(genus)) %>% select(-Season, -sp, -scientificName)

beeplant_sp <- beeplant_sep %>% filter(sp != "spp" & !is.na(sp)) %>% filter(!duplicated(scientificName)) %>%
  select(-Season, -groupName) %>% mutate(source = "Grozinger") %>%
  bind_rows(
    beeplants_fowler %>% select(Scientific, Common) %>%
      rename(scientificName = Scientific, commonName = Common) %>%
      mutate(scientificName = gsub("\\(Swida\\) ","",scientificName)) %>%
      separate_wider_delim(scientificName, delim=" ",
                           names=c("genus","sp"),
                           too_few = "align_start",
                           cols_remove = FALSE) %>%
      mutate(source = "Fowler")
  ) %>%
  filter(!duplicated(scientificName))



saveRDS(list(genus = beeplant_genus, species = beeplant_sp), "data/beeplants.rds")
