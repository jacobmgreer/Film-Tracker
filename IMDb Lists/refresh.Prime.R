required <- c("rvest", "tidyverse", "magrittr")
lapply(required, require, character.only = TRUE)

## load movies available on Prime and IMDb TV
nextlink <- 'https://www.imdb.com/search/title/?title_type=feature&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&count=250'
count <-
  read_html(nextlink) %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Films.on.Prime <- data.frame()
for (i in 1:ceiling(count/250)) {
  link <- read_html(nextlink)
  page <-
    data.frame(
      #ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16)
      #ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .)
    )
  Films.on.Prime <- rbind(Films.on.Prime, page)
  nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
} 

## load documentaries available on Prime and IMDb TV
nextlink <- 'https://www.imdb.com/search/title/?title_type=documentary&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&sort=release_date,asc&count=250'
count <-
  read_html(nextlink) %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Docs.on.Prime <- data.frame()
for (i in 1:ceiling(count/250)) {
  link <- read_html(nextlink)
  page <-
    data.frame(
      #ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16)
      #ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .)
    )
  Docs.on.Prime <- rbind(Docs.on.Prime, page)
  nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
}

write.csv(Docs.on.Prime, "output/Prime-Docs.csv", row.names = FALSE)
write.csv(Films.on.Prime, "output/Prime-Films.csv", row.names = FALSE)

rm(nextlink, page, link, i, required, count)
