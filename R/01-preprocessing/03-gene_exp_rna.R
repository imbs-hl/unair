## Make sure your current directory is 01-preprocessing
source("init.R", chdir = TRUE)
gene_expression <- fread(gene_expression_file)
gene_expression$V1 <- NULL
gene_expression$gene_5 <- NULL
fwrite(x = gene_expression,
       file = gene_expression_pro_file)