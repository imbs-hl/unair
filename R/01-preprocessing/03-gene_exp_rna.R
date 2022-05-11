## Make sure your current directory is 01-preprocessing
working_dir <- file.path(main_dir, "01-preprocessing")
source("init.R", chdir = TRUE)
if(!file.exists(gene_expression_file)){
  download.file(
    url = "https://archive.ics.uci.edu/ml/machine-learning-databases/00401/TCGA-PANCAN-HiSeq-801x20531.tar.gz",
    destfile = paste(tools::file_path_sans_ext(gene_expression_file),
                     "tar", sep = ".")
  )
  untar(tarfile = paste(tools::file_path_sans_ext(gene_expression_file),
              "tar", sep = "."),
        exdir = dirname(gene_expression_file))
}
if(!file.exists(file.path(dirname(gene_expression_file),
                          "TCGA-PANCAN-HiSeq-801x20531/data.csv"))){
  stop(sprintf("Please firtly unzip the downloaded .tar file: %s",
               paste(tools::file_path_sans_ext(gene_expression_file),
                     "tar", sep = ".")))
} else {
  gene_expression <- fread(file.path(dirname(gene_expression_file),
                                     "TCGA-PANCAN-HiSeq-801x20531/data.csv"))
  fwrite(x = gene_expression, file = gene_expression_file)
}

gene_expression <- fread(gene_expression_file)
gene_expression$V1 <- NULL
gene_expression$gene_5 <- NULL
fwrite(x = gene_expression,
       file = gene_expression_pro_file)