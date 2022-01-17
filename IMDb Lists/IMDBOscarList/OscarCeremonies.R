required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex", "fuzzyjoin","readr","tools","textutils","purrr","plyr")
lapply(required, require, character.only = TRUE)

OscarCeremonies <- read_csv("output/OscarCeremonies.raw.csv")

# OscarCeremonies <- NULL
# for (i in list.files("IMDb Lists/IMDBOscarList/OscarsArchives", pattern="*.webarchive", include.dirs = FALSE)) {
#   OscarCeremonies <- bind_rows(OscarCeremonies,
#          regex_left_join(
#            read_html(file.path("IMDb Lists/IMDBOscarList/OscarsArchives", i)) %>% 
#            html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-category') %>%
#            map_df(~{
#              AwardCategory <- .x %>% html_nodes('div.event-widgets__award-category-name') %>% html_text
#              AwardWinner <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node("div.event-widgets__winner-badge") %>% html_text
#              PrimaryTitle <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node("div.event-widgets__primary-nominees > span > span > a") %>% html_text
#              PrimaryID <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13)
#              SecondaryName <- .x %>% html_nodes('div.event-widgets__award-nomination') %>% html_node('div.event-widgets__secondary-nominees') %>% html_text
#              tibble(AwardCategory, AwardWinner, PrimaryTitle, PrimaryID, SecondaryName)
#            }) %>%
#            mutate(AwardCeremony = file_path_sans_ext(i)),
#          
#            read_html(file.path("IMDb Lists/IMDBOscarList/OscarsArchives", i))%>%
#            html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-category') %>%
#            map_df(~{
#              SecondaryName <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name') %>% html_text %>% {if(length(.) == 0) NA else .}
#              SecondaryID <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name > a') %>% html_attr("href") %>% {if(length(.) == 0) NA else .} %>% substr(., 2, nchar(.)-13)
#              AwardCategory <- .x %>% html_nodes('div.event-widgets__award-category-name') %>% html_text
#              tibble(SecondaryID, SecondaryName, AwardCategory)
#            }),
#          by = c("AwardCategory", "SecondaryName")))}
# 
# colnames(OscarCeremonies)[which(names(OscarCeremonies) == "AwardCategory.x")] <- "AwardCategory"
# colnames(OscarCeremonies)[which(names(OscarCeremonies) == "SecondaryName.x")] <- "SecondaryName.list"
# colnames(OscarCeremonies)[which(names(OscarCeremonies) == "SecondaryName.y")] <- "SecondaryName"
# 
# write.csv(OscarCeremonies, "output/OscarCeremonies.raw.csv", row.names = FALSE)
#

## corrections
OscarCeremonies.corrected <-
  OscarCeremonies %>%
  distinct() %>%
  mutate(
    FilmID = ifelse(grepl("^title",PrimaryID), str_remove(PrimaryID, "title/"), ifelse(grepl("^title",SecondaryID), str_remove(SecondaryID, "title/"), NA)),
    FilmName = ifelse(grepl("^title",PrimaryID), PrimaryTitle, ifelse(grepl("^title",SecondaryID), SecondaryName, NA)),
    PersonID = ifelse(grepl("^name",PrimaryID), str_remove(PrimaryID, "name/"), ifelse(grepl("^name",SecondaryID), str_remove(SecondaryID, "name/"), NA)),
    PersonName = ifelse(grepl("^name",PrimaryID), PrimaryTitle, ifelse(grepl("^name",SecondaryID), SecondaryName, NA)),
    CompanyID = ifelse(grepl("^company",PrimaryID), str_remove(PrimaryID, "company/"), ifelse(grepl("^company",SecondaryID), str_remove(SecondaryID, "company/"), NA)),
    CompanyName = ifelse(grepl("^company",PrimaryID), PrimaryTitle, ifelse(grepl("^company",SecondaryID), SecondaryName, NA)),
  ) %>%
  select(-c(PrimaryTitle,PrimaryID,SecondaryID,SecondaryName,AwardCategory.y)) %>%
  mutate(
    FilmID = ifelse(is.na(FilmID) & SecondaryName.list == "Birdman or (The Unexpected Virtue of Ignorance)","tt2562232",FilmID),
    FilmName = ifelse(is.na(FilmName) & SecondaryName.list == "Birdman or (The Unexpected Virtue of Ignorance)","Birdman or (The Unexpected Virtue of Ignorance)",FilmName)) %>%
  left_join(., OscarsOMDB %>% dplyr::rename(IMDb = `Internet Movie Database`, RottenTomatoes = `Rotten Tomatoes`), by="FilmID")

write.csv(OscarCeremonies.corrected, "output/OscarCeremonies.csv", row.names = FALSE)

# award.connectors <- 
  # read_html("Pull IMDb Lists/IMDBOscarList/Oscar_Ceremonies/80-2008.webarchive") %>%
  # html_nodes('div.event-widgets__award:first-of-type div.event-widgets__award-nomination') %>%
  # map_df(~{
  #   PrimaryTitle <- .x %>% html_node("div.event-widgets__primary-nominees > span > span > a") %>% html_text
  #   PrimaryID <- .x %>% html_node('div.event-widgets__primary-nominees span.event-widgets__nominee-name > a') %>% html_attr("href") %>% substr(., 2, nchar(.)-13)
  #   SecondaryName <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name') %>% html_text %>% {if(length(.) == 0) NA else .}
  #   SecondaryID <- .x %>% html_nodes('div.event-widgets__secondary-nominees') %>% html_nodes('span.event-widgets__nominee-name > a') %>% html_attr("href") %>% {if(length(.) == 0) NA else .} %>% substr(., 2, nchar(.)-13)
  #   tibble(PrimaryTitle, PrimaryID, SecondaryID, SecondaryName)
  # })

#rm(list=ls(pattern="^oscars"))

rm(required, OscarCeremonies)

