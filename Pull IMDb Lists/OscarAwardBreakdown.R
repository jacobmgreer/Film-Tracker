required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

Oscar.Winners <- read_csv("Pull IMDB Lists/Oscar.Winners.IMDB.csv", col_types = cols())

Oscar.Winners.Missing <- 
  read_csv("Pull IMDB Lists/Oscar.Winners.IMDB.csv", col_types = cols()) %>% 
  filter(is.na(IMDBid)) %>%
  filter(!is.na(Film)) %>%
  left_join(., IMDBoscars, by=c("Film" = "ItemTitle")) %T>%
  write.csv(.,"Pull IMDB Lists/imdb.review.matches.csv", row.names = FALSE)

Oscar.Winners.Review <- 
  Oscar.Winners.Missing %>%
  filter(is.na(IMDBid.y)) %T>%
  write.csv(.,"Pull IMDB Lists/imdb.missing.csv", row.names = FALSE)

rm(required)