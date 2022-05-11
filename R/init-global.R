## Install the pranger package develop computation of random forest
## proximity measure using the ranger package.
if(!any(rownames(installed.packages()) == "pranger")){
  devtools::install_github("imbs-hl/pranger")
}
## ================================
## Load necessary packages
## ================================
##
pacman::p_load(
  data.table,
  ggplot2,
  tikzDevice,
  batchtools,
  ## For heatmap
  golubEsets,
  ComplexHeatmap,
  dendextend
)

## =====================================
##            Main directories settings
## =====================================
##
## Please set up your main directories in this part.
##
## Set your main directory using your user name here. Should be the path
## to "R-code"
user <- Sys.info()[["user"]]
main_dir <- "/imbs/home/cesaire/projects/urf_mtry_paper/R-code"
## Image directory
img_dir <- file.path(dirname(main_dir))
if(!dir.exists(img_dir)){
  dir.create(img_dir) 
}

## Registry directory to be used by batchtools, located on the cluster
registry_dir <- file.path(main_dir, "registry")
if(!dir.exists(registry_dir)){
  dir.create(registry_dir) 
}

## ===========================================
##     Configuration of batchtools resources
## ===========================================

## Batchtools configuration file
config_file <- file.path(main_dir, "99_batchtools/batchtools.conf.R")

## For resource manager, e.g. SLURM
partition <- "prio"
account <- "dzhkomics"

## ===============================
##      Set data directories
## ===============================
##
functions_dir <- file.path(main_dir, "functions")
source(file.path(functions_dir, "batchtoolswrapper.R"))
data_dir <- file.path(main_dir, "data")
if(!dir.exists(data_dir)){
  dir.create(data_dir) 
}
breast_cancer_dir <- file.path(data_dir, "breast_cancer_coimbra_data_set")
cervical_dir <- file.path(data_dir, "cervical_cancer")
gene_expression_dir <- file.path(data_dir, "gene_expression_cancer_rna")
heart_failure_clinical_dir <- file.path(data_dir, "heart_failure_clinical")
mice_protein_expression_dir <- file.path(data_dir, "mice_protein_expression")
wine_dir <- file.path(data_dir, "wine")
golub_dir <- file.path(data_dir, "gene_expr_golub")

## ========================
## Files 
## ========================
##
### Original files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
breast_cancer_file <- file.path(breast_cancer_dir,
                                "dataR2.csv")
cervical_file <- file.path(cervical_dir, "sobar72.csv")
gene_expression_file <- file.path(gene_expression_dir,
                                  "data.csv")
gene_expression_labels_file <- file.path(gene_expression_dir,
                                  "labels.csv")
heart_failure_clinical_file <- file.path(heart_failure_clinical_dir,
                                         "heart_failure_clinical_records_dataset.csv")
mice_protein_expression_file <- file.path(mice_protein_expression_dir,
                                     "Data_Cortex_Nuclear.csv")
wine_file <- file.path(wine_dir, "wine.csv")
golub_expr_file <- file.path(golub_dir, "golub_expr.csv")
golub_expr_pheno_file <- file.path(golub_dir, "golub_pheno.csv")
### Proceed files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
breast_cancer_pro_file <- file.path(breast_cancer_dir,
                                "dataR2_pro.csv")
cervical_pro_file <- file.path(cervical_dir, "sobar72_pro.csv")
gene_expression_pro_file <- file.path(gene_expression_dir,
                                  "data_pro.csv")
gene_expr_unairc_file <- file.path(gene_expression_dir,
                                      "gene_expr_unairc.rds")
gene_expr_airc_file <- file.path(gene_expression_dir,
                                   "gene_expr_airc.rds")

heart_failure_clinical_pro_file <- file.path(heart_failure_clinical_dir,
                                         "heart_failure_clinical_records_dataset_pro.csv")
mice_protein_expression_pro_file <- file.path(mice_protein_expression_dir,
                                          "Data_Cortex_Nuclear_pro.csv")
mice_protein_unairc_file <- file.path(mice_protein_expression_dir,
                                      "mice_protein_unairc.rds")
wine_pro_file <- file.path(wine_dir, "wine_pro.csv")
golub_expr_pro_file <- golub_expr_file
golub_unairc_file <- file.path(golub_dir, "golub_expr_unairc.rds")
golub_airc_file <- file.path(golub_dir, "golub_expr_airc.rds")

### Data names %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_names <- c("breast", "cervical", "geneExp", "heart", "protein", "wine")
data_files <- c(
  breast_cancer = breast_cancer_pro_file,
  cervical = cervical_pro_file,
  gene_expression = gene_expression_pro_file,
  heart_failure_clinical = heart_failure_clinical_pro_file,
  mice_protein_expression = mice_protein_expression_pro_file,
  wine = wine_pro_file
)
names(data_files) <- data_names