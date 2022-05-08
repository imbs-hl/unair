#' Wrapper around typically batchMap() setup
#'
#' @title wrap_batchtools_R used for parallel computation on a slurm cluster.
#'                          We encourage, for simplicity, to use the 
#'                          configuration file locate in the directory 
#'                          99_batchtools
#'
#' @param reg_name [char] Name of registry to load
#' @param r_function  [r object] Name of R function to run
#' @param vec_args [list] Vector to loop over
#' @param more_args [list] Static arguments, handed to more.args of \code{\link{batchtools:batchMap}}
#' @param overwrite [logical] TRUE deletes the registry to force re-execution of
#'     jobs, default is FALSE
#' @param memory [string] set memory needed for batch job, example '8G'
#' @param packages [string vector] r string vector of package names that are required
#' @param work_dir [string] working directory
#' @param reg_dir [string] registry name
#' @param n_cpus [integer] number of cpus
#' @param walltime [integer] walltime
#' @param partition [string] partition to be used
#' @param account [string] account to be used
#' @param test_job [boolean] if TRUE, then test the first jobs only
#' @param wait_for_jobs [boolean] if TRUE, then wait for jobs
#' @param config_file [string] path to the configuration file
#' @param name [string] chunk name to appeared in swatch (SLURM)
#'
#' @return Nothing, throws an error if not all jobs are finished 
#' @export
wrap_batchtools <- function(reg_name,
                            name = "",
                            work_dir = getwd(),
                            reg_dir,
                            r_function,
                            vec_args,
                            more_args,
                            overwrite = FALSE,
                            memory = memory,
                            n_cpus = 1,
                            walltime = walltime,
                            partition = partition,
                            account = account,
                            test_job = FALSE,
                            wait_for_jobs = TRUE,
                            source_file = character(0),
                            packages = character(0),
                            config_file){
  
  
  library(batchtools, quietly = TRUE)
  ## Delete registry if overwrite
  reg_abs <- file.path(reg_dir, reg_name)
  reg <- NULL
  print(reg_abs)
  if(overwrite) {
    if(file.exists(reg_abs)){
      unlink(reg_abs, recursive = TRUE)
    }
    ## create or load reg
    reg <- batchtools::makeRegistry(
      file.dir = reg_abs,
      work.dir = work_dir,
      conf.file = config_file,
      source = source_file,
      packages = packages)
    
    
    
    
    ## Add jobs to map, if reg is empty
    if (nrow(batchtools::findJobs(reg))) {
      ids <- batchtools::findJobs(reg)
    } else {
      ## build job map
      message('Build job map')
      if(!is.list(vec_args)){
        do.call(what = batchtools::batchMap,
                args = c(vec_args, list(reg = reg, fun = r_function,
                                        more.args = more_args
                )))
      } else {
        batchtools::batchMap(reg = reg,
                             fun = r_function,
                             vec_args,
                             more.args = more_args
        )
      }
    }
  } else {
    ## Reload existing directory
    message("Loading registry...\n")
    reg <- batchtools::loadRegistry(file.dir = reg_abs,
                                    writeable = TRUE)
    message("Loading done!\n")
  }
  if(test_job){
    batchtools::testJob(id = 1, reg = reg)
  } else {   
    ## submit unfinished jobs, i.e. for first run: all
    ids <- batchtools::findNotDone(reg = reg)
    if(nrow(ids) > 0){
      message(nrow(ids), ' jobs found, (re)submitting')
      ids[ , chunk := 1]
      batchtools::submitJobs(
        ids = ids, 
        resources = list(
          name = name,
          ntasks = 1, 
          ncpus = n_cpus, 
          memory = memory,
          account = account,
          walltime = walltime,
          partition = partition,
          chunks.as.arrayjobs = TRUE),
        reg = reg)
    }
    if(wait_for_jobs){
      wait <- batchtools::waitForJobs(reg = reg)
      if(!wait){
        warning('Jobs for registry ', reg_name, ' not completed')
      }
    }
  }
  return(reg)
}

