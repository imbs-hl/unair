## %%%%%%%%%%%%%%%%%%%%%%%%%%
## Compute unairc importances
## %%%%%%%%%%%%%%%%%%%%%%%%%%

get_urf_importance <- function(i,
                               data = golub_expression,
                               target =  "yy",
                               num.trees = 10e4,
                               mtry = sqrt(ncol(golub_expression)),
                               resampling_seed = 123,
                               seed = 123 + i){
  source("init.R", chdir = TRUE)
  message(sprintf("i = %s", i))
  st_ujani <- system.time({
    golub_vimp_unairc <- urf_test(data = data,
             target =  "yy",
             num.trees = num.trees,
             mtry = sqrt(ncol(data)),
             resampling_seed = resampling_seed,
             seed = 123 + i
    )[ , importance]
    })
  st_jani <- system.time({
    golub_vimp_airc <- airc_pvalue(data = data,
                num.trees = num.trees,
                mtry = sqrt(ncol(data)),
                seed = 123 + i)[ , "importance"]
  })
  golub_vimp <- cbind(golub_vimp_unairc,
                      golub_vimp_airc,
                      time = st_jani["elapsed"],
                      utime = st_ujani["elapsed"])
}

urf_cluster <- function(data,
                           sig_vimp,
                           truth,
                           num.trees = 2000,
                           mtry,
                           seed,
                           ...){
  # sig_vimp <- which(rowMeans(vimp_rep) > threshold)
  data_vimp <- data[ , sig_vimp]
  data_dist <- pranger(data = data_vimp,
                       strategy = "boostrepl",
                       num.trees = num.trees,
                       mtry = mtry,
                       approach = "shi",
                       seed = seed)
  heat_cluster <- heatmap(data_dist,
                          labCol = truth,
                          labRow = FALSE)
  c(nb_sig_imp = sum(sig_vimp),
    num.trees = num.trees,
    mtry = mtry,
    error_rate = mean(truth != truth[heat_cluster$rowInd]))
}


## Prediction error
pred_error <- function(data,
                       seed,
                       mtry,
                       num.trees,
                       ...){
  seed <- ifelse(missing(seed), 123, seed)
  set.seed(seed = seed)
  data_resampled <- pranger::resampling(
    data = data,
    strategy = "boostrepl"
  )
  ## Importance in original case
  ## =========================================================
  ##              Grow random forest in original case
  ## =========================================================
  forest_golub_expr <- ranger(data = data_resampled,
                              dependent.variable.name = "yy",
                              mtry = mtry,
                              num.trees = num.trees,
                              ...
  )
  forest_golub_expr$prediction.error
  return(forest_golub_expr$prediction.error)
}
