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

type1_reg <- batchtools::loadRegistry(file = file.path(registry_dir,
  "type1"))
type1_res <- batchtools::reduceResultsList(reg = type1_reg,
                                               ids = 1:nrow(param_settings))
## Make sure your current directory is 02-dist_null_case
type1_res_DT <- rbindlist(type1_res)
names(type1_res_DT)[1:2] <- c("AIR", "UNAIR")
type1_res_air <- data.table::melt(data = type1_res_DT,
                            measure.vars = c("AIR", "UNAIR"),
                            variable.name = "Measure", value.name = "Type1")
type1_res_air <- type1_res_air
type1_res_air$Type1 <- round(type1_res_air$Type1, digits = 5)
type1_res_air <- unique(type1_res_air, by = c("Type1", "data", "Measure"))
## %%%%%%%%%%%%%%%%%%%%%%%%
## Plot type 1 error
## %%%%%%%%%%%%%%%%%%%%%%%%
tikz(file = file.path(img_dir, '02type1error/type1.tex'),
     standAlone = TRUE,
     width = 5, height = 3,
     packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
plot_airc_type1 <- ggplot(data = type1_res_air,
                   aes(x = data,
                       y = Type1)) +
  geom_boxplot(outlier.size = 0.15) + 
  # scale_y_continuous(limits = c(0, 0.25)) +
  ylab("Type 1 error") +
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=1),
        axis.title.x = element_blank(),
        plot.title = element_text(hjust = 0.5),
        plot.margin = unit(c(0.1,1,1.0,1.2),"cm"),
        text = element_text(size = 15)) +
  geom_hline(yintercept = 0.05, color = "red", linetype='dashed', size = 1) +
  # ggtitle("AIRC") +
  facet_wrap(~Measure, nrow = 1) +
  guides(fill = guide_legend(nrow = 1, byrow = TRUE))
print(plot_airc_type1)
dev.off()

setEPS()
postscript(file = file.path(img_dir, '02type1error/type1.eps'),
           width = 5, height = 3)
print(plot_airc_type1)
dev.off()

setwd(working_dir)
