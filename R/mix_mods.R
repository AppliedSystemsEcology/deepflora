library(mixtools)

make_dist <- function(x, mean, sd, lambda, n, binwidth) {
  dnorm(x, mean = mean, sd = sd) * n * binwidth * lambda
}

make_dist_mix <- function(mixmod, binwidth){
  mu <- mixmod[["mu"]]          #mean
  sgma <- mixmod[["sigma"]]    # standard deviation
  lmbda <- mixmod[["lambda"]]  # amplitude
  n <- length(mixmod[["x"]])    # sample size

  xvals <- seq(from = min(mixmod[["x"]]),
               to = max(mixmod[["x"]]),
               length.out = 101)

  mixdists <- list()
  for (i in seq_along(mu)){
    mixdist.i <- make_dist(x = xvals, mean = mu[i], sd = sgma[i], lambda = lmbda[i], n = n, binwidth = binwidth)

    mixdists[[i]] <- data.frame(x = xvals, y = mixdist.i)
  }
  dplyr::bind_rows(mixdists, .id = "dist")
}

ggmake_dists <- function(mean, sd, lambda, n, binwidth, ...) {
  stat_function(
    fun = function(x) {
      make_dist(x, mean, sd, lambda, n, binwidth)
    },
    ...
  )
}


fitmix <- function(gdd, tryk = c(2,3,4)){
  mixtry <- list()
  for(i in seq_along(try)){
    mixtry[[i]] <- normalmixEM(gdd, k = tryk[i])
  }
  bestLogLik <- which.min(sapply(mixtry, \(x) x$loglik))
  mixtry[[bestLogLik]]
}

from_gdd <- function(gdd, mixmod){
  mu <- mixmod[["mu"]]          #mean
  sgma <- mixmod[["sigma"]]    # standard deviation
  lmbda <- mixmod[["lambda"]]  # amplitude
}
