source("init.R", chdir = TRUE)
type1 <- function(
  data_file,
  data_name,
  pnoise = 500,
  num.trees = 10000,
  mtry = 22,
  seed = 123,
  ...
){
  source("init.R", chdir = TRUE)
  my_data <- fread(data_file)
  cmp <- compare_dist_null(
    data = data.frame(my_data),
    pnoise = pnoise,
    num.trees = num.trees,
    mtry = mtry,
    seed = seed
  )
  cmp$data <- data_name
  cmp$AIRC <- mean(cmp$janitza < 0.05)
  cmp$UNAIRC <- mean(cmp$ujanitza < 0.05)
  return(cmp)
}

pnoise <- 1000
num.trees <- 15000
mtry <- floor(sqrt(pnoise))
seed <- 123 + 1:length(rep(data_files, each = 100))
param_settings <- data.frame(data_file = rep(data_files, each = 100),
                             seed = 123 + 1:length(rep(data_files, each = 100)),
                             data_name = rep(data_names, each = 100),
                             stringsAsFactors = FALSE)



type1_reg <- wrap_batchtools(reg_name = "type1",
                                     work_dir = working_dir,
                                     reg_dir = registry_dir,
                                     r_function = type1,
                                     vec_args = param_settings,
                                     more_args = list(
                                       pnoise = pnoise,
                                       num.trees = num.trees,
                                       mtry = mtry
                                     ),
                                     name = "urf_distnull",
                                     overwrite = TRUE,
                                     memory = "5g",
                                     n_cpus = 1L,
                                     walltime = "60",
                                     partition = partition,
                                     account = account,
                                     test_job = FALSE,
                                     wait_for_jobs = TRUE,
                                     packages = c(
                                       "devtools",
                                       "data.tree"
                                     ),
                                     config_file = config_file)
