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

run_cmp_dist_null <- batchtools::loadRegistry(file = file.path(registry_dir,
                                                               "compare_dist_null"),
                                              writeable = TRUE)
cmp_dist_null <- batchtools::reduceResultsList(reg = run_cmp_dist_null,
                                                        ids = 1:nrow(param_settings))
cmp_dist_null_DT <- rbindlist(cmp_dist_null)
names(cmp_dist_null_DT)[1:2] <- c("AIR", "UNAIR")
res_air <- data.table::melt(data = cmp_dist_null_DT,
                            measure.vars = c("AIR", "UNAIR"),
                            variable.name = "Measure", value.name = "Importance")
res_air <- res_air[Measure %in% c("AIR", "UNAIR"), ]
tikz(file = file.path(img_dir, '01nulldist/qqplot.tex'),
     standAlone = TRUE,
     width = 5, height = 3,
     packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
plot_air <- ggplot(data = cmp_dist_null_DT,
                   aes(x = AIR,
                       y = UNAIR)) +
  geom_point(size = 0.75) + 
  geom_abline(slope = 1, color = "red") +
  facet_wrap(~ data, scales = "free")
print(plot_air)
dev.off()

## %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##  Histogram
## %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
tikz(file = file.path(img_dir, '01nulldist/histogram.tex'),
     standAlone = TRUE,
     width = 6, height = 3,
     packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
plot_histo_air <- ggplot(data = res_air,
                   aes(x = Importance, color = Measure, fill = Measure)) +
  geom_histogram(alpha = 0.1, bins = 35) + 
  geom_vline(xintercept = 0, color = "black", linetype = "dashed") +
  theme(legend.position = "bottom",
        text = element_text(size = 15)) +
  facet_wrap(~ data, scales = "free")
print(plot_histo_air)
dev.off()

setEPS()
postscript(file = file.path(img_dir, '01nulldist/histogram.eps'),
           width = 6, height = 3.0)
print(plot_histo_air)
dev.off()

## %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##  Boxplot
## %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
##
tikz(file = file.path(img_dir, '01nulldist/boxplot.tex'),
     standAlone = TRUE,
     width = 5, height = 4,
     packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
plot_box_air <- ggplot(data = res_air,
                         aes(x = data, y = Importance)) +
  geom_boxplot(outlier.size = 0.75) + 
  # ylab("Variable Importance Measure") + 
  geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
  xlab("") +
  theme(axis.text.x = element_text(angle = 50, vjust = 0.5, hjust=1), 
        legend.position = "bottom",
        text = element_text(size = 15),
        axis.title.x = element_text(margin = margin(t = 0,
                                                    r = 20,
                                                    b = 0,
                                                    l = 0)),
        axis.text = element_text(margin = margin(t = 0,
                                                 r = 0,
                                                 b = 0,
                                                 l = 0))) +
  facet_wrap(~ Measure, nrow = 1)
print(plot_box_air)
dev.off()

setEPS()
postscript(file = file.path(img_dir, '01nulldist/boxplot.eps'),
           width = 5, height = 4.0)
print(plot_box_air)
dev.off()