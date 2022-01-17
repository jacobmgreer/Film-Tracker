required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex", "scales", "numform")
lapply(required, require, character.only = TRUE)
options(readr.show_col_types = FALSE)

### Lists for Comparison
IMDBafi1998 <- read_csv("output/IMDBafi1998.csv")
IMDBafi2007 <- read_csv("output/IMDBafi2007.csv")
IMDBebert <- read_csv("output/IMDBebert.csv")
IMDBnyt1000 <- read_csv("output/IMDBnyt1000.csv")
OscarCeremonies.corrected <- read_csv("output/OscarCeremonies.csv")

## load Personal Ratings on IMDB
# nextlink <- 'https://www.imdb.com/user/ur28723514/ratings/'
# count <-
#   read_html(nextlink) %>%
#   html_nodes(., '#lister-header-current-size') %>%
#   html_text(.) %>%
#   parse_number(.)
# IMDBratings <- data.frame()
# for (i in 1:ceiling(count/100)) {
#   link <- read_html(nextlink)
#   page <- 
#     data.frame(
#       ItemTitle= link %>% html_nodes(.,'.lister-item-header a:first-of-type') %>% html_text(.) %>% gsub("^\\s+|\\s+$", "", .),
#       IMDBid= link %>% html_nodes(.,'.lister-item-image') %>% html_attr("data-tconst"),
#       Rating= link %>% html_nodes(.,'div.lister-item-content > div.ipl-rating-widget > div.ipl-rating-star.ipl-rating-star--other-user.small > span.ipl-rating-star__rating') %>% html_text(.),
#       Rated.Date= link %>% html_nodes(.,'div.ipl-rating-widget + p') %>% html_text(.)
#     )
#   IMDBratings <- rbind(IMDBratings, page)
#   nextlink <- paste0("https://www.imdb.com",link %>% html_nodes(.,'#ratings-container > div.footer.filmosearch > div > div > a.flat-button.lister-page-next.next-page') %>% html_attr("href"))
# } 

## Streaming Availability

Streaming.Available <- 
  rbind(read_csv("output/Prime-Docs.csv") %>% 
          mutate(Service = "Prime") %>%
          mutate(Type = "Documentary"), 
        read_csv("output/Prime-Films.csv") %>% 
          mutate(Service = "Prime") %>%
          mutate(Type = "Feature Film"))

## combine OscarCeremonies with IMDBratings

OscarData <-
  left_join(OscarCeremonies.corrected, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by=c("FilmID" = "IMDBid")) %T>%
  write.csv(.,"Oscars/OscarsTracking.csv", row.names = FALSE)

OscarRatings <-  
  left_join(OscarCeremonies.corrected, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by=c("FilmID" = "IMDBid")) %>%
  filter(FilmID != "") %>%
  mutate(AwardWinner = ifelse(AwardWinner == "Winner",TRUE,FALSE)) %>%
  select(AwardCeremony, AwardWinner, FilmID, Rating) %>%
  distinct %>%
  dplyr::group_by(FilmID) %>%
    dplyr::mutate(
      filmwon=ifelse(any(AwardWinner),TRUE,FALSE),
      filmwon=ifelse(all(is.na(filmwon)),FALSE,filmwon)
    ) %>%
    dplyr::mutate(keep_row=ifelse(filmwon,AwardWinner,TRUE)) %>%
    dplyr::filter(!(filmwon == TRUE & is.na(keep_row))) %>%
  ungroup %>%
  mutate(
    Seen = ifelse(is.na(Rating), FALSE, TRUE),
    Year = sub('.*-', '', AwardCeremony),
    Ceremony = ifelse(f_ordinal(sub("\\-.*", "", str_remove(AwardCeremony, "^0+"))) == 13, "13th", f_ordinal(sub("\\-.*", "", str_remove(AwardCeremony, "^0+")))), 
    Menu = paste0("<h5>",Ceremony," Academy Awards</h5><h1>",Year,"</h1>")) %>%
  dplyr::group_by(AwardCeremony, Year) %>%
  dplyr::summarise(
    Winner.Y = n_distinct(FilmID[Seen == TRUE & AwardWinner == TRUE]),
    Winner.N = n_distinct(FilmID[Seen == FALSE & AwardWinner == TRUE]),
    Nominee.Y = n_distinct(FilmID[Seen == TRUE & is.na(AwardWinner)]),
    Nominee.N = n_distinct(FilmID[Seen == FALSE & is.na(AwardWinner)])) %>%
  arrange(Year) %>%
  select(-Year) %T>%
  write.csv(.,"Oscars/OscarsSummary.csv", row.names = FALSE)

# IMDBcombinedEbert <- 
#   left_join(IMDBebert, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
#   mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
#   mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
#   left_join(., Streaming.Available, by="IMDBid") %T>%
#   write.csv(.,"GreatFilmsEbert/Data.csv", row.names = FALSE)

# IMDBcombinedAFI1998 <- 
#   left_join(IMDBafi1998, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
#   mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
#   mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
#   left_join(., Streaming.Available, by="IMDBid") %T>%
#   write.csv(.,"AFITop100/1998/Data.csv", row.names = FALSE)

# IMDBcombinedAFI2007 <- 
#   left_join(IMDBafi2007, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
#   mutate(Decade = paste0(10 * floor(as.numeric(ItemYear)/10),"s")) %>%
#   mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
#   left_join(., Streaming.Available, by="IMDBid") %T>%
#   write.csv(.,"AFITop100/2007/Data.csv", row.names = FALSE)

#mutate(Decade = floor(as.numeric(ItemYear)/10)*10)

## combine IMDBlists with IMDBratings
IMDBcombinedNYT1000 <- 
  left_join(IMDBnyt1000, IMDBratings %>% select(IMDBid, Rating, Rated.Date), by="IMDBid") %>%
  mutate(Seen = ifelse(is.na(Rating), "No", "Yes")) %>%
  left_join(., Streaming.Available, by="IMDBid") %T>%
  write.csv(.,"NYT1000/NYT1000Data.csv", row.names = FALSE)

## NYT-1000 Data for CSV
  IMDBcombinedNYT1000 %>% 
  dplyr::group_by(ItemYear = as.numeric(ItemYear)) %>% 
    dplyr::summarize(
    Y = n_distinct(IMDBid[Seen == "Yes"]),
    N = n_distinct(IMDBid[Seen == "No"])) %>%
  select(ItemYear, Y, N) %>%
  write.csv(.,"NYT1000/NYT1000Summary.csv", row.names = FALSE)

#rm(i, page, link, nextlink, required, count)
rm(IMDBafi1998, IMDBafi2007, IMDBebert, IMDBnyt1000, IMDBcombinedNYT1000, Streaming.Available)
#rm(IMDBcombinedAFI2007, IMDBcombinedEbert, IMDBcombinedOscars, IMDBcombinedAFI1998)

