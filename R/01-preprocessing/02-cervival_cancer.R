## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
cervical <- fread(cervical_file)
cervical$ca_cervix <- NULL
fwrite(x = cervical, file = cervical_pro_file)