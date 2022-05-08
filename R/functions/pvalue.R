## ===============================
##          URF test
## ===============================
##
#' Title
#'
#' @param data [data.frame] original data
#' @param target [character] name of the artificial target variable
#' @param resampling_seed [integer] resampling seed
#' @param ... more parameters to pass to ranger
#'
#' @return
#' @export
#'
#' @examples
urf_test <- function(
  data,
  target = "target",
  resampling_seed,
  ...
){
  if(!missing(resampling_seed)){
    set.seed(seed = resampling_seed)
  }
  data_resampled <- pranger::resampling(
    data = data,
    strategy = "boostrepl"
  )
  names(data_resampled)[1] <- target
  ## Importance in original case
  ## =========================================================
  ##              Grow random forest in original case
  ## =========================================================
  forest <- ranger(data = data_resampled,
                   dependent.variable.name = target,
                   importance = "impurity",
                   ...
  )
  imp <- ranger::importance(x = forest)
  ## =========================================================
  ##              Create the null case scenario
  ## ========================================================= 
  ##
  if(!missing(resampling_seed)){
    set.seed(seed = resampling_seed + 1)
  }
  data_null <- lapply(data, function(i){
    sample(i)
  })
  data_null <- data.frame(data_null)
  if(!missing(resampling_seed)){
    set.seed(seed = resampling_seed + 2)
  }
  data_null_resampled <- pranger::resampling(
    data = data_null,
    strategy = "boostrepl"
  )
  names(data_null_resampled)[1] <- target
  forest_null <- ranger(data = data_null_resampled,
                        dependent.variable.name = target,
                        importance = "impurity",
                        ...
  )
  imp_null <- ranger::importance(x = forest_null)
  ## =========================================================
  ##              Compute pvalue
  ## ========================================================= 
  imp_diff <- imp - imp_null
  dist_null <- c(imp_diff[imp_diff < 0],
                 imp_diff[imp_diff == 0],
                 -imp_diff[imp_diff < 0])
  if(length(imp_diff) < 100){
    warning("There is not enough negativ values for the null distributions")
  }
  pvalue <- sapply(imp_diff, function(x){
    1 - mean(dist_null <= x)
  })
  return(data.table(
    importance = imp_diff,
    pvalue = pvalue
  ))
}