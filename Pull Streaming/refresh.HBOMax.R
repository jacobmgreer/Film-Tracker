required <- c("rvest", "tidyverse", "magrittr")
lapply(required, require, character.only = TRUE)

## load movies available on HBOMax
nextlink <- 'https://www.imdb.com/search/title/?companies=co0754095&title_type=feature&count=250'
count <-
  read_html(nextlink) %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Films.on.HBOMax <- data.frame()
for (i in 1:ceiling(count/250)) {
  link <- read_html(nextlink)
  page <-
    data.frame(
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16)
    )
  Films.on.HBOMax <- rbind(Films.on.HBOMax, page)
  nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
} 

## load documentaries available on HBOMax
nextlink <- 'https://www.imdb.com/search/title/?companies=co0754095&title_type=documentary&count=250'
count <-
  read_html(nextlink) %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Docs.on.HBOMax <- data.frame()
for (i in 1:ceiling(count/250)) {
  link <- read_html(nextlink)
  page <-
    data.frame(
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16)
    )
  Docs.on.HBOMax <- rbind(Docs.on.HBOMax, page)
  nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
} 

rm(nextlink, page, link, i, required, count)