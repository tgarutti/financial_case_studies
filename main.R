##------------------------------------------------------------------##
## Main function.
##------------------------------------------------------------------##
source("source_file.R")


## PCA and analysis of factors
#Select data needed, either US or UK.
yieldCurve <- us_yield_ortec
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

#Select PCE core inflation from the dataset. Demean the dataset, using a different mean every x years.
x <- 100
inflation <- countryData[,5]

for (i in 1:(floor(length(inflation)/(4*x))+1))
{
  s = ((i-1)*4*x+1)
  e = i*4*x
  if (e > length(inflation))
  {
    inflation[s:length(inflation)] = inflation[s:length(inflation)] - mean(inflation[s:length(inflation)])
  }
  else
  {
    inflation[s:e] = inflation[s:e] - mean(inflation[s:e])
  }
}

inflation <- inflation - mean(inflation)

#Plot the level factor against inflation.
plot(-normLt/100, ylim = c(-0.02,0.03), col = "green")
lines(inflation)
##------------------------------------------------------------------##
##------------------------------------------------------------------##