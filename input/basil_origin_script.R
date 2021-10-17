library(tidyverse)
library(extrantsr)
library(ANTsRCore)

nifti_dir <- "~/Documents/IMCo_analyses/input/niftis/"

reference_origin <- check_ants(list.files(file.path(nifti_dir, "alff"), full.names = TRUE)[1]) %>% antsGetOrigin()
reference_direction <- check_ants(list.files(file.path(nifti_dir, "alff"), full.names = TRUE)[1]) %>% antsGetDirection()
basil_path <- list.files(file.path(nifti_dir, "cbf-basil"), full.names = TRUE)
basil_names <- list.files(file.path(nifti_dir, "cbf-basil"))

for (i in 1:length(basil_path)) {
  basil_image <- check_ants(basil_path[i])
  antsSetOrigin(basil_image, reference_origin)
  antsSetDirection(basil_image, reference_direction)
  antsImageWrite(basil_image, file.path(nifti_dir, "cbf-basil-origin", basil_names[i]))
  print(paste("Done:", i))
}
