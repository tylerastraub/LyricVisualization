library(tidyverse)
library(rvest)
library(geniusR)
library(Rspotify)
library(stringr)
library(tidytext)
library(wordcloud)

spotifyKeys <- spotifyOAuth("mostpopularsongs", "019bc354fbac43bcb0963d1d600ae611", "5248804d1eeb4a1b9ab6220922db7826")

# first gather data using Rspotify from the big spotify playlists
topRap <- getPlaylistSongs("Spotify", "37i9dQZF1DX0XUsuxWHRQd", token = spotifyKeys) # rap caviar
topPop <- getPlaylistSongs("Spotify", "37i9dQZF1DXcBWIGoYBM5M", token = spotifyKeys) # today's top hits
topRnB <- getPlaylistSongs("Spotify", "37i9dQZF1DX4SBhb3fqCJd", token = spotifyKeys) # are & be
topCountry <- getPlaylistSongs("Spotify", "37i9dQZF1DX1lVhptIYRda", token = spotifyKeys) # hot country
topClassicRock <- getPlaylistSongs("Spotify", "37i9dQZF1DWXRqgorJj26U", token = spotifyKeys) # classic rock
topMetal <- getPlaylistSongs("Spotify", "37i9dQZF1DWWOaP4H0w5b0", token = spotifyKeys) # metal
topRock <- getPlaylistSongs("Spotify", "37i9dQZF1DXcF6B6QPhFDv", token = spotifyKeys) # rock

# clean up data so that it will be fed into genius
# remove anything in parentheses to get rid of (feat. ...)
topRap$tracks <- str_replace(topRap$tracks, " \\(.*\\)", "")
topPop$tracks <- str_replace(topPop$tracks, " \\(.*\\)", "")
topRnB$tracks <- str_replace(topRnB$tracks, " \\(.*\\)", "")
topCountry$tracks <- str_replace(topCountry$tracks, " \\(.*\\)", "")
topClassicRock$tracks <- str_replace(topClassicRock$tracks, " \\(.*\\)", "")
topMetal$tracks <- str_replace(topMetal$tracks, " \\(.*\\)", "")
topRock$tracks <- str_replace(topRock$tracks, " \\(.*\\)", "")

# now we need to make a table of compiled lyrics from each of these datasets
rapLyrics <- add_genius(topRap, artist, tracks, type = "lyrics")
popLyrics <- add_genius(topPop, artist, tracks, type = "lyrics")
rnbLyrics <- add_genius(topRnB, artist, tracks, type = "lyrics")
countryLyrics <- add_genius(topCountry, artist, tracks, type = "lyrics")
classicRockLyrics <- add_genius(topClassicRock, artist, tracks, type = "lyrics")
metalLyrics <- add_genius(topMetal, artist, tracks, type = "lyrics")
rockLyrics <- add_genius(topRock, artist, tracks, type = "lyrics")

# split every lyric/individual word into its own row then count occurences
rapLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> rapLyrics
rapLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> rapLyricsCount
names(rapLyricsCount)[names(rapLyricsCount) == 'n'] <- "rap"
  
popLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> popLyrics
popLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> popLyricsCount
names(popLyricsCount)[names(popLyricsCount) == 'n'] <- "pop"

rnbLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> rnbLyrics
rnbLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> rnbLyricsCount
names(rnbLyricsCount)[names(rnbLyricsCount) == 'n'] <- "rnb"

countryLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> countryLyrics
countryLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> countryLyricsCount
names(countryLyricsCount)[names(countryLyricsCount) == 'n'] <- "country"

classicRockLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> classicRockLyrics
classicRockLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> classicRockLyricsCount
names(classicRockLyricsCount)[names(classicRockLyricsCount) == 'n'] <- "classic.rock"

metalLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> metalLyrics
metalLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> metalLyricsCount
names(metalLyricsCount)[names(metalLyricsCount) == 'n'] <- "metal"

rockLyrics %>%
  group_by(artist, tracks) %>%
  unnest_tokens(words, lyric) -> rockLyrics
rockLyrics %>%
  ungroup() %>%
  count(words, sort = TRUE) %>%
  anti_join(stop_words, by = c("words" = "word")) -> rockLyricsCount
