library(IMCo)
library(stringr)
library(magrittr)

args <- commandArgs(trailingOnly = TRUE)
files <- args[1] %>%
        str_split(pattern = ",") %>%
        unlist() %>%
        as.list()
mask <- args[2]
output_dir <- args[3]
out_name <- args[4]
fwhm <- args[5] %>% as.numeric()
prop_miss <- args[6] %>% as.numeric()

change_mode <- function(mode) {
        if (mode == "global_wcov") {
                path <- "global_wcov"
                pca_type <- "global"
                matrix_type <- "wcov"
        } else if (mode == "unscaled_wcor") {
                path <- "unscaled_wcor"
                pca_type <- "unscaled"
                matrix_type <- "wcor"
        } else
                stop("Must enter global_wcov or unscaled_wcor")

        mode_output_dir <- file.path(output_dir, "niftis/coupled", path)
        dir.create(mode_output_dir, showWarnings = FALSE, recursive = TRUE)

        imco(files,
             mask,
             out_dir = mode_output_dir,
             out_name = out_name,
             fwhm = fwhm,
             prop_miss = prop_miss,
             pca_type = pca_type,
             matrix_type = matrix_type
        )

        return(NULL)
}

change_mode("global_wcov")
change_mode("unscaled_wcor")

