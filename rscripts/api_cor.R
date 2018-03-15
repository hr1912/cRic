#! /usr/bin/env R

# libs

library(magrittr)
#library(methods)
library(ggplot2)
#library(parallel)

# args
args <- commandArgs(TRUE)

stopifnot(length(args) == 2)

query_symbol <- args[2] #query genes

#test
#query_symbol <- "EIF4G3|QKI"

q <- strsplit(query_symbol, '[|]') %>% unlist %>% unique #query genes

# Path
root_path <- args[1]

# test
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

cor_path <- file.path(resource_data, "cor_result.rds.gz")
regulator_path <- file.path(resource_data, "regulator_matrix.rds.gz")

combined_json_file <- file.path(resource_jsons, glue::glue("api_cor.{query_symbol}.json"))

cor <- readr::read_rds(path = cor_path) %>% 
  dplyr::filter(gene %in% q) %>% 
  dplyr::mutate(fdr = format(fdr, scientific = T, digits = 4))

regulator <- readr::read_rds(path = regulator_path) %>% 
  dplyr::filter(gene %in% q)

if (nrow(cor) < 1) {
  
  jsonlite::write_json(x = NULL, path = combined_json_file)
  quit(save = "no", status = 0)
  
} else {
  
  jsonlite::write_json(x = cor, path = combined_json_file)
  
}  

save_png = function(query_gene) {
  
  png_file <- file.path(resource_pngs, glue::glue("api_cor.{query_gene}.png"))
  
  if (! file.exists(png_file)) {
  
  regulator %>% dplyr::filter(gene == query_gene) %>% 
  ggplot( aes( x =  exp, y = log(circ_reads,2)))+
    geom_point(alpha = .6, colour = 'blue4')+
    geom_smooth(method="lm", se=T, colour = 'grey14', linetype = 'dashed', size = .5)+
    xlab(paste0(query_gene, " expression") ) +
    ylab(paste0("log2 (total backsplicing reads)")) +
    theme_bw(base_size = 20) -> p
  
  
  png(png_file, width = 1080, height = 630)
  print(p)  
  
  dev.off()
  
  }
  
}

parallel::mclapply(q, save_png, mc.cores = parallel::detectCores())
