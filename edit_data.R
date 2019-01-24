##------------------------------------------------------------------##
##Functions for reading and editing data.
##------------------------------------------------------------------##
interpData <- function(data_1, x)
{
  counter <- t(as.matrix(1:length(data_1[,1])))
  result <- apply(counter, 2, lin_int <- function(i)
  {
    y <- coredata(as.array((data_1[i,])))
    return(t(spline(x = x, y = y, n = 40, xmin = 0.25, xmax = 10)$y))
  })
  return(result)
}

interpolate <- function(data_1)
{
  maturities <- strtoi(str_sub(colnames(data_1), 2, -1))/12
  data_interp <- t(interpData(data_1, maturities))
  col_names <- c(3, 6, 9, 12, 15, 18, 21, 24, 30, 36, 48, 60, 72, 84, 96, 108, 120)
  data_interp <- data_interp[, c(1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 16, 20, 24, 28, 32, 36, 40)]
  colnames(data_interp) <- col_names
  data_interp <- as.zoo(data_interp)
  index(data_interp) <- index(data_1)
  return(data_interp)
}

monthlyToQuarterly <- function(data1, start_date)
{
  quarterly_data <- apply(data1, 2, FUN = f <- function(d)
  {
    m <- ts(d, start = start_date, frequency = 12)
    q <- aggregate(m, nfrequency = 4, mean)
    return(q)
  })
  return(quarterly_data)
}

basic_descriptives <- function(data1)
{
  descriptives <- apply(data1, 2, FUN = f <- function(c)
  {
    c <- coredata(c)
    avg <- mean(c)
    std <- sqrt(var(c))
    autocorrelations <- acf(c, lag.max = 20)$acf[c(2,3,4,11)]
    stats <- c(avg, std, autocorrelations)
    return(stats)
  })
  rownames(descriptives) <- c("Mean", "Std. Dev.", "ar1", "ar2", "ar3", "ar10")
  return(t(descriptives))
}
##------------------------------------------------------------------##
##------------------------------------------------------------------##