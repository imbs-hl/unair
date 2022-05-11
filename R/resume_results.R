## Global initialization
source("init-global.R", chdir = TRUE)


## Resume results for null case distribution of importance estimates
working_dir <- file.path(main_dir, "02-dist_null_case")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("res_compare_dist_null.R", chdir = TRUE)
source("res_type1.R", chdir = TRUE)

## Power study
working_dir <- file.path(main_dir, "03-dist_alternativ_case")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("res_simulate_effect.R", chdir = TRUE)

## Real data application
working_dir <- file.path(main_dir, "04-real_data_applications")
setwd(working_dir)
source("init.R", chdir = TRUE)
source("res_golub.R", chdir = TRUE)