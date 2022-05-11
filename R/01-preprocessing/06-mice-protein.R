## Make sure your current directory is 01-preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
source("init.R", chdir = TRUE)
if(!file.exists(mice_protein_expression_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00342/Data_Cortex_Nuclear.xls",
    destfile = mice_protein_expression_file
  )
}
mice_protein_expression <- data.table(readxl::read_xls(mice_protein_expression_file))
mice_protein_expression$MouseID <- NULL
mice_protein_expression <- mice_protein_expression[ , 1:77]

mice_protein_expression <- mice_protein_expression[, lapply(.SD, impute_na)]
fwrite(
  x = mice_protein_expression,
  file = mice_protein_expression_pro_file
)
