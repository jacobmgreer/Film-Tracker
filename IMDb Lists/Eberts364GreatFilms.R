required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

## More Information: https://www.rogerebert.com/great-movies

# load IMDB List
IMDBebertcount <-
  read_html("https://www.imdb.com/list/ls020212874/") %>%
  html_nodes(., '#main > div > div.lister.list.detail.sub-list > div.header.filmosearch > div > div.desc.lister-total-num-results') %>%
  html_text(.) %>%
  parse_number(.)
IMDBebert <- data.frame()
for (i in 1:ceiling(IMDBebertcount/100)) {
  link <- read_html(paste0('https://www.imdb.com/list/ls020212874/?page=',i))
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
      ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
    )
  IMDBebert <- rbind(IMDBebert, page)
}

write.csv(IMDBebert, "output/IMDBebert.csv", row.names = FALSE)

rm(i, page, link, required, IMDBebertcount)