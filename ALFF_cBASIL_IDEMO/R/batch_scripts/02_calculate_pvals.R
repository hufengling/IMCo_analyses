library(magrittr)
library(readr)
library(extrantsr)
library(stringr)
library(IMCo)

top_dir <- file.path(getwd(), "../..")
load(file.path(top_dir, "input/csvs/settings.RData")) #load settings.RData

predictors <- read_csv(settings$predictors_path)
input_filepaths <- read_csv(settings$input_filepaths_path)
cores <- 16

# Functions
load_images <- function(dir, mask, file_paths) {
  if (!is.null(file_paths)) {
    file_paths <- file_paths
  } else {
    files <- list.files(dir)
    file_paths <- file.path(dir, files)
  }

  image_vector_list <- lapply(file_paths,
                              function(x, mask) {

                                image <- extrantsr::check_ants(x)
                                image_vector <- image %>% as.numeric()
                                mask_vector <- mask %>% as.numeric()
                                image_vector[mask_vector == 0] <- NA
                                image_vector_in_mask <- image_vector[!is.na(image_vector)]

                                image_vector_in_mask[image_vector_in_mask == 0] <- NA #remove any true 0s from coupling

                                return(image_vector_in_mask)
                              },
                              mask = mask
  )
  return(image_vector_list)
}

transpose_list <- function(list) {
  matrix <- list %>%
    unlist() %>%
    matrix(byrow = TRUE, nrow = length(list))
  transposed_list <- lapply(seq_len(ncol(matrix)), function(i) matrix[, i])
  return(transposed_list)
}

make_descriptive_images <- function(voxel_vector_list) {
  descriptive_vector <- lapply(voxel_vector_list, function(voxel_vector) {
    voxel_mean <- sum(voxel_vector)/length(voxel_vector)
    voxel_variance <- var(voxel_vector)

    return(c(voxel_mean, voxel_variance))
  }) %>% unlist()

  voxel_mean_vector <- descriptive_vector[c(T, F)]
  voxel_variance_vector <- descriptive_vector[c(F, T)]

  return(list(voxel_mean_vector, voxel_variance_vector))
}

get_pvals_by_voxel <- function(voxel_vector, predictors) {
  if (length(voxel_vector) != nrow(predictors)) {
    stop("n doesn't match")
  }

  regression <- lm(voxel_vector ~
                     sex + ageAtScan1 +
                     race2 + pcaslRelMeanRMSMotion + restRelMeanRMSMotion + idemoRelMeanRMSMotion, #TOCHANGE
                   data = predictors) %>%
    summary()
  reg_pvals <- regression$coefficients[c(2, 3), 4]

  interaction_regression <- lm(voxel_vector ~
                                 sex * ageAtScan1 +
                                 race2 + pcaslRelMeanRMSMotion + restRelMeanRMSMotion + idemoRelMeanRMSMotion, #TOCHANGE
                               data = predictors) %>%
    summary()
  int_pvals <- interaction_regression$coefficients[8, 4]

  pvals <- c(reg_pvals, int_pvals)
  return(pvals)
}

write_pvals <- function(image_list, mask, dir, is_descriptive, is_modality) {
  mask_indices <- which(as.array(mask) > 0)
  reference <- extrantsr::check_ants(file.path(dir, list.files(dir)[[1]]))
  file_name <- (dir %>% str_split("/"))[[1]]
  file_name <- file_name[length(file_name)]

  if (is_descriptive) {
    descriptive_dir <- file.path(settings$output_dir, "niftis/descriptive")
    dir.create(descriptive_dir, showWarnings = FALSE)
    names <- c("_mean", "_variance")
    for (i in 1:length(image_list)) {
      descriptive_image <- make_ants_image(image_list[[i]], mask_indices, reference)
      ANTsRCore::antsImageWrite(
        descriptive_image,
        file.path(descriptive_dir,
                  paste0(file_name, names[i], ".nii.gz")))
    }

    return(NULL)
  }

  if (is_modality) {
    pval_output_dir <- file.path(settings$output_dir, "niftis/pvals/modality_raw")
  }
  else {
    pval_output_dir <- file.path(settings$output_dir, "niftis/pvals/raw")
  }

  for (i in 1:length(image_list)) {
    pval_image <- make_ants_image(image_list[[i]], mask_indices, reference)
    ANTsRCore::antsImageWrite(
      pval_image,
      file.path(pval_output_dir,
                paste0(file_name, "_pval_", i, ".nii.gz")))
  }

  return(NULL)
}

analyze_coupled_images <- function(nifti_dir, mask, predictors, cores = 2, is_modality, file_paths = NULL) {
  mask <- extrantsr::check_ants(mask)

  cat("Loading images\n")
  image_vector_list <- load_images(nifti_dir, mask, file_paths)
  voxel_vector_list <- transpose_list(image_vector_list)

  cat("Making descriptive images\n")
  descriptive_list <- make_descriptive_images(voxel_vector_list)

  cat("Sending out voxel_vectors!\n")

  pvalbyvoxel_list <- parallel::mclapply(voxel_vector_list,
                                         get_pvals_by_voxel,
                                         predictors = predictors,
                                         mc.cores = cores)
  # pvalbyvoxel_list <- lapply(voxel_vector_list,
  #                            get_pvals_by_voxel,
  #                            predictors = predictors)
  pvalbycoef_list <- transpose_list(pvalbyvoxel_list)

  cat("Writing pvals!\n")
  write_pvals(descriptive_list, mask, nifti_dir, is_descriptive = TRUE, is_modality)
  write_pvals(pvalbycoef_list, mask, nifti_dir, is_descriptive = FALSE, is_modality)

  return(NULL)
}

# Run
analyze_coupled_images(nifti_dir = file.path(settings$output_dir, "niftis/coupled/global_wcov"),
                       mask = settings$mask_path,
                       predictors = predictors,
                       cores = cores,
                       is_modality = FALSE)

analyze_coupled_images(nifti_dir = file.path(settings$output_dir, "niftis/coupled/unscaled_wcor"),
                       mask = settings$mask_path,
                       predictors = predictors,
                       cores = cores,
                       is_modality = FALSE)

analyze_coupled_images(nifti_dir = file.path(settings$nifti_dir, settings$modalities[1]),
                       mask = settings$mask_path,
                       predictors = predictors,
                       cores = cores,
                       is_modality = TRUE,
                       file_paths = input_filepaths$modality_1 %>% as.list())

analyze_coupled_images(nifti_dir = file.path(settings$nifti_dir, settings$modalities[2]),
                       mask = settings$mask_path,
                       predictors = predictors,
                       cores = cores,
                       is_modality = TRUE,
                       file_paths = input_filepaths$modality_2 %>% as.list())

analyze_coupled_images(nifti_dir = file.path(settings$nifti_dir, settings$modalities[3]), #TOCHANGE
                       mask = settings$mask_path,
                       predictors = predictors,
                       cores = cores,
                       is_modality = TRUE,
                       file_paths = input_filepaths$modality_3 %>% as.list())
