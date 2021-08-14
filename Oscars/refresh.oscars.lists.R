required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

## load Oscar Winners on IMDB
IMDBoscarscount <-
  read_html("https://www.imdb.com/search/title/?groups=oscar_winner&sort=year,desc") %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
IMDBnextlink <- 'https://www.imdb.com/search/title/?groups=oscar_winner&sort=year,desc'
IMDBoscars <- data.frame()
for (i in 1:ceiling(IMDBoscarscount/50)) {
  link <- read_html(IMDBnextlink)

  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
      ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
    )
  IMDBoscars <- rbind(IMDBoscars, page)

  IMDBnextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
}

rm(i, page, link, IMDBnextlink, required)