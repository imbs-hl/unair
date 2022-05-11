## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
if(!file.exists(heart_failure_clinical_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00519/heart_failure_clinical_records_dataset.csv",
    destfile = heart_failure_clinical_file
  )
}
heart_failure_clinical <- fread(heart_failure_clinical_file)
heart_failure_clinical$time <- NULL
heart_failure_clinical$DEATH_EVENT <- NULL
fwrite(x = heart_failure_clinical,
       file = heart_failure_clinical_pro_file)