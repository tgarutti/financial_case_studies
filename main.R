##----------------------------------------------------------------------------------------------------------##
## Main function.
##----------------------------------------------------------------------------------------------------------##
setwd("~/Documents/Repositories/financial_case_studies/")
source("source_file.R")

us_pca <- prcomp(us_yieldCurve)
Lt <- us_pca$x[,1]
normLt <- as.zoo((Lt - mean(Lt))/sqrt(var(Lt)))
St <- us_pca$x[,2]
normSt <- (St - mean(St))/sqrt(var(St))

usInflation <- window(us_data[,4], start = "1990-03-1", end = "2018-03-01")
ukInflation <- uk_data[,4]

plot(-normLt/100, col="red")
par(new=TRUE)
plot(usInflation, col = "green")