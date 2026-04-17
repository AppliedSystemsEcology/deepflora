library(raster)

prismgrid <- raster("~/Desktop/BeePlants/data/prismgrid.grd")
statesgrid <- raster("~/Desktop/BeePlants/data/statesgrid.grd")


####



makecumulative <- function(x) {
	for(i in seq_len(nrow(x))) {
		x[i,] <- cumsum(x[i,])
	}
	x
}

#


makeweek <- function(x, thisyear) {

	thisweek <- seq(as.Date(paste(thisyear, "01", "01", sep="-")), as.Date(paste(thisyear, "12", "31", sep="-")), by = "day")
	thisweek <- format(thisweek, "%V")


	while(thisweek[1] != "01") {
		x <- x[, -1]
		thisweek <- thisweek[-1]
	}

	while(thisweek[length(thisweek)] != "52") {
		x <- x[, -length(thisweek)]
		thisweek <- thisweek[-length(thisweek)]
	}

	byweek <- lapply(seq_len(nrow(x)), function(i) {
					 x <- tapply(x[i,], thisweek, FUN = "max")
					 x})
	byweek <- do.call(rbind, byweek)

	byweek
}




#### fully stable years


filelist <- list.files(pattern = "bil$")
tmean2005 <- lapply(filelist, function(thisfile) {
	infile <- raster(thisfile)
	infile <- crop(infile, extent(prismgrid))
	values(infile)

})
tmean2005 <- do.call(cbind, tmean2005)
dim(tmean2005)
gdd2005 <- tmean2005 - 5
gdd2005[gdd2005 < 0] <- 0
gddcum2005 <- makecumulative(gdd2005)
week2005 <- makeweek(gddcum2005, 2005)
rm(gdd2005)


#### mixed provisional and stable year

filelist <- c(list.files(pattern = "stable.*bil$"), list.files(pattern = "provisional.*bil$"))

tmean2021 <- lapply(filelist, function(thisfile) {

	infile <- raster(thisfile)
	infile <- crop(infile, extent(prismgrid))
	values(infile)

})

tmean2021 <- do.call(cbind, tmean2021)
dim(tmean2021)

temp <- matrix(NA, nrow=nrow(tmean2021), ncol=length(seq(as.Date("2021-11-01"), as.Date("2021-12-31"), by="day")))

tmean2021 <- cbind(tmean2021, temp)
rm(temp)

gdd2021 <- tmean2021 - 5
gdd2021[gdd2021 < 0] <- 0

gddcum2021 <- makecumulative(gdd2021)
week2021 <- makeweek(gddcum2021, 2021)


### fifteen-year summaries

week.mean <- (week2006 +
			  week2007 +
			  week2008 +
			  week2009 +
			  week2010 +
			  week2011 +
			  week2012 +
			  week2013 +
			  week2014 +
			  week2015 +
			  week2016 +
			  week2017 +
			  week2018 +
			  week2019 +
			  week2020) / 15

dev2006 <- week2006 - week.mean
dev2007 <- week2007 - week.mean
dev2008 <- week2008 - week.mean
dev2009 <- week2009 - week.mean
dev2010 <- week2010 - week.mean
dev2011 <- week2011 - week.mean
dev2012 <- week2012 - week.mean
dev2013 <- week2013 - week.mean
dev2014 <- week2014 - week.mean
dev2015 <- week2015 - week.mean
dev2016 <- week2016 - week.mean
dev2017 <- week2017 - week.mean
dev2018 <- week2018 - week.mean
dev2019 <- week2019 - week.mean
dev2020 <- week2020 - week.mean
dev2021 <- week2021 - week.mean


