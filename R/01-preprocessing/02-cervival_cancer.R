## Make sure your current directory is 01-preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
source("init.R", chdir = TRUE)
if(!file.exists(cervical_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00537/sobar-72.csv",
    destfile = cervical_file
  )
}
cervical <- fread(cervical_file)
cervical$ca_cervix <- NULL
fwrite(x = cervical, file = cervical_pro_file)