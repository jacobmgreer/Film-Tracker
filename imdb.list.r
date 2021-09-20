required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

## load Personal Ratings on IMDB
nextlink <- 'https://www.imdb.com/user/ur28723514/ratings/'
count <-
  read_html(nextlink) %>%
  html_nodes(., '#lister-header-current-size') %>%
  html_text(.) %>%
  parse_number(.)
IMDBratings <- data.frame()
for (i in 1:ceiling(count/100)) {
  link <- read_html(nextlink)
  page <- 
    data.frame(
      ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
      IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
      Rating= link %>% html_nodes(.,'div.lister-item-content > div.ipl-rating-widget > div.ipl-rating-star.ipl-rating-star--other-user.small > span.ipl-rating-star__rating') %>% html_text(.),
      Rated.Date= link %>% html_nodes(.,'div.ipl-rating-widget + p') %>% html_text(.)
    )
  IMDBratings <- rbind(IMDBratings, page)
  nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#ratings-container > div.footer.filmosearch > div > div > a.flat-button.lister-page-next.next-page') %>% html_attr("href"))
} 

## Streaming Availability

Streaming.Films <- 
  Films.on.Prime %>% 
  mutate(Service = "Prime") %>%
  mutate(Type = "Feature Film") %>%
  spread(Service, Service)
Streaming.Docs <- 
  Docs.on.Prime %>% 
  mutate(Service = "Prime") %>%
  mutate(Type = "Documentary") %>%
  spread(Service, Service)
Streaming.Available <- 
  rbind(Streaming.Docs, Streaming.Films)

## combine IMDBlists with IMDBratings

IMDBcombinedNYT1000 <- 
  left_join(IMDBnyt1000, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"NYT1000/NYT1000Data.csv", row.names = FALSE)
  
IMDBcombinedOscars <- 
  left_join(IMDBoscars, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"Oscars/OscarsData.csv", row.names = FALSE)

IMDBcombinedEbert <- 
  left_join(IMDBebert, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"GreatFilmsEbert/Data.csv", row.names = FALSE)

IMDBcombinedEbert <- 
  left_join(IMDBebert, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"GreatFilmsEbert/Data.csv", row.names = FALSE)

IMDBcombinedAFI1998 <- 
  left_join(IMDBafi1998, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"AFITop100/1998/Data.csv", row.names = FALSE)

IMDBcombinedAFI2007 <- 
  left_join(IMDBafi2007, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"AFITop100/2007/Data.csv", row.names = FALSE)

## Oscar Data for CSV
  IMDBcombinedOscars %>% 
  #mutate(Decade = floor(as.numeric(ItemYear)/10)*10) %>%
  filter(ItemYear != "2021") %>%
  group_by(ItemYear = as.numeric(ItemYear)) %>% 
  summarize(
    Y = n_distinct(IMDBid[Seen == "Yes"]),
    N = n_distinct(IMDBid[Seen == "No"])) %>%
  select(ItemYear, Y, N) %>%
  write.csv(.,"Oscars/OscarsSummary.csv", row.names = FALSE)

## NYT-1000 Data for CSV
  IMDBcombinedNYT1000 %>% 
  group_by(ItemYear = as.numeric(ItemYear)) %>% 
  summarize(
    Y = n_distinct(IMDBid[Seen == "Yes"]),
    N = n_distinct(IMDBid[Seen == "No"])) %>%
  select(ItemYear, Y, N) %>%
  write.csv(.,"NYT1000/NYT1000Summary.csv", row.names = FALSE)

rm(i, page, link, nextlink, required, count)
