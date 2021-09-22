required <- c("rvest", "tidyverse", "magrittr", "jsonlite", "qdapRegex")
lapply(required, require, character.only = TRUE)

Oscar.Winners <- read_csv("Pull IMDB Lists/oscar.data.csv", col_types = cols()) %>%
  filter(Winner == 1) %T>%
  write.csv(.,"Pull IMDB Lists/oscar.winners.imdb.csv", row.names = FALSE)


rm(required)