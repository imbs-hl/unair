## Global initialization
source("init-global.R", chdir = TRUE)

## =============================================================================
## !!!!!!!!!!!!!!!!!!! Please set these variable before !!!!!!!!!!!!!!!!!!!!! ##
## =============================================================================
##
## For resource manager, e.g. SLURM
partition <- "prio" ## Should be the name of the queue
account <- "dzhkomics" ## Should your slurm account

## Batchtools configuration file
config_file <- file.path(main_dir, "99_batchtools/batchtools.conf.R")


## Data download and preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("01-breast_cancer.R", chdir = TRUE)
source("02-cervival_cancer.R", chdir = TRUE)
source("03-gene_exp_rna.R", chdir = TRUE)
source("05-heart_failure.R", chdir = TRUE)
source("06-mice-protein.R", chdir = TRUE)
source("07-wine.R", chdir = TRUE)

## Compute null case distribution of importance estimates
working_dir <- file.path(main_dir, "02-dist_null_case")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("run_compare_dist_null.R", chdir = TRUE)
source("type1.R", chdir = TRUE)

## Power study
working_dir <- file.path(main_dir, "03-dist_alternativ_case")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("run_simulate_effect.R", chdir = TRUE)

## Real data application
working_dir <- file.path(main_dir, "04-real_data_applications")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("03-golub.R", chdir = TRUE)