boxplot(data.frame(
	d2006 = dev2006[, 39], 
	d2007 = dev2007[, 39], 
	d2008 = dev2008[, 39], 
	d2009 = dev2009[, 39], 
	d2010 = dev2010[, 39], 
	d2011 = dev2011[, 39], 
	d2012 = dev2012[, 39], 
	d2013 = dev2013[, 39], 
	d2014 = dev2014[, 39], 
	d2015 = dev2015[, 39], 
	d2016 = dev2016[, 39], 
	d2017 = dev2017[, 39], 
	d2018 = dev2018[, 39], 
	d2019 = dev2019[, 39], 
	d2020 = dev2020[, 39], 
	d2021 = dev2021[, 39])) 



save(dev2006, file="data/dev2006.RDS")
save(dev2007, file="data/dev2007.RDS")
save(dev2008, file="data/dev2008.RDS")
save(dev2009, file="data/dev2009.RDS")
save(dev2010, file="data/dev2010.RDS")
save(dev2011, file="data/dev2011.RDS")
save(dev2012, file="data/dev2012.RDS")
save(dev2013, file="data/dev2013.RDS")
save(dev2014, file="data/dev2014.RDS")
save(dev2015, file="data/dev2015.RDS")
save(dev2016, file="data/dev2016.RDS")
save(dev2017, file="data/dev2017.RDS")
save(dev2018, file="data/dev2018.RDS")
save(dev2019, file="data/dev2019.RDS")
save(dev2020, file="data/dev2020.RDS")
save(dev2021, file="data/dev2021.RDS")


save(week2006, file="data/week2006.RDS")
save(week2007, file="data/week2007.RDS")
save(week2008, file="data/week2008.RDS")
save(week2009, file="data/week2009.RDS")
save(week2010, file="data/week2010.RDS")
save(week2011, file="data/week2011.RDS")
save(week2012, file="data/week2012.RDS")
save(week2013, file="data/week2013.RDS")
save(week2014, file="data/week2014.RDS")
save(week2015, file="data/week2015.RDS")
save(week2016, file="data/week2016.RDS")
save(week2017, file="data/week2017.RDS")
save(week2018, file="data/week2018.RDS")
save(week2019, file="data/week2019.RDS")
save(week2020, file="data/week2020.RDS")
save(week2021, file="data/week2021.RDS")


save(gddcum2006, file="data/gddcum2006.RDS")
save(gddcum2007, file="data/gddcum2007.RDS")
save(gddcum2008, file="data/gddcum2008.RDS")
save(gddcum2009, file="data/gddcum2009.RDS")
save(gddcum2010, file="data/gddcum2010.RDS")
save(gddcum2011, file="data/gddcum2011.RDS")
save(gddcum2012, file="data/gddcum2012.RDS")
save(gddcum2013, file="data/gddcum2013.RDS")
save(gddcum2014, file="data/gddcum2014.RDS")
save(gddcum2015, file="data/gddcum2015.RDS")
save(gddcum2016, file="data/gddcum2016.RDS")
save(gddcum2017, file="data/gddcum2017.RDS")
save(gddcum2018, file="data/gddcum2018.RDS")
save(gddcum2019, file="data/gddcum2019.RDS")
save(gddcum2020, file="data/gddcum2020.RDS")
save(gddcum2021, file="data/gddcum2021.RDS")


###



### thirty-year summaries

week.mean30 <- (week1991 +
			  week1992 +
			  week1993 +
			  week1994 +
			  week1995 +
			  week1996 +
			  week1997 +
			  week1998 +
			  week1999 +
			  week2000 +
			  week2001 +
			  week2002 +
			  week2003 +
			  week2004 +
			  week2005 +
			  week2006 +
			  week2007 +
			  week2008 +
			  week2009 +
			  week2010 +
			  week2011 +
			  week2012 +
			  week2013 +
			  week2014 +
			  week2015 +
			  week2016 +
			  week2017 +
			  week2018 +
			  week2019 +
			  week2020) / 30


