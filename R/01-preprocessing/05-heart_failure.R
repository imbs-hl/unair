## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
heart_failure_clinical <- fread(heart_failure_clinical_file)
heart_failure_clinical$time <- NULL
heart_failure_clinical$DEATH_EVENT <- NULL
fwrite(x = heart_failure_clinical,
       file = heart_failure_clinical_pro_file)