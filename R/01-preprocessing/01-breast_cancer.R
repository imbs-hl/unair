## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
breast_cancer <- fread(breast_cancer_file)
breast_cancer$Classification <- NULL
fwrite(x = breast_cancer,
       file = breast_cancer_pro_file)