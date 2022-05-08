# unair
Here we are describing how to run the R code. The R code is intended to be parallelized using the R package batchtools.

The "init-global.R" file contains initializations required for all other files. Please use it to set the path to the local main directory. If you want to use a cluster for parallel computation, please set up the remote main directory. Also configure the required batchtools' resources. You can optionally use the file "batchtools.conf.R" for configurations. Specify partition (or queue) and account on your cluster with the corresponding variables in "init-global.R".

All results presented in the article can be obtained by running the codes in each directory in the order of the numbers prefixing their names. To run the codes contained in a specific directory, set this as your current directory, and firstly run the init.R file. The other R files contained in each directory are numbered in the order the should have to be executed. 

Data are downloaded and saved into directory "data". Concerning the data set "geneExp", please unzip the downloaded file once the download is done.