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

golub_urf_imp <- batchtools::loadRegistry(file = file.path(
  registry_dir, 
  "golub_urf_imp"))
golup_urf_imp_res <- batchtools::reduceResultsList(reg = golub_urf_imp,
                                                   ids = 1:500)
golup_urf_imp_res <- as.matrix(Reduce(f = "cbind", golup_urf_imp_res))

## Retrieve importances
unairc_imp <- golup_urf_imp_res[ , seq(from = 1, to = 2000, by = 4)]
airc_imp <- golup_urf_imp_res[ , seq(from = 2, to = 2000, by = 4)]
golup_unairc_imp_medians <- rowMedians(unairc_imp)
golup_airc_imp_medians <- rowMedians(airc_imp)
golup_unairc_imp_medians_null <- c(golup_unairc_imp_medians[golup_unairc_imp_medians < 0],
                                   golup_unairc_imp_medians[golup_unairc_imp_medians == 0],
                                   -golup_unairc_imp_medians[golup_unairc_imp_medians < 0])
golup_airc_imp_medians_null <- c(golup_airc_imp_medians[golup_airc_imp_medians < 0],
                                 golup_airc_imp_medians[golup_airc_imp_medians == 0],
                                 -golup_airc_imp_medians[golup_airc_imp_medians < 0])
golub_unairc_pvalue <- sapply(golup_unairc_imp_medians, function(x){
  (1 - mean(golup_unairc_imp_medians_null <= x))
})
golub_airc_pvalue <- sapply(golup_airc_imp_medians, function(x){
  1 - mean(golup_unairc_imp_medians <= x)
})


## Compute clustering error rate for unairc
data("Golub_Train")
truth <- as.character(Golub_Train$ALL.AML)
sig_pvalue <- (golub_unairc_pvalue < 0.05) 
top5percent <- (golup_unairc_imp_medians > quantile(golup_unairc_imp_medians,
                                                    0.95))

## Compute URF dissimilarities
data_reduced <- data.frame(golub_expression)[ , sig_pvalue & top5percent]
data_reduced_dist <- pranger(data = data_reduced,
                             strategy = "boostrepl",
                             num.trees = 100e3,
                             mtry = sqrt(sum(sig_pvalue & top5percent)),
                             approach = "shi",
                             seed = 123)

## Multidimensional scaling
mds <- data.frame(cmdscale(data_reduced_dist, 2))
names(mds) <- c("PC1", "PC2")
mds$Label <- Golub_Train$ALL.AML

## PLot Dendrogram
truth_BT_cell <- as.character(Golub_Train$T.B.cell)
truth_BT_cell[is.na(truth_BT_cell)] <- "AML"
truth_BT_cell <- sub(pattern = "cell",
                     replacement = "ALL",
                     x = truth_BT_cell)
cltrs <- cutree(hclust(dist(mds[,1:2]), method = "ward.D"), 2)
dendro_train <- as.dendrogram(hclust(dist(mds[,1:2]), method = "ward.D"))
dendro_train <- dendro_train %>% color_branches(k = 3) %>% 
  set_labels(truth_BT_cell)  %>%
  color_labels(labels = truth_BT_cell, col = c(rep("black", 25),
                                               rep("red", 2),
                                               rep("black", 11)))
if(FALSE){
  pdf(file = file.path(img_dir, '04real/01Train.pdf'),
      width = 7.00, height = 4.50)
  plot(dendro_train, yaxt = "n", main = "(a)")
  dev.off()
}

setEPS()
postscript(file = file.path(img_dir, '04real/01Train.eps'),
           width = 7, height = 4.50)
plot(dendro_train, yaxt = "n", main = "(a)")
dev.off()

## Compute clustering error rate for airc
sum(golub_airc_pvalue < 0.05)

## We stop the analysis with the airc approach since no significant vimp has
## been found.

n1 <- max(length(golup_unairc_imp_medians),
          length(golup_airc_imp_medians))
n2 <- max(length(golup_unairc_imp_medians_null),
          length(golup_airc_imp_medians_null))
vimp_dt <- rbindlist(list(data.table(importance = c(golup_unairc_imp_medians[1:n1],
                                                    golup_airc_imp_medians[1:n1]),
                                     Measure = rep(c("UNAIR", "AIR"),
                                                   each = n1)),
                          data.table(importance = c(golup_unairc_imp_medians_null[1:n2],
                                                    golup_airc_imp_medians_null[1:n2]),
                                     Measure = rep(c("(NULL) UNAIR",
                                                     "(NULL) AIR"),
                                                   each = n2)))
)

vimp_dt$Measure <- factor(vimp_dt$Measure,
                          levels = c("AIR", "UNAIR",
                                     c("(NULL) AIR",
                                       "(NULL) UNAIR")))

