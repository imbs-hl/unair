source("../init-global.R", chdir = TRUE)
## =====================
## functions
## =====================
##
source(file.path(functions_dir, "pvalue.R"))
source(file.path(functions_dir, "compare_dist_null.R"))
source(file.path(functions_dir, "imputation.R"))
working_dir <- file.path(main_dir, "01-preprocessing")

