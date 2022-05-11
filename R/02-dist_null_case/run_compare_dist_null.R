## Make sure your current directory is 02-dist_null_case
source("init.R", chdir = TRUE)

run_compare_dist_null <- function(
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
    cmp$index <- 1:pnoise
    cmp$AIRC <- sort(cmp$AIRC, decreasing = FALSE)
    cmp$UNAIRC <- sort(cmp$UNAIRC, decreasing = FALSE)
  return(cmp)
}

pnoise <- 1000
num.trees <- 15000
mtry <- floor(sqrt(pnoise))
seed <- 123 + 1:length(data_files)
param_settings <- data.frame(data_file = data_files,
                             seed = 123 + 1:length(data_files),
                             data_name = data_names,
                             stringsAsFactors = FALSE)

run_cmp_dist_null <- wrap_batchtools(reg_name = "compare_dist_null",
                                      work_dir = working_dir,
                                      reg_dir = registry_dir,
                                      r_function = run_compare_dist_null,
                                      vec_args = param_settings,
                                      more_args = list(
                                        pnoise = pnoise,
                                        num.trees = num.trees,
                                        mtry = mtry
                                      ),
                                      name = "urf_distnull",
                                      overwrite = TRUE,
                                      memory = "10g",
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

