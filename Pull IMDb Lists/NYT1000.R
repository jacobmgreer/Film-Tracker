required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

# load IMDB List
IMDBnyt1000count <-
  read_html("https://www.imdb.com/list/ls505489207/") %>%
  html_nodes(., '#main > div > div.lister.list.detail.sub-list > div.header.filmosearch > div > div.desc.lister-total-num-results') %>%
  html_text(.) %>%
  parse_number(.)
IMDBnyt1000 <- data.frame()
for (i in 1:ceiling(IMDBnyt1000count/100)) {
  link <- read_html(paste0('https://www.imdb.com/list/ls505489207/?page=',i))
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
      ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
    )
  IMDBnyt1000 <- rbind(IMDBnyt1000, page)
}

rm(i, page, link, required, IMDBnyt1000count)