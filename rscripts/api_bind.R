#! /usr/bin/env R

# libs

library(magrittr)
#library(methods)
library(ggplot2)

args <- commandArgs(TRUE)

stopifnot(length(args) == 2)

query_symbol <- args[2]

#test
#query_symbol <- "COL1A1|POLR2A"

q <- strsplit(query_symbol, '[|]') %>% unlist %>% unique #query genes

# Path

root_path <- args[1]

# test
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

#### parsing

# miRNA_filename <- file.path(resource_data, "miRNA_circRNA_result.rds.gz")
# RBP_filename <- file.path(resource_data, "RBPs_circRNA_profile.rds.gz")
# 
# miRNA <- readr::read_rds(path = miRNA_filename)
# RBP <- readr::read_rds(path = RBP_filename)
# 
# miRNA_query_gene <- miRNA %>% pull(circ) %>%
#   sapply(., function (xx) {unlist(strsplit(xx, split = '[|]'))[[2]]}) %>%
#   unname
# 
# miRNA <- miRNA %>% mutate(query_gene = miRNA_query_gene)
# 
# miRNA <- miRNA[c("circ", "miRNA", "query_gene")]
# 
# readr::write_rds(miRNA, path=file.path(resource_data,"miRNAs_circRNAs_result.rds.gz"))
# 
# RBP_query_gene <- RBP %>% pull(circRNA) %>%
#   sapply(., function (xx) {unlist(strsplit(xx, split = '[|]'))[[2]]}) %>%
#   unname
# 
# RBP <- RBP %>% mutate(query_gene = RBP_query_gene)
# 
# readr::write_rds(RBP, path=file.path(resource_data,"RBPs_circRNAs_result.rds.gz"))

#### parsing end 

miRNA_filename <- file.path(resource_data, "miRNAs_circRNAs_result.rds.gz")
RBP_filename <- file.path(resource_data, "RBPs_circRNAs_result.rds.gz")

combined_json_miRNA_file <- file.path(resource_jsons, 
                                      glue::glue("api_bind.miRNA.{query_symbol}.json"))
combined_json_RBP_file <- file.path(resource_jsons, 
                                    glue::glue("api_bind.RBP.{query_symbol}.json"))

miRNA <- readr::read_rds(path = miRNA_filename) %>% 
  dplyr::filter(query_gene %in% q)

RBP <- readr::read_rds(path = RBP_filename) %>% 
  dplyr::filter(query_gene %in% q)

if (nrow(miRNA) < 1 & nrow(RBP) < 1) {
  
  jsonlite::write_json(x = NULL, path = combined_json_miRNA_file)
  jsonlite::write_json(x = NULL, path = combined_json_RBP_file)
  
  quit(save = "no", status = 0)
  
}

if (nrow(miRNA) < 1 & nrow(RBP) >= 1) {
  
  jsonlite::write_json(x = NULL, path = combined_json_miRNA_file)
  jsonlite::write_json(x = RBP, path = combined_json_RBP_file)
  
} 

if (nrow(miRNA) >=1 & nrow(RBP) < 1) {
  
  jsonlite::write_json(x = miRNA, path = combined_json_miRNA_file)
  jsonlite::write_json(x = NULL, path = combined_json_RBP_file)
  
}

if (nrow(miRNA) >= 1 & nrow(RBP) >= 1) {
 
  jsonlite::write_json(x = miRNA, path = combined_json_miRNA_file) 
  jsonlite::write_json(x = RBP, path = combined_json_RBP_file)
  
}  

# do not need plot :)
