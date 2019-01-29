##------------------------------------------------------------------##
## Write descriptive statistics.
##------------------------------------------------------------------##

#Function: calculates basic descriptive statistcs of data1
basic_descriptives <- function(data1)
{
  descriptives <- apply(data1, 2, FUN = f <- function(c)
  {
    c <- coredata(c)
    avg <- mean(c)
    std <- sqrt(var(c))
    mx <- max(c)
    mn <- min(c)
    autocorrelations <- acf(c, lag.max = 20)$acf[c(2,3,4,11)]
    stats <- c(avg, std, mx, mn, autocorrelations)
    return(stats)
  })
  rownames(descriptives) <- c("Mean", "Std. Dev.", "Maximum", "Minimum", "ar1", "ar2", "ar3", "ar10")
  return(t(descriptives))
}

#Obtain and export descriptives on the yield curve data (Ortec)
descriptives <- basic_descriptives(us_yield_ortec)
write_table(descriptives, "descriptivesYieldsOrtec.csv")

#Obtain and export descriptives on the US Data (Ortec)
descriptives <- basic_descriptives(us_data)
write_table(descriptives, "descriptivesUSData.csv")

#Obtain and export descriptives on the principal components from Ortec
descriptives <- basic_descriptives(pcOrtec)
write_table(descriptives, "descriptivesPCOrtec.csv")

#Obtain and export descriptives on the principal components from the yield curve data
descriptives <- basic_descriptives(pca$x)
write_table(descriptives, "descriptivesPCYieldData.csv")

#Obtain and export correlation between US Data and principal components from the yield curve data
corr <- cor(pca$x, us_data)
write_table(corr, "corrPCYieldData_USData.csv")

#Obtain and export correlation between US Data and principal components from the yield curve data
corr <- cor(pcOrtec, us_data)
write_table(corr, "corrPCOrtec_USData.csv")

#Obtain and export correlation between US Data and principal components from the yield curve data
corr <- cor(pca$x, us_yield_ortec)
write_table(corr, "corrPCYieldData_YieldsOrtec.csv")

#Obtain and export correlation between US Data and principal components from the yield curve data
corr <- cor(pcOrtec, us_yield_ortec)
write_table(corr, "corrPCOrtec_YieldsOrtec.csv")

#Obtain and export correlation between US Data and principal components from the yield curve data
corr <- cor(us_data)
write_table(corr, "corrUSData.csv")

rm(descriptives, corr)
##------------------------------------------------------------------##
##------------------------------------------------------------------##