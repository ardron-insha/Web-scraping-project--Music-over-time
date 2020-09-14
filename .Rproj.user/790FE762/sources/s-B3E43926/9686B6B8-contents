Fun with music: Exploring how words in pop songs have changed over time
================

### Sources:

  - Pop songs and their ranking: Pop songs for each year were gathered
    from Billboard’s top 100 rankings found here:
    <https://www.billboard.com/charts/hot-100> For each song, the date
    when the song peaked and the peak ranking on Billboard was gathered
    from each song’s page, for example:
    <https://www.billboard.com/charts/hot-100?rank=1>

  - Lyrics: All lyrics were gathered from AZLyrics.com

### Step 1: Getting the data

The file “01 Scrapping Songs” scrapes Billboard for the top 100 songs in
each year from 2009 to 2019. From Billboard I can get the peak rank for
the song, it’s peak date and highest rank position in the year and
supporting artists. Then, each song + artist combo is searched on
AZLyrics to create the lyrics dataset. Some songs were associated with
the supporting artists on AZLyrics only so I re-ran the script to get
more matches.

**Total songs and artists by year gathered from
Billboard:**

| Year | Total Songs | Distinct Artists | Songs With Lyrics | Songs with Peak Dates |
| :--- | ----------: | ---------------: | ----------------: | --------------------: |
| 2009 |         100 |               88 |                 9 |                    95 |
| 2010 |         100 |               91 |                 0 |                    88 |
| 2011 |          99 |               99 |                 0 |                    86 |
| 2012 |         100 |               84 |                 0 |                    90 |
| 2013 |         100 |              104 |                 0 |                    85 |
| 2014 |         100 |              109 |                 0 |                    92 |
| 2015 |         100 |              101 |                 0 |                    93 |
| 2016 |          99 |               90 |                 0 |                    94 |
| 2017 |         100 |              105 |                 0 |                    91 |
| 2018 |         100 |              100 |                 0 |                    81 |
| 2019 |         100 |               94 |                 0 |                    73 |

**Notes:**

  - There is an extra song in 2012. This is because Christina Perri’s
    song “A Thousand Years” comes in two parts and is being treated as
    one entry. For now I will keep these songs separate despite having
    the same ranking
  - For some reason 2011 and 2016 have missing songs. In 2011, number 7
    is missing and in 2016, number 87 is missing
  - Peak date information was not available for all songs but ranges
    from 70% to 95% depending on year
