library(stringr)
library(tidyverse)

##lyric data

song_df <- readRDS("complete_data.rds") 

##naive analysis of how many words there are in each song

song_df_2 <- song_df %>% 
  mutate(lyrics_clean= gsub("\\[[^][]*]","",lyrics)) %>% ##AZ lyrics adds comments in square brackets
  mutate(lyrics_clean= gsub("\n|\\s{2,}"," ",lyrics_clean)) %>% ##tidying up spaces
  mutate(lyrics_clean= gsub("\"|\\\\","",lyrics_clean)) %>%
  mutate(No_Wrds= sapply(strsplit(lyrics_clean, "\\s"), length)) 
  

lyrics_list=list()
for (i in song_df_2$ID) {
  
  x <- as.data.frame(str_split(song_df_2[i, "lyrics_clean"], "\\s")) %>% 
    mutate(artist= song_df_2[i, "artist"]) %>% 
    mutate(songname=song_df_2[i, "songname"])

  lyrics_list[[paste0(song_df_2[i,"songname"], "_", song_df_2[i,"artist"] )]] <- x
  
}

all_words <- do.call("rbind", lyrics_list)

names(all_words) <- c("lyrics", "artist", "songname") 

all_words %>% 
  group_by(artist, songname ) %>% 
  summarize(total_words= n(),
    unique_words= n_distinct(lyrics))
