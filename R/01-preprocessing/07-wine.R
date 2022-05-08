## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
wine <- fread(wine_file)
fwrite(x = wine, file = wine_pro_file)