library(readr)
# setwd("/workspace/database/tRic.dev/tRic_portal/cRic/static/download/")

root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_data <- file.path(resource, "data")

setwd(resource_data)

download_path <- file.path(root_path,"static/download")

f <- read_rds("circRNA_matrix.rds.gz")
out <- file.path(download_path,"circRNA_expression.csv")
write_excel_csv(f,out)

f <- read_rds("regulator_matrix.rds.gz")
out <- file.path(download_path,"regulator.csv")
write_excel_csv(f,out)

f <- read_rds("CTRP_diff_gene_based_for_all_gene_and_drug.rds.gz")
out <- file.path(download_path,"diff_gene_CTRPv2.csv")
write_excel_csv(f,out)

f <- read_rds("gdsc_diff_gene_based_for_all_gene_and_drug.rds.gz")
out <- file.path(download_path,"diff_gene_GDSC.csv")
write_excel_csv(f,out)

f <- read_rds("miRNAs_circRNAs_result.rds.gz")
out <- file.path(download_path,"miRNA_circRNA.csv")
write_excel_csv(f,out)

f <- read_rds("RBPs_circRNAs_result.rds.gz")
out <- file.path(download_path,"RBPs_circRNA.csv")
write_excel_csv(f,out)
