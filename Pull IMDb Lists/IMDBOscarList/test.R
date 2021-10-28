required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)


r <- 
  read_html("Pull IMDb Lists/IMDBOscarList/Oscar_Ceremonies/80-2008.webarchive") %>% 
  html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-category') %>% 
  map_df(~{
    AwardCategory <- .x %>% html_nodes('div.event-widgets__award-category-name') %>% html_text
    AwardWinner <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node("div.event-widgets__winner-badge") %>% html_text
    PrimaryTitle <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node("div.event-widgets__primary-nominees > span > span > a") %>% html_text
    PrimaryID <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13)
    SecondaryText <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node('div.event-widgets__secondary-nominees') %>% html_text
    tibble(AwardCategory, AwardWinner, PrimaryTitle, PrimaryID, SecondaryText)
  })

s <- 
  read_html("Pull IMDb Lists/IMDBOscarList/Oscar_Ceremonies/80-2008.webarchive") %>% 
  html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-category') %>% 
  map_df(~{
    SecondaryName <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name') %>% html_text %>% {if(length(.) == 0) NA else .}
    SecondaryID <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name > a') %>% html_attr("href") %>% {if(length(.) == 0) NA else .} %>% substr(., 2, nchar(.)-13)
    AwardCategory <- .x %>% html_nodes('div.event-widgets__award-category-name') %>% html_text
    tibble(SecondaryID, SecondaryName, AwardCategory)
  })

t <- 
  read_html("Pull IMDb Lists/IMDBOscarList/Oscar_Ceremonies/80-2008.webarchive") %>% 
  html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-nomination') %>% 
  map_df(~{
    PrimaryTitle <- .x %>% html_node("div.event-widgets__primary-nominees > span > span > a") %>% html_text
    PrimaryID <- .x %>% html_node('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13)
    SecondaryName <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name') %>% html_text %>% {if(length(.) == 0) NA else .}
    SecondaryID <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name > a') %>% html_attr("href") %>% {if(length(.) == 0) NA else .} %>% substr(., 2, nchar(.)-13)
    tibble(PrimaryTitle, PrimaryID, SecondaryID, SecondaryName)
  })