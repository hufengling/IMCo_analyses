library(IMCo)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
files <- args[1]

out_dir <- args[2]

imco(files, mask,
     out_dir = "output/niftis/coupled/global_wcov",
     out_name = "3234",
     ref = 1, fwhm = 3,
     propMiss = 0.9, pcaType = "global", matrixType = "wcov"
)

imco(files, mask,
     ref = 1, fwhm = 3, retimg = T, type = "pca",
     propMiss = 0.9, pcaType = "global", matrixType = "wcov"
)