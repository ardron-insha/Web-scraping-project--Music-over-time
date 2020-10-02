Fun with music: Exploring how words in pop songs have changed over time
================

#### Sources

  - Pop songs and their ranking: Pop songs for each year were gathered
    from Billboard’s top 100 rankings found here:
    <https://www.billboard.com/charts/hot-100> For each song, the date
    when the song peaked and the peak ranking on Billboard was gathered
    from each song’s page, for example:
    <https://www.billboard.com/charts/hot-100?rank=1>

  - Lyrics: All lyrics were gathered from AZLyrics.com

#### Getting the data

The file “01 Scrapping Songs” scrapes Billboard for the top 100 songs in
each year from 2009 to 2019. From Billboard I can get the peak rank for
the song, it’s peak date and highest rank position in the year and
supporting artists. Then, each song + artist combo is searched on
AZLyrics to create the lyrics dataset. Some songs were associated with
the supporting artists on AZLyrics only so I re-ran the script to get
more matches.

**Total songs and artists by year gathered from
Billboard:**

    ## Warning: 7 failed to parse.

| Year | Total Songs | Distinct Artists | Songs With Lyrics | Songs with Peak Dates |
| ---: | ----------: | ---------------: | ----------------: | --------------------: |
| 2000 |         100 |               95 |                74 |                    83 |
| 2001 |         100 |              101 |                82 |                    70 |
| 2002 |         100 |               95 |                85 |                    63 |
| 2003 |         100 |              108 |                86 |                    68 |
| 2004 |         100 |              104 |                85 |                    65 |
| 2005 |         100 |               95 |                82 |                    65 |
| 2006 |         100 |              103 |                77 |                    62 |
| 2007 |         100 |               94 |                83 |                    66 |
| 2008 |         100 |               90 |                90 |                    69 |
| 2009 |         100 |               88 |                86 |                    95 |
| 2010 |         100 |               91 |                86 |                    88 |
| 2011 |          99 |               99 |                85 |                    85 |
| 2012 |         100 |               84 |                91 |                    90 |
| 2013 |         100 |              104 |                87 |                    85 |
| 2014 |         100 |              109 |                92 |                    92 |
| 2015 |         100 |              101 |                85 |                    93 |
| 2016 |          99 |               90 |                85 |                    93 |
| 2017 |         100 |              105 |                88 |                    91 |
| 2018 |         100 |              100 |                92 |                    81 |
| 2019 |         100 |               94 |                96 |                    73 |

**Notes:**

  - There is an extra song in 2012. This is because Christina Perri’s
    song “A Thousand Years” comes in two parts and is being treated as
    one entry. For now I will keep these songs separate despite having
    the same ranking
  - For some reason 2011 and 2016 have missing songs. In 2011, number 7
    is missing and in 2016, number 87 is missing
  - Peak date information was not available for all songs but ranges
    from 70% to 95% depending on year

#### Looking at top artists over time

The top 10 most popular artists across the data:

| Artist            | Total Top Songs |
| :---------------- | --------------: |
| Drake             |              51 |
| Rihanna           |              44 |
| Lil Wayne         |              31 |
| Chris Brown       |              29 |
| Nicki Minaj       |              29 |
| Ludacris          |              27 |
| Taylor Swift      |              26 |
| Beyonce           |              23 |
| Justin Timberlake |              23 |
| Maroon 5          |              23 |

Drake is consinderably more popular than the next artist in the list
with over 50 songs making the top 100 list.

How does the success of top artists track over time?

![](readme_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

#### Looking at the lyrics of songs by year

The lyrics data is pretty messy, it has a lot of “words” like “oh oh
oh…”. I have tried to filter these out using stop words from
tidytext as well as other general cleaning (removing punctuation, spaces
etc).

To start, I want to see whether words fall into “positive” or “negative”
categories. I’m using “get\_sentiment” from tidytext and Bing Liu and
Co’s dataset. This dataset classifies words into “positive” or
“negative” categories. How does this change over time?

![](readme_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

I see a lot of words that are marked NA. I’m not sure which ones are NA
because they’re neutral and which ones are NA because they’re not really
words like “oooh”. *Problem* Need to solve for this- maybe I can remove
words that are non-standard?

| Year | Negative | Positive | Neutral/Unlabeled | Songs With Lyrics |
| ---: | :------- | :------- | :---------------- | ----------------: |
| 2000 | 6.55%    | 7.18%    | 86.27%            |                74 |
| 2001 | 6.5%     | 6.88%    | 86.62%            |                82 |
| 2002 | 6.76%    | 6.61%    | 86.64%            |                85 |
| 2003 | 6.82%    | 6.65%    | 86.53%            |                86 |
| 2004 | 7.15%    | 6.5%     | 86.35%            |                85 |
| 2005 | 6.55%    | 6.17%    | 87.28%            |                82 |
| 2006 | 7.89%    | 5.92%    | 86.18%            |                77 |
| 2007 | 6.9%     | 6.72%    | 86.38%            |                83 |
| 2008 | 7.5%     | 7.06%    | 85.45%            |                90 |
| 2009 | 6.87%    | 8.77%    | 84.36%            |                86 |
| 2010 | 7.61%    | 7.1%     | 85.29%            |                86 |
| 2011 | 6.64%    | 7.19%    | 86.17%            |                85 |
| 2012 | 7.59%    | 6.44%    | 85.97%            |                91 |
| 2013 | 7.63%    | 8.31%    | 84.06%            |                87 |
| 2014 | 7.92%    | 7.17%    | 84.91%            |                92 |
| 2015 | 7.76%    | 6.39%    | 85.84%            |                85 |
| 2016 | 7.57%    | 6.26%    | 86.17%            |                85 |
| 2017 | 8.91%    | 7.03%    | 84.06%            |                88 |
| 2018 | 7.82%    | 5.93%    | 86.25%            |                92 |
| 2019 | 8.62%    | 5.67%    | 85.71%            |                96 |

Taking a look at the most common words and their sentiments:

| Words | Sentiment | Total Instances |
| :---- | :-------- | --------------: |
| you   | NA        |           25424 |
| the   | NA        |           17671 |
| and   | NA        |           11084 |
| not   | NA        |           10844 |
| that  | NA        |            7486 |
| like  | positive  |            5260 |
| your  | NA        |            5117 |
| are   | NA        |            4329 |
| know  | NA        |            4226 |
| all   | NA        |            4203 |

Looking at top 10 positive, negative and neutral words:
![](readme_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

Unsurprisingly, most words are just filler words.

Looking at only words marked “positive” and “negative” over time:
![](readme_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

Was the sentiment of pop songs more positive or negative by year?
![](readme_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

However, this is an oversimplified approach, what if the lyric is “bad
love”, the sentiment should be negative but will be classified as both
negative (bad) and positive (love). Maybe getting a ratio of positive to
negative words for each song will be a better assessment.

![](readme_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->
