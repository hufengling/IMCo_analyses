library(IMCo)
library(stringr)

args <- commandArgs(trailingOnly = TRUE)
files <- as.list(unlist(str_split(args[1], pattern = ",")))
mask <- args[2]
output_dir <- args[3]
out_name <- paste0(args[4], "_", args[5])
fwhm <- as.numeric(args[5])
prop_miss <- as.numeric(args[6])


change_mode <- function(mode) {
        if (mode != "global_wcov" & mode != "unscaled_wcor") {
                stop("Must enter global_wcov or unscaled_wcor")
        }

        mode_output_dir <- file.path(output_dir, "niftis/coupled", mode)
        dir.create(mode_output_dir, showWarnings = FALSE, recursive = TRUE)

        imco(files = files,
             brain_mask = mask,
             out_dir = mode_output_dir,
             out_name = out_name,
             fwhm = fwhm,
             prop_miss = prop_miss,
             pca_type = mode,
             use_ratio = TRUE
        )

        return(NULL)
}

change_mode("global_wcov")
change_mode("unscaled_wcor")