names(rockLyricsCount)[names(rockLyricsCount) == 'n'] <- "rock"

# WORD CLOUDS
wordcloud(rapLyricsCount$words, rapLyricsCount$rap, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(popLyricsCount$words, popLyricsCount$pop, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(rnbLyricsCount$words, rnbLyricsCount$rnb, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(countryLyricsCount$words, countryLyricsCount$country, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(classicRockLyricsCount$words, classicRockLyricsCount$classic.rock, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(metalLyricsCount$words, metalLyricsCount$metal, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))
wordcloud(rockLyricsCount$words, rockLyricsCount$rock, random.order = FALSE, max.words = 75, colors = brewer.pal(8, "Dark2"))

# word diversity
wordDiversity <- data.frame("rap" = nrow(rapLyricsCount) / nrow(topRap), "pop" = nrow(popLyricsCount) / nrow(topPop), "rnb" = nrow(rnbLyricsCount) / nrow(topRnB), "country" = nrow(countryLyricsCount) / nrow(topCountry), "classicRock" = nrow(classicRockLyricsCount) / nrow(topClassicRock), "metal" = nrow(metalLyricsCount) / nrow(topMetal), "rock" = nrow(rockLyricsCount) / nrow(topRock))
wordDiversity %>%
  gather(key = 'Genre', value = 'Unique Words') -> wordDiversity
ggplot() +
  geom_bar(wordDiversity, mapping = aes(x = Genre, y = `Unique Words`, fill = Genre), stat = 'Identity')

# look at occurrences by inner joining with dataframe of words we wanna know
# profanities copied from https://en.wiktionary.org/wiki/Category:English_swear_words
profanities <- data.frame(words = c("ass", "asses", "asshole", "assholes", "bastard", "bastards", "bitch", "bitches", "bitching", "bullshit", "cock", "crap", "cunt", "cunts", "damn", "damned", "damnit", "dick", "fuck", "fucked", "fucker", "fucks", "goddamn", "hell", "nigga", "niggas", "shit", "shitty", "shits", "shitted"))

badWordsInMusic <- left_join(profanities, rapLyricsCount) %>%
  left_join(popLyricsCount) %>%
  left_join(rnbLyricsCount) %>%
  left_join(countryLyricsCount) %>%
  left_join(classicRockLyricsCount) %>%
  left_join(metalLyricsCount) %>%
  left_join(rockLyricsCount)
badWordsInMusic[is.na(badWordsInMusic)] <- 0

# make tidy
badWordsInMusic %>%
  gather(key = 'Genre', value = 'Number of Profanities', -words) %>%
  filter(`Number of Profanities` != 0) -> tidyBadWords

# plot profranities
substr(tidyBadWords$words, 2, 4) <- "**"
ggplot() +
  geom_bar(tidyBadWords, mapping = aes(x = Genre, y = `Number of Profanities`, fill = `words`), stat = "identity")

# plot profanities based on proportion
badWordsProportion <- data.frame("genre" = c("rap", "pop", "rnb", "country", "classicRock", "metal", "rock"), "proportion" = 0)
badWordsProportion[1, "proportion"] <- sum(badRap$n) / nrow(rapLyrics)
badWordsProportion[2, "proportion"] <- sum(badPop$n) / nrow(popLyrics)
badWordsProportion[3, "proportion"] <- sum(badRnB$n) / nrow(rnbLyrics)
badWordsProportion[4, "proportion"] <- sum(badCountry$n) / nrow(countryLyrics)
badWordsProportion[5, "proportion"] <- sum(badClassicRock$n) / nrow(classicRockLyrics)
badWordsProportion[6, "proportion"] <- sum(badMetal$n) / nrow(metalLyrics)
badWordsProportion[7, "proportion"] <- sum(badRock$n) / nrow(rockLyrics)

ggplot() +
  geom_bar(badWordsProportion, mapping = aes(x = genre, y = proportion, fill = genre), stat = "identity")

# what about other trends in lyrics?
# let's look at drug references
drugsURL <- "https://www.therecoveryvillage.com/drug-addiction/street-names-for-drugs/#gref"
drugPage <- read_html(drugsURL)
drugHTML <- html_nodes(drugPage, "li")
drugSlang <- html_text(drugHTML)
drugSlang <- drugSlang[-c(1:229)]
drugSlang <- drugSlang[-c(246:275)]
drugSlang <- append(drugSlang, c("adderall", "cocaine", "medicine", "meth", "ecstasy", "mdma", "heroin", "inhalants", "ketamine", "lsd", "marijuana", "mushrooms", "oxycontin", "ritalin", "vicodin", "xanax", "xan", "pcp"))
drugSlang <- append(drugSlang, c("vodka", "whiskey", "drink", "drank", "rum", "bourbon", "brandy", "cognac", "henny", "hennesey", "beer", "hops", "wine", "liquor", "gin"))
drugSlang <- sapply(drugSlang, tolower)
drugSlang <- data.frame(words = drugSlang)

drugsInMusic <- left_join(drugSlang, rapLyricsCount) %>%
  left_join(popLyricsCount) %>%
  left_join(rnbLyricsCount) %>%
  left_join(countryLyricsCount) %>%
  left_join(classicRockLyricsCount) %>%
  left_join(metalLyricsCount) %>%
  left_join(rockLyricsCount)

drugsInMusic <- drugsInMusic[rowSums(is.na(drugsInMusic)) < 7,] # removes all empty rows
drugsInMusic[is.na(drugsInMusic)] <- 0

# get rid of words that probably aren't drugs
drugsInMusic <- drugsInMusic[!(drugsInMusic$words == "adam" | drugsInMusic$words == "bars" | drugsInMusic$words == "beans" | drugsInMusic$words == "bliss" | drugsInMusic$words == "bloom" | drugsInMusic$words == "blue" | drugsInMusic$words == "bold" | drugsInMusic$words == "boy" | drugsInMusic$words == "buttons" | drugsInMusic$words == "clarity" | drugsInMusic$words == "glad" | drugsInMusic$words == "glass" | drugsInMusic$words == "hog" | drugsInMusic$words == "horse" | drugsInMusic$words == "hug" | drugsInMusic$words == "ice" | drugsInMusic$words == "jet" | drugsInMusic$words == "joker" | drugsInMusic$words == "killers" | drugsInMusic$words == "line" | drugsInMusic$words == "mud" | drugsInMusic$words == "pineapple" | drugsInMusic$words == "purple" | drugsInMusic$words == "robo" | drugsInMusic$words == "rolls" | drugsInMusic$words == "rush" | drugsInMusic$words == "scratch" | drugsInMusic$words == "shards" | drugsInMusic$words == "smack" | drugsInMusic$words == "thunder" | drugsInMusic$words == "velvet" | drugsInMusic$words == "white"),]

# drug reference proportion
drugsProportion <- data.frame("Genre" = c("rap", "pop", "rnb", "country", "classicRock", "metal", "rock"), "proportion" = 0)
drugsProportion[1, "Proportion"] <- sum(drugsInMusic$rap) / nrow(rapLyrics)
drugsProportion[2, "Proportion"] <- sum(drugsInMusic$pop) / nrow(popLyrics)
drugsProportion[3, "Proportion"] <- sum(drugsInMusic$rnb) / nrow(rnbLyrics)
drugsProportion[4, "Proportion"] <- sum(drugsInMusic$country) / nrow(countryLyrics)
drugsProportion[5, "Proportion"] <- sum(drugsInMusic$classic.rock) / nrow(classicRockLyrics)
drugsProportion[6, "Proportion"] <- sum(drugsInMusic$metal) / nrow(metalLyrics)
drugsProportion[7, "Proportion"] <- sum(drugsInMusic$rock) / nrow(rockLyrics)

drugsInMusic <- gather(drugsInMusic, key = 'Genre', value = 'Drugs', -words)
drugsInMusic <- drugsInMusic[!(drugsInMusic$Drugs == 0),] # removes all empty rows again

# total count
ggplot() +
  geom_bar(drugsInMusic, mapping = aes(x = Genre, y = Drugs, fill = words), stat = "Identity")

# proportion
ggplot() +
  geom_bar(drugsProportion, mapping = aes(x = Genre, y = Proportion, fill = Genre), stat = "Identity")
