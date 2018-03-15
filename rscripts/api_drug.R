#! /usr/bin/env R

# libs

library(magrittr)
#library(methods)
library(ggplot2)

args <- commandArgs(TRUE)

stopifnot(length(args) == 3)

query_symbol <- args[2]
q <- strsplit(query_symbol, '[|]') %>% unlist %>% unique #query genes

# Path

root_path <- args[1]

# test
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

drug_db_i <- args[3]


# test
#drug_db_indicator <- "CTRP"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

filename <- ifelse(drug_db_i=="gdsc", 
                  "gdsc_diff_gene_based_for_all_gene_and_drug.rds.gz",
                  "ccle_diff_gene_based_for_all_gene_and_drug.rds.gz") %>% 
          file.path(resource_data, .)

drug_names <- readr::read_rds(file.path(resource_data, "drug_names.rds.gz")) %>% 
  dplyr::pull(drug) 

by_drug <- query_symbol %in% drug_names 

combined_json_file <- file.path(resource_jsons,
                                glue::glue("api_drug.{query_symbol}.{drug_db_i}.json"))


if (by_drug) {
  
  readr::read_rds(path = filename) %>% 
    dplyr::filter(drug %in% q) -> selected
} else {
  
  readr::read_rds(path = filename) %>% 
    dplyr::filter(circ_gene %in% q) -> selected
  
}

  # readr::read_rds(path = filename) %>% 
  # ifelse(by_drug, dplyr::filter(drug %in% q), dplyr::filter(circ_gene %in% q)) -> selected
#  dplyr::filter(circ_gene %in% q) -> selected

# test
#selected <- readr::read_rds(path=filename) %>% dplyr::filter(circ_gene %in% "ASPH") 

# selected %>% mutate(sig=ifelse(selected$fdr < .05, "FDR<0.05", "Not Sig")) -> selected


if (nrow(selected) < 1) {
  
  jsonlite::write_json(x = NULL, path = combined_json_file)
  quit(save = "no", status = 0)
  
} else {
  
  jsonlite::write_json(x = selected %>% dplyr::mutate(fdr = format(fdr, scientific = T, digits = 4)),
                       path = combined_json_file)
  
}

### filter
selected <- selected %>% 
  dplyr::mutate(sig=ifelse(selected$fdr < .05, "FDR < 0.05", "FDR >= 0.05"))  


save_png_1 = function (query_gene) {
  
  png_file <- file.path(resource_pngs, glue::glue("api_drug.{query_gene}.{drug_db_i}.png"))
  
  if (! file.exists(png_file)) {
  
    selected %>% dplyr::filter(circ_gene == query_gene) %>% 
      ggplot( aes(diff, -log10(fdr))) +
      geom_point(aes(col=sig), size=2.5, alpha = .75) +
#      ggsci::scale_color_npg() +
      scale_color_manual(values = c("#E64B35FF","grey50"), labels = c("FDR < 0.05", "FDR >= 0.05"), name="") +
      ggrepel::geom_label_repel(data= dplyr::filter(selected, fdr<.05) %>% 
                                  dplyr::arrange(fdr) %>% 
                                  dplyr::slice(1:20),
                               aes(label=drug)) + 
      xlab("Drug IC50 Difference") +
      ylab("-Log10(FDR)") +
      theme_bw(base_size = 20) -> p
    
    png(png_file, width = 1080, height = 630)
    print(p)
    
    dev.off()
    
  }
  
}

save_png_2 = function (query_drug) {
  
  png_file <- file.path(resource_pngs, glue::glue("api_drug.{query_drug}.{drug_db_i}.png"))
  
  if (! file.exists(png_file)) {
    
    selected %>% dplyr::filter(drug == query_drug) %>% 
      ggplot( aes(diff, -log10(fdr))) +
      geom_point(aes(col=sig), size=2.5, alpha = .75) +
      #      ggsci::scale_color_npg() +
      scale_color_manual(values = c("#E64B35FF","grey50"), labels = c("FDR < 0.05", "FDR >= 0.05"), name="") +
      ggrepel::geom_label_repel(data= dplyr::filter(selected, fdr<.05) %>% 
                                  dplyr::arrange(fdr) %>% 
                                  dplyr::slice(1:20),
                                aes(label=circ_gene)) + 
      xlab("Drug IC50 Difference") +
      ylab("-Log10(FDR)") +
      theme_bw(base_size = 20) -> p
    
    png(png_file, width = 1080, height = 630)
    print(p)
    
    dev.off()
    
  }
  
}

if (by_drug) {

  parallel::mclapply(q, save_png_2, mc.cores = parallel::detectCores())

} else {
  
  #circ_genes <- unique(selected$circ_gene)
  parallel::mclapply(q, save_png_1, mc.cores = parallel::detectCores())
  
}  
