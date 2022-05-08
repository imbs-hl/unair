## Imputation function
impute_na <- function(x, val = mean, ...){
  if(!is.numeric(x))return(x)
  na <- is.na(x)
  if(is.function(val))
    val <- val(x[!na])
  if(!is.numeric(val)||length(val)>1)
    stop("'val' needs to be either a function or a single numeric value!")
  x[na] <- val
  x
}