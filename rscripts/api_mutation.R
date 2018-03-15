#! /usr/bin/env R

library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query_symbol <- args[2]
root_path <- args[1]

# test
#query_symbol <- 'VIM'
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

mutation_result_simplify <-  readr::read_rds(file.path(resource_data,'mutation_result_simplify.rds.gz'))
circ_RNA_matrix <- readr::read_rds(file.path(resource_data,'circ_RNA_matrix.rds.gz'))
ccle_mut_matrix <- readr::read_rds(file.path(resource_data, 'ccle_mut_matrix.rds.gz'))

mutation_result_simplify %>% 
  dplyr::filter( circ_gene == query_symbol) %>% 
  dplyr::select( circRNA = circ,mutated_gene = mut, fdr, type) -> 
  json_datatable

json_datatable_file <- file.path(resource_jsons,
                                 glue::glue("api_mutation.{query_symbol}.json"))

if (nrow(json_datatable) < 1) {
  
  jsonlite::write_json(x = NULL, path = json_datatable_file)
  quit(save = "no", status = 0)
  
} else {
  
  jsonlite::write_json(x = json_datatable, path = json_datatable_file)
  
}

## plot the data 
# fn_get_mut_circ_matrix <- function(x,y,z){ ## extract the mutation and circ profile 
#   # x = '10_17271723_17271867|VIM' ; y = 'TP53'
#   dplyr::bind_rows(circ_RNA_matrix %>% dplyr::filter(circ == x) %>% dplyr::select(-circ),
#                    ccle_mut_matrix %>% dplyr::filter(gene == y) %>% dplyr::select(-gene)) -> output
#   output$gene = c(paste0('circ',z),y)
#   # output$gene = c(z,y)
#   output
# }
# 
# svg_file <- file.path(resource_pngs, glue::glue("api_mutation.{query_symbol}.svg"))
# 
# if (! file.exists(svg_file)) {
# 
#   mutation_result_simplify %>% 
#     dplyr::filter( circ_gene == query_symbol) %>% head(1) %>% 
#     dplyr::mutate( matrix = purrr::pmap(.l = list( circ,  mut,circ_gene),  .f = fn_get_mut_circ_matrix)) %>% 
#     dplyr::select(matrix) %>% tidyr::unnest(matrix) -> plot_matrix
# 
# ## generate the  ccl ( x axis) order
#   plot_matrix %>% tidyr::gather(key = ccl, value = mut, -gene) %>% 
#     tidyr::spread(key = gene, value = mut) ->a
#   colnames(a) = c('ccl','geneA','geneB')
#   a %>% dplyr::mutate(sum = geneA + geneB) %>% 
#     dplyr::arrange(sum) %>% 
#     dplyr::arrange(geneA) %>% 
#     dplyr::arrange(geneB)  -> ccl_order
# 
#   plot_matrix %>% tidyr::gather(key = ccl, value = mut, -gene) %>% 
#     dplyr::mutate(mut = ifelse(mut ==0,'red','grey')) %>% 
#     dplyr::mutate(ccl = factor(ccl, levels = rev(ccl_order$ccl ))) %>% 
#     ggplot(aes(x = (ccl), y = gene, fill = mut))+
#     geom_tile(show.legend = F)+
#     scale_fill_manual(values = c('#E64B35FF','grey50'))+
#     theme_bw(base_size = 20)+
#     theme(axis.text.x = element_blank(),
#         axis.text.y = element_text(angle = 0, size = 20),
#         axis.title = element_blank(),
#         axis.ticks = element_blank(),
#         panel.background = element_blank(),
#         panel.grid = element_blank())+
#     geom_hline(yintercept = 1.5, linetype = 'dashed') -> p
#   
#   svg(svg_file, width = 11.5, height = 4)
#   print(p)
#   
#   dev.off()
# 
# }
