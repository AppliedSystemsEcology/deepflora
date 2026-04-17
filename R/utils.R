# useful spatial functions
require(sp)
require(dplyr)

# convert c to f
c2f <- function(cdeg) {
  9/5 * cdeg + 32
}

# combine prismgrid with week (gdd) data
gdd.map <- function(x, prism=prismgrid, states=statesgrid) {

  thismap <- as(prism, "SpatialGridDataFrame")

  thismap@data <- data.frame(thismap@data, x)
  thismap <- stack(thismap)
  thismap[is.na(states)] <- NA

  thismap

}

# function to extract a species and date
findsp <- function(sp, allplants = plants, startyr = 2016, endyr = 2020){

  thisdat <- subset(allplants, grepl(sp, scientificName))
  thisdat <- thisdat[complete.cases(thisdat), ]
  thisdat <- subset(thisdat, format(thisdat$eventDate, "%Y") >= startyr &
                      format(thisdat$eventDate, "%Y") <= endyr)
  thisdat$year <- format(thisdat$eventDate, "%Y")
  thisdat$week <- factor(format(thisdat$eventDate, "%V"), levels = sprintf("%02d", 1:52))
  thisdat$day <- format(thisdat$eventDate, "%j")
  thisdat <- subset(thisdat, !is.na(week))

  return(thisdat)
}


# give a prismgrid index, get the gdd
getgdd <- function(prismid, year, week, prism.index = prismdf){
  matrix.index <- prism.index %>% filter(id == prismid) %>% pull(index)

  yeardata <- get(paste("week",year,sep=""))
  gdd <- yeardata[matrix.index,week]

  return(gdd)
}

getgddvec <- Vectorize(getgdd)

# get likely flowering range based on Sarah's code
phenotrim <-  function(x, targetdiff = 4, weekmin = 1, weekmax = 52) {

  x <- as.vector(table(x))
  x <- 100 * x / max(x)

  xdiff <- abs(diff(c(0, x)))

  xdat <- data.frame(week = weekmin:weekmax,
                     x = x, xdiff = xdiff, flower = x)

  xdat$xdiff[xdat$week < weekmin] <- 0
  xdat$xdiff[xdat$week > weekmax] <- 0

  i <- weekmin
  while(xdat[i, "xdiff"] < targetdiff) {
    xdat$flower[i] <- NA
    i <- i + 1
  }

  i <- weekmax
  while(xdat[i, "xdiff"] < targetdiff) {
    xdat$flower[i] <- NA
    i <- i - 1
  }

  xrange <- range(xdat$week[!is.na(xdat$flower)])
  xmax <- xdat$week[min(which(xdat$flower == max(xdat$flower, na.rm=TRUE)))]

  c(xrange, xmax)

}

# fit different shapes using Sarah's code
rtrim <- function(x, trimrange) {
  xlevels <- levels(x)
  x <- as.numeric(x)
  x <- x[x >= trimrange[1] & x <= trimrange[2]]

  factor(x, levels = seq_len(length(xlevels)))

}


fit.all <- function(y, trim = FALSE, ...) {

  if(trim) {
    prange <- phenotrim(y, ...)
    y <- rtrim(y, trimrange = prange[c(1,2)])
  }


  y <- table(y)
  y <- 100 * y / sum(y)
  y <- cumsum(y)

  x = names(y)

  dat <- data.frame(x=as.numeric(x), y = y)
  list(
    l3 = try(nls(y ~ SSlogis(x, Asym, ymid, scal), data = dat), silent = TRUE),
    l4 = try(nls(y ~ SSfpl(x, A, B, xmid, scal), data = dat), silent = TRUE),
    w  = try(nls(y ~ SSweibull(x, Asym, Drop, lrc, pwr), data = dat), silent = TRUE),
    g  = try(nls(y ~ SSgompertz(x, Asym, b2, b3), data = data.frame(x = seq_len(52), y =  ifelse(y == 0, .1, y))), silent = TRUE))

}

pred.fit.all <- function(x, repnum=52){
  testgood <- function(maybe.model){
    if(class(maybe.model)=="try-error"){
      rep(NA, repnum)
    }else{
      diff(c(0, predict(maybe.model)))
    }
  }

  l3.pred <- testgood(x$l3)
  l4.pred <- testgood(x$l4)
  w.pred <- testgood(x$w)
  g.pred <- testgood(x$g)

  return(data.frame(model = rep(c("l3", "l4", "w", "g"), each=repnum),
                    week = rep(seq_len(repnum), times=4),
                    pred = c(l3.pred, l4.pred, w.pred, g.pred)))
}

##### fit weibull with manually provided trim range (seasons) #####

# season reference
seasonref <- data.frame(
  season = c("Spring", "Summer", "Fall"),
  week = c(11, 25, 38),
  gdd = c(250, 2400, 6000),
  gddlevel = c(3, 25, 61)
)

gddbinref <- data.frame(gdd = seq(1:4600)) %>%
  mutate(gddbin = cut(gdd, breaks=seq(-1,4600, by = 100),
                      labels=seq(100,4600, by = 100))) %>%
  mutate(gddlevel = as.numeric(gddbin)) %>% select(-gdd) %>% distinct() %>%
  na.omit()

fit.wei <- function(y,
                    trim = FALSE, trim.by = NULL,
                    splookupname = NULL,
                    seasons = seasonref, plantdata = selected.plants) {

  if(trim) {
    bloom.season = plantdata %>% filter(scientificName == splookupname) %>%
      pull(Season)
    trim.begin = min(seasonref[seasonref$season==bloom.season, trim.by])
    trim.end = max(lead(seasonref[,trim.by])[seasonref$season==bloom.season])
    if(is.na(trim.end)){. # if end of range is NA (for fall)
      trim.end <- Inf
    }

    y <- rtrim(y, trimrange = c(trim.begin-1, trim.end+1)) # widen the window by 1
  }


  y.cum <- table(y)
  y.cum <- 100 * y.cum / sum(y.cum)
  y.cum <- cumsum(y.cum)

  x = names(y.cum)

  dat <- data.frame(x=as.numeric(x), y = y.cum)
  w  = try(nls(y ~ SSweibull(x, Asym, Drop, lrc, pwr), data = dat), silent = TRUE)
  return(list(w, table(y)))
}
