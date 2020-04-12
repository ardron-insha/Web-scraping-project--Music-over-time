##rvest

library(rvest)
library(dplyr)
library(stringr)
library(httr)

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
  mutate(songtitle= tolower(gsub("<div class=\"ye-chart-item__title\">\n|</div>", "",as.character.html_nodes.webpage....ye.chart.item__title...))) %>% ##HTML clean up
  mutate(artist= tolower(gsub("<div class=\"ye-chart-item__artist\">\n|</div>|<a href=\"/music|</a>", "",as.character.html_nodes.webpage....ye.chart.item__artist...))) %>% ##HTML clean up
  mutate(artist= gsub(".*>", "", artist)) %>% 
  mutate(artist= gsub(",|featuring| x ", "&amp;", artist)) %>% 
  mutate(artist2= ifelse(grepl("&amp;&amp;", artist), sub("^.*?&amp;&amp;", "", artist), 
                         ifelse(grepl("&amp;", artist), sub("^.*?&amp;", "", artist),"")))  %>% 
  mutate(artist3= ifelse(grepl("&amp;&amp;", artist2), sub("^.*?&amp;&amp;", "", artist2), 
                         ifelse(grepl("&amp;", artist2), sub("^.*?&amp;", "", artist2),""))) %>% 
  mutate_at(vars("songtitle", "artist", "artist2", "artist3"), text_tidy) %>% 
  mutate(year=i) %>% 
  mutate(rank= rownames(.)) %>%  
  mutate(artist= ifelse(artist=="lilnas", "lilnasx", artist)) %>% 
  select(year, rank, songtitle, artist, artist2, artist3)  %>% 
  mutate(songtitle= gsub("\\(.*", "", songtitle)) %>% 
  mutate(songtitle= gsub("[[:punct:]]", "", songtitle))  %>% 
  mutate(artist= gsub("[[:punct:]]", "", artist))  %>% 
  mutate(artist2= gsub("[[:punct:]]", "", artist2)) %>% 
  mutate_at(vars(artist, artist2, artist3), funs(ifelse(.=="cardib", "cardi-b", .))) %>% 
  mutate_at(vars(artist, artist2, artist3), funs(ifelse(.=="aboogiewitdahoodie", "boogiewitdahoodie", .))) %>% 
  mutate_at(vars(artist, artist2, artist3), funs(ifelse(.=="pnk", "pink", .))) 
 
pos <- match(i, year)
hottestsongs[[pos]] <-  top100songs
rm(list=paste0(pos))


}

top100songs <- do.call("rbind", hottestsongs) %>% 
  mutate(ID=row_number())

##for some reason the last two numbers in 2011 didn't come through? I will append them myself, but not sure why that happened...
y2011_100 <- data.frame("year"= c("2011"),
                        "rank"= c("100"),
                        "songtitle"=c("mylast"),
                        "artist"= c("bigsean"),
                        "artist2"= c("chrisbrown"),
                        "artist3"= c(""),
                        "ID"= c("1099"))

y2016_100 <- data.frame("year"= c("2016"),
                        "rank"= c("100"),
                        "songtitle"=c("perfect"),
                        "artist"= c("onedirection"),
                        "artist2"= c(""),
                        "artist3"= c(""),
                        "ID"= c("1100"))


top100songs <- top100songs %>% 
  rbind(y2011_100) %>% 
  rbind(y2016_100)



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
  mutate(lyrics=gsub("\r\n", " ",lyric_data[2]  )) %>% 
  mutate(artist=gsub("Lyrics", "", lyric_data[1]) ) %>% 
  mutate(songname=gsub("<b>|\"|</b>", "",songname ))  %>% 
  select(-`lyric_data[2]`) %>% 
  mutate(ID=i) %>% 
  mutate(rank=top100songs[i,"rank"]) %>% 
  mutate(year= top100songs[i,"year"])

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
 final %>% 
   group_by(year) %>% 
   tally()

saveRDS(final,"FINAL SONGS.rds" )

write.csv(final, "ALL SONGS.csv")

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

saveRDS(round2,"complete_data.rds")


