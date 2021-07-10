required <- c("rvest", "tidyverse", "magrittr")
lapply(required, require, character.only = TRUE)

# ## load movies available on Prime and IMDb TV
Prime.Film.count <-
  read_html("https://www.imdb.com/search/title/?title_type=feature&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&sort=release_date,asc&count=250") %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Primenextlink <- 'https://www.imdb.com/search/title/?title_type=feature&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&sort=release_date,asc&count=250'
Prime.Films.Available <- data.frame()
for (i in 1:ceiling(Prime.Film.count/250)) {
  link <- read_html(Primenextlink)
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .)
    )
  Prime.Films.Available <- rbind(Prime.Films.Available, page)

  Primenextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
} 
Prime.Films.Available <- Prime.Films.Available %>% mutate(Type = "Feature Film")

## load documentaries available on Prime and IMDb TV
Prime.Documentary.count <-
  read_html("https://www.imdb.com/search/title/?title_type=documentary&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&sort=release_date,asc&count=250") %>%
  html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
  html_text(.) %>%
  gsub(".{8}$|.*of ", "", .) %>%
  parse_number(.)
Primenextlink <- 'https://www.imdb.com/search/title/?title_type=documentary&online_availability=US%2FIMDbTV,US%2Ftoday%2FAmazon%2Fsubs&sort=release_date,asc&count=250'
Prime.Documentary.Available <- data.frame()
for (i in 1:ceiling(Prime.Documentary.count/250)) {
  link <- read_html(Primenextlink)
  page <-
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16),
      ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .)
    )
  Prime.Documentary.Available <- rbind(Prime.Documentary.Available, page)
  
  Primenextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
}
Prime.Documentary.Available <- Prime.Documentary.Available %>% mutate(Type = "Documentary")

Prime.Available <- rbind(Prime.Documentary.Available, Prime.Films.Available) %>% arrange(ItemYear)

rm(Primenextlink, page, link, i)
