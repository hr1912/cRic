#! /usr/bin/env R

library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query_symbol <- args[2]
root_path <- args[1]

# test
#query_symbol <- 'HCLS1'
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

f1 <- readr::read_rds(file.path(resource_data, "mRNA_matrix.rds.gz")) 
f2 <- readr::read_rds(file.path(resource_data, "circ_RNA_matrix_mRNA_association.rds.gz")) 
f3 <- readr::read_rds(file.path(resource_data, "mRNA_circ_matrix_simplify.rds.gz")) 

f3 %>% 
  dplyr::filter(circ_gene == query_symbol) %>% 
  dplyr::select(circRNA = circ, mRNA_gene = gene, difference = diff, fdr) %>% 
  dplyr::mutate(difference = round(difference,3), fdr = signif(fdr,4)) -> 
  json_datatable

json_datatable_file <- file.path(resource_jsons,
                                 glue::glue("api_mrna.{query_symbol}.json"))


if (nrow(json_datatable) < 1) {
  
  jsonlite::write_json(x = NULL, path = json_datatable_file)
  quit(save = "no", status = 0)
  
} else {
  
  jsonlite::write_json(x = json_datatable, path = json_datatable_file)
  
}

# fn_contain_circ_ccl <- function(x) {
#   
#   tmp <- f2 %>% dplyr::filter(circ==x) %>% 
#     dplyr::select(-circ) %>% dplyr::slice(1) %>% 
#     unlist(use.names = F)
#   colnames(f2)[-1][!tmp==0]
#   
# }
# 
# 
# save_svg = function (id) {
#   
#   tmp <- stringr::str_split(id, "-") %>% unlist
#   circRNA = tmp[1]
#   mRNA_gene = tmp[2] 
#   
#   svg_file <- file.path(resource_pngs, glue::glue("api_mrna.{circRNA}.{mRNA_gene}.svg"))
#   
#   if (! file.exists(svg_file)) {
#     
#     f3 %>% 
#       dplyr::filter(circ_gene == query_symbol) %>% dplyr::arrange((fdr)) %>% 
#       dplyr::filter(circ == circRNA & gene == mRNA_gene ) %>% ## generate plot for each mRNA
#       dplyr::mutate(contain_circ_ccl = purrr::map(.x = circ, .f = fn_contain_circ_ccl))  %>% 
#       dplyr::select(gene, contain_circ_ccl) -> var_for_plot
#     
#     f1 %>% 
#       dplyr::filter( gene  == var_for_plot$gene ) %>% 
#       dplyr::mutate(type = dplyr::if_else( ccl %in% unlist(var_for_plot$contain_circ_ccl), 'circRNA(+)', 'circRNA(-)')) %>% 
#       ggplot(aes(x = type, y = log(mRNA+1,2), colour = type))+
#       stat_boxplot(geom = "errorbar", width = .4 , lwd = 1.5, show.legend = F)+
#       geom_boxplot(width = .5, outlier.shape = NA, lwd = 1.5, show.legend = F)+theme_bw(base_size = 20)+
#       ggsci::scale_color_npg() +
#       theme( axis.title.x = element_blank(),
#              axis.text = element_text(size = 20))+
#       ylab('log2(TPM)') -> p 
#     
#     svg(svg_file, width = 11.5, height = 7)
#     print(p)
#     
#     dev.off()
#     
#   }  
#   
# }
# 
# #json_datatable_idx <- seq(1:nrow(json_datatable))
# 
# json_datatable %>% 
#   dplyr::mutate(id=paste0(circRNA, "-" , mRNA_gene)) %>% 
#   pull(id) -> ids
# 
# parallel::mclapply(ids, save_svg, mc.cores = parallel::detectCores())

