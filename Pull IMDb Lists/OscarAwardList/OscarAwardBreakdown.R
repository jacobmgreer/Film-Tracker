required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

# Oscar.Winners <- 
#   read_csv("Pull IMDB Lists/OscarAwardList/the_oscar_award.csv", col_types = cols()) %>%
#   mutate(film = str_replace(film, ";", "")) %>%
#   filter(winner == "TRUE") %>%
#   filter(!is.na(film)) %>% # review this list
#   left_join(., IMDBoscars %>% mutate(ItemYear = as.double(ItemYear)), by=c("film" = "ItemTitle", "year_film" = "ItemYear"))

# Oscar.Winners.Review <-
#   Oscar.Winners %>%
#   filter(is.na(IMDBid)) %T>%
#   write.csv(.,"Pull IMDB Lists/OscarAwardList/imdb.missing.csv", row.names = FALSE)

Oscar.Winners.Fixed <- 
  read_csv("Pull IMDB Lists/OscarAwardList/imdb.winners.repairs.csv", col_types = cols()) %>%
  left_join(., IMDBoscars %>% mutate(ItemYear = as.double(ItemYear)), by=c("film" = "ItemTitle", "year_film" = "ItemYear")) %>%
  filter(!category %in% c(
    "SPECIAL ACHIEVEMENT AWARD (Sound Effects)",
    "SPECIAL ACHIEVEMENT AWARD (Sound Effects Editing)",
    "SPECIAL ACHIEVEMENT AWARD (Sound Editing)",
    "SPECIAL ACHIEVEMENT AWARD (Visual Effects)")) %>%
  rename(
    ItemTitle = film,
    AwardRecipient = name,
    Award = category, 
    ItemYear = year_film) %T>%
  write.csv(.,"Pull IMDB Lists/OscarAwardList/imdb.winners.revision.csv", row.names = FALSE)


AwardYears <- Oscar.Winners.Fixed %>% count(ceremony, year_ceremony)
# Oscar.Winners.Repair <-
#   Oscar.Winners.Fixed %>%
#   filter(is.na(IMDBid)) %T>%
#   write.csv(.,"Pull IMDB Lists/OscarAwardList/imdb.winners.missing.csv", row.names = FALSE)

# ## Checks
# Oscar.Winners.Missing <- anti_join(IMDBcombinedOscars, Oscar.Winners.Fixed %>% select(IMDBid))
# Oscar.Winners.Missing2 <- anti_join(Oscar.Winners.Repair, IMDBcombinedOscars %>% select(IMDBid))

# Oscar.Nominees <- 
#   read_csv("Pull IMDB Lists/OscarAwardList/the_oscar_award.csv", col_types = cols()) %>%
#   mutate(film = str_replace(film, ";", "")) %>%
#   filter(winner == "FALSE") %>%
#   filter(!is.na(film)) %>% # review this list
#   left_join(., IMDBoscars %>% mutate(ItemYear = as.double(ItemYear)), by=c("film" = "ItemTitle", "year_film" = "ItemYear"))
# 
# Oscar.Nominees.Review <-
#   Oscar.Nominees %>%
#   filter(is.na(IMDBid))

rm(required)