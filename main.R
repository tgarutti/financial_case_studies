##------------------------------------------------------------------##
## Main function.
##------------------------------------------------------------------##
source("source_file.R")


## PCA and analysis of factors
#Select data needed, either US or UK.
yieldCurve <- us_yield_ortec
countryData <- us_data
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

# x <- 100
# 
# for (i in 1:(floor(length(inflation)/(4*x))+1))
# {
#   s = ((i-1)*4*x+1)
#   e = i*4*x
#   if (e > length(inflation))
#   {
#     inflation[s:length(inflation)] = inflation[s:length(inflation)] - mean(inflation[s:length(inflation)])
#   }
#   else
#   {
#     inflation[s:e] = inflation[s:e] - mean(inflation[s:e])
#   }
# }

inflation <- inflation - mean(inflation)

## Calculate and write descriptive statistics.
descriptives <- basic_descriptives(us_yield_ortec)
write_table(descriptives, "descriptivesYieldsOrtec.csv")
corr1 <- cor(-normalize(pca$x)/100, countryData)
corr2 <- cor(pcOrtec, countryData)

corrInflation <- cor(-normalize(pca$x)[,1]/100, inflation)

#Plot the level factor against inflation.
plot(-normLt/100, ylim = c(-0.02,0.03), col = "green")
lines(inflation)

#OLS regression of slope factor on inflation and output gap
inf <- inflation - Lt
output_gap <- countryData[,3]
unemp <- countryData[,9]
nairu <- countryData[,10]
data_St <- data.frame(St, inf, output_gap)
model1 <- lm(St ~ inf+output_gap, data = data_St)
model2 <- lm(normCt/100 ~ normData[,3] + normData[,9])
model3 <- lm(normSt ~ normData[,5] - normLt + normData[,3] + normData[,9])

plot(fitted.values(model1),ylim=c(-0.05,0.05), type="l", col="blue")
lines(St)
##------------------------------------------------------------------##
##------------------------------------------------------------------##