library(RMySQL)
library(ggplot2)

# import YearlyStats data.frame from SQL ----
setwd("~/Dropbox/Grant Collaborations 2015")

con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con, "SELECT * FROM YearlyStatistics")
YearlyStats <-fetch(data,n=11)
dbClearResult(data)
dbDisconnect(con)
YearlyStats

# create scatter plot of ratio awarded and ratio single ----
png(file="figures/statstest.png",width=500,height=400)
ggplot(YearlyStats, aes(x=GrantYear)) +
        geom_point(aes(y=RatioAwarded),colour = 'blue') +
        geom_point(aes(y=RatioSingle), colour = 'red')
dev.off()

#histograms ----
con <- dbConnect(MySQL(), user='root', password ='password', 
                 dbname='GrantsProject')
data <- dbSendQuery(con,"SELECT TeamSize, GrantYear FROM Main")
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





