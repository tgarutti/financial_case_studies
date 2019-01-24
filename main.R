##------------------------------------------------------------------##
## Main function.
##------------------------------------------------------------------##
source("source_file.R")


## PCA and analysis of factors
#Select data needed, either US or UK.
yieldCurve <- us_quarterly
countryData <- us_data

#Perform pca on the yield curve data.
pca <- prcomp(yieldCurve)

#Select the first principal component as the level factor.
Lt <- pca$x[,1]
normLt <- as.zoo((Lt - mean(Lt))/sqrt(var(Lt)))
index(normLt) <- index(yieldCurve)

#Select the second principal component as the slope factor.
St <- pca$x[,2]
normSt <- as.zoo(St - mean(St))/sqrt(var(St))
index(normSt) <- index(yieldCurve)

#Select PCE core inflation from the dataset.
inflation <- countryData[,5] - mean(countryData[,5])

#Plot the level factor against inflation.
plot(-normLt/100, ylim = c(-0.02,0.03), col = "green")
lines(inflation)

normPC1 <- as.zoo((pcOrtec[,1] - mean(pcOrtec[,1])/sqrt(var(pcOrtec[,1]))))
plot(-normLt/100, ylim = c(-0.02,0.03), col = "green")
lines(-normPC1/100, col = "red")
lines(inflation)
##------------------------------------------------------------------##
##------------------------------------------------------------------##