## Make sure your current directory is 05-runtime
source("init.R", chdir = TRUE)

## Load type 1 error results
type1_reg <- loadRegistry(file = type1_reg_path)
type1_res <- batchtools::reduceResultsList(reg = type1_reg,
                                           ids = 1:350)
type1_runtime <- rbindlist(type1_res)
tmp <- type1_runtime$time
type1_runtime$time <- type1_runtime$utime
type1_runtime$utime <- tmp
type1_study <- type1_runtime[ , c("data", "time", "utime")]
type1_study$study <- "type1"
type1_study[ , meantime := round(mean(time), 2), by = data]
type1_study[ , umeantime := round(mean(utime), 2), by = data]
type1_study <- unique(type1_study, by = "data")
## Load power results
power_reg <- loadRegistry(file = power_reg_path)
power_res <- batchtools::reduceResultsList(reg = power_reg,
                                           ids = 1:175)
power_runtime <- rbindlist(power_res)
tmp <- power_runtime$time
power_runtime$time <- power_runtime$utime
power_runtime$utime <- tmp

power_study <- power_runtime[ , c("data", "time", "utime")]
power_study$study <- "power"
power_study[ , meantime := round(mean(time), 2), by = data]
power_study[ , umeantime := round(mean(utime), 2), by = data]
power_study <- unique(power_study, by = "data")

runtime_study <- rbindlist(list(type1_study, power_study))
