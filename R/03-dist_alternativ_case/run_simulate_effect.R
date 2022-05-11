## Make sure your current directory is 03-dist_alternative_case
source("init.R", chdir = TRUE)

run_simulate_effect <- function(
  data_file,
  data_name,
  effect = 0:5/2,
  n_effect_repl = 20,
  pnoise = 1000,
  num.trees = 20000,
  mtry,
  seed = 123,
  ...
){
  source("init.R", chdir = TRUE)
  my_data <- fread(data_file)
  res_tmp <- urf_power(data = my_data,
                       effect = effect,
                       n_effect_repl = n_effect_repl,
                       pnoise = pnoise,
                       num.trees = num.trees,
                       mtry = floor(sqrt(ncol(my_data) + pnoise)),
                       seed = 123,
                       ...)
  res_tmp$data <- data_name
  return(res_tmp)
}

## =======================================
## Parameters setting
## =======================================
##
effect <- seq(0, 2, by = 0.3)
n_effect_repl <- 20
pnoise <- 1000
num.trees <- 15000
mtry <- floor(sqrt(pnoise))
seed <- 123 + 1:length(data_files)
n_bench <- 100
param_settings <- data.frame(data_file = rep(data_files, each = n_bench),
                             seed = 123 + 1:length(rep(data_files, each = n_bench)),
                             data_name = rep(data_names, each = n_bench),
                             stringsAsFactors = FALSE)


run_power_reg <- wrap_batchtools(reg_name = "power",
                                     work_dir = working_dir,
                                     reg_dir = registry_dir,
                                     r_function = run_simulate_effect,
                                     vec_args = param_settings,
                                     more_args = list(
                                       effect = effect,
                                       n_effect_repl = n_effect_repl,
                                       pnoise = pnoise,
                                       num.trees = num.trees,
                                       mtry = mtry
                                     ),
                                     name = "urf_power",
                                     overwrite = TRUE,
                                     memory = "5g",
                                     n_cpus = 1L,
                                     walltime = "0",
                                     partition = partition,
                                     account = account,
                                     test_job = FALSE,
                                     wait_for_jobs = TRUE,
                                     packages = c(
                                       "devtools",
                                       "data.tree"
                                     ),
                                     config_file = config_file)
