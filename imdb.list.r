required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

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

rm(i, page, link, IMDBnextlink, required)
