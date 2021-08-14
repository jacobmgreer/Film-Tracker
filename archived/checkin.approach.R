# ## IMDb Check-ins
# IMDBcheckins <-
#   read_html("https://www.imdb.com/user/ur28723514/checkins?sort=date_added%2Cdesc&view=grid") %>%
#   toString %>%
#   ex_between(., "jacobmgreer's Check-Ins\",\"description\":{\"html\":\"\"},\"items\":", "],\"facets\":") %>%
#   gsub("[", "", ., fixed=TRUE) %>%
#   gsub("]", "", ., fixed=TRUE) %>%
#   toJSON %>%
#   gsub("\\\"", "\"", ., fixed=TRUE) %>%
#   gsub("[\"", "[", ., fixed=TRUE) %>%
#   gsub("\"]", "]", ., fixed=TRUE) %>%
#   fromJSON %>%
#   flatten %>%
#   select(-itemId,-description.html,-position) %>%
#   rename(IMDBid = const)
# IMDBcheckins.genres <-
#   read_html("https://www.imdb.com/user/ur28723514/checkins?sort=date_added%2Cdesc&view=grid") %>%
#   toString %>%
#   ex_between(., "\"genres\",\"facets\":[", "]},\"RELEASE_DATE\"") %>%
#   gsub("[", "", ., fixed=TRUE) %>%
#   gsub("]", "", ., fixed=TRUE) %>%
#   toJSON %>%
#   gsub("\\\"", "\"", ., fixed=TRUE) %>%
#   gsub("[\"", "[", ., fixed=TRUE) %>%
#   gsub("\"]", "]", ., fixed=TRUE) %>%
#   fromJSON %>%
#   select(label, count)
# IMDBcheckins.details <-
#   read_html("https://www.imdb.com/user/ur28723514/checkins?sort=date_added%2Cdesc&view=grid") %>%
#   toString %>%
#   ex_between(., "\"titles\":", "});") %>%
#   toJSON %>%
#   gsub("\\\"", "\"", ., fixed=TRUE) %>%
#   gsub("[[\"", "{\"watchlist\":[", ., fixed=TRUE) %>%
#   gsub("\"]]", "]}", ., fixed=TRUE) %>%
#   fromJSON