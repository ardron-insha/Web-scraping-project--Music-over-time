##getting earlier years, Billboard does not have information before 2008 on their website

##collecting hottest 100 songs each year from Billboard

hottestsongs =list()
year = 2000:2008
for (i in year) {
  webpage <- read_html(paste0("https://longboredsurfer.com/charts/", i ))
  
  #Using CSS selectors to scrape the rankings section
  songname <- as.vector(data.frame(as.character(html_nodes(webpage,"p")))[1,])
  
  songs = data.frame("raw_code"=unlist(strsplit(songname, "<br>\n")))
  songs= songs %>% 
    mutate(rank= gsub("\\..*", "", raw_code),
           rank= as.numeric(gsub("<p>", "", rank)),
           songtitle= tolower(gsub(".*<strong>|</strong>.*", "", raw_code)),
           artist= tolower(gsub(".*»\\s", "", raw_code)),
           artist1= gsub(",|featuring| x ", "&amp;", artist),
           artist2= ifelse(grepl("&amp;&amp;", artist1), sub("^.*?&amp;&amp;", "", artist1), 
                           ifelse(grepl("&amp;", artist1), sub("^.*?&amp;", "", artist1),"")),
           artist3= ifelse(grepl("&amp;&amp;", artist2), sub("^.*?&amp;&amp;", "", artist2), 
                           ifelse(grepl("&amp;", artist2), sub("^.*?&amp;", "", artist2),""))) %>% 
    mutate_at(vars(songtitle, artist1, artist2, artist3), text_tidy) %>% 
    mutate(year=i,
           artist1= ifelse(artist1=="lilnas", "lilnasx", artist1)) %>% 
    select(year, rank, songtitle, artist, artist1, artist2, artist3)  %>% 
    mutate(songtitle= gsub("\\(.*", "", songtitle),
           songtitle= gsub("[[:punct:]]", "", songtitle),
           artist1= gsub("[[:punct:]]", "", artist1),
           artist2= gsub("[[:punct:]]", "", artist2)) %>% 
    mutate_at(vars(artist1, artist2, artist3), funs(ifelse(.=="cardib", "cardi-b", .))) %>% 
    mutate_at(vars(artist1, artist2, artist3), funs(ifelse(.=="aboogiewitdahoodie", "boogiewitdahoodie", .))) %>% 
    mutate_at(vars(artist1, artist2, artist3), funs(ifelse(.=="pnk", "pink", .))) 
  
  pos <- match(i, year)
  hottestsongs[[pos]] <-  songs
  #rm(list=paste0(pos))
  
  
}

top100songs <- do.call("rbind", hottestsongs) %>% 
  mutate(ID=row_number())

top100songs <- top100songs %>% 
  mutate(artist_1_refeed= gsub("/|.*>", "", artist),
         artist_1_refeed= str_trim(artist_1_refeed),
         artist_1_refeed= gsub("\\s", "-", artist_1_refeed),
         artist_1_refeed= gsub(",|featuring| x ", "&amp;", artist_1_refeed),
         artist_1_refeed= gsub("-$", "", text_tidy(artist_1_refeed)),
         artist_1_refeed=ifelse(grepl("jay-z", artist_1_refeed), "jay-z", artist_1_refeed),
         artist_1_refeed=gsub("ke\\$ha", "kesha", artist_1_refeed))

# Download binaries, start driver, and get client object.
rd <- rsDriver(browser= "firefox", port=4444L)
ffd <- rd$client

##peakdates for a song are based on artist searched
##focusing mainly on primary artist for now
artists_for_search <- top100songs %>% 
  distinct(artist_1_refeed)

peakdate_DF = data.frame("song_name"= as.character(), 
                         "peak_date"= as.character(), 
                         "song_name_clean"= as.character(),
                         "artist"= as.character(),
                         "peak_position"= as.character(),
                         "as.character.html_nodes.info....chart.history__item..."=as.character())