dev30.1991 <- week1991 - week.mean30
dev30.1992 <- week1992 - week.mean30
dev30.1993 <- week1993 - week.mean30
dev30.1994 <- week1994 - week.mean30
dev30.1995 <- week1995 - week.mean30
dev30.1996 <- week1996 - week.mean30
dev30.1997 <- week1997 - week.mean30
dev30.1998 <- week1998 - week.mean30
dev30.1999 <- week1999 - week.mean30
dev30.2000 <- week2000 - week.mean30
dev30.2001 <- week2001 - week.mean30
dev30.2002 <- week2002 - week.mean30
dev30.2003 <- week2003 - week.mean30
dev30.2004 <- week2004 - week.mean30
dev30.2005 <- week2005 - week.mean30
dev30.2006 <- week2006 - week.mean30
dev30.2007 <- week2007 - week.mean30
dev30.2008 <- week2008 - week.mean30
dev30.2009 <- week2009 - week.mean30
dev30.2010 <- week2010 - week.mean30
dev30.2011 <- week2011 - week.mean30
dev30.2012 <- week2012 - week.mean30
dev30.2013 <- week2013 - week.mean30
dev30.2014 <- week2014 - week.mean30
dev30.2015 <- week2015 - week.mean30
dev30.2016 <- week2016 - week.mean30
dev30.2017 <- week2017 - week.mean30
dev30.2018 <- week2018 - week.mean30
dev30.2019 <- week2019 - week.mean30
dev30.2020 <- week2020 - week.mean30
dev30.2021 <- week2021 - week.mean30


###

par(mfrow=c(2, 1))

boxplot(data.frame(
	d1991 = NA,
	d1992 = NA,
	d1993 = NA,
	d1994 = NA,
	d1995 = NA,
	d1996 = NA,
	d1997 = NA,
	d1998 = NA,
	d1999 = NA,
	d2000 = NA,
	d2001 = NA,
	d2002 = NA,
	d2003 = NA,
	d2004 = NA,
	d2005 = NA,
	d2006 = dev2006[, 39], 
	d2007 = dev2007[, 39], 
	d2008 = dev2008[, 39], 
	d2009 = dev2009[, 39], 
	d2010 = dev2010[, 39], 
	d2011 = dev2011[, 39], 
	d2012 = dev2012[, 39], 
	d2013 = dev2013[, 39], 
	d2014 = dev2014[, 39], 
	d2015 = dev2015[, 39], 
	d2016 = dev2016[, 39], 
	d2017 = dev2017[, 39], 
	d2018 = dev2018[, 39], 
	d2019 = dev2019[, 39], 
	d2020 = dev2020[, 39], 
	d2021 = dev2021[, 39])) 
abline(h=0, col="red", lwd=4)



boxplot(data.frame(
	d1991 = dev30.1991[, 39], 
	d1992 = dev30.1992[, 39], 
	d1993 = dev30.1993[, 39], 
	d1994 = dev30.1994[, 39], 
	d1995 = dev30.1995[, 39], 
	d1996 = dev30.1996[, 39], 
	d1997 = dev30.1997[, 39], 
	d1998 = dev30.1998[, 39], 
	d1999 = dev30.1999[, 39], 
	d2000 = dev30.2000[, 39], 
	d2001 = dev30.2001[, 39], 
	d2002 = dev30.2002[, 39], 
	d2003 = dev30.2003[, 39], 
	d2004 = dev30.2004[, 39], 
	d2005 = dev30.2005[, 39], 
	d2006 = dev30.2006[, 39], 
	d2007 = dev30.2007[, 39], 
	d2008 = dev30.2008[, 39], 
	d2009 = dev30.2009[, 39], 
	d2010 = dev30.2010[, 39], 
	d2011 = dev30.2011[, 39], 
	d2012 = dev30.2012[, 39], 
	d2013 = dev30.2013[, 39], 
	d2014 = dev30.2014[, 39], 
	d2015 = dev30.2015[, 39], 
	d2016 = dev30.2016[, 39], 
	d2017 = dev30.2017[, 39], 
	d2018 = dev30.2018[, 39], 
	d2019 = dev30.2019[, 39], 
	d2020 = dev30.2020[, 39], 
	d2020 = dev30.2021[, 39])) 
