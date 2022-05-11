## Please, carefully run this file step by step!
## Make sure your current directory is 04-real_data_application
source("init.R", chdir = TRUE)

golub_expression <- fread(golub_expr_pro_file)
golub_expression <- data.frame(t(golub_expression))

golub_urf_imp <- wrap_batchtools(reg_name = "golub_urf_imp",
                                 work_dir = working_dir,
                                 reg_dir = registry_dir,
                                 r_function = get_urf_importance,
                                 vec_args = 1:500,
                                 more_args = list(
                                   data = golub_expression,
                                   target =  "yy",
                                   num.trees = 10e4,
                                   mtry = sqrt(ncol(golub_expression)),
                                   resampling_seed = 123
                                 ),
                                 name = "urf_golub",
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

