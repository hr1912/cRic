library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query <- args[2]
root_path <- args[1]

# test
#query = '1_201459347_201465347|CSRP1-EIF4E'

tmp <- stringr::str_split(query, "-") %>% unlist
circ = tmp[1]
protein_g = tmp[2] 

query_symbol = stringr::str_split(circ, "\\|") %>% unlist %>% .[[2]] 

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

png_file <- file.path(resource_pngs, glue::glue("api_protein.{circ}.{protein_g}.png"))

if (! file.exists(png_file)) {

protein_association <- readr::read_rds(file.path(resource_data, 
                                                   "protein_circ_gene_pair_with_annotation_20180302.rds.gz"))
protein_association %>% 
  dplyr::filter(circ_gene == query_symbol) %>% 
  dplyr::filter(circ == circ & protein_gene == protein_g) %>% 
  dplyr::select(with_circ_protein_level,without_circ_protein_level) %>% 
  tidyr::gather(key = type, value = 'RPPA_protein_abundances') %>% 
  tidyr::unnest(RPPA_protein_abundances) %>% ## extract the RPPA protein value
  dplyr::mutate(type = ifelse( type == 'with_circ_protein_level','circRNA(+)','circRNA(-)')) %>% 
  ggplot2::ggplot(aes( x = type, y = RPPA_protein_abundances, colour = type))+
  stat_boxplot(geom = "errorbar", width = .4 , lwd = 1.5, show.legend = F)+
  geom_boxplot(width = .5, outlier.shape = NA, lwd = 1.5, show.legend = F)+theme_bw(base_size = 20)+
  theme( axis.title.x = element_blank(),
         axis.text = element_text(size = 20)) -> p
  
  png(png_file, width = 1080, height = 360)
  print(p)
  dev.off()

}