required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

## load Oscar Winners on IMDB
link <- read_html("Pull IMDb Lists/IMDBOscarList/Oscar_Ceremonies/93-2021.webarchive") 

award.categories <- link %>% html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-category')
categories <- function(section){
  t <- tibble(
    Category = section %>% html_node('div.event-widgets__award-category-name') %>% html_text,
    #PrimaryText = section %>% html_node('div.event-widgets__primary-nominees') %>% html_text(),
    PrimaryName = section %>% html_nodes("div.event-widgets__primary-nominees > span > span > a") %>% html_text,
    PrimaryID = section %>% html_nodes('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13),
    SecondaryText =  section %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_text
    #SecondaryIDs = list(section %>% html_nodes('div.event-widgets__secondary-nominees span.event-widgets__nominee-name > a:first-of-type') %>% html_attr("href") %>% substr(., 2, nchar(.)-13))
  )
  return(t)
}
IMDBoscars1 <- purrr::map_dfr(award.categories, categories)

award.nominees <- link %>% html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-nomination')
nominees <- function(section) {
  t <- tibble(
    #PrimaryText = section %>% html_node('div.event-widgets__primary-nominees') %>% html_text(),
    Winner = section %>% html_node("div.event-widgets__winner-badge") %>% html_text,
    PrimaryName = section %>% html_node("div.event-widgets__primary-nominees > span > span > a") %>% html_text,
    PrimaryID = section %>% html_node('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13),
    PrimaryNote = section %>% html_node("div.event-widgets__nomination-notes") %>% html_text,
    SecondaryText =  section %>% html_node('div.event-widgets__secondary-nominees') %>% html_text,
    SecondaryName = section %>% html_nodes('div.event-widgets__secondary-nominees > span span.event-widgets__nominee-name > a') %>% html_text %>% {if(length(.) == 0) NA else .},
    SecondaryID = section %>% html_nodes('div.event-widgets__secondary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% {if(length(.) == 0) NA else .} %>% substr(., 2, nchar(.)-13)
    #SecondaryIDs = list(section %>% html_nodes('div.event-widgets__secondary-nominees span.event-widgets__nominee-name > a:first-of-type') %>% html_attr("href") %>% substr(., 2, nchar(.)-13))
  )
  return(t)
}
IMDBoscars2 <- purrr::map_dfr(award.nominees, nominees)

IMDBoscarscombined <- 
  left_join(IMDBoscars1, IMDBoscars2, by = c("PrimaryName", "PrimaryID", "SecondaryText")) %>%
  mutate(
    IMDbPersonID = ifelse(startsWith(PrimaryID, "title/"), SecondaryID, PrimaryID),
    IMDbFilmID = ifelse(startsWith(PrimaryID, "name/"), SecondaryID, PrimaryID),
  ) %>%
  select(-c("PrimaryID","SecondaryID","PrimaryName","SecondaryName")) %>%
  mutate(
    IMDbPersonID = substr(IMDbPersonID, 6, nchar(IMDbPersonID)),
    IMDbFilmID = substr(IMDbFilmID, 7, nchar(IMDbFilmID))
  ) %>%
  left_join(., IMDBcombinedOscars, by=c("IMDbFilmID" = "IMDBid"))


rm(required, link, categories, nominees, award.nominees, award.categories)

