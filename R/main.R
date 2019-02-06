##------------------------------------------------------------------##
## Main function
## -------------
## 
##------------------------------------------------------------------##
source("source_file.R")

PCs <- prcomp(us_yield_ortec)$x
PC_norm <- normalize(PCs)
Lt <- -PC_norm[,1]
St <- PC_norm[,2]

  