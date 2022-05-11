## Make sure your current directory is 01-preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
source("init.R", chdir = TRUE)
if(!file.exists(breast_cancer_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00451/dataR2.csv",
    destfile = breast_cancer_file
  )
}
breast_cancer <- fread(breast_cancer_file)
breast_cancer$Classification <- NULL
fwrite(x = breast_cancer,
       file = breast_cancer_pro_file)