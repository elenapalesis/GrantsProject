library(RMySQL)
library(ggplot2)
library(dplyr)

# import YearlyStats data.frame from SQL ----
setwd("~/Dropbox/Grant Collaborations 2015")

con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con, "SELECT * FROM YearlyStatistics")
YearlyStats <-fetch(data,n=11)
dbClearResult(data)
dbDisconnect(con)
YearlyStats <- tbl_df(YearlyStats)

# create scatter plot of ratio awarded and ratio single ----
title <- 'Percentage of Successful Grant Proposals By Year'
ggplot(YearlyStats, aes(x=GrantYear)) +
        geom_point(aes(y=RatioAwarded),colour = 'blue') +
        ggtitle(title)
ggsave(
        'figures/RatioAwardedByYear.png',
        width = 6,
        height = 5,
        dpi = 600)





title <- 'Percentage of Grants with Single Investigator by Year'
ggplot(YearlyStats, aes(x=GrantYear)) +
        geom_point(aes(y=RatioSingle), colour = 'red') +
        ggtitle(title)
ggsave(
        'figures/RatioSingleByYear.png',
        width = 6,
        height = 5,
        dpi = 600)


title <- 'Percentage of Grants with \nMissing or Fake Names by Year'
ggplot(YearlyStats, aes(x=GrantYear)) +
        geom_point(aes(y=RatioBad), size=4, colour = 'darkgreen') +
        ggtitle(title)
ggsave(
        'figures/RatioBadByYear.png',
        width = 5,
        height = 4,
        dpi = 600)



title <- 'Percent of Grants Awarded vs. Single Investigator'
ggplot(YearlyStats, aes(x=RatioAwarded, y=RatioSingle)) +
        geom_point(size=5) +
        ggtitle(title)
ggsave(
        'figures/RatioAwardedVsRatioSingle.png',
        width = 6,
        height = 5,
        dpi = 600)





title <- 'Percent of Ratio Single vs. Ratio Missing'
ggplot(YearlyStats, aes(x=RatioSingle, y=RatioBad)) +
        geom_point(size=5) +
        ggtitle(title)
ggsave(
        'figures/RatioSingleVsRatioMissing.png',
        width = 6,
        height = 5,
        dpi = 600)
#histograms ----
con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con,"SELECT TeamSize, GrantYear, FlagBad FROM Main")
TeamSizeYear <-fetch(data,n=-1)
dbClearResult(data)
dbDisconnect(con)




title <- 'Normalized Frequency of Grant Team Size by Year'
ggplot(TeamSizeYear, aes(x=TeamSize)) + 
        geom_histogram(aes(y=..density..), binwidth = 1, fill='darkgreen') +
        facet_wrap(~ GrantYear) +
        ggtitle(title)
ggsave(
        'figures/DistributionTeamSizeByYear.png',
        width = 6,
        height = 5,
        dpi = 600)


title <- 'Percentage of Grants with Single Investigator by Year'
ggplot(YearlyStats, aes(x=GrantYear)) +
        geom_point(aes(y=RatioSingle), colour = 'red') +
        ggtitle(title)


title <- 'Normalized Frequency of Grant Team Size by Year (truncated)'
ggplot(TeamSizeYear, aes(x=TeamSize)) + 
        geom_histogram(aes(y=..density..),
                       binwidth = 1,
                       colour = 'darkblue',
                       fill='lightblue') +
        facet_wrap(~ GrantYear) +
        coord_cartesian(xlim=c(1,12)) +
        ggtitle(title)
ggsave('figures/DistributionTeamSizeByYearTruncated.png',
        width = 6,
        height = 5,
        dpi = 600)





