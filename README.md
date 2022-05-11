# unair
Here we describe how to run the R code. The R code is intended to be parallelized using the R package [`batchtools`](https://github.com/mllg/batchtools).

The `init-global.R` file contains initializations required for all other files. Please use it to set the path to the local main directory. Please firstly set your main directory before running the R code.

Also configure further required `batchtools`' resources in the head of the `start_jobs.R` file. You can optionally use our configuration file `batchtools.conf.R` and adjust it to your specifications or use the one of the `batchtools` ' template, that available [here](https://github.com/mllg/batchtools/tree/master/inst/templates). Specify partition (or queue) and the account to be used on your cluster with the corresponding variables in `start_jobs.R`.

All results presented in the article can be reproduced by running the codes in each directory following the order of the numbers prefixing their names.

Data will be downloaded and saved into directory `data`.

To reproduce all results:

1. Configure the `init-global.R`
2. Start the jobs using the `start_jobs.R` file

Make sure all jobs have completely run

3. Resume all results using the `resume_results.R` file