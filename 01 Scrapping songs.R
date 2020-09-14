##rvest

library(rvest)
library(dplyr)
library(stringr)
library(httr)
library(RSelenium)

text_tidy <- function(x) {
  
  x <- gsub("\n|\\s", "", ifelse(grepl("&amp;",x), gsub("&amp;.*", "", x), x))
  
  return(x)
}

##collecting hottest 100 songs each year from Billboard

hottestsongs =list()
year = 2009:2019
for (i in year) {
webpage <- read_html(paste0("https://www.billboard.com/charts/year-end/", i, "/hot-100-songs" ))

#Using CSS selectors to scrape the rankings section
songname <- data.frame(as.character(html_nodes(webpage,".ye-chart-item__title")))
artists <- data.frame(as.character(html_nodes(webpage,".ye-chart-item__artist")))

top100songs <- cbind(songname, artists) %>% 
  mutate(songtitle= tolower(gsub("<div class=\"ye-chart-item__title\">\n|</div>", "",as.character.html_nodes.webpage....ye.chart.item__title...)),
         artist= tolower(gsub("<div class=\"ye-chart-item__artist\">\n|</div>|<a href=\"/music|</a>", "",as.character.html_nodes.webpage....ye.chart.item__artist...)),
         artist1= gsub(".*>", "", artist),
         artist1= gsub(",|featuring| x ", "&amp;", artist1),
         artist2= ifelse(grepl("&amp;&amp;", artist1), sub("^.*?&amp;&amp;", "", artist1), 
                         ifelse(grepl("&amp;", artist1), sub("^.*?&amp;", "", artist1),"")),
         artist3= ifelse(grepl("&amp;&amp;", artist2), sub("^.*?&amp;&amp;", "", artist2), 
                         ifelse(grepl("&amp;", artist2), sub("^.*?&amp;", "", artist2),""))) %>% 
  mutate_at(vars(songtitle, artist1, artist2, artist3), text_tidy) %>% 
  mutate(year=i,
         rank= rownames(.),
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
hottestsongs[[pos]] <-  top100songs
rm(list=paste0(pos))


}

top100songs <- do.call("rbind", hottestsongs) %>% 
  mutate(ID=row_number())



top100songs <- top100songs %>% 
  rbind(y2011_100) %>% 
  rbind(y2016_100)


######GET PEAK DATE---------------
top100songs <- top100songs %>% 
  mutate(artist_1_refeed= gsub("/|.*>", "", artist),
         artist_1_refeed= str_trim(artist_1_refeed),
         artist_1_refeed= gsub("\\s", "-", artist_1_refeed),
         artist_1_refeed= gsub(",|featuring| x ", "&amp;", artist_1_refeed),
         artist_1_refeed= gsub("-$", "", text_tidy(artist_1_refeed)),
         artist_1_refeed=ifelse(grepl("jay-z", artist_1_refeed), "jay-z", artist_1_refeed),
         artist_1_refeed=gsub("ke\\$ha", "kesha", artist_1_refeed))

  peakdate_DF = data.frame("song_name"= as.character(), 
                           "peak_date"= as.character(), 
                           "song_name_clean"= as.character(),
                           "artist"= as.character())
  
  
  ##error catch function to get peak date
  #peak_date_parser <- function(artist) {
    
    tryCatch( {
      url <- paste0("https://www.billboard.com/music/", artist, "/chart-history")

      webpage <- read_html(url)
      return(webpage)
    }, error=function(giveup) {
        message(paste0("This rank didn't work: ", artist))
        webpage=NA
        return(webpage)
      } )
    
    
  }

 ##get peak dates
#for (i in top100songs$artist_1_refeed) {
  
  webpage <- peak_date_parser(i)

if (!is.na(webpage)) {
  
  
peak_date1 <- data.frame(as.character(html_nodes(webpage,".chart-history__item")))

song_name <- gsub(".*primary font--semi-bold\">|</p>.*", "" ,peak_date1$as.character.html_nodes.webpage....chart.history__item... )
peak_date <- gsub(".*color--secondary font--bold\" href=\"\">|</a>.*", "" ,peak_date1$as.character.html_nodes.webpage....chart.history__item... )

peakdate_fin <- data.frame(song_name) %>% 
  cbind(peak_date) %>% 
  mutate_all(as.character) %>% 
  mutate(song_name_clean= tolower(text_tidy(song_name)),
         song_name_clean= gsub("\\(.*", "", song_name_clean),
         song_name_clean= gsub("[[:punct:]]", "", song_name_clean))  %>% 
  mutate(artist=paste(i)) 

peakdate_DF <- peakdate_DF %>% 
  rbind(peakdate_fin) 

}else {
  
  print("boo")
}

}
 
 ######artists for 1048 songs were found, 52 remainign
  #match <- top100songs %>% 
   # filter(artist_1_refeed%in% peakdate_DF$artist)
  #####some songs could not be found even if the artist could, about 193 of them
  #songnamenotmatch <- anti_join(match, peakdate_DF, by=c("songtitle"= "song_name_clean", 
                                          #               "artist_1_refeed"="artist"))
  ##the problem might be because rvest doesn't scroll down to find more songs
  ##I'm using this adapted loop to get more songs from artists where song could not be found above
 # Download binaries, start driver, and get client object.
 rd <- rsDriver(browser= "firefox", port=4444L)
 ffd <- rd$client
 
 ##peakdates for a song are based on artist searched
 ##focusing mainly on primary artist for now
 artists_for_search <- top100songs %>% 
   distinct(artist_1_refeed)
 
 
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
 
 ##there is one dup
 top100songs1 %>% 
   group_by(ID) %>% 
   tally() %>% 
   filter(n>1)
 
 ##2011 and 2016 don't have the number 7 song and the number 87 song respectively, I need to reorder rank to adjust for this
 fix_years_fun <- function(fix_year, rank_fix, df){
 
   fix_year_df <-  df %>% 
  filter(year==fix_year ) %>% 
   mutate(rank = as.numeric(rank),
           rank = ifelse(rank>=rank_fix, rank +1, rank)) %>% 
   filter(rank<101)
   
   df <- df %>% 
     filter(year != fix_year) %>% 
     rbind(fix_year_df)
 return(df)
}
 
 top100songs1 = fix_years_fun(2011, 7, top100songs1)
 top100songs1 = fix_years_fun(2016, 87, top100songs1)
 
 saveRDS(top100songs1, "Billboard_data.rds")
 
 
 ##get lyrics with some error catching in the function

lyric_parser <- function(ID, DATA) {
  
  tryCatch( {
    url <- paste0("https://www.azlyrics.com/lyrics/", DATA[ID, "artist"], "/", DATA[ID, "songtitle"], ".html" )
    
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



saveRDS(round2,"AZ_data.rds")




