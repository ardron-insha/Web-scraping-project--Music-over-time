library(stringr)
library(tidyverse)
library(quanteda)

##lyric data

song_df <- readRDS("complete_data.rds") 

##naive analysis of how many words there are in each song

song_df_2 <- song_df %>% 
  mutate(lyrics_clean= gsub("\\[[^][]*]","",lyrics), ##AZ lyrics adds comments in square brackets
         lyrics_clean= gsub("\n|\\s{2,}"," ",lyrics_clean),
         lyrics_clean= gsub("\"|\\\\","",lyrics_clean),##tidying up spaces
         No_Wrds= sapply(strsplit(lyrics_clean, "\\s"), length))


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



all_words_complete <- all_words %>% 
  group_by(artist, songname , ID, rank, year) %>% 
  mutate(syllables=nsyllable(lyrics),
         three_more_syll =ifelse(syllables>=3, 1, 0)) 


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

saveRDS(all_words_complete, "all_words_complete.rds")
