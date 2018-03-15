library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query <- args[2]
root_path <- args[1]

# test
#query <- '17_48266113_48266364|COL1A1-COL1A2'
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

tmp <- stringr::str_split(query, "-") %>% unlist
circRNA = tmp[1]
mRNA_gene = tmp[2] 

query_symbol = stringr::str_split(circRNA, "\\|") %>% unlist %>% .[[2]] 

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

f1 <- readr::read_rds(file.path(resource_data, "mRNA_matrix.rds.gz")) 
f2 <- readr::read_rds(file.path(resource_data, "circ_RNA_matrix_mRNA_association.rds.gz")) 
f3 <- readr::read_rds(file.path(resource_data, "mRNA_circ_matrix_simplify.rds.gz")) 


fn_contain_circ_ccl <- function(x) {
  
  tmp <- f2 %>% dplyr::filter(circ==x) %>% 
    dplyr::select(-circ) %>% dplyr::slice(1) %>% 
    unlist(use.names = F)
  colnames(f2)[-1][!tmp==0]
  
}

png_file <- file.path(resource_pngs, glue::glue("api_mrna.{circRNA}.{mRNA_gene}.png"))

if (! file.exists(png_file)) {
  
  f3 %>% 
    dplyr::filter(circ_gene == query_symbol) %>% dplyr::arrange((fdr)) %>% 
    dplyr::filter(circ == circRNA & gene == mRNA_gene ) %>% ## generate plot for each mRNA
    dplyr::mutate(contain_circ_ccl = purrr::map(.x = circ, .f = fn_contain_circ_ccl))  %>% 
    dplyr::select(gene, contain_circ_ccl) -> var_for_plot
  
  f1 %>% 
    dplyr::filter( gene  == var_for_plot$gene ) %>% 
    dplyr::mutate(type = dplyr::if_else( ccl %in% unlist(var_for_plot$contain_circ_ccl), 'circRNA(+)', 'circRNA(-)')) %>% 
    ggplot(aes(x = type, y = log(mRNA+1,2), colour = type))+
    stat_boxplot(geom = "errorbar", width = .4 , lwd = 1.5, show.legend = F)+
    geom_boxplot(width = .5, outlier.shape = NA, lwd = 1.5, show.legend = F)+theme_bw(base_size = 20)+
    ggsci::scale_color_npg() +
    theme( axis.title.x = element_blank(),
           axis.text = element_text(size = 20))+
    ylab('log2(TPM)') -> p 
  
  png(png_file, width = 1080, height = 360)
  print(p)
  
  dev.off()
}

