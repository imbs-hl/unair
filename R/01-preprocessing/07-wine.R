## Make sure your current directory is 01-preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
source("init.R", chdir = TRUE)
if(!file.exists(wine_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data",
    destfile = wine_file
  )
}
wine <- fread(wine_file)
wine$V1 <- NULL
fwrite(x = wine, file = wine_pro_file)
