# unair
Here we describe how to run the R code. The R code is intended to be parallelized using the R package [`batchtools`](https://github.com/mllg/batchtools).

The `init-global.R` file contains initializations required for all other files. Please use it to set the path to the local main directory. If you want to use a cluster for parallel computation, please set up the remote main directory. Also configure further required `batchtools`' resources. You can optionally use the file `batchtools.conf.R` for configurations. `batchtools` ' template files could be found [here](https://github.com/mllg/batchtools/tree/master/inst/templates). Specify partition (or queue) and account on your cluster with the corresponding variables in `init-global.R`.

All results presented in the article can be reproduced by running the codes in each directory in the order of the numbers prefixing their names. To run the codes contained in a specific directory, please set this to your current directory, and firstly run the `init.R` file. The other `R` files contained in each directory are numbered in the order the should have to be executed. 

Data are downloaded and saved into directory `data`. Especially for the data set `geneExp`, please unzip the downloaded file once the download is done. The first run is expected to throw an error because the downloaded file is not yet unzipped.

To reproduce all results:

1. Configure the `init-global.R`
2. Start the jobs using the `start_jobs.R` file
Make sure all jobs completely run

3. Resume all results using the `resume_results.R` file