if(FALSE){
  tikz(file = file.path(img_dir, '04real/golubhist.tex'),
       standAlone = TRUE,
       width = 6.5, height = 5,
       packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                  "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
  golub_hist <- ggplot(
    data = vimp_dt,
    aes(x = importance)) +
    geom_histogram(alpha = 0.1, bins = 35, fill = "white", color = "black") + 
    geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
    xlab("Variable Importance Measure") +
    theme(legend.position = "bottom",
          axis.title.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.text.y = element_blank(),
          plot.margin = margin(0.45, 0.15, 1, 1, "cm"),
          text = element_text(size = 15),
          axis.text.x = element_text(angle = 45, vjust = 0.8, hjust = 1),
          axis.title.x = element_text(margin = margin(t = 5,
                                                      r = 15,
                                                      b = 1,
                                                      l = 0))) +
    scale_x_continuous(labels = function(x) format(x, scientific = TRUE)) +
    facet_wrap(~ Measure, scales = "free")
  print(golub_hist)
  dev.off()
}

setEPS()
postscript(file = file.path(img_dir, '04real/golubhist.eps'),
           width = 6.5, height = 5)
golub_hist
dev.off()

if(FALSE){
  tikz(file = file.path(img_dir, '04real/golubbox.tex'),
       standAlone = TRUE,
       width = 5, height = 4,
       packages=c(options()$tikzLatexPackages, "\\usepackage{amsfonts}",
                  "\\usepackage[T1]{fontenc}", "\\usepackage{times}"))
  golub_box <- ggplot(data = vimp_dt, aes(x = Measure, y = importance)) +
    geom_boxplot() +
    geom_hline(yintercept = 0, color = "red", linetype = "dashed") +
    scale_y_continuous(labels = function(x) format(x, scientific = TRUE)) +
    theme(axis.title.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.x = element_blank()) +
    facet_wrap(~ Measure, scales = "free")
  print(golub_box)
  dev.off()
}


## ============================================================
##              Cluster using validation data set
## ============================================================
##
## Compute clustering error rate for unairc
data("Golub_Test")
truth_test <- as.character(Golub_Test$ALL.AML)
truth_test_BT_cell <- as.character(Golub_Test$T.B.cell)
truth_test_BT_cell[is.na(truth_test_BT_cell)] <- "AML"
truth_test_BT_cell <- sub(pattern = "cell",
                          replacement = "ALL",
                          x = truth_test_BT_cell)
sig_pvalue <- (golub_unairc_pvalue < 0.05) 
top5percent <- (golup_unairc_imp_medians > quantile(golup_unairc_imp_medians,
                                                    0.95))
golub_expression_test <- data.frame(t(Golub_Test@assayData$exprs))

## Plot Dendrogram
data_reduced_test <- data.frame(golub_expression_test)[ , sig_pvalue & top5percent]
data_reduced_dist_test <- pranger(data = data_reduced_test,
                                  strategy = "boostrepl",
                                  num.trees = 100e3,
                                  mtry = sqrt(sum(sig_pvalue & top5percent)),
                                  seed = 123,
                                  approach = "shi")

## PLot Dendrogram
clrs <- cutree(hclust(dist(cmdscale(data_reduced_dist_test, 2)), method = "ward.D"), 2)
clrs[(clrs == 1) & (truth_test == "ALL")] <- "red"
clrs[(clrs == 2) & (truth_test == "AML")] <- "red"
clrs[clrs != "red"] <- "black"
mds_test <- cmdscale(data_reduced_dist_test, 2)
dendro_test <- as.dendrogram(hclust(dist(mds_test), method = "ward.D"))
dendro_test <- dendro_test %>% color_branches(k = 3) %>% 
  set_labels(truth_test_BT_cell) %>%
  color_labels(labels = truth_test_BT_cell, col = c(rep("black", 16),
                                                    rep("red", 4),
                                                    rep("black", 14)))
## Use this to plot in pdf format
if(FALSE){
  pdf(file = file.path(img_dir, '04real/03Testwithselected.pdf'),
      width = 7, height = 4.50)
  par(mar = c(0, 0, -2, 0))
  plot(dendro_test, yaxt = "n", main = "(c)")
  dev.off()
}

setEPS()
postscript(file = file.path(img_dir, '04real/03Testwithselected.eps'),
           width = 7, height = 4.50)
# par(mar = c(0, 0, -2, 0))
plot(dendro_test, yaxt = "n", main = "(c)")
dev.off()

## Plot Dendrogram for all variables in the test data
data_reduced_test_all <- data.frame(golub_expression_test)
data_reduced_dist_test_all <- pranger(data = data_reduced_test_all,
                                      strategy = "boostrepl",
                                      num.trees = 100e3,
                                      # mtry = sqrt(sum(sig_pvalue & top5percent)),
                                      seed = 123,
                                      approach = "shi")
## PLot Dendrogram
clrs_all <- cutree(hclust(dist(cmdscale(data_reduced_dist_test_all, 2)), method = "ward.D"), 3)
mds_test_all <- cmdscale(data_reduced_dist_test_all, 2)
dendro_test_all <- as.dendrogram(hclust(dist(mds_test_all), method = "ward.D"))
dendro_test_all <- dendro_test_all %>% color_branches(k = 3) %>% 
  set_labels(truth_test_BT_cell) %>%
  color_labels(labels = truth_test_BT_cell, col = c(rep("black", 20),
                                                    rep("red", 5),
                                                    rep("black", 9)))
## Use this to plot in pdf format
if(FALSE){
  pdf(file = file.path(img_dir, '04real/02Testwithall.pdf'),
      width = 7, height = 4.50)
  plot(dendro_test_all, yaxt = "n", main = "(b)")
  dev.off()
}


## Plot all in one
if(FALSE){
  pdf(file = file.path(img_dir, '04real/04alldendro.pdf'),
      width = 7, height = 10)
  par(mfrow = c(3, 1))
  plot(dendro_train, yaxt = "n", main = "(a)")
  plot(dendro_test_all, yaxt = "n", main = "(b)")
  plot(dendro_test, yaxt = "n", main = "(c)")
  dev.off()
}

setEPS()
postscript(file = file.path(img_dir, '04real/04alldendro.eps'),
           width = 7, height = 10)
par(mfrow = c(3, 1))
plot(dendro_train, yaxt = "n", main = "(a)")
plot(dendro_test_all, yaxt = "n", main = "(b)")
plot(dendro_test, yaxt = "n", main = "(c)")
dev.off()
