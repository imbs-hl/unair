## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
mice_protein_expression <- fread(mice_protein_expression_file,
                                 dec = ",")
mice_protein_expression <- mice_protein_expression[ , -c(78, 79, 80)]

mice_protein_expression <- mice_protein_expression[, lapply(.SD, impute_na)]
fwrite(
  x = mice_protein_expression,
  file = mice_protein_expression_pro_file
)