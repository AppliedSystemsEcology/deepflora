library(tidyverse)

# gbif data - combine by species column, scientificName has subsp. that deepbiosphere ignores
plants_pa <- read.csv("data-raw/big/plants_pa_2017.csv", sep = "\t") |>
  select(genus, species, scientificName) |> filter(species != "") |>
  group_by(genus, species) |> summarize(n = n(), .groups = "drop")
plants_ny <- read.csv("data-raw/big/plants_ny_2017.csv", sep = "\t") |>
  select(genus, species, scientificName) |> filter(species != "") |>
  group_by(genus, species) |> summarize(n = n(), .groups = "drop")

combined_sp <- bind_rows(list(pa=plants_pa, ny=plants_ny), .id="state") |>
  pivot_wider(names_from = state, values_from = n, values_fill = 0) |>
  mutate(
    total = pa+ny,
    pa.pc = 100*pa/total,
    ny.pc = 100*ny/total
  )

write.csv(combined_sp, "data/combined_sp.csv", row.names = FALSE)
