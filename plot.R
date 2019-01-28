##------------------------------------------------------------------##
## Plots.
##------------------------------------------------------------------##
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
model3 <- lm(St ~ inf+output_gap + unemp - nairu)

plot(fitted.values(model3),ylim=c(-0.05,0.05), type="l", col="blue")
lines(St)
##------------------------------------------------------------------##
##------------------------------------------------------------------##