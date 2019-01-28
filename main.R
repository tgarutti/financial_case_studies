##------------------------------------------------------------------##
## Main function.
##------------------------------------------------------------------##
source("source_file.R")

## PCA and analysis of factors
#Select data needed, either US or UK.
yieldCurve <- us_yield_ortec
countryData <- us_data

#Normalize data
normData <- as.zoo(normalize(countryData))
index(normData) <- index(countryData)
normPCOrtec <- as.zoo(normalize(pcOrtec))
index(normPCOrtec) <- index(countryData)

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

#Select the second principal component as the slope factor.
Ct <- pca$x[,3]
normCt <- as.zoo(Ct - mean(Ct))/sqrt(var(Ct))
index(normCt) <- index(yieldCurve)

#Select PCE core inflation from the dataset. Demean the dataset, using a different mean every x years.
inflation <- countryData[,5]
inflation <- inflation - mean(inflation)

## Calculate and write descriptive statistics.
 #source("descriptives.R")

## Plots.
source("plot.R")
##------------------------------------------------------------------##
##------------------------------------------------------------------##