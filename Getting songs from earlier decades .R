

library(rvest)
library(dplyr)
library(stringr)
library(httr)
library(RSelenium)

text_tidy <- function(x) {
  
  x <- gsub("\n|\\s", "", ifelse(grepl("&amp;",x), gsub("&amp;.*", "", x), x))
  
  return(x)
}
##get lyrics with some error catching in the function

lyric_parser <- function(ID, DATA) {
  
  tryCatch( {
    url <- paste0("https://www.azlyrics.com/lyrics/", DATA[ID, "artist1"], "/", DATA[ID, "songtitle"], ".html" )
    
    webpage <- read_html(url)
    return(webpage)
  }, 
  error=function(tryartist2) {
    
    tryCatch({
      url <- paste0("https://www.azlyrics.com/lyrics/", DATA[ID, "artist2"], "/", DATA[ID, "songtitle"], ".html" )
      
      webpage <- read_html(url)
      return(webpage)
      
    }, error=function(giveup) {
      message(paste0("This rank didn't work: ", ID))
      webpage=NA
      return(webpage)
    } )
    
    
  })
  
  
}


##searching for artist on AZ lyrics  
final_list <- list()  
final = data.frame()

##making a function as I will probably need to re-run this on smaller chunks of songs later
 waiting_time <- c(25:30) ##had to bake in some delay for this loop to work, AZ lyrics banned me for running too many requests
  for (i in DATA$ID) {
    
    
    webpage <- lyric_parser(i, DATA)
    
    if (!is.na(webpage)) {
      #Using CSS selectors to scrape the rankings section
      lyricsscrapped <- html_nodes(webpage,"br+ div , h2")
      songname <- as.character(html_nodes(webpage,"b")[2][1])
      
      #Converting the lyrics data to text
      lyric_data <- html_text(lyricsscrapped)
      
      songs <- as.data.frame(lyric_data[2] ) %>% 
        mutate(lyrics=gsub("\r\n", " ",lyric_data[2]  ),
               artist=gsub("Lyrics", "", lyric_data[1]),
               songname=gsub("<b>|\"|</b>", "",songname ))  %>% 
        select(-`lyric_data[2]`) %>% 
        mutate(ID=i,
               rank=DATA[i,"rank"],
               year= DATA[i,"year"])
      
      final_list[[i]] <- assign(paste0("Rank_", DATA[i,"rank"], "_in_year", DATA[i,"year"]), songs)
      
      rm(list=paste0("Rank_", DATA[i,"rank"], "_in_year", DATA[i,"year"]))
      
    }else{
      message(paste0("This number pooped: ", i))
    }
    
    Sys.sleep(sample(waiting_time, 1))
    
  }
  

final = do.call("rbind", final_list)

saveRDS(final,"lyrics_2000_to_2008.rds")
top100songs2000to2008 = readRDS("top100songs2000to2008.rds")