for(i in artists_for_search$artist_1_refeed) {
  
  ffd$navigate(paste0("https://www.billboard.com/music/", i, "/chart-history"))
  
  
  webElem <- ffd$findElement("css", "body")
  webElem$sendKeysToElement(list(key = "end"))
  
  for(j in 1:50){      
    # ffd$executeScript("window.scrollTo(0,document.body.scrollHeight);")
    ffd$executeScript(paste("scroll(0,",j*10000,");"))
    #Sys.sleep(3)    
  }
  
  #get the page html
  page_source<-ffd$getPageSource()
  
  info <-  read_html(page_source[[1]]) 
  info2 <- data.frame(as.character(html_nodes(info, ".chart-history__item") ))
  
  song_name <- gsub(".*primary font--semi-bold\">|</p>.*", "" ,info2$as.character.html_nodes.info....chart.history__item... )
  peak_date <- gsub(".*secondary font--bold\" href=\"/charts/hot-100/|</a></p></div>\n</div>.*", "" ,info2$as.character.html_nodes.info....chart.history__item... )
  peak_position <- gsub(".*class=\"font--semi-bold\">Peaked</span> at #| on <a class=\"color--secondary font--bold\".*", "",info2$as.character.html_nodes.info....chart.history__item... )
  
  peakdate_fin <- data.frame(song_name) %>% 
    cbind(peak_date, peak_position, info2) %>% 
    mutate_all(as.character) %>% 
    mutate(song_name_clean= tolower(text_tidy(song_name)),
           song_name_clean= gsub("\\(.*", "", song_name_clean),
           song_name_clean= gsub("[[:punct:]]", "", song_name_clean),
           artist=paste(i)) 
  
  peakdate_DF <- peakdate_DF %>% 
    rbind(peakdate_fin) 
  
  print(paste("completed ", i, "at position ", which(artists_for_search$artist_1_refeed == i)))
  
}



ffd$close()
rm(rd)
gc()


match <- top100songs %>% 
  filter(artist_1_refeed%in% peakdate_DF$artist)
#####some songs could not be found even if the artist could, about 193 of them
songnamenotmatch <- anti_join(match, peakdate_DF, by=c("songtitle"= "song_name_clean", 
                                                       "artist_1_refeed"="artist"))



##I was able to get peak dates for about 1000 out of 1100 records
top100songs1 <- top100songs %>% 
  left_join(peakdate_DF , by=c("songtitle"= "song_name_clean", 
                               "artist_1_refeed"="artist"))  %>% 
  distinct()

##there are three dups
top100songs1 %>% 
  group_by(ID) %>% 
  tally() %>% 
  filter(n>1)


top100songs2000to2008 = top100songs1 %>% 
  filter(!(ID == 316 & peak_position == 74)) %>% 
  filter(!(ID == 572 & peak_position == 50)) %>% 
  filter(!(ID == 639 & peak_position == 50))

top100songs2000to2008 %>% 
  group_by(ID) %>% 
  tally() %>% 
  filter(n>1)

#current <- readRDS("Billboard_data.rds")


setdiff(names(current), names(top100songs1)) 

#saveRDS(top100songs1, "Billboard_data.rds")



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

##making a function as I will probably need to re-run this on smaller chunks of songs later

Get_lyrics_function <- function(DATA) {
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
               rank=top100songs[i,"rank"],
               year= top100songs[i,"year"])
      
      final_list[[i]] <- assign(paste0("Rank_", top100songs[i,"rank"], "_in_year", top100songs[i,"year"]), songs)
      
      rm(list=paste0("Rank_", top100songs[i,"rank"], "_in_year", top100songs[i,"year"]))
      
    }else{
      message(paste0("This number pooped: ", i))
    }
    
    Sys.sleep(sample(waiting_time, 1))
    
  }
  
  final <- do.call("rbind", final_list) 
  return(final)
  
}



Get_lyrics_function(top100songs2000to2008)
warnings()





#need to review unmatched songs and assess how many more can be gathered


##ran a second round of the function with some more cleaning
##noticed that AZ often chops off "the" before an artist name, noticed Beyonce is written with last name

CHECK <- top100songs %>% 
  left_join(final, by=c("ID")) %>% 
  filter(is.na(lyrics)) %>% 
  mutate(artist.x=ifelse(artist.x=="beyonce", "beyonceknowles", artist.x)) %>% 
  mutate(artist.x=ifelse(grepl("^the", artist.x), gsub("^the", "", artist.x), artist.x)) 

##try again
round2 <- Get_lyrics_function(CHECK)%>% 
  filter(!ID %in% final$ID)


#Out of 1100 songs, I was able to scrape 973. This is okay for now but the missing data is skewed towards earlier years
complete_data <- final %>%
  rbind(round2)

plyr::count(complete_data$year)



##saveRDS(round2,"AZ_data.rds")