abline(h=0, col="red", lwd=4)


####


save(dev30.1991, file="data/dev30.1991.RDS")
save(dev30.1992, file="data/dev30.1992.RDS")
save(dev30.1993, file="data/dev30.1993.RDS")
save(dev30.1994, file="data/dev30.1994.RDS")
save(dev30.1995, file="data/dev30.1995.RDS")
save(dev30.1996, file="data/dev30.1996.RDS")
save(dev30.1997, file="data/dev30.1997.RDS")
save(dev30.1998, file="data/dev30.1998.RDS")
save(dev30.1999, file="data/dev30.1999.RDS")
save(dev30.2000, file="data/dev30.2000.RDS")
save(dev30.2001, file="data/dev30.2001.RDS")
save(dev30.2002, file="data/dev30.2002.RDS")
save(dev30.2003, file="data/dev30.2003.RDS")
save(dev30.2004, file="data/dev30.2004.RDS")
save(dev30.2005, file="data/dev30.2005.RDS")
save(dev30.2006, file="data/dev30.2006.RDS")
save(dev30.2007, file="data/dev30.2007.RDS")
save(dev30.2008, file="data/dev30.2008.RDS")
save(dev30.2009, file="data/dev30.2009.RDS")
save(dev30.2010, file="data/dev30.2010.RDS")
save(dev30.2011, file="data/dev30.2011.RDS")
save(dev30.2012, file="data/dev30.2012.RDS")
save(dev30.2013, file="data/dev30.2013.RDS")
save(dev30.2014, file="data/dev30.2014.RDS")
save(dev30.2015, file="data/dev30.2015.RDS")
save(dev30.2016, file="data/dev30.2016.RDS")
save(dev30.2017, file="data/dev30.2017.RDS")
save(dev30.2018, file="data/dev30.2018.RDS")
save(dev30.2019, file="data/dev30.2019.RDS")
save(dev30.2020, file="data/dev30.2020.RDS")
save(dev30.2021, file="data/dev30.2021.RDS")


save(gddcum1991, file="data/gddcum1991.RDS")
save(gddcum1992, file="data/gddcum1992.RDS")
save(gddcum1993, file="data/gddcum1993.RDS")
save(gddcum1994, file="data/gddcum1994.RDS")
save(gddcum1995, file="data/gddcum1995.RDS")
save(gddcum1996, file="data/gddcum1996.RDS")
save(gddcum1997, file="data/gddcum1997.RDS")
save(gddcum1998, file="data/gddcum1998.RDS")
save(gddcum1999, file="data/gddcum1999.RDS")
save(gddcum2000, file="data/gddcum2000.RDS")
save(gddcum2001, file="data/gddcum2001.RDS")
save(gddcum2002, file="data/gddcum2002.RDS")
save(gddcum2003, file="data/gddcum2003.RDS")
save(gddcum2004, file="data/gddcum2004.RDS")
save(gddcum2005, file="data/gddcum2005.RDS")


save(week1991, file="data/week1991.RDS")
save(week1992, file="data/week1992.RDS")
save(week1993, file="data/week1993.RDS")
save(week1994, file="data/week1994.RDS")
save(week1995, file="data/week1995.RDS")
save(week1996, file="data/week1996.RDS")
save(week1997, file="data/week1997.RDS")
save(week1998, file="data/week1998.RDS")
save(week1999, file="data/week1999.RDS")
save(week2000, file="data/week2000.RDS")
save(week2001, file="data/week2001.RDS")
save(week2002, file="data/week2002.RDS")
save(week2003, file="data/week2003.RDS")
save(week2004, file="data/week2004.RDS")
save(week2005, file="data/week2005.RDS")

