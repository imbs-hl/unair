get_correlation <- function(data = hcv, n_var = 5){
  tokeep <- which(sapply(data.table(data), is.numeric))
  data <- data[ , tokeep, with = FALSE]
  cor_mat <- cor(x = data[ , 1:min(n_var, ncol(data))], method = "pearson")
  return(cor_mat)
}

simulate_effect <- function(data = wine,
                            effect = 0:4,
                            n_effect_repl = 20
){
  n <- ceiling(nrow(data) / 3)
  p <- ncol(data)
  l <- lapply(1:n_effect_repl, function(i){
    m1 <- MASS::mvrnorm(n, mu = effect,
                        Sigma = get_correlation(data = data,
                                                n_var = length(effect)))
    m2 <- MASS::mvrnorm(n, mu = rep(0, length(effect)),
                        Sigma = get_correlation(data = data,
                                                n_var = length(effect)))
    m3 <- MASS::mvrnorm(n, mu = -1 * effect,
                        Sigma = get_correlation(data = data,
                                                n_var = length(effect)))
    m123 <- rbind(m1, m2, m3)
    
  })
  new_data <- data.frame(l)
  return(new_data[1:nrow(data), ])
}


urf_power <- function(data = wine,
                      effect = 0:5/2,
                      n_effect_repl = 20,
                      pnoise = 1000,
                      num.trees = 20000,
                      mtry = floor(sqrt(ncol(data) + pnoise)),
                      seed = 123,
                      ...){
  ## Firstly simulate effect data
  data_effect <- simulate_effect(data = data,
                                 effect = effect,
                                 n_effect_repl = n_effect_repl)
  ## Secondly simulate noise data
  n <- nrow(data)
  data <- data.frame(data)
  data_noise <- lapply(1:(pnoise), function(i){
    set.seed(seed = i + seed)
    sample(x = data[ , (i %% ncol(data)) + 1])
  })
  data_noise <- as.data.frame(data_noise)
  data_new <- data.frame(data_effect, data_noise)
  names(data_new) <- paste("X", 1:ncol(data_new), sep = "")
  ## ==================================
  ## My new test
  ## ==================================
  ##
  st_ujani <- system.time(
    ujanitza <- urf_test(
      data = data_new,
      target = "yy",
      num.trees = num.trees,
      mtry = mtry
    )    
  )
  ujanitza$Method <- "UJanitza"
  ujanitza$time <- st_ujani["elapsed"]
  st_jani <- system.time({
    set.seed(seed = seed)
    data_resampled <- pranger::resampling(
      data = data_new,
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
  janitza$time <- st_jani["elapsed"]
  df_res <- data.table(
    effect = factor(as.character(rep(effect, n_effect_repl))),
    AIRC = janitza$importance[1:(length(effect) * n_effect_repl)],
    UNAIRC = ujanitza$importance[1:(length(effect) * n_effect_repl)],
    janitza = janitza$pvalue[1:(length(effect) * n_effect_repl)],
    ujanitza = ujanitza$pvalue[1:(length(effect) * n_effect_repl)],
    utime = ujanitza$time[1],
    time = janitza$time[1],
    p = ncol(data_new),
    n = n,
    mtry = mtry
  )
}



