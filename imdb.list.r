required <- c("rvest", "tidyverse", "magrittr")
lapply(required, require, character.only = TRUE)

## load IMDB List
# IMDBlistcount <-
#   read_html("https://www.imdb.com/list/ls505489207/") %>%
#   html_nodes(., '#main > div > div.lister.list.detail.sub-list > div.header.filmosearch > div > div.desc.lister-total-num-results') %>%
#   html_text(.) %>%
#   parse_number(.)
# IMDBlist <- data.frame()
# for (i in 1:ceiling(IMDBlistcount/100)) {
#   link <- read_html(paste0('https://www.imdb.com/list/ls505489207/?page=',i))
#   page <-
#     data.frame(
#       ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
#       IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
#       ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
#       ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
#     )
#   IMDBlist <- rbind(IMDBlist, page)
# }

# ## load Oscar Winners on IMDB
# IMDBoscarscount <-
#   read_html("https://www.imdb.com/search/title/?groups=oscar_winner&sort=year,desc") %>%
#   html_nodes(., '#main > div > div.nav > div.desc > span:nth-child(1)') %>%
#   html_text(.) %>%
#   gsub(".{8}$|.*of ", "", .) %>%
#   parse_number(.)
# IMDBnextlink <- 'https://www.imdb.com/search/title/?groups=oscar_winner&sort=year,desc'
# IMDBoscars <- data.frame()
# for (i in 1:ceiling(IMDBoscarscount/50)) {
#   link <- read_html(IMDBnextlink)
#   
#   page <- 
#     data.frame(
#       ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
#       IMDBid= link %>% html_nodes(.,'div.lister-item-content > h3 > a:first-of-type') %>% html_attr("href") %>% substr(., 8, nchar(.)-16),
#       ItemYear= link %>% html_nodes(.,'.lister-item-header span.lister-item-year:nth-child(3)') %>% html_text(.) %>% sub('.*(\\d{4}).*', '\\1', .),
#       ItemRuntime= link %>% html_nodes(.,'.lister-item-header + p span.runtime') %>% html_text(.)
#     )
#   IMDBoscars <- rbind(IMDBoscars, page)
#   
#   IMDBnextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#main > div > div.desc > a.next-page') %>% html_attr("href"))
# } 


## load Personal Ratings on IMDB
IMDBratingscount <-
  read_html("https://www.imdb.com/user/ur28723514/ratings/") %>%
  html_nodes(., '#lister-header-current-size') %>%
  html_text(.) %>%
  parse_number(.)
IMDBnextlink <- 'https://www.imdb.com/user/ur28723514/ratings/'
IMDBratings <- data.frame()
for (i in 1:ceiling(IMDBratingscount/100)) {
  link <- read_html(IMDBnextlink)
  
  page <- 
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      Rating= link %>% html_nodes(.,'div.lister-item-content > div.ipl-rating-widget > div.ipl-rating-star.ipl-rating-star--other-user.small > span.ipl-rating-star__rating') %>% html_text(.),
      Rated.Date= link %>% html_nodes(.,'div.ipl-rating-widget + p') %>% html_text(.)
    )
  IMDBratings <- rbind(IMDBratings, page)
  
  IMDBnextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#ratings-container > div.footer.filmosearch > div > div > a.flat-button.lister-page-next.next-page') %>% html_attr("href"))
} 

## combine IMDBlists with IMDBratings
IMDBcombinedNYT1000 <- 
  left_join(IMDBlist, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Prime.Available %>% select(IMDBid, Type) %>% mutate(Prime = "Y"), by="IMDBid") %T>%
  write.csv(.,"NYT1000/NYT1000Data.csv", row.names = FALSE)
IMDBcombinedOscars <- 
  left_join(IMDBoscars, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Prime.Available %>% select(IMDBid, Type) %>% mutate(Prime = "Y"), by="IMDBid") %T>%
  write.csv(.,"Oscars/OscarsData.csv", row.names = FALSE)

## Oscar Data for CSV
IMDBcombinedOscars %>% 
mutate(Decade = floor(as.numeric(ItemYear)/10)*10) %>%
filter(ItemYear != "2021") %>%
group_by(ItemYear = as.numeric(ItemYear)) %>% 
summarize(
  Y = n_distinct(IMDBid[Seen == "Yes"]),
  N = n_distinct(IMDBid[Seen == "No"])) %>%
select(ItemYear, Y, N) %>%
write.csv(.,"Oscars/OscarsSummary.csv", row.names = FALSE)

## NYT-1000 Data for CSV
NYT1000 <- IMDBcombinedNYT1000 %>% 
  group_by(ItemYear = as.numeric(ItemYear)) %>% 
  summarize(
    Y = n_distinct(IMDBid[Seen == "Yes"]),
    N = n_distinct(IMDBid[Seen == "No"])) %>%
  select(ItemYear, Y, N) %T>%
  write.csv(.,"NYT1000/NYT1000Summary.csv", row.names = FALSE)

rm(i, page, link, IMDBnextlink)
