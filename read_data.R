##----------------------------------------------------------------------------------------------------------##
## Reads and transforms the data.
##----------------------------------------------------------------------------------------------------------##
source("edit_data.R")
uk_yieldCurve <- load("/Users/user/Documents/Repositories/financial_case_studies/data/united_kingdom_fromExcel.RData")
us_yieldCurve <- load("/Users/user/Documents/Repositories/financial_case_studies/data/united_states_fromExcel.RData")
us_data <- read.zoo("./data/USdata.csv", header = TRUE, sep = ",",format="%m/%d/%Y",index.column = 1)
us_data <- window(us_data, start = "1990-03-1", end = "2018-03-01")
uk_data <- read.zoo("./data/UKdata.csv", header = TRUE, sep = ",",format="%m/%d/%Y",index.column = 1)
uk_data <- window(uk_data, start = "1995-03-1", end = "2018-03-01")

us_yieldCurve <- interpolate(united_states)[,c(1,2,4,8,10,11,12,13,14,15,16,17)]
uk_yieldCurve <- interpolate(united_kingdom)[,c(1,2,4,8,10,11,12,13,14,15,16,17)]

us_quarterly <- as.zoo(monthlyToQuarterly(us_yieldCurve, c(1990,1)))
colnames(us_quarterly) = colnames(us_yieldCurve)
index(us_quarterly) = index(us_data)[62:(62+112)]

uk_quarterly <- as.zoo(monthlyToQuarterly(window(uk_yieldCurve, start = "1995-01-01", end = "2018-05-01"), c(1995,1)))
colnames(uk_quarterly) = colnames(uk_yieldCurve)
index(uk_quarterly) = index(uk_data)[1:93]
rm(united_kingdom, united_states)