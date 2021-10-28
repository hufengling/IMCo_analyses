library(tidyverse)
library(extrantsr)
library(ANTsRCore)

orig_basil_path <- list.files("niftis/basilPNC", full.name = TRUE)
orig_basil_name <- list.files("niftis/basilPNC")
basil_ids <- read_csv("bblid_scanid_sub.csv", col_names = FALSE)
new_dir <- "niftis/cbf-basil/"

for (i in 1:length(orig_basil_path)) {
  basil_image <- check_ants(orig_basil_path[i])
  id_num <- ((orig_basil_name[i] %>% str_split("_"))[[1]][1] %>% str_split("-"))[[1]][2]
  row_num <- which(basil_ids[, 3] == id_num)
  scan_id <- basil_ids[row_num, 2] %>% as.numeric()
  
  antsImageWrite(basil_image, paste0(new_dir, scan_id, "_basil.nii.gz"))
  
  cat(paste("Wrote:", scan_id, "\n"))
}
