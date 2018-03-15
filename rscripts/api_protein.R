library(magrittr)
library(ggplot2)

args <- commandArgs(TRUE)
stopifnot(length(args) == 2)

query_symbol <- args[2]
root_path <- args[1]

#test
#query_symbol <- 'CSRP1'
#root_path <- "/workspace/database/tRic.dev/tRic_portal/cRic"

resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

protein_association <- readr::read_rds(file.path(resource_data, 
                                 "protein_circ_gene_pair_with_annotation_20180302.rds.gz"))

protein_association %>% 
  dplyr::filter(circ_gene ==query_symbol) %>% 
  dplyr::mutate(diff = round(diff,3), fdr = signif(fdr,4)) %>% 
  dplyr::select(circRNA = circ, protein = antibody, protein_gene, difference = diff, fdr) ->
  json_datatable

json_datatable_file <- file.path(resource_jsons,
                                 glue::glue("api_protein.{query_symbol}.json"))

if (nrow(json_datatable) < 1) {
  
  jsonlite::write_json(x = NULL, path = json_datatable_file)
  quit(save = "no", status = 0)
  
} else {
  
  jsonlite::write_json(x = json_datatable, path = json_datatable_file)
  
}