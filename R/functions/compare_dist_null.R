compare_dist_null <- function(
  data,
  pnoise = 500,
  num.trees = 10000,
  mtry = 22,
  seed = 123,
  ...
){
  n <- nrow(data)
  data_null <- lapply(1:(pnoise), function(i){
    set.seed(seed = i + seed)
    sample(x = data[ , (i %% ncol(data)) + 1])
  })
  data_null <- data.frame(data_null)
  names(data_null) <- paste("X", 1:ncol(data_null), sep = "")
  ## ==================================
  ## Our new test
  ## ==================================
  ##
  st_ujani <- system.time(
  ujanitza <- urf_test(
    data = data_null,
    target = "yy",
    num.trees = num.trees,
    mtry = mtry
  )
  )
  ujanitza$Method <- "UJanitza"
  st_jani <- system.time({
  set.seed(seed = seed)
  data_resampled <- pranger::resampling(
    data = data_null,
    strategy = "boostrepl"
  )
  ## Importance in original case
  ## =========================================================
  ##              Grow random forest in original case
  ## =========================================================
  forest <- ranger(data = data_resampled,
                   dependent.variable.name = "yy",
                   importance = "impurity_corrected",
                   mtry = mtry,
                   num.trees = num.trees,
                   ...
  )
  janitza <- data.table(ranger::importance_pvalues(x = forest, method = "janitza"))
  })
  janitza$Method <- "Janitza"
  df_res <- data.table(
    AIRC = janitza$importance,
    UNAIRC = ujanitza$importance,
    janitza = janitza$pvalue,
    ujanitza = ujanitza$pvalue,
    time = st_jani["elapsed"],
    utime = st_ujani["elapsed"],
    p = ncol(data_null),
    n = n,
    mtry = mtry
  )
  return(df_res)
}
