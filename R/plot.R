##------------------------------------------------------------------##
## Plots.
##------------------------------------------------------------------##

## Plot fitted values against second (S) factor.
#OLS regression of slope factor on inflation and output gap
inf <- inflation - Lt
output_gap <- countryData[,3]
unemp <- countryData[,9]
nairu <- countryData[,10]
data_St <- data.frame(St, inf, output_gap)
model1 <- lm(St ~ inf+output_gap, data = data_St)
model2 <- lm(normCt/100 ~ normData[,3] + normData[,9])
model3 <- lm(St ~ inf+output_gap + unemp - nairu)
fit <- as.zoo(fitted.values(model3))
St <- as.zoo(St)
index(fit) <- index(yieldCurve)
index(St) <- index(yieldCurve)

#Create Plot
plot(100* fit,ylim=c(-4, 4), type="l", col="blue", xlab = "", ylab = "Percent")
lines(100*St)

## Plot the level factor against inflation.
plot(-normLt, ylim = c(-2, 3), col = "green", xlab = "", ylab = "Percent")
lines(100*inflation)
##------------------------------------------------------------------##
##------------------------------------------------------------------##