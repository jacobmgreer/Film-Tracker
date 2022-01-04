required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

# load IMDB List for AFI.Top100.1998
IMDBaficount <-
  read_html("https://www.imdb.com/list/ls033319715/") %>%
  html_nodes(., '#main > div > div.lister.list.detail.sub-list > div.header.filmosearch > div > div.desc.lister-total-num-results') %>%
  html_text(.) %>%
  parse_number(.)
IMDBafi1998 <- data.frame()
for (i in 1:ceiling(IMDBaficount/100)) {
  link <- read_html(paste0('https://www.imdb.com/list/ls033319715/?page=',i))
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
      ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
    )
  IMDBafi1998 <- rbind(IMDBafi1998, page)
}

# load IMDB List for AFI.Top100.2007
IMDBaficount <-
  read_html("https://www.imdb.com/list/ls027841309/") %>%
  html_nodes(., '#main > div > div.lister.list.detail.sub-list > div.header.filmosearch > div > div.desc.lister-total-num-results') %>%
  html_text(.) %>%
  parse_number(.)
IMDBafi2007 <- data.frame()
for (i in 1:ceiling(IMDBaficount/100)) {
  link <- read_html(paste0('https://www.imdb.com/list/ls027841309/?page=',i))
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
      ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
    )
  IMDBafi2007 <- rbind(IMDBafi2007, page)
}

write.csv(IMDBafi1998, "output/IMDBafi1998.csv", row.names = FALSE)
write.csv(IMDBafi2007, "output/IMDBafi2007.csv", row.names = FALSE)

rm(i, page, link, required, IMDBaficount)