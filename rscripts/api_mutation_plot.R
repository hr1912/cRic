library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query <- args[2]
root_path <- args[1]

# test
#query <- '10_17271723_17271867|VIM-TP53'
#query_symbol <- 'VIM'
#root_path <- "/workspace/database/001.tRic/tRic_portal/cRic"

tmp <- stringr::str_split(query, "-") %>% unlist
circRNA = tmp[1]
mutated_gene = tmp[2] 

query_symbol = stringr::str_split(circRNA, "\\|") %>% unlist %>% .[[2]] 

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

mutation_result_simplify <-  readr::read_rds(file.path(resource_data,'mutation_result_simplify.rds.gz'))
circ_RNA_matrix <- readr::read_rds(file.path(resource_data,'circ_RNA_matrix.rds.gz'))
ccle_mut_matrix <- readr::read_rds(file.path(resource_data, 'ccle_mut_matrix.rds.gz'))

## plot the data 
fn_get_mut_circ_matrix <- function(x,y,z){ ## extract the mutation and circ profile 
  # x = '10_17271723_17271867|VIM' ; y = 'TP53'
  dplyr::bind_rows(circ_RNA_matrix %>% dplyr::filter(circ == x) %>% dplyr::select(-circ),
                   ccle_mut_matrix %>% dplyr::filter(gene == y) %>% dplyr::select(-gene)) -> output
  output$gene = c(paste0('circ',z),y)
  # output$gene = c(z,y)
  output
}

png_file <- file.path(resource_pngs, glue::glue("api_mutation.{circRNA}.{mutated_gene}.png"))

if (! file.exists(png_file)) {
  
  mutation_result_simplify %>% 
    dplyr::filter( circ_gene == query_symbol) %>% 
    dplyr::filter( circ == circRNA & mut == mutated_gene) %>% 
    dplyr::mutate( matrix = purrr::pmap(.l = list( circ,  mut,circ_gene),  .f = fn_get_mut_circ_matrix)) %>% 
    dplyr::select(matrix) %>% tidyr::unnest(matrix) -> plot_matrix
  
  ## generate the  ccl ( x axis) order
  plot_matrix %>% tidyr::gather(key = ccl, value = mut, -gene) %>% 
    tidyr::spread(key = gene, value = mut) ->a
  colnames(a) = c('ccl','geneA','geneB')
  a %>% dplyr::mutate(sum = geneA + geneB) %>% 
    dplyr::arrange(sum) %>% 
    dplyr::arrange(geneA) %>% 
    dplyr::arrange(geneB)  -> ccl_order
  
  # plot_matrix %>% tidyr::gather(key = ccl, value = mut, -gene) %>% 
  #   dplyr::mutate(mut = ifelse(mut ==0,'red','grey')) %>% 
  #   dplyr::mutate(ccl = factor(ccl, levels = rev(ccl_order$ccl ))) %>% 
  #   ggplot(aes(x = (ccl), y = gene, fill = mut))+
  #   geom_tile(show.legend = F)+
  #   scale_fill_manual(values = c('#E64B35FF','grey50'))+
  #   theme_bw(base_size = 20)+
  #   theme(axis.text.x = element_blank(),
  #         axis.text.y = element_text(angle = 0, size = 20),
  #         axis.title = element_blank(),
  #         axis.ticks = element_blank(),
  #         panel.background = element_blank(),
  #         panel.grid = element_blank())+
  #   geom_hline(yintercept = 1.5, linetype = 'dashed') -> p
  
  ccle_info <- readr::read_rds(file.path(resource_data,'ccle_cancer_type.rds')) 
  ccle_colour_info <- readr::read_rds(file.path(resource_data,'ccle_colour_info.rds.gz'))
  ccle_colour_info$color[ccle_colour_info$type=='LUHC'] = '#104A7F'
  ccle_colour_info <- dplyr::inner_join(ccle_colour_info, ccle_info) %>% tibble::as.tibble()
  
  library(ComplexHeatmap)
  library(circlize)  
  complex_matrix = as.data.frame(plot_matrix)
  rownames(complex_matrix) = complex_matrix$gene
  complex_matrix = complex_matrix[,-ncol(complex_matrix)]
  complex_matrix = complex_matrix[,rev(ccl_order$ccl)]
  
  col_df = data.frame(ccl =colnames(complex_matrix) )
  col_df %>% 
    dplyr::left_join(ccle_colour_info)  -> col_df
  col_vector = col_df$color
  names(col_vector) = col_df$type
  df = data.frame(lineage = col_df$type)
  ha = HeatmapAnnotation(df = df,
                         col = list( lineage = col_vector),
                         annotation_legend_param = list(lineage = list(title = "", nrow = 2,
                                                                       by_row =T,
                                                                       title_gp = gpar(fontsize = 14),
                                                                       labels_gp = gpar(fontsize = 14)))) ## set the font size
  
  ht = Heatmap(complex_matrix,  cluster_rows = F,cluster_columns = F,
              show_row_names = T,show_heatmap_legend = F, show_column_names = F,
              col  = c('grey','red'),row_names_gp = gpar(fontsize = 24), 
              top_annotation = ha, split = rownames(complex_matrix),gap = unit(1, "mm"))
  
  
  png(png_file, width = 1080, height = 360)
  #print(p)
  
  ComplexHeatmap::draw(ht, annotation_legend_side = "top")

  dev.off()
  
}