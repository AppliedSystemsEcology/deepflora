library(terra)
# give a prismgrid index, get the gdd

# load gdd
load("data-raw/gdd/week2016.RDS")
load("data-raw/gdd/week2017.RDS")
load("data-raw/gdd/week2018.RDS")
load("data-raw/gdd/week2019.RDS")
load("data-raw/gdd/week2020.RDS")

prismgrid <- terra::rast("data/prismgrid_wgs84.tif")

prismdf <- readRDS("data/prismids.rds")

querygdd <- function(year, week, matrix.index){
  yeardata <- get(paste("week",year,sep=""))
  yeardata[matrix.index,week]
}

getgdd_prismid <- function(prismid, year, week, prism.index = prismdf){
  matrix.index <- sapply(prismid, \(x) prism.index[match(x, prism.index$id),"index"])
  gdd <- mapply(querygdd, year = year, week = week, matrix.index = matrix.index)
  return(gdd)
}

event_to_week <- function(eventDate){
  eventDate <- as.Date(eventDate)
  factor(format(eventDate, "%V"), levels = sprintf("%02d", 1:52))
}

get_gdd <- function(eventDate, lat, lon){
  eventYear <- as.Date(eventDate) |> format("%Y")
  eventWeek <- event_to_week(eventDate)
  eventPrismid <- terra::extract(prismgrid, data.frame(lon,lat), cells=FALSE, xy=FALSE, ID=FALSE)[[1]]

  getgdd_prismid(eventPrismid, eventYear, eventWeek)
}
