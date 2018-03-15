readr::read_rds(path = filename) %>% dplyr::group_by(circ) %>%
  dplyr::summarise(ct = count(ccl_names)) %>% arrange(circ) %>% head

reptimes <- readr::read_rds(path = filename) %>% dplyr::count(circ) %>% pull(n)
names(reptimes) <- read_rds(path = filename) %>% dplyr::count(circ) %>% pull(circ)

circ_names <- names(reptimes)

expr <- readr::read_rds(path = filename)

aa <- expr %>% group_by(circ, ccl_name) %>% tally %>% 
  group_by(circ) %>% summarise(num_ccl = n()) 

bb <- expr %>% group_by(circ, type) %>% tally %>% 
  group_by(circ) %>% summarise(num_ct = n())


inner_join(aa,bb) %>% inner_join(expr,.) %>% 
  #select(circ, num_ccl, reads, num_ct) %>% 
  arrange(desc(num_ct), desc(num_ccl), desc(reads))  %>% 
  readr::write_rds(path = file.path(resource_data, "circRNAs_expression_matrix.rds.gz"), compress = "gz") 

inner_join(aa,bb) %>% inner_join(expr,.) %>% 
  #select(circ, num_ccl, reads, num_ct) %>% 
  arrange(desc(num_ct), desc(num_ccl), desc(reads)) %>% 
  readr::write_csv("circRNAs_expression_matrix.csv", col_names = F)

# no_ccl <- vector(mode="integer") 
# no_ct <- vector(mode="integer")

# tmp <- function(xx) {
# 
# ccl_number <- expr %>% filter(circ %in% xx) %>% count(ccl_name) %>% pull(n)
# tp_number <- expr %>% filter(circ %in% xx) %>% count(type) %>% pull(n)
# 
# no_ccl <- append(no_ccl, rep(ccl_number, times = reptimes[xx]))
# no_ct <- append(no_ct, rep(tp_number, times = reptimes[xx]))
# 
# }

# for (i in 1:length(circ_names)) {
#   
#   xx = circ_names[i]
#   
#   ccl_number <- expr %>% filter(circ %in% xx) %>% count(ccl_name) %>% pull(n)
#   tp_number <- expr %>% filter(circ %in% xx) %>% count(type) %>% pull(n)
#   
#   no_ccl <- append(no_ccl, rep(ccl_number, times = reptimes[i]))
#   no_ct <- append(no_ct, rep(tp_number, times = reptimes[i]))
#   
# }


