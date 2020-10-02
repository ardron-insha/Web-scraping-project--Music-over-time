library(stringr)
library(tidyverse)
library(quanteda)
library(qdap)
library(tm)
library(tidytext)
library(textdata)
##lyric data

songs_df = readRDS("AZ_data.rds")
##naive analysis of how many words there are in each song

song_df_2 <- song_df %>% 
  mutate(lyrics_clean= gsub("\\[[^][]*]","",lyrics), ##AZ lyrics adds comments in square brackets
         lyrics_clean= gsub("\n|\\s{2,}"," ",lyrics_clean),
         lyrics_clean= gsub("\"|\\\\","",lyrics_clean),##tidying up spaces
         No_Wrds= sapply(strsplit(lyrics_clean, "\\s"), length))
##function from https://www.datacamp.com/community/tutorials/R-nlp-machine-learning
fix.contractions <- function(doc) {
  # "won't" is a special case as it does not expand to "wo not"
  doc <- gsub("won't", "will not", doc)
  doc <- gsub("can't", "can not", doc)
  doc <- gsub("n't", " not", doc)
  doc <- gsub("'ll", " will", doc)
  doc <- gsub("'re", " are", doc)
  doc <- gsub("'ve", " have", doc)
  doc <- gsub("'m", " am", doc)
  doc <- gsub("'d", " would", doc)
  doc <- gsub("'cause", "because", doc)
  # 's could be 'is' or could be possessive: it has no expansion
  doc <- gsub("'s", "", doc)
  return(doc)
}
song_df_2$lyrics_clean <- sapply(song_df_2$lyrics_clean, fix.contractions)
song_df_2$lyrics_clean <- sapply(song_df_2$lyrics_clean, tolower)
song_df_2 =  song_df_2 %>% 
  mutate(lyrics_clean = removePunctuation(lyrics_clean))

lyrics_list=list()
for (i in song_df_2$ID) {
  lyric <- unlist((str_split(song_df_2[i, "lyrics_clean"], "\\s")))
  
  x <- data.frame("lyrics"=lyric)%>% 
    mutate(artist= song_df_2[i, "artist"],
           songname=song_df_2[i, "songname"],
           ID=song_df_2[i, "ID"],
           rank=song_df_2[i, "rank"],
           year=song_df_2[i, "year"] ) %>% 
    mutate_all(as.character)  %>% 
    filter(grepl("\\s|...|-", lyrics))
  

  lyrics_list[[paste0(song_df_2[i,"songname"], "_", song_df_2[i,"artist"] )]] <- x
  
}

all_words <- do.call("rbind", lyrics_list) 

#label stop words
all_words = all_words %>% 
  mutate(stop_word= ifelse(lyrics %in% c("oh", "like","can","get","yeah", "you", stopwords("en")), 1, 0))


all_words_complete <- all_words %>% 
  group_by(artist, songname , ID, rank, year) %>% 
  mutate(syllables=nsyllable(lyrics),
         three_more_syll =ifelse(syllables>=3, 1, 0))  %>% 
  left_join(get_sentiments("bing"), by=c("lyrics"= "word"))

all_words_complete %>% 
  ungroup() %>% 
  filter(stop_word==0) %>% 
  count(lyrics) %>% 
  arrange(desc(n)) %>% 
  head(20)

summary1 <- all_words2%>% 
  summarize(total_words= n(),
    unique_words= n_distinct(lyrics) , 
    avg_syllables= mean(syllables, na.rm=T),
    no_words_with_three_or_mor= sum(three_more_syll, na.rm=T)) 

all_words_unique <- all_words2 %>% 
  distinct()


summary2 <- all_words_unique%>% 
  summarize(
            no_words_with_three_or_mor= sum(three_more_syll, na.rm=T)) 



saveRDS(all_words_complete, "Lyrics_data.rds")
