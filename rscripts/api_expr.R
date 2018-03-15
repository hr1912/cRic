#! /usr/bin/env R

# libs

library(magrittr)
#library(methods)
library(ggplot2)

# args
args <- commandArgs(TRUE)

stopifnot(length(args) == 2) 
# 1 root path; 2 query symbol; 
#3 binary indicater if by cancer cell line or by gene symbol

query <- args[2] # query by symbol or by cancer cell line
#q <- strsplit(query_symbol, '[|]') %>% unlist %>% unique #query genes

# Path

root_path <- args[1]
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

filename <- file.path(resource_data, "circRNAs_expression_matrix_mod.rds.gz")

#### write txt for cancer cell line and symbol name autocomplete

# ccl_names <- readr::read_rds(filename) %>%
#   dplyr::pull(ccl_name) %>% unique
# 
# gene_symbols <- readr::read_rds(filename) %>%
#   dplyr::pull(circ_gene) %>% unique
# 
# c(ccl_names, gene_symbols) %>%
#   tibble(query = .) %>%
#   readr::write_delim("ccl_symbol.txt", col_names = F)
# 
# beware of the quote symbol added !!!

# readr::read_rds(filename) %>% 
#    dplyr::pull(ccl_name) %>% 
#    unique %>% tibble(ccl=.) %>% 
#    readr::write_rds(path = file.path(resource_data, "ccl_name.rds.gz"), compress = "gz") 

ccl_names <- readr::read_rds(file.path(resource_data, "ccl_name.rds.gz")) %>% 
  dplyr::pull(ccl) 

by_ccl <- query %in% ccl_names 
# binary indicater if by cancer cell line or by gene symbol
# ccl_names %>% tibble(query = .) %>% readr::write_delim("ccl_names.txt", col_names = F)
# gene_symbols %>% tibble(query = .) %>% readr::write_delim("symbol_names.txt", col_names = F)

# test
# query <- "SORT1"
# q<- query_symbol %>%  strsplit('[|]') %>% unlist %>% unique()
# 

combined_json_file <- file.path(resource_jsons, 
                      glue::glue("api_expr.{query}.json"))
                    
if (by_ccl) {
  expr <- readr::read_rds(path = filename) %>%
  dplyr::filter(ccl_name %in% query)  
  #dplyr::select(circ, ccl_name, reads, type)
  
} else {
  expr <- readr::read_rds(path = filename) %>%
  dplyr::filter(circ_gene %in% query) %>%
  dplyr::group_by(circ) %>% 
  dplyr::distinct(circ, .keep_all =TRUE) %>%
  dplyr::select(circ, num_ccl, mean_reads, num_ct) %>%
  dplyr::mutate(mean_reads = format(mean_reads, digits = 4))
}

if (nrow(expr) < 1) {
  
  jsonlite::write_json(x = NULL, path = combined_json_file)
  quit(save = "no", status = 0)
  
} else {
 
  jsonlite::write_json(x = expr, path = combined_json_file)
  
}


#### test

# expr %>% 
#   dplyr::filter( circ == '1_109897106_109898072|SORT1') -> plot_data
# 
# #nrow(plot_data)
# #nrow(dplyr::distinct(plot_data, type))
# 
# plot_data %>% dplyr::group_by(type) %>% 
#   dplyr::summarise( mean_reads = mean(reads)) %>% dplyr::ungroup() %>% 
#   dplyr::arrange(desc(mean_reads)) -> cancer_type_order
# 
# plot_data %>% dplyr::count(type) %>% 
#   dplyr::right_join(cancer_type_order) %>% 
#   dplyr::mutate(lab_text = paste0(type, '\n (n=',n,')')) -> xlab_order 
# 
# ggplot(plot_data,aes(x =  type, y = reads, colour = type))+
#   geom_boxplot(outlier.shape = NA)+theme_bw(base_size = 24)+
#   theme(legend.position = 'none')+
#   # geom_point()+
#   scale_x_discrete(limits = xlab_order$type, labels = xlab_order$lab_text)+
#   expand_limits( y = 0)+
#   xlab('Cancer types')+ylab('Backsplicing Reads count')
# 
# expr %>% 
#   dplyr::filter( ccl_name =='COR-L24')  ->  plot_data2
#   number_of_circ = nrow(plot_data2)
# 
# ggplot(plot_data2,aes(x =  ccl_name, y = reads, colour = ccl_name))+
#   geom_boxplot(outlier.shape = NA)+theme_bw(base_size = 24 )+geom_jitter()+
#   theme(legend.position = 'none',
#         axis.text.x = element_text(size = 24))+
#   expand_limits( y = 0)+xlab(paste0('(N = ',number_of_circ,')'))+ylab('Backsplicing Reads count')

#### test end

save_png  = function (query_circ_gene) {
  
  q <- strsplit(query_circ_gene, '[|]') %>% unlist %>% .[[2]]
  
  png_file <- file.path(resource_pngs, glue::glue("api_expr.{query_circ_gene}.png"))
  
  if (! file.exists(png_file)) {
    
  expr %>% 
    dplyr::filter( circ == query_circ_gene ) -> plot_data  
    
  plot_data %>% dplyr::group_by(type) %>% 
    dplyr::summarise( mean_read = mean(reads)) %>% dplyr::ungroup() %>% 
    dplyr::arrange(desc(mean_read)) -> cancer_type_order
    
  plot_data %>% dplyr::count(type) %>% 
    dplyr::right_join(cancer_type_order) %>% 
    dplyr::mutate(lab_text = paste0(type, '\n (n=',n,')')) -> xlab_order 
  
  plot_data %>% ggplot(aes(x =  type, y = reads, colour = type))+
    geom_boxplot(outlier.shape = NA)+theme_bw(base_size = 20)+
    theme(legend.position = 'none', 
          axis.text.x = element_text(angle = 45, hjust = 1, size = 13),
          axis.title.x = element_blank())+
    scale_x_discrete(limits = xlab_order$type, labels = xlab_order$lab_text)+
    expand_limits( y = 0)+
    xlab('Cancer types')+ylab('Backsplicing Reads count') -> p
  
  # expr %>% dplyr::filter(circ == query_circ_gene) %>% 
  #   ggplot(aes(x=type, y=reads, color = type)) +
  #   geom_boxplot(outlier.shape = NA) + 
  #   ggsci::scale_color_npg() + 
  #   theme_bw(base_size = 24) + 
  #   ylab("# BS reads") +
  #   theme(legend.position = 'none') -> p
    
    png(png_file, width = 1080, height = 630)
    print(p)
    
    dev.off()
  }
  
}

if (by_ccl) {
  
  number_of_circ = nrow(expr)
  
  png_file <- file.path(resource_pngs, glue::glue("api_expr.{query}.png"))
  
  expr %>% 
    ggplot(aes(x =  ccl_name, y = log2(reads), colour = ccl_name))+
    geom_boxplot(outlier.shape = NA)+theme_bw(base_size = 20 )+geom_jitter()+ 
    theme(legend.position = 'none',
          axis.text.x = element_text(size = 20)) +
    expand_limits( y = 0) + 
    xlab(paste0('(N = ',number_of_circ,')')) + 
    ylab('log2(backsplicing reads count)') -> p
  
  png(png_file, width = 1080, height = 630)
  print(p)
  
  dev.off()
  
} else {

  expr <- readr::read_rds(path = filename) %>%
    dplyr::filter(circ_gene %in% query)

  circ_genes <- unique(expr$circ)
  parallel::mclapply(circ_genes, save_png, mc.cores = parallel::detectCores())
  
}
