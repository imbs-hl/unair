## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
data("Golub_Train")
fwrite(x = Golub_Train@assayData$exprs, file = golub_expr_file)
fwrite(x = Golub_Train@assayData$exprs, file = wine_pro_